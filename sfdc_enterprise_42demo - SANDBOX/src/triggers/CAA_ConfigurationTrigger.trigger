trigger CAA_ConfigurationTrigger on CAA_Configuration__c (after undelete, after insert, after update, before insert, before update) {
	
	//
	// Not a test
	if(Trigger.isBefore) { 
		//
		// Checks the configuration
		for(CAA_Configuration__c caac : Trigger.New) {
			//
			// Init meta data stubs
			Schema.SObjectType soSource;
			Schema.SObjectType soTarget;
			Schema.Describesobjectresult sodSource;
			Schema.Describesobjectresult sodTarget;
			Map<String,Schema.Sobjectfield> fieldsSource;
			Map<String,Schema.Sobjectfield> fieldsTarget;
			
			if(!CopyAnythingAnywhere.globalDescribeResult.containsKey(caac.Source_Object__c)) {
				caac.addError('Source object does not exist: '+caac.Source_Object__c);
			} else {
				soSource = CopyAnythingAnywhere.globalDescribeResult.get(caac.Source_Object__c);
			}
			if(!CopyAnythingAnywhere.globalDescribeResult.containsKey(caac.Target_Object__c)) {
				caac.addError('Target object does not exist: '+caac.Target_Object__c);
			} else {
				soTarget = CopyAnythingAnywhere.globalDescribeResult.get(caac.Target_Object__c);
			}
			//
			// Check the Formulafield
			if(soSource!=null && caac.Formula_Field_Name__c!=null) {
				sodSource = soSource.getDescribe();
				fieldsSource = sodSource.fields.getMap();
				if(fieldsSource.containsKey(caac.Formula_Field_Name__c)) {
					Schema.SObjectField targetFormulaField = fieldsSource.get(caac.Formula_Field_Name__c);
					Schema.Describefieldresult targetFormulaFieldDsc = targetFormulaField.getDescribe(); 
					if(!targetFormulaFieldDsc.isCalculated() || !targetFormulaFieldDsc.isCustom() ) {
						caac.addError('Value ('+caac.Formula_Field_Name__c+') specified as Formula Field is not a valid Formula Field on the source object');
					}
				}			
			}		
			//
			// Check the dedupe field
			if(soTarget!=null && caac.Dedupe_Field_Name__c!=null) {
				sodTarget = soTarget.getDescribe();
				fieldsTarget = sodTarget.fields.getMap();
				if(fieldsTarget.containsKey(caac.Dedupe_Field_Name__c)) {
					Schema.SObjectField targetDeDupeField = fieldsTarget.get(caac.Dedupe_Field_Name__c);
					Schema.Describefieldresult targetDeDupeFieldDsc = targetDeDupeField.getDescribe(); 
					if(!targetDeDupeFieldDsc.isUnique()) {
						caac.addError('Deduplication field '+caac.Dedupe_Field_Name__c+' is not unique');
					}
					Schema.DisplayType fieldType = targetDeDupeFieldDsc.getType();
					System.Debug('#### Checking fieldtype '+fieldType);
					if(!CopyAnythingAnywhere.allowedDedupeTypes.contains(fieldType)) { 
						String typesMessage = '';
						Integer numValues = CopyAnythingAnywhere.allowedDedupeTypes.size();
						Integer counter = 0;
						for(Schema.DisplayType dt : CopyAnythingAnywhere.allowedDedupeTypes) {
							counter++;
							if(counter==numValues) {
								typesMessage += String.valueOf(dt);
							} else {
								typesMessage += String.valueOf(dt)+', ';
							}	
						}
						caac.addError(caac.Dedupe_Field_Name__c+' ('+fieldType+') is not valid for deduplication ! Use:\n'+typesMessage);
								
					} 	
				} else {
					caac.addError('Dedupe field '+caac.Dedupe_Field_Name__c+' does not exist on target object');
				}
				
			}
		}
	} // end if isbefore	
	
	//
	// For unit test we use CAA to copy from CAA_Config__c to CAA_Config__c. This branche will only
	// be executed in unit test
	if(Trigger.isAfter && CopyAnythingAnywhere.testFlag) {
		// Testing with the actual CAA objects
		CopyAnythingAnywhere.doCopy(Trigger.newMap, Trigger.oldMap, Trigger.IsUpdate, Trigger.IsInsert, Trigger.isUnDelete);
	}
}