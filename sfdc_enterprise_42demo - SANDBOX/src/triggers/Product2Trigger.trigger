trigger Product2Trigger on Product2 (after insert, after undelete, after update) {
	Map<ID,Product2> relevantProducts = new Map<ID,Product2>();
	for(Product2 p : Trigger.new) {
		if(p.Add_to_Pricebooks__c != null || p.Deactivate_in_Pricebooks__c != null) {
			relevantProducts.put(p.Id,p);
		}
	}
	Product2ImportUtil.handleProduct2Records(relevantProducts);	
	if(!Product2ImportUtil.hasRun) {
		//
		// Finally reset the product records
		Product2ImportUtil.clearProduct2(relevantProducts.keySet());
	}	
}