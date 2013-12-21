public with sharing class Product2ImportUtil {
    //
    // To prevent recursion
    public static Boolean hasRun = false;
    
    // =============================================================================================================================
    // Product2ImportUtil.handleProduct2Records:
    // Method examines Add_to_Pricebooks__c and Deactivate_in_Pricebooks__c  on Product2
    // 1)   If Add_to_Pricebooks__c contains a comma separated list of valid pricebook names, this method will
    //      try to create PricebookEntries for those and, if necessary, add the standardprice (Pricebookentry in Standard PB)
    // 2)   If  Deactivate_in_Pricebooks__c contains a comma separated list of valid pricebook names, this method will
    //      try to de-activate PricebookEntries for those and, if necessary, add the standardprice (Pricebookentry in Standard PB)
    // =============================================================================================================================
    public static void handleProduct2Records(Map<ID,Product2> productMap) {
        //
        // Used to store all Pricebookentries affected
        List<PriceBookEntry> updatePbe = new List<PriceBookEntry>();
        List<PriceBookEntry> missingStandardPrices = new List<PriceBookEntry>();
        
        //
        // Used to store all Product2 Ids so the fields Add_to_Pricebooks__c and Deactivate_in_Pricebooks__c
        // can be cleared 
        Set<ID> updateProducts = new Set<ID>();     
        
        //
        // Holds a map of all active Pricebooks indexed by their Name
        Map<String,PriceBook2> priceBookMap = new Map<String,PriceBook2>(); 
        
        //
        // Hold the standard pricebook
        PriceBook2 stdPb;

        //
        // Set contains all Product2 record Id´s that have a standardPrice
        Set<ID> productsWithAStandardPrice = new Set<ID>(); 
        //
        // Populate pricebook stuff
        for(PriceBook2 pb : [SELECT Id, Name, IsStandard FROM PriceBook2]) {
            priceBookMap.put(pb.Name,pb);
            if(pb.IsStandard) {
                //
                // Set the standard Pricebook
                stdPb = pb;
            }           
        }
        
        for(PriceBookEntry pbe : [SELECT Id, Product2Id FROM PriceBookEntry WHERE PriceBook2Id = :stdPb.Id]) {
            productsWithAStandardPrice.add(pbe.Product2Id); 
        }
        
        //
        // Simply create standardprices for all products in the trigger 
        // that do not have one yet
        for(String product2Id : productMap.keySet()) {
            
            //
            // If there's no standard price yet, add it 
            if(!productsWithAStandardPrice.contains(product2Id)) {
                PriceBookEntry spbe = new PriceBookEntry();
                spbe.Product2Id = product2Id;
                spbe.PriceBook2Id = stdPb.Id;
                spbe.IsActive = true;
                spbe.UnitPrice = 0.00;
                missingStandardPrices.add(spbe);
            }
        }

        //
        // First add the missing Standard Prices
        // They are necessary
        try {
            System.Debug('### STD PRICES :'+missingStandardPrices.size());
            insert missingStandardPrices;
        }
        catch(Exception e) {
            System.Debug('#### Exception adding standardprices');
        }

        // 
        // Map in format Pricebook2Id -> List<Product2Id> 
        Map<String,Set<String>> activateInPriceBooks = new Map<String,Set<String>> ();
        Map<String,Set<String>> deActivateInPriceBooks = new Map<String,Set<String>> ();

        //
        // Now iterate over the product2 records
        for(String product2Id : productMap.keySet()) {
            //
            // Collect pricebooks to activate
            String activateInPb = productMap.get(product2Id).Add_to_Pricebooks__c;
            if(activateInPb != null) {
                for(String priceBookName : activateInPb.split(',',0)) {
                    priceBookName = priceBookName.trim();
                     
                    if(priceBookMap.containsKey(priceBookName)) {
                        PriceBook2 pb2 = priceBookMap.get(priceBookName);
                        Set<String> tempProductList = new Set<String>();
                        if(activateInPriceBooks.containsKey(pb2.Id)) {
                            tempProductList = activateInPriceBooks.get(pb2.Id);
                        }
                        tempProductList.add(product2Id);
                        activateInPriceBooks.put(pb2.Id,tempProductList);
                    } else {
                        System.Debug('#### ERROR: Listed pricebook for activation '+priceBookName+' on product '+product2Id+' not found!');
                    }
                }                       
            }
            
            //
            // Collect pricebooks to deactivate
            String deActivateInPb = productMap.get(product2Id).Deactivate_in_Pricebooks__c;
            if(deActivateInPb != null) {
                for(String priceBookName : deActivateInPb.split(',',0)) {
                    priceBookName = priceBookName.trim();
                    if(priceBookMap.containsKey(priceBookName)) {
                        PriceBook2 pb2 = priceBookMap.get(priceBookName);
                        Set<String> tempProductList = new Set<String>();
                        if(deActivateInPriceBooks.containsKey(pb2.Id)) {
                            tempProductList = deActivateInPriceBooks.get(pb2.Id);
                        }
                        tempProductList.add(product2Id);
                        deActivateInPriceBooks.put(pb2.Id,tempProductList);
                    } else {
                        System.Debug('#### ERROR: Listed pricebook for deactivation '+priceBookName+' on product '+product2Id+' not found!');
                    }                       
                }                       
            }
        }

        System.Debug('### ACTIVATE PB:'+activateInPriceBooks);
        System.Debug('### DEACTIVATE PB:'+deActivateInPriceBooks);
        if(!deActivateInPriceBooks.isEmpty() || !activateInPriceBooks.isEmpty()) {
            
            // 
            // Now create the appropriate PriceBookEntry objects
            for(String pbId : activateInPriceBooks.keySet()) {
                Set<String> productIds = activateInPriceBooks.get(pbId);
                for(String prodId : productIds) {
                    PriceBookEntry pbe = new PriceBookEntry();
                    pbe.Product2Id = prodId;
                    pbe.PriceBook2Id = pbId;
                    pbe.IsActive = true;
                    pbe.UnitPrice = 0.00;
                    updatePbe.add(pbe);
                }
            }
            for(String pbId : deActivateInPriceBooks.keySet()) {
                Set<String> productIds = deActivateInPriceBooks.get(pbId);
                for(String prodId : productIds) {
                    PriceBookEntry pbe = new PriceBookEntry();
                    pbe.Product2Id = prodId;
                    pbe.PriceBook2Id = pbId;
                    pbe.IsActive = false;
                    pbe.UnitPrice = 0.00;
                    updatePbe.add(pbe);
                }
            }
            
            //
            // Now, build a query, to see if any of the desired pricebook entry updates
            // is already, by matching the product and pricebook id in one pricebookentry   
            String query = 'SELECT Id, Product2Id, PriceBook2Id, IsActive FROM PriceBookEntry WHERE ';
            Integer totalPriceBooks = activateInPriceBooks.keySet().size();
            Integer counter = 0;
            //
            // Active one's
            for(String pbId : activateInPriceBooks.keySet()) {
                counter++;
                Set<String> productIds = activateInPriceBooks.get(pbId);
                if(!productIds.isEmpty()) {
                    Integer totalProducts = productIds.size(); 
                    query += ' (PriceBook2Id = \''+pbId+'\'' ;
                    query += ' AND ';
                    query += ' Product2Id IN (';
                    Integer counter2 = 0;
                    for(String prodId : productIds) {
                        counter2++;
                        query += '\''+prodId+'\'';
                        if(counter2 < totalProducts) {
                            query += ','; 
                        }
                    }
                    query += '))';
                    if(counter < totalPriceBooks) {
                        query += ' OR ';            
                    }
                }
            }
            if(!deActivateInPriceBooks.isEmpty() && !activateInPriceBooks.isEmpty()) {
                query += ' OR ';
            }
            
            //
            // Inactive one's
            counter = 0;
            totalPriceBooks = deActivateInPriceBooks.keySet().size();
            for(String pbId : deActivateInPriceBooks.keySet()) {
                counter++;
                Set<String> productIds = deActivateInPriceBooks.get(pbId);
                if(!productIds.isEmpty()) {
                    Integer totalProducts = productIds.size(); 
                    query += ' (PriceBook2Id = \''+pbId+'\'' ;
                    query += ' AND ';
                    query += ' Product2Id IN (';
                    Integer counter2 = 0;
                    for(String prodId : productIds) {
                        counter2++;
                        query += '\''+prodId+'\'';
                        if(counter2 < totalProducts) {
                            query += ','; 
                        }
                    }
                    query += '))';
                    if(counter < totalPriceBooks) {
                        query += ' OR ';            
                    }
                }
            }       
            System.Debug('## QUERY: '+query);
    
            //
            // Fetch the existing PricebookEntries
            List<PriceBookEntry> existingPbe = new List<PriceBookEntry>(); 
            for(List<PriceBookEntry> objs : Database.query(query)) {
                existingPbe.addAll(objs);
            }   
            
            for(PriceBookEntry pbe : updatePbe) {
                System.Debug('### BEFORE PBE:'+pbe);    
            }
            
            //
            // Update the records in our upsert list if necessary.
            // Cannot use external Ids on pricebookentries, nor can we 'set' the readonly Id field
            // We need a map here, since we cannot modify items in the list we're iterating
            // So we store the index + record to insert into it.
            Map<Integer,PriceBookEntry> replacements = new Map<Integer,PriceBookEntry>(); 
            for(Integer x = 0; x < updatePbe.size(); x++) {
                PriceBookEntry newPbeSituation = updatePbe[x];
                for(PriceBookEntry oldPbeSituation : existingPbe) {
                    if(oldPbeSituation.Product2Id == newPbeSituation.Product2Id && oldPbeSituation.PriceBook2Id == newPbeSituation.PriceBook2Id) {
                        // 
                        // Product was allready present in this pricebook, replace 
                        // the new situation with the old and overwrite the IsActive field
                        // so it will be effectively updated                    
                        Boolean isActiveCopy = newPbeSituation.IsActive;
                        newPbeSituation = oldPbeSituation.clone();
                        newPbeSituation.IsActive = isActiveCopy;
                        replacements.put(x,newPbeSituation);
                    }
                }
            }
            
            //
            // Execute replacements
            // Replacing existing pricebookentries, with their existing counterpart, containing an Id
            // This Id will be usefull when we do the upsert of pricebookentries lateron
            for(Integer x : replacements.keySet()) {
                updatePbe.set(x,replacements.get(x));   
            }
            /*for(PriceBookEntry pbe : updatePbe) {
                System.Debug('### RESULTING PBE:'+pbe); 
            }*/
            try {
                //
                // Upsert the list of new and changed Pricebookentries
                Database.UpsertResult[] results = Database.upsert(updatePbe);
                System.Debug('### RESULTS:'+results);
            }
            catch(Exception e) {
                System.Debug('Exception occurred updating Pricebookentries: '+e.getMessage());
            }
        } 
    }
    // =============================================================================================================================
    // Product2ImportUtil.clearProduct2:
    // Clears / resets the fields Add_to_Pricebooks__c and Deactivate_in_Pricebooks__c on Product2
    // =============================================================================================================================
    @future
    public static void clearProduct2(Set<ID> product2RecordsToClear) {
        hasRun = true;
        for(Product2[] prods : [SELECT Id, Deactivate_in_Pricebooks__c, Add_to_Pricebooks__c FROM Product2 WHERE Id IN :product2RecordsToClear]) {
            for(Product2 prod : prods) {
                prod.Deactivate_in_Pricebooks__c = '';
                prod.Add_to_Pricebooks__c = '';
            }
            update prods;
        }
    }
}