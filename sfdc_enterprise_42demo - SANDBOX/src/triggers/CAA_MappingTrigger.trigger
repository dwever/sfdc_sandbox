trigger CAA_MappingTrigger on CAA_Mapping_Item__c (after undelete, before insert, before update) {
	//
	// Fetch parents too, indexed by 
	Map<String,String> configIdsPerMappingItem = new Map<String,String>();
	for(CAA_Mapping_Item__c caai : Trigger.New) {
		configIdsPerMappingItem.put(caai.Id,caai.CAA_Configuration__c);
	}
	Map<ID,CAA_Configuration__c> caaCfg = new Map<ID, CAA_Configuration__c>([SELECT Id, Target_Object__c,Source_Object__c FROM CAA_Configuration__c WHERE Id IN :configIdsPerMappingItem.values()]);
	
	if(configIdsPerMappingItem!=null && configIdsPerMappingItem.size()>0) {
		//
		// Cache describe results
		Map<String,Schema.Describesobjectresult> describeObjectCache = new Map<String,Schema.Describesobjectresult>();
		Map<String,Map<String,Schema.Sobjectfield>> fieldsCache = new Map<String,Map<String,Schema.Sobjectfield>>(); 	
		Map<String,Schema.DescribeFieldResult> fieldsDescribeCache = new Map<String,Schema.DescribeFieldResult>();
		for(CAA_Mapping_Item__c caamp : Trigger.new) {
			//
			// Init meta data stubs
			Schema.SObjectType soSource;
			Schema.SObjectType soTarget;
			Schema.Describesobjectresult sodSource;
			Schema.Describesobjectresult sodTarget;
			Map<String,Schema.Sobjectfield> fieldsSource;
			Map<String,Schema.Sobjectfield> fieldsTarget;
			
			//
			// Fetch parent details
			//
			// Validation trigger on config should prevent any errors here
			soSource = CopyAnythingAnywhere.globalDescribeResult.get(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c);
			soTarget = CopyAnythingAnywhere.globalDescribeResult.get(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c);
			
			//
			// Source
			if(describeObjectCache.containsKey(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c)) {
				sodSource = describeObjectCache.get(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c);
				fieldsSource = fieldsCache.get(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c);
				
			} else {
				sodSource = soSource.getDescribe();
				describeObjectCache.put(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c,sodSource);
				fieldsSource = sodSource.fields.getMap();
				fieldsCache.put(caaCfg.get(caamp.CAA_Configuration__c).Source_Object__c,fieldsSource);
			}

			//
			// Target
			if(describeObjectCache.containsKey(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c)) {
				sodTarget = describeObjectCache.get(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c);
				fieldsTarget = fieldsCache.get(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c);
				
			} else {
				sodTarget = soTarget.getDescribe();
				describeObjectCache.put(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c,sodTarget);
				fieldsTarget = sodTarget.fields.getMap();
				fieldsCache.put(caaCfg.get(caamp.CAA_Configuration__c).Target_Object__c,fieldsTarget);
			}
			
			//
			// Now compare source and target and check viability of mapping
			Schema.DisplayType sourceFieldType;
			Schema.DisplayType targetFieldType;
			Schema.Describefieldresult sourceDescribe;
			Schema.Describefieldresult targetDescribe;
			if(caamp.Source_Field__c!=null) { 
				if(fieldsSource.containsKey(caamp.Source_Field__c)) {
					if(fieldsDescribeCache.containsKey(caamp.Source_Field__c)) {
						sourceDescribe = fieldsDescribeCache.get(caamp.Source_Field__c);
					} else {
						sourceDescribe = fieldsSource.get(caamp.Source_Field__c).getDescribe();
						fieldsDescribeCache.put(caamp.Source_Field__c,sourceDescribe);
					}
					sourceFieldType = sourceDescribe.getType();				
				} else {
					caamp.addError('Source field '+caamp.Source_Field__c+' unknown');
					continue;
				}
			}
			if(fieldsTarget.containsKey(caamp.Target_Field__c)) {
				if(fieldsDescribeCache.containsKey(caamp.Target_Field__c)) {
					targetDescribe = fieldsDescribeCache.get(caamp.Target_Field__c);
				} else {
					targetDescribe = fieldsTarget.get(caamp.Target_Field__c).getDescribe();
					fieldsDescribeCache.put(caamp.Target_Field__c,targetDescribe);
				}
				targetFieldType = targetDescribe.getType();
				if(!targetDescribe.isUpdateable()) {
					caamp.addError('Target field '+caamp.Target_Field__c+' is readonly!');
					continue;
				}				
			} else {
				caamp.addError('Target field '+caamp.Target_Field__c+' unknown');
				continue;
			}
			
			//
			// Compare types
			if(!CopyAnythingAnywhere.isCompatible(sourceFieldType, targetFieldType)) {
				caamp.addError(caamp.Source_Field__c+' ('+sourceFieldType+') and '+caamp.Target_Field__c+' ('+targetFieldType+') are incompatible');
				continue;
			}
		}		
	}
}