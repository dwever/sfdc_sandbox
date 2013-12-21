@isTest
private class TestProduct2Import {	
	private static List<PriceBook2> pbs {
		get {
			List<PriceBook2> pbs = new List<PriceBook2>();
			PriceBook2 pb1 = new PriceBook2();
			pb1.Name = 'Test HKO PB 1';
			pb1.IsActive = true;
			pbs.add(pb1);
			PriceBook2 pb2 = new PriceBook2();
			pb2.Name = 'Test HKO PB 2';
			pb2.IsActive = true;
			pbs.add(pb2);
			return pbs;			
		}		
	}
	private static testMethod void testActivationDeActivation() {
		insert pbs;
		System.Debug([SELECT ID, Name FROM Pricebook2]);
		List<Product2> products = new List<Product2>();
		for(Integer x=0; x<250; x++) { 
			Product2 p = new Product2();
			p.Name = 'Test HKO '+x;
			p.Add_to_Pricebooks__c = 'Test HKO PB 1, SomeOther'; // SomeOther being a dummy.
			p.Deactivate_in_Pricebooks__c = 'Test HKO PB 2';
			p.IsActive = true;
			p.Material_number__c= String.valueOf(x);
			products.add(p);
		}
		
		Test.StartTest();
		Database.upsert(products,Product2.Fields.Material_number__c);
		
		//
		// Now we should have 250 active standard pbe
		System.AssertEquals(250, [SELECT Id FROM PriceBookEntry WHERE PriceBook2.IsStandard = true AND Product2.Name LIKE 'Test HKO%' AND IsActive = true].size());
		
		//
		// ... and 250 in the Test HKO PB 1
		System.AssertEquals(250, [SELECT Id FROM PriceBookEntry WHERE PriceBook2.Name = 'Test HKO PB 1' AND Product2.Name LIKE 'Test HKO%' AND IsActive = true].size());		
				
		//
		// ... and 0 in the Test PB 2
		System.AssertEquals(0, [SELECT Id FROM PriceBookEntry WHERE PriceBook2.Name = 'Test HKO PB 2' AND Product2.Name LIKE 'Test HKO%' AND IsActive = true].size());		
		
		//
		// Now deactivate some
		List<Product2> products2 = new List<Product2>();
		for(Integer x=0; x<125; x++) { 
			Product2 p = new Product2();
			p.Name = 'Test HKO '+x;
			p.Add_to_Pricebooks__c = '';
			p.Deactivate_in_Pricebooks__c = 'Test HKO PB 1, Test HKO PB 2';
			p.IsActive = true;
			p.Material_number__c= String.valueOf(x);
			products2.add(p);
		}
		Database.upsert(products2,Product2.Fields.Material_number__c);		
		
		//
		// Now we should have 250 active standard pbe
		System.AssertEquals(250, [SELECT Id FROM PriceBookEntry WHERE PriceBook2.IsStandard = true AND Product2.Name LIKE 'Test HKO%' AND IsActive = true].size());
		
		//
		// ... and 125 in the Test PB 1
		System.AssertEquals(125, [SELECT Id FROM PriceBookEntry WHERE PriceBook2.Name = 'Test HKO PB 1' AND Product2.Name LIKE 'Test HKO%' AND IsActive = true].size());		
		Test.StopTest();
		
		//
		// Fields should have been reset
		System.AssertEquals(null,[SELECT Id, Deactivate_in_Pricebooks__c, Add_to_Pricebooks__c FROM Product2 WHERE Name Like 'Test HKO%' LIMIT 1].Deactivate_in_Pricebooks__c);
		System.AssertEquals(null,[SELECT Id, Deactivate_in_Pricebooks__c, Add_to_Pricebooks__c FROM Product2 WHERE Name Like 'Test HKO%' LIMIT 1].Add_to_Pricebooks__c);
	}
}