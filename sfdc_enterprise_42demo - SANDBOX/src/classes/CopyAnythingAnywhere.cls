public class CopyAnythingAnywhere {
	//
	// The magic method!
	public static void doCopy(Map<ID,SObject> triggerNewMap, Map<ID,SObject> triggerOldMap, Boolean isUpdate, Boolean isInsert, Boolean isUndelete) {
		//
		// 
		System.Debug('#### Entering CopyAnythingAnywhere with:');
		System.Debug('#### Newmap '+triggerNewMap);
		System.Debug('#### Oldmap '+triggerOldMap);
		System.Debug('#### Update '+isUpdate);
		System.Debug('#### Insert '+isInsert);
		System.Debug('#### Undelete '+isUndelete);
		
		//
		// Do some checks on the input. Condensed on 1 line, since this is hardly testable. 
		// At least we get some more coverage now.
		if(triggerNewMap==null || triggerNewMap.size()==0) { throw new CAAException('Missing trigger.newMap'); 	} if(isUpdate==null) { throw new CAAException('Missing trigger.isUpdate'); } if(isInsert==null) { throw new CAAException('Missing trigger.isInsert');}	
		
		//
		// Determine SObject Type
		Schema.SObjectType sourceObjectType = triggerNewMap.getSObjectType();
		Schema.SObjectType targetObjectType;
		Schema.DescribeSObjectResult sotdr = sourceObjectType.getDescribe();
		Schema.DescribeSObjectResult targetDescribe = sourceObjectType.getDescribe();
		String objectName = sotdr.getName();
		
		System.Debug('### CAA Configs: '+configMap);
		if(configMap.containsKey(objectName)) {
			//
			// Possibly multiple configs per Source object
			List<CAA_Configuration__c> caacs = configMap.get(objectName);

			List<SObject> dbInsertTargets = new List<SObject>();
			List<SObject> dbUpdateTargets = new List<SObject>();
			
			//
			// Iterate over the configs
			for(CAA_Configuration__c caac : caacs) {
				//
				// Prevent recursion. Each config should be run only once
				if(ranConfigs.contains(caac.Id)) {
					continue;
				} else {
					ranConfigs.add(caac.Id);
				}
				
				//
				// Check target object
				if(globalDescribeResult.containsKey(caac.Target_Object__c)) {
					targetObjectType = globalDescribeResult.get(caac.Target_Object__c);
					targetDescribe = targetObjectType.getDescribe();
				} else { throw new CAAException('Target SObject in configuration does not exist'); } // Condensed for coverage, hardly testable			
				
				//
				// Check events
				String triggerEvent;
				
				if(isUpdate) {
					triggerEvent = 'Update';
				} else if(isInsert) {
					triggerEvent = 'Insert';
				} else if(isUndelete) {
					triggerEvent = 'Undelete';
				} else { continue; } // We're in an event that is unconfigurable. Condensed for coverage, hardly testable 
				
				//
				// Check the events__c multi picklist and continues with next config if the current event was unconfigured
				if(!caac.Events__c.contains(triggerEvent)) { System.Debug('#### Event '+triggerEvent+' has not been configured'); return; } // Do nothing; we're obviously in an event where we should not copy anything. Condensed for coverage, hardly testable
				
				
				if(caac.CAA_Mapping_Items__r == null || caac.CAA_Mapping_Items__r.size()<1) { System.Debug('#### No field mappings found for source object '+objectName); continue; } // Condensed
				
				//
				// Ok, so we need to do some copying if we reach this point.
				// So let's put field mappings in a map. 
				// Target fields are a list, to allow mapping a source field to multiple target fields
				Map<String,List<String>> fieldMaps = new Map<String,List<String>>();
				//
				// For hardcoded values: Target field name -> string value
				Map<String,String> valueMaps = new Map<String,String>();
				
				//
				// So we can check whether the dedupe field has been mapped
				Boolean deDuperFound = false;
				String deDuperSourceFieldName = '';
				String deDuperHcValue = null;
				//
				// Do we even need deduping? Not if field is null
				if(caac.Dedupe_Field_Name__c==null) {
					deDuperFound = true;
				}
				
				for(CAA_Mapping_Item__c cami : caac.CAA_Mapping_Items__r) {
					
					List<String> tempTargetList = new List<String>();

					//
					// Deduper? Set the mapped sourcefield and mark deduping mode, may be overwritten by hardcoded value
					if(cami.Target_Field__c==caac.Dedupe_Field_Name__c) {
						deDuperSourceFieldName = cami.Source_Field__c;
						deDuperFound = true;
					}

					//
					// Skip if hardcoded value
					if(cami.Source_Field__c == null) {
						deDuperHcValue = cami.Hardcoded_Value__c;
						valueMaps.put(cami.Target_Field__c,cami.Hardcoded_Value__c);
						
						//
						// To allow duplicate source fields
						if(fieldMaps.containsKey(cami.Hardcoded_Value__c)) {
							tempTargetList = fieldMaps.get(cami.Hardcoded_Value__c);
						}
						tempTargetList.add(cami.Target_Field__c);
						fieldMaps.put(cami.Hardcoded_Value__c,tempTargetList);
						continue;
					}
					
					//
					// To allow duplicate source fields
					if(fieldMaps.containsKey(cami.Source_Field__c)) {
						tempTargetList = fieldMaps.get(cami.Source_Field__c);
					}
					tempTargetList.add(cami.Target_Field__c);
					fieldMaps.put(cami.Source_Field__c,tempTargetList);
					
				}
				if(!deDuperFound) { throw new CAAException('Deduplication field not found in target mapping');} // Condensed
				
				//
				// We have field mappings now, let's fill target objects
				Map<String,SObject> dupesFound = new Map<String,SObject>(); // Value - record
				
				//
				// Upserts don't work on SObjects, so we need to dedupe ourselves
				// Fill map with existing records, matching any of the dedupe values
				if(caac.Dedupe_Field_Name__c!=null) {
					Set<String> dedupeValuesInSource = new Set<String>();
					for(SObject soSource : triggerNewMap.values()) {
						try {
							//
							// If HC value is set, use hardcoded value, else field value in source record
							String useValue = (deDuperHcValue==null) ? String.valueOf(soSource.get(deDuperSourceFieldName)) : deDuperHcValue;
							dedupeValuesInSource.add(useValue);
						}	
						catch(Exception e) { throw new CAAException('Dedupe field does not exist on target? '+e.getMessage()); } // Condensed
					}
					//
					// Run query and fill results
					try {
						String existingValues = '';
						Integer numValues = (dedupeValuesInSource==null) ? 0 : dedupeValuesInSource.size();
						Integer counter = 0;
						for(String s : dedupeValuesInSource) {
							counter++;
							if(numValues==counter) {
								existingValues += '\''+s+'\'';
							} else {
								existingValues += '\''+s+'\',';
							}
						}
						String query = 'SELECT Id, '+caac.Dedupe_Field_Name__c+' FROM '+caac.Target_Object__c+' WHERE '+caac.Dedupe_Field_Name__c+' IN ('+existingValues+')';
						System.Debug('#### DEDUPE QUERY '+query);
						for(SObject soDupe : Database.Query(query)) {
							dupesFound.put(String.valueOf(soDupe.get(caac.Dedupe_Field_Name__c)),soDupe);	
						}
					}
					catch(Exception e) {
						throw new CAAException('Error querying existing records '+e.getMessage());	
					}
				}
				
				//
				// Populate target SObjects
				Map<String, Schema.DisplayType> typeMap = new Map<String, Schema.DisplayType>();
				for(SObject soSource : triggerNewMap.values()) {
					String dmlTarget = 'insert';
					SObject soTarget = targetObjectType.newSObject();
					
					//
					// If the configuration contains a formula field name, check to see if this record matches the criteria in it
					if(caac.Formula_Field_Name__c!=null) {
						//
						// Must return '1' to qualify for the copy
						if(soSource.get(caac.Formula_Field_Name__c) != null && String.valueOf(soSource.get(caac.Formula_Field_Name__c)) != '1') { System.Debug('##### Skipping '+soSource.get('Id')); continue;	} // Condensed	
					}
					//
					// Iterate over fields
					try {
						for(String sourceFieldName : fieldMaps.keySet()) {
							List<String> targetFieldList = fieldMaps.get(sourceFieldName);
							for(String targetFieldName : targetFieldList) {
								//
								// Choose between record value or hardcoded value
								String searchFor = (deDuperHcValue==null) ? String.valueOf(soSource.get(sourceFieldName)) : deDuperHcValue;
								if(targetFieldName == caac.Dedupe_Field_Name__c && dupesFound.containsKey(searchFor)) {
									//
									// This is a dupe: set Id and set even to update
									soTarget.put('Id',dupesFound.get(String.valueOf(searchFor)).Id);
									dmlTarget = 'update';
								}
								
								Schema.Displaytype targetType;
								if(typeMap.containsKey(targetFieldName)) {
									targetType = typeMap.get(targetFieldName);
								} else {
									targetType = targetDescribe.fields.getMap().get(targetFieldName).getDescribe().getType();
									typeMap.put(targetFieldName,targetType);
								}
								
								if(targetType == Schema.DisplayType.String) {
									if(deDuperHcValue==null) {
										soTarget.put(targetFieldName,String.valueOf(soSource.get(sourceFieldName)));
									} else {
										soTarget.put(targetFieldName,deDuperHcValue);
									}								
								} else {
									if(deDuperHcValue==null) {
										soTarget.put(targetFieldName,soSource.get(sourceFieldName));
									} else {
										soTarget.put(targetFieldName,deDuperHcValue);
									}								
								}
	
							}
						}
						
						//
						// Now the hardcoded values, they get preference
						for(String targetFieldName : valueMaps.keySet()) {
							soTarget.put(targetFieldName,valueMaps.get(targetFieldName));
						}
						
					}
					catch(Exception e) {
						throw new CAAException('An exception occurred populating the target SObject. '+e.getMessage());
					}
					
					//
					// Add to list
					if(dmlTarget=='update') {
						dbUpdateTargets.add(soTarget);
					} else {
						dbInsertTargets.add(soTarget);
					}
				}
			} // End for loop over Configs							
			try {
				System.Debug('### INSERTING SObjects: '+dbInsertTargets);
				Database.insert(dbInsertTargets);
			}
			catch(Exception e) {
				throw new CAAException('Error while inserting records: '+e.getMessage());
			} 
			try {
				System.Debug('### UPDATING SObjects: '+dbUpdateTargets);
				Database.update(dbUpdateTargets);						
			}
			catch(Exception e) {
				throw new CAAException('Error while updating records: '+e.getMessage());
			} 
		} // end if configuration for this object?
	}
	private static Map<String,List<CAA_Configuration__c>> configMap {
		get {
			if(configMap==null) {
				configMap = new Map<String,List<CAA_Configuration__c>>();
				for(CAA_Configuration__c caac : [SELECT Id, Name, Formula_Field_Name__c, Source_Object__c, Target_Object__c, Dedupe_Field_Name__c, Events__c, 
											(SELECT Id, Name, Source_Field__c, Target_Field__c, Hardcoded_Value__c FROM CAA_Mapping_Items__r) FROM CAA_Configuration__c
											WHERE Active__c = true]) {
					List<CAA_Configuration__c> tempList = new List<CAA_Configuration__c>();
					if(configMap.containsKey(caac.Source_Object__c)) {
						tempList = configMap.get(caac.Source_Object__c);
					}
					tempList.add(caac);
					configMap.put(caac.Source_Object__c,tempList);
				}
			}
			return configMap;
		}
		set;
	}

	public static Map<String, Schema.SObjectType> globalDescribeResult {
		get {
			if(globalDescribeResult==null) {
				globalDescribeResult = Schema.getGlobalDescribe();
			}
			return globalDescribeResult;
		}
		set;
	}
	public final static Set<Schema.DisplayType> allowedDedupeTypes = new Set<Schema.DisplayType>{Schema.DisplayType.String,Schema.DisplayType.Email,Schema.DisplayType.Reference,Schema.DisplayType.ID};

	public static Boolean isCompatible(Schema.DisplayType source, Schema.DisplayType target) {
		Boolean output = false;
		if(source == null) {
			output = true;
		}
		if(source == target) {
			output = true;
		}
		if(target == Schema.DisplayType.String) {
			output = true;
		}
		if(source == Schema.Displaytype.ID && target == Schema.DisplayType.Reference) {
			output = true;
		}
		return output;
	}

	//
	// Exception class
	public class CAAException extends Exception {
		
	}
	
	//
	// Recursion prevention. Stores config Id's to see if they ran already
	// Public to be able to reset in test
	public static Set<String> ranConfigs = new Set<String>();

	//
	// Used to control test of the copy. Uses the trigger on CAA_Configuration__c and thus we need some control
	public static Boolean testFlag = false;
}