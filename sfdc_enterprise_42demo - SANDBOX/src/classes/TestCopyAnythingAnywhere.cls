@isTest
private class TestCopyAnythingAnywhere {
	@IsTest(SeeAllData=false) 
	private static void testConfigurationTrigger() {
		Test.startTest();
		CAA_Configuration__c testConfig; 
		
		//
		// Error
		testConfig = configErrorSource;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(true);
		}
		//
		// Error
		testConfig = configErrorTarget;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(true);
		}
		//
		// Error
		testConfig = configErrorFormula;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(true);
		}
		//
		// Error
		testConfig = configErrorDeDupe;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(true);
		}
		
		//
		// Ok
		testConfig = configDefault;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(false);
		}
		//
		// Ok
		testConfig = configFormula;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(false);
		}
		//
		// Ok
		testConfig = configDeDupe;
		try {
			insert testConfig;
		}
		catch(Exception e) {
			System.assert(false);
		}
		Test.stopTest();
	}
	
	@IsTest(SeeAllData=false) 
	private static void testMappingTrigger() {
		Test.startTest();
		List<CAA_Mapping_Item__c> resultingMappings;
		try {
			resultingMappings = getCorrectMappings(); 
		}
		catch(Exception e) {
			System.assert(false);
		}
		System.assertEquals(2, [SELECT count() FROM CAA_Mapping_Item__c]);

		try {
			resultingMappings = getErrorMappings(); 
		}
		catch(Exception e) {
			System.assert(true);
		}
		
		//
		// Still just 2
		System.assertEquals(2, [SELECT count() FROM CAA_Mapping_Item__c]);
		Test.stopTest();
	}
		
	@IsTest(SeeAllData=false) 
	private static void testCopyAutonomousSimple() {
		//
		// Creates config+mappings
		try {
			List<CAA_Mapping_Item__c> resultingMappings= getCorrectMappings(); 
		}
		catch(Exception e) {
			System.assert(false);
		}
		System.assertEquals(1, [SELECT count() FROM CAA_Configuration__c]);
		System.assertEquals(2, [SELECT count() FROM CAA_Mapping_Item__c]);

		Test.startTest();
		CopyAnythingAnywhere.testFlag = true;
		//
		// First a basic one
		CAA_Configuration__c triggeringCAAC = new CAA_Configuration__c();
		triggeringCAAC.Active__c = false; // Just to be sure ;)
		triggeringCAAC.Source_Object__c = 'Account';
		triggeringCAAC.Target_Object__c = 'Contact';
		insert triggeringCAAC;
		
		//
		// We had 1 config, now we added 1 and that created another 1 thanks to the copy. Total: 3
		System.assertEquals(3, [SELECT count() FROM CAA_Configuration__c]);
		
		//
		// We're not de-duping, so an update should cause 1 extra to be copied
		// Reset the anti-recursion set first
		CopyAnythingAnywhere.ranConfigs.clear();
		update triggeringCAAC;
		System.assertEquals(4, [SELECT count() FROM CAA_Configuration__c]);
		
		//
		// Now delete (=3) and then undelete (=5)
		CopyAnythingAnywhere.ranConfigs.clear();
		delete triggeringCAAC;
		System.assertEquals(3, [SELECT count() FROM CAA_Configuration__c]);
		undelete triggeringCAAC;
		System.assertEquals(5, [SELECT count() FROM CAA_Configuration__c]);
		Test.stopTest();
	}

	@IsTest(SeeAllData=false) 
	private static void testCopyAutonomousDeDupe() {
		//
		// Creates config+mappings
		try {
			List<CAA_Mapping_Item__c> resultingMappings= getCorrectDeDupeMappings(); 
		}
		catch(Exception e) {
			System.assert(false);
		}
		System.assertEquals(1, [SELECT count() FROM CAA_Configuration__c]);
		//
		// Unique field mapped as well + double source x 2
		System.assertEquals(5, [SELECT count() FROM CAA_Mapping_Item__c]);

		Test.startTest();
		CopyAnythingAnywhere.testFlag = true;
		
		//
		// First a basic one
		CAA_Configuration__c triggeringCAAC = new CAA_Configuration__c();
		triggeringCAAC.Active__c = false; // Just to be sure ;)
		triggeringCAAC.Source_Object__c = 'Account';
		triggeringCAAC.Target_Object__c = 'Contact';
		insert triggeringCAAC;
		
		//
		// We had 1 config, now we added 1 and that created another 1 thanks to the copy. Total: 3
		System.assertEquals(3, [SELECT count() FROM CAA_Configuration__c]);
		
		//
		// One should have Test_Target_Unique__c field populated with 'Contact'
		System.assertEquals(1, [SELECT count() FROM CAA_Configuration__c WHERE Test_Target_Unique__c='Contact']);
		
		//
		// We're de-duping, so an update should cause no extra to be copied
		// Reset the anti-recursion set first
		CopyAnythingAnywhere.ranConfigs.clear();
		update triggeringCAAC;
		System.assertEquals(3, [SELECT count() FROM CAA_Configuration__c]);
		//
		// One should have Test_Target_Unique__c field populated with 'Contact'
		System.assertEquals(1, [SELECT count() FROM CAA_Configuration__c WHERE Test_Target_Unique__c='Contact']);
		
		//
		// Now delete (=2) and then undelete (=3)
		CopyAnythingAnywhere.ranConfigs.clear();
		delete triggeringCAAC;
		System.assertEquals(2, [SELECT count() FROM CAA_Configuration__c]);
		undelete triggeringCAAC;
		//
		// Again, no copy, just an update
		System.assertEquals(3, [SELECT count() FROM CAA_Configuration__c]);
		Test.stopTest();
	}
	
	//
	// Test the triggers created by admins dynamically
	// Needs actual data
	@isTest(SeeAllData=true)
	private static void testUserDefinedTriggers() {
		//
		// Just to cover the trigger! No functional testing
		List<CAA_Configuration__c> actualConfigs = [SELECT Id, Source_Object__c, Events__c FROM CAA_Configuration__c WHERE Active__c=true];
		if(actualConfigs != null && actualConfigs.size()>1) {
			Set<String> doneObjects = new Set<String>();
			
			//
			// Dynamically create objects for each Source Object in the configuration 
			for(CAA_Configuration__c caac : actualConfigs) {
				if(!doneObjects.contains(caac.Source_Object__c)) {
					doneObjects.add(caac.Source_Object__c);
				} else {
					continue;
				}
				Schema.SObjectType triggerObject;
				if(CopyAnythingAnywhere.globalDescribeResult.containsKey(caac.Source_Object__c)) {
					triggerObject = CopyAnythingAnywhere.globalDescribeResult.get(caac.Source_Object__c);
					
					Map<String,Schema.SObjectField> fieldToks = triggerObject.getDescribe().fields.getMap();
					
					//
					// Init 100 records
					List<SObject> dmlRecs = new List<SObject>();
					Map<String,Schema.Describefieldresult> describeCache = new Map<String,Schema.Describefieldresult>();
					//
					// Stress tested with 100; decreased to 10 to improve speed of the test
					for(Integer x=0;x<10;x++) {
						SObject so = triggerObject.newSObject();
						for(String fieldName : fieldToks.keySet()) {
							Schema.SObjectField fToken; 
							Schema.Describefieldresult fDesc; 
							if(!describeCache.containsKey(fieldName)) {
								fToken = fieldToks.get(fieldName);
								fDesc = fToken.getDescribe();
								describeCache.put(fieldName,fDesc);
							} else {
								fDesc = describeCache.get(fieldName);
							}
							//
							// Populate the SObject fields based on their type.
							if(fDesc.isUpdateable() && !fDesc.isDefaultedOnCreate() && !fDesc.isRestrictedPicklist()) {
								Schema.DisplayType fType = fDesc.getType();
								if(fType == Schema.Displaytype.String ||
									fType == Schema.Displaytype.Picklist ||
									fType == Schema.Displaytype.Textarea ||
									fType == Schema.Displaytype.MultiPicklist) {
									so.put(fieldName,'A');
								}
								if(fType == Schema.DisplayType.Phone) {
									so.put(fieldName,'0619928888');
								}
								if(fType == Schema.DisplayType.URL) {
									so.put(fieldName,'http://www.google.com');
								}
								if(fType == Schema.Displaytype.Integer ||
										fType == Schema.DisplayType.Percent) {
									so.put(fieldName,1);
								}
								if(fType == Schema.DisplayType.Double ||
										fType == Schema.DisplayType.Currency) {
									so.put(fieldName,1.0);
								}
								if(fType == Schema.DisplayType.Email) {
									so.put(fieldName,'test@test.com');
								}
								if(fType == Schema.Displaytype.Date) {
									so.put(fieldName,System.Today());
								}
								if(fType == Schema.Displaytype.DateTime) {
									so.put(fieldName,System.Now());
								}
								if(fType == Schema.Displaytype.Boolean) {
									so.put(fieldName,true);
								}
							}
						}
						dmlRecs.add(so.clone(false));
					}							
					if(dmlRecs.size()>0) {
						//
						// Always insert
						System.Debug('#### DML RECS '+dmlRecs);
						insert dmlRecs;
						
						if(caac.Events__c.contains('Update')) {
							update dmlRecs;
						}
						if(caac.Events__c.contains('Undelete')) {
							delete dmlRecs;
							undelete dmlRecs;
						}
					}
				}
			}
		}
	}

	// =======================================================================
	// Static testdata
	// =======================================================================
	private static CAA_Configuration__c configErrorSource {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'xCAA_Configuration__c'; // Does not exist
			c.Target_Object__c = 'CAA_Configuration__c';
			c.Formula_Field_Name__c = null;
			c.Dedupe_Field_Name__c = null;
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configErrorTarget {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c';
			c.Target_Object__c = 'xCAA_Configuration__c';  // Does not exist
			c.Formula_Field_Name__c = null;
			c.Dedupe_Field_Name__c = null;
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configErrorDeDupe {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c';
			c.Target_Object__c = 'CCAA_Configuration__c';
			c.Formula_Field_Name__c = null;
			c.Dedupe_Field_Name__c = 'Name'; // Not unique
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configErrorFormula {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c'; 
			c.Target_Object__c = 'CAA_Configuration__c';
			c.Formula_Field_Name__c = 'Target_Object__c'; // Not valid
			c.Dedupe_Field_Name__c = null;
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configDefault {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c';
			c.Target_Object__c = 'CAA_Configuration__c';
			c.Formula_Field_Name__c = null;
			c.Dedupe_Field_Name__c = null;
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configFormula {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c';
			c.Target_Object__c = 'CAA_Configuration__c';
			c.Formula_Field_Name__c = 'SomeField';
			c.Dedupe_Field_Name__c = null;
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static CAA_Configuration__c configDeDupe {
		get {
			CAA_Configuration__c c = new CAA_Configuration__c();
			c.Source_Object__c = 'CAA_Configuration__c';
			c.Target_Object__c = 'CAA_Configuration__c';
			c.Formula_Field_Name__c = null;
			c.Dedupe_Field_Name__c = 'Test_Target_Unique__c';
			c.Events__c = 'Insert;Update;Undelete';
			c.Active__c = true;
			return c;
		}
		private set;
	}
	private static List<CAA_Mapping_Item__c> getCorrectMappings() {
		CAA_Configuration__c caac = configDefault;
		insert caac;
	
		List<CAA_Mapping_Item__c> cm = new List<CAA_Mapping_Item__c>();
		
		CAA_Mapping_Item__c m = new CAA_Mapping_Item__c();
		m.Hardcoded_Value__c = null;
		m.Source_Field__c = 'Source_Object__c';
		m.Target_Field__c = 'Source_Object__c';
		m.CAA_Configuration__c = caac.Id;
		
		CAA_Mapping_Item__c m2 = new CAA_Mapping_Item__c();
		m2.Hardcoded_Value__c = null;
		m2.Source_Field__c = 'Target_Object__c';
		m2.Target_Field__c = 'Target_Object__c';
		m2.CAA_Configuration__c = caac.Id;

		cm.add(m);			
		cm.add(m2);

		insert cm;
		return cm;
	}

	private static List<CAA_Mapping_Item__c> getCorrectDeDupeMappings() {
		CAA_Configuration__c caac = configDeDupe;
		insert caac;
	
		List<CAA_Mapping_Item__c> cdm = new List<CAA_Mapping_Item__c>();
		
		CAA_Mapping_Item__c m = new CAA_Mapping_Item__c();
		m.Hardcoded_Value__c = null;
		m.Source_Field__c = 'Source_Object__c';
		m.Target_Field__c = 'Source_Object__c';
		m.CAA_Configuration__c = caac.Id;
		
		CAA_Mapping_Item__c m2 = new CAA_Mapping_Item__c();
		m2.Hardcoded_Value__c = null;
		m2.Source_Field__c = 'Target_Object__c';
		m2.Target_Field__c = 'Target_Object__c';
		m2.CAA_Configuration__c = caac.Id;


		CAA_Mapping_Item__c m3 = new CAA_Mapping_Item__c();
		//
		// Use hardcoded word 'Contact', which will act as the dedupe value
		//m3.Hardcoded_Value__c = null;
		m3.Hardcoded_Value__c = 'Contact';
		//m3.Source_Field__c = 'Target_Object__c';
		m3.Source_Field__c = null;
		m3.Target_Field__c = 'Test_Target_Unique__c';
		m3.CAA_Configuration__c = caac.Id;

		//
		// Duplicatie source by field 
		CAA_Mapping_Item__c m4 = new CAA_Mapping_Item__c();
		m4.Hardcoded_Value__c = null;
		m4.Source_Field__c = 'Target_Object__c';
		m4.Target_Field__c = 'Test_Target_Normal__c';
		m4.CAA_Configuration__c = caac.Id;

		//
		// Duplicatie source by hardcoded value 
		CAA_Mapping_Item__c m5 = new CAA_Mapping_Item__c();
		m5.Hardcoded_Value__c = 'Contact';
		m5.Source_Field__c = null;
		m5.Target_Field__c = 'Test_Target_Normal__c';
		m5.CAA_Configuration__c = caac.Id;

		cdm.add(m);			
		cdm.add(m2);
		cdm.add(m3);
		cdm.add(m4);
		cdm.add(m5);

		insert cdm;
		return cdm;
	}

	private static List<CAA_Mapping_Item__c> getErrorMappings() {
		CAA_Configuration__c caac = configDefault;
		insert caac;
	
		List<CAA_Mapping_Item__c> errorMappings = new List<CAA_Mapping_Item__c>();
		
		CAA_Mapping_Item__c m = new CAA_Mapping_Item__c();
		m.Hardcoded_Value__c = null;
		m.Source_Field__c = 'xSource_Object__c';
		m.Target_Field__c = 'Source_Object__c';
		m.CAA_Configuration__c = caac.Id;
		
		CAA_Mapping_Item__c m2 = new CAA_Mapping_Item__c();
		m2.Hardcoded_Value__c = null;
		m2.Source_Field__c = 'Target_Object__c';
		m2.Target_Field__c = 'yTarget_Object__c';
		m2.CAA_Configuration__c = caac.Id;
		errorMappings.add(m);			
		errorMappings.add(m2);
		insert errorMappings;
		return errorMappings;
	}
	
}