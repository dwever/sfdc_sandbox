public class TwinfieldTestUtil {
	public static List<TwinfieldSalesInvoice> createTfTestSalesinvoices(Integer numInvoices) {
		List<TwinfieldSalesInvoice> outputList = new List<TwinfieldSalesInvoice>();
		//
		// Each invoice will have it's own debtor 
		// Each invoice will contain 5 lines
		for(Integer x = 0; x < numInvoices; x++) {
			TwinfieldSalesInvoice tfsi = new TwinfieldSalesInvoice();
			tfsi.invoiceLines = new List<TwinfieldSalesInvoiceline>(); 
			tfsi.debtor = new TwinfieldDebtor('DEMO DEBTOR','10001');
			
			tfsi.office = '12025';
			tfsi.invoiceType = 'FACTUUR';
			tfsi.invoiceNumber = '10101';
			tfsi.status = 'final';
			//tfsi.customer = '';
			tfsi.currencyCode = '';
			tfsi.period = '2011/04';
			tfsi.invoiceDate = System.Today();
			tfsi.dueDate = System.Today()+1;
			//tfsi.performanceDate = System.Today() + 60;
			tfsi.paymentMethod = 'bank'; // 'cash', 'cheque', 'cashondelivery', 'DA'
			tfsi.bank = '';
			tfsi.invoiceAddressNumber = ''; // integer
			tfsi.deliveryAddressNumber = ''; // integer
			tfsi.headerText = '';
			tfsi.footerText = '';
			tfsi.userDefinedTag = 'XXXYYYZZZ';
			
		
			Decimal totalAmount = 0;	
			List<TwinfieldSalesInvoiceline> tempList = new List<TwinfieldSalesInvoiceline>(); 		
			for(Integer y = 0; y < 5; y++) {
				TwinfieldSalesInvoiceline tfsil = new TwinfieldSalesInvoiceline();
				
				tfsil.allowDiscountOrPremium = '';
				tfsil.article = '0';
				tfsil.subArticle = '';
				tfsil.quantity = '1';
				tfsil.units = '';
				tfsil.unitsPriceExcl = '13.0';
				tfsil.unitsPriceInc = '';
				tfsil.vatCode = 'VH';
				tfsil.freeText1 = '';
				tfsil.freeText2 = '';
				tfsil.freeText3 = '';
				if(y==1) {
					tfsil.dim1 = '8015';
				} else {
					tfsil.dim1 = '8011';
					
				}
				tfsil.dim2 = '';
				tfsil.dim2 = '';
				tfsil.dim4 = '';
				tfsil.description = '';
				//tfsil.performanceDate = System.Today() + 60;
				//tfsil.valueExcl = '';
				//tfsil.vatValue = '';
				//tfsil.valueInc = '';
				tfsil.userDefinedTag = '';	

				//
				// Add to the main invoice object
				tempList.add(tfsil); 		
			}

			tfsi.invoiceLines.addAll(tempList);
			outputList.add(tfsi);
		}
		return outputList;
	}
	public static List<TwinfieldFinancialMutation> createTfTestFinMut(Integer numFinMut) {
		List<TwinfieldFinancialMutation> outputList = new List<TwinfieldFinancialMutation>();
		for(Integer x = 0; x < numFinMut; x++) {
			TwinfieldFinancialMutation tfMut = new TwinfieldFinancialMutation();
			tfMut.detailLines = new List<TwinfieldFinancialMutationDetail>();
			tfMut.transactionDestiny = 'temporary';
			tfMut.closeValue = '';
			if(x==1) {
			tfMut.code = 'VRK';
			}
			tfMut.currencyCode = 'EUR';
			//tfMut.currencyDate = System.Today();
			tfMut.dayBookNumber = '';
			tfMut.description = 'TEST OMSCHRIJVING';			
			tfMut.dueDate = System.Today() + 10;
			tfMut.invoiceNumber = '123454322';
			if(x==1) {
				tfMut.office = '12025';
			}
			tfMut.origin = '';
			tfMut.period = '2011/07';
			tfMut.startValue = '';
			tfMut.statementNumber = '';
			tfMut.transactionDate = System.Today();
			tfMut.userCode = '';
			tfMut.userDefinedTag = '';
			
			Decimal totalAmount = 0;	
			//
			// Total will be one!
			Integer lineCounter = 2;
			
			List<TwinfieldFinancialMutationDetail> tempList = new List<TwinfieldFinancialMutationDetail>(); 		
			for(Integer y = 0; y < 2; y++) {
				TwinfieldFinancialMutationDetail tfMutDet = new TwinfieldFinancialMutationDetail();
				tfMutDet.lineType = 'detail'; // total / vat
				tfMutDet.debitcredit = 'credit';
				tfMutDet.description = 'omschrijving '+lineCounter;
				tfMutDet.lineNum = lineCounter;
				tfMutDet.destOffice = '';
				tfMutDet.dim1 = '8015';
				tfMutDet.dim2 = '';
				tfMutDet.dim3 = '';
				tfMutDet.dim4 = '';
				tfMutDet.dim5 = '';
				tfMutDet.dim6 = '';
				//tfMutDet.dueDate = System.Today() + 10;
				tfMutDet.freeChar = '';
				//tfMutDet.freeText1 = 'test 2';
				//tfMutDet.freeText2 = 'test 3';
				//tfMutDet.freeText3 = '';
				tfMutDet.invNumber = '';
				tfMutDet.lineValue = String.valueOf(25);
				tfMutDet.userDefinedTag = '';
				tfMutDet.vatCode = 'VH';
				tempList.add(tfMutDet); 
					
				totalAmount += 25;	
				lineCounter++;
			}
			TwinfieldFinancialMutationDetail tfMutTotal = new TwinfieldFinancialMutationDetail();
			tfMutTotal.lineType = 'total'; // total / vat
			tfMutTotal.debitcredit = 'debit';
			tfMutTotal.dim1 = '1200';
			tfMutTotal.dim2 = '10002';
			tfMutTotal.lineValue = String.valueOf(totalAmount * 1.19);
			//tfMutTotal.lineValue = String.valueOf(totalAmount);
			tfMutTotal.lineNum = 1;
			tempList.add(tfMutTotal); 
			
			tfMut.detailLines.addAll(tempList);
			outputList.add(tfMut);
		}
		return outputList;
	}
	//
	// Generate a list of responses
	public static List<TwinfieldFinancialMutationResponse> createFinMutResponses() {
		List<TwinfieldFinancialMutationResponse> outList = new List<TwinfieldFinancialMutationResponse>();
		for(Integer x =0; x<10; x++ ) {
			TwinfieldFinancialMutationResponse resp = new TwinfieldFinancialMutationResponse();
			resp.transactionResponse.transactionResult = String.valueOf(x);
			resp.codeResponse.codeValue = String.valueOf(x);
			resp.responseLines = new List<TwinfieldFinancialMutationDetailResponse>();
			for(Integer y =0; y<5; y++ ) {
				TwinfieldFinancialMutationDetailResponse tfDetail = new TwinfieldFinancialMutationDetailResponse();
				tfDetail.lineResponse.lineId = String.valueOf(x);
				resp.responseLines.add(tfDetail);	
			}
			outList.add(resp);		
		}
		return outList;
	} 
}