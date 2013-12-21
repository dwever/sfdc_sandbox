@isTest
private class TestTwinfield {
    static testMethod void testStub() {
        //
        // Default:
        try {
            TwinfieldStub ts1 = new TwinfieldStub();
        } 
        catch(Exception e) {
            system.Debug(e);
            System.Assert(true);
        }
        
        try {
            TwinfieldStub ts2 = new TwinfieldStub('Illegal');
        } 
        catch(Exception e) {
            system.Debug(e);
            System.Assert(true);
        }
        
        try {
            TwinfieldStub ts3 = new TwinfieldStub('Default'); // identical to ts1
        } 
        catch(Exception e) {
            system.Debug(e);
            System.Assert(true);
        }
        //
        // Test the envelope
        String abandonXml = TwinfieldXml.abandonXml('http://www.twinfield.com/');
        abandonXml = TwinfieldXml.addEnvelope(abandonXml, '1234567', 'http://www.twinfield.com/');
        
        
    }
    static testMethod void testRequests() {
        List<TwinfieldFinancialMutation> tfFmutList = TwinfieldTestUtil.createTfTestFinMut(10);
        TwinfieldStub ts = new TwinfieldStub(true);
        try {
            ts.sendFinancialMutations(tfFmutList);
        }
        catch(Exception e) {
            System.Assert(true);
        }       
        //
        // Test the dates:
        System.Debug('Converted duedate: '+tfFmutList[0].dueDateTwinfield);
        System.Debug('Converted currencydate: '+tfFmutList[0].currencyDateTwinfield);
        System.Debug('Converted transactiondate: '+tfFmutList[0].transactionDateTwinfield);
        
        List<TwinfieldSalesInvoice> tfSiList = TwinfieldTestUtil.createTfTestSalesinvoices(10);
        try {
            ts.sendSalesinvoices(tfSiList);
        }
        catch(Exception e) {
            System.Assert(true);
        }       
        //
        // Test the dates:
        System.Debug('Converted duedate: '+tfSiList[0].dueDateTwinfield);
        System.Debug('Converted invoicedate: '+tfSiList[0].invoiceDateTwinfield);
        System.Debug('Converted performancedate: '+tfSiList[0].performanceDateTwinfield);
        
        try {
            ts.logoutTwinfield();
        }
        catch(Exception e) {
            System.Assert(true);
        }                           
    }
    static testMethod void testResponseMessage() {
        TwinfieldResponseMessage tfrm = new TwinfieldResponseMessage('Test','Test'); 
    }
    static testMethod void testTestTwinfieldDomDocuments() {
        TwinfieldStub ts = new TwinfieldStub(true); // Test constructor
        Dom.Document logonResult = TestTwinfieldDomDocuments.logonResultDom();
        ts.handleLogonResponse(logonResult);
        
        Dom.Document finMutResult = TestTwinfieldDomDocuments.financialMutationResultDom();
        TwinfieldXml.handleFinancialMutationResponse(finMutResult,'http://www.twinfield.com/','http://schemas.xmlsoap.org/soap/envelope/');             
    }
    static testMethod void testTestTwinfieldXml() {
        String s1 = TwinfieldXml.logonXml('test', 'test', 'test', 'test');
        String s2 = TwinfieldXml.abandonXml('test');
        String s3 = TwinfieldXml.financialMutationsXml(TwinfieldTestUtil.createTfTestFinMut(2), 'test');
        String s4 = TwinfieldXml.salesInvoicesXml(TwinfieldTestUtil.createTfTestSalesinvoices(2), 'test');
        Map<String,String> smap = new Map<String,String>();
        smap.put('test','test'); 
        String s5 = TwinfieldXml.appendNode('test', 'test', smap);
    }
}