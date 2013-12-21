/* --------------------------------------------------------------------
// Class for XML generation conform Twinfield specs
-------------------------------------------------------------------- */
public class TwinfieldXml {
	/* --------------------------------------------------------------------
	// Generation of XML. Builds XML files usable to send to the Twinfield
	// API based on APEX objects
	-------------------------------------------------------------------- */
	
	//
	// Returns the XML to login to Twinfield as a String
	public static String logonXml(String user, String password, String organization, String twinfieldNameSpace) {
		String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XmlSchema-instance" xmlns:xsd="http://www.w3.org/2001/XmlSchema">';
		requestBody += '<soap:Body>';
		requestBody += '<Logon xmlns="'+twinfieldNameSpace+'">';
		requestBody += '<user>';
		requestBody += EncodingUtil.urlEncode(user,'UTF-8');
		requestBody += '</user>';
		requestBody += '<password>';
		requestBody += EncodingUtil.urlEncode(password,'UTF-8');
		requestBody += '</password>';
		requestBody += '<organisation>';
		requestBody += EncodingUtil.urlEncode(organization,'UTF-8');
		requestBody += '</organisation>';
		requestBody += '</Logon>';
		requestBody += '</soap:Body></soap:Envelope>';
		return requestBody;
	}

	//
	// Returns the XML to lgout from Twinfield as a String
	public static String abandonXml(String twinfieldNameSpace) {
		String requestBody = '<Abandon xmlns="'+twinfieldNameSpace+'" />';
		return requestBody;
	}

	//
	// Returns the XML to create the passed invoices in Twinfield as a String
	public static String salesInvoicesXml(List<TwinfieldSalesInvoice> sInvoices, String twinfieldNameSpace) {		
		String requestBody = '<ProcessXmlString xmlns="'+twinfieldNameSpace+'"><xmlRequest><![CDATA[';
		//
		// Add transactions
		requestBody += '<salesinvoices>';
		for(TwinfieldSalesInvoice si : sInvoices) {
			requestBody += '<salesinvoice raisewarning="false">';
			
			//
			// Invoice header
			requestBody += '<header>';
			requestBody += appendNode('office',si.office);
			requestBody += appendNode('invoicetype',si.invoiceType);
			requestBody += appendNode('invoicenumber',si.invoiceNumber);
			requestBody += appendNode('status',si.status);
			requestBody += appendNode('customer',si.customer);
			requestBody += appendNode('currency',si.currencyCode);
			requestBody += appendNode('period',si.period);
			requestBody += appendNode('invoicedate',si.invoiceDateTwinfield);
			requestBody += appendNode('duedate',si.dueDateTwinfield);
			requestBody += appendNode('performancedate',si.performanceDateTwinfield);
			requestBody += appendNode('paymentmethod',si.paymentMethod);
			requestBody += appendNode('bank',si.bank);
			requestBody += appendNode('invoiceaddressnumber',si.invoiceAddressNumber);
			requestBody += appendNode('deliveryaddressnumber',si.deliveryAddressNumber);
			requestBody += appendNode('headertext',si.headerText);
			requestBody += appendNode('footertext',si.footerText);
			requestBody += appendNode('userdefinedtag',si.userDefinedTag);
			requestBody += '</header>';
			
			//
			// Invoicelines
			requestBody += '<lines>';
			
			//
			// Lines need an incrementing number:
			Integer lineCounter = 1;
			for(TwinfieldSalesInvoiceline sil : si.invoiceLines) {
				requestBody += '<line id="'+String.valueOf(lineCounter)+'">';

				requestBody += appendNode('allowdiscountorpremium',sil.allowDiscountOrPremium);
				requestBody += appendNode('article',sil.article);
				requestBody += appendNode('subarticle',sil.subArticle);
				requestBody += appendNode('quantity',sil.quantity);
				requestBody += appendNode('units',sil.units);
				requestBody += appendNode('unitspriceexcl',sil.unitsPriceExcl);
				requestBody += appendNode('unitspriceinc',sil.unitsPriceInc);
				requestBody += appendNode('vatcode',sil.vatCode);
				requestBody += appendNode('freeText1',sil.freeText1);
				requestBody += appendNode('freetext2',sil.freetext2);
				requestBody += appendNode('freetext3',sil.freetext3);
				requestBody += appendNode('dim1',sil.dim1);
				requestBody += appendNode('dim2',sil.dim2);
				requestBody += appendNode('dim3',sil.dim3);
				requestBody += appendNode('dim4',sil.dim4);
				requestBody += appendNode('description',sil.description);
				requestBody += appendNode('performancedate',sil.performanceDateTwinfield);
				requestBody += appendNode('userdefinedtag',sil.userDefinedTag);
				requestBody += '</line>';
				//
				// Increment linecounter				
				lineCounter++;
			}
			requestBody += '</lines>';
			requestBody += '</salesinvoice>';
		}
		requestBody += '</salesinvoices>';
		requestBody += ']]></xmlRequest></ProcessXmlString>';
		return requestBody;
	}
	//
	// Returns the XML to create the passed invoices in Twinfield as a String
	public static String financialMutationsXml(List<TwinfieldFinancialMutation> fMuts, String twinfieldNameSpace) {		
		String requestBody = '<ProcessXmlString xmlns="'+twinfieldNameSpace+'"><xmlRequest><![CDATA[';
		//
		// Add transactions
		requestBody += '<transactions>';
		for(TwinfieldFinancialMutation mut : fMuts) {
			requestBody += '<transaction raisewarning="false" destiny="'+mut.transactionDestiny+'" autobalancevat="true">';
			
			//
			// Invoice header
			requestBody += '<header>';
			requestBody += appendNode('office',mut.office);
			requestBody += appendNode('code',mut.code);
			requestBody += appendNode('number',mut.dayBookNumber);
			requestBody += appendNode('period',mut.period);
			requestBody += appendNode('currency',mut.currencyCode);
			requestBody += appendNode('date',mut.transactionDateTwinfield);
			requestBody += appendNode('currencydate',mut.currencyDateTwinfield);
			requestBody += appendNode('duedate',mut.dueDateTwinfield);
			requestBody += appendNode('invoicenumber',mut.invoiceNumber);
			requestBody += appendNode('description',mut.description);
			requestBody += appendNode('statementnumber',mut.statementNumber);
			requestBody += appendNode('startvalue',mut.startValue);
			requestBody += appendNode('closevalue',mut.closeValue);
			requestBody += appendNode('userdefinedtag',mut.userDefinedTag);
			requestBody += '</header>';
			
			//
			// Invoicelines
			requestBody += '<lines>';
			
			for(TwinfieldFinancialMutationDetail sil : mut.detailLines) {
				requestBody += '<line id="'+String.valueOf(sil.lineNum)+'" type="'+sil.lineType+'">';

				requestBody += appendNode('destoffice',sil.destOffice);
				requestBody += appendNode('dim1',sil.dim1);
				requestBody += appendNode('dim2',sil.dim2);
				requestBody += appendNode('dim3',sil.dim3);
				requestBody += appendNode('dim4',sil.dim4);
				requestBody += appendNode('dim5',sil.dim5);
				requestBody += appendNode('dim6',sil.dim6);
				requestBody += appendNode('invnumber',sil.invNumber);
				requestBody += appendNode('freechar',sil.freeChar);
				requestBody += appendNode('freeText1',sil.freeText1);
				requestBody += appendNode('freetext2',sil.freetext2);
				requestBody += appendNode('freetext3',sil.freetext3);
				requestBody += appendNode('value',sil.lineValue);
				requestBody += appendNode('debitcredit',sil.debitCredit);
				requestBody += appendNode('description',sil.description);
				requestBody += appendNode('duedate',sil.dueDateTwinfield);
				//
				// MEMORIAAL CAN'T CONTAIN vatCode
				if (mut.Code != 'MEMO') {
					requestBody += appendNode('vatcode',sil.vatCode);
				}
				requestBody += appendNode('userdefinedtag',sil.userDefinedTag);
				requestBody += '</line>';

			}
			requestBody += '</lines>';
			requestBody += '</transaction>';
		}
		requestBody += '</transactions>';
		requestBody += ']]></xmlRequest></ProcessXmlString>';
		System.Debug('### JORRIT ###' + requestBody);
		return requestBody;
	}
	/* --------------------------------------------------------------------
	// Response handlers. Convert Dom.Documents sent by Twinfield
	// back to APEX objects for easy handling
	-------------------------------------------------------------------- */
	/*
	public static List<TwinfieldSalesInvoiceResponse> handleSalesInvoiceResponse(Dom.Document responseXml, String twinfieldNameSpace,String soapNameSpace) {
		Dom.XmlNode rootElement = responseXml.getRootElement();
		//
		// TODO : BUILD
		return new List<TwinfieldSalesInvoiceResponse>();
	}*/
	public static List<TwinfieldFinancialMutationResponse> handleFinancialMutationResponse(Dom.Document responseXml,String twinfieldNameSpace,String soapNameSpace) {
		List<TwinfieldFinancialMutationResponse> outList = new List<TwinfieldFinancialMutationResponse>();
		
		Dom.Document responseData = getResponseData(responseXml,twinfieldNameSpace,soapNameSpace);
		Dom.XmlNode rootElement = responseData.getRootElement();
		System.Debug('######## PARSING RESPONSE XML:'+responseXml.toXmlString());
		//
		// Root element (transactions) contains 1 or more transaction nodes 
		for(Dom.XmlNode transactionNode : rootElement.getChildElements()) {
			Dom.XmlNode headerNode = transactionNode.getChildElement('header', null);
			if(headerNode == null) {
				throw new TwinfieldXmlException('Illegal response: header not found!');	
			}
			Dom.XmlNode detailLines = transactionNode.getChildElement('lines', null);
			if(detailLines == null) {
				throw new TwinfieldXmlException('Illegal response: no lines not found!');	
			}
			
			//
			// Fetch other nodes			
			Dom.XmlNode officeNode = headerNode.getChildElement('office', null);
			Dom.XmlNode codeNode = headerNode.getChildElement('code', null);
			Dom.XmlNode periodNode = headerNode.getChildElement('period', null);
			Dom.XmlNode currencyNode = headerNode.getChildElement('currency', null);
			Dom.XmlNode dueDateNode = headerNode.getChildElement('duedate', null);
			Dom.XmlNode invoiceNumberNode = headerNode.getChildElement('invoicenumber', null);
			Dom.XmlNode descriptionNode = headerNode.getChildElement('description', null);
			Dom.XmlNode originNode = headerNode.getChildElement('origin', null);
			Dom.XmlNode userNode = headerNode.getChildElement('user', null);
			Dom.XmlNode numberNode = headerNode.getChildElement('number', null);
			Dom.XmlNode udtNode = headerNode.getChildElement('userdefinedtag', null);
									
			//
			// Construct the object
			TwinfieldFinancialMutationResponse tfr = new TwinfieldFinancialMutationResponse();

			//
			// Retrieve data from the main node
			tfr.transactionResponse.transactionResult = transactionNode.getAttributeValue('result', null);
			tfr.transactionResponse.transactionRaiseWarning = transactionNode.getAttributeValue('raisewarning', null);
			tfr.transactionResponse.transactionAutoBalanceVat = transactionNode.getAttributeValue('autobalancevat', null);
			tfr.transactionResponse.transactionLocation = transactionNode.getAttributeValue('location', null);
			tfr.transactionResponse.message = new TwinfieldResponseMessage(transactionNode.getAttributeValue('msgtype', null), transactionNode.getAttributeValue('msg', null));
			//
			// Retrieve header data 
			if(codeNode != null) {
				tfr.codeResponse.codeValue = codeNode.getText();
				tfr.codeResponse.codeName = codeNode.getAttributeValue('name', null);
				tfr.codeResponse.codeShortName = codeNode.getAttributeValue('shortname', null);
				tfr.codeResponse.message = new TwinfieldResponseMessage(codeNode.getAttributeValue('msgtype', null), codeNode.getAttributeValue('msg', null));
			} 			
			if(officeNode != null) {
				tfr.officeResponse.officeValue = officeNode.getText();
				tfr.officeResponse.officeName = officeNode.getAttributeValue('name', null);
				tfr.officeResponse.officeShortName = officeNode.getAttributeValue('shortname', null);
				tfr.officeResponse.message = new TwinfieldResponseMessage(officeNode.getAttributeValue('msgtype', null), officeNode.getAttributeValue('msg', null));
			} 			
			if(periodNode != null) {
				tfr.periodResponse.periodValue = periodNode.getText();
				tfr.periodResponse.message = new TwinfieldResponseMessage(periodNode.getAttributeValue('msgtype', null), periodNode.getAttributeValue('msg', null));
			} 			
			if(currencyNode != null) {
				tfr.currencyResponse.currencyValue = currencyNode.getText();
				tfr.currencyResponse.message = new TwinfieldResponseMessage(currencyNode.getAttributeValue('msgtype', null), currencyNode.getAttributeValue('msg', null));
			} 			
			if(dueDateNode != null) {
				tfr.dueDateResponse.dueDateValue = dueDateNode.getText();
				tfr.dueDateResponse.message = new TwinfieldResponseMessage(dueDateNode.getAttributeValue('msgtype', null), dueDateNode.getAttributeValue('msg', null));
			} 			
			if(invoiceNumberNode != null) {
				tfr.invoiceNumberResponse.invoiceNumberValue = invoiceNumberNode.getText();
				tfr.invoiceNumberResponse.message = new TwinfieldResponseMessage(invoiceNumberNode.getAttributeValue('msgtype', null), invoiceNumberNode.getAttributeValue('msg', null));
			} 			
			if(descriptionNode != null) {
				tfr.descriptionResponse.descriptionValue = descriptionNode.getText();
				tfr.descriptionResponse.message = new TwinfieldResponseMessage(descriptionNode.getAttributeValue('msgtype', null), descriptionNode.getAttributeValue('msg', null));
			} 	
			if(originNode != null) {
				tfr.originResponse.originValue = originNode.getText();
				tfr.originResponse.message = new TwinfieldResponseMessage(originNode.getAttributeValue('msgtype', null), originNode.getAttributeValue('msg', null));
			} 			
			if(numberNode != null) {
				tfr.numberResponse.numberValue = numberNode.getText();
				tfr.numberResponse.message = new TwinfieldResponseMessage(numberNode.getAttributeValue('msgtype', null), numberNode.getAttributeValue('msg', null));
			}
			if(udtNode != null) {
				tfr.userDefinedTagResponse.userDefinedTagValue = udtNode.getText();
				tfr.userDefinedTagResponse.message = new TwinfieldResponseMessage(udtNode.getAttributeValue('msgtype', null), udtNode.getAttributeValue('msg', null));
			}
			 			
			if(userNode != null) {
				tfr.userResponse.userValue = userNode.getText();
				tfr.userResponse.userName = userNode.getAttributeValue('name', null);
				tfr.userResponse.userShortName = userNode.getAttributeValue('shortname', null);
				tfr.userResponse.message = new TwinfieldResponseMessage(userNode.getAttributeValue('msgtype', null), userNode.getAttributeValue('msg', null));
			}
			

			//
			// Not iterate over the lines	
			for(Dom.XmlNode lineNode : detailLines.getChildElements()) {
				//
				// Fetch nodes
				Dom.XmlNode dim1Node = lineNode.getChildElement('dim1', null);
				Dom.XmlNode dim2Node = lineNode.getChildElement('dim2', null);
				Dom.XmlNode valueNode = lineNode.getChildElement('value', null);
				Dom.XmlNode debitCreditNode = lineNode.getChildElement('debitcredit', null);
				Dom.XmlNode rateNode = lineNode.getChildElement('rate', null);
				Dom.XmlNode baseValueNode = lineNode.getChildElement('basevalue', null);
				Dom.XmlNode matchLevelNode = lineNode.getChildElement('matchlevel', null);
				Dom.XmlNode customerSupplierNode = lineNode.getChildElement('customersupplier', null);
				Dom.XmlNode openValueNode = lineNode.getChildElement('openvalue', null);
				Dom.XmlNode openBaseValueNode = lineNode.getChildElement('openbasevalue', null);
				Dom.XmlNode matchStatusNode = lineNode.getChildElement('matchstatus', null);
				Dom.XmlNode vatTotalNode = lineNode.getChildElement('vattotal', null);
				Dom.XmlNode vatBaseTotalNode = lineNode.getChildElement('vatbasetotal', null);
				Dom.XmlNode udtLineNode = lineNode.getChildElement('userdefinedtag', null);
				
				TwinfieldFinancialMutationDetailResponse det = new TwinfieldFinancialMutationDetailResponse();

				//
				// Fetch line detail from the main node, all in attribs¨
				det.lineResponse.lineId = lineNode.getAttributeValue('id', null);
				det.lineResponse.lineType = lineNode.getAttributeValue('type', null);
				det.lineResponse.message = new TwinfieldResponseMessage(lineNode.getAttributeValue('msgtype', null), lineNode.getAttributeValue('msg', null));
				
				//
				// Populate the line
				if(dim1Node != null) {
					det.dim1Response.dim1Value = dim1Node.getText();
					det.dim1Response.dim1Name = dim1Node.getAttributeValue('name', null);
					det.dim1Response.dim1ShortName = dim1Node.getAttributeValue('shortname', null);
					det.dim1Response.dim1Type = dim1Node.getAttributeValue('type', null);
					det.dim1Response.dim1InUse = dim1Node.getAttributeValue('inuse', null);
					det.dim1Response.dim1VatCode = dim1Node.getAttributeValue('vatcode', null);
					det.dim1Response.dim1VatObligatory = dim1Node.getAttributeValue('vatobligatory', null);
					det.dim1Response.message = new TwinfieldResponseMessage(dim1Node.getAttributeValue('msgtype', null), dim1Node.getAttributeValue('msg', null));
				} 			
				if(dim2Node != null) {
					det.dim2Response.dim2Value = dim2Node.getText();
					det.dim2Response.dim2Name = dim2Node.getAttributeValue('name', null);
					det.dim2Response.dim2ShortName = dim2Node.getAttributeValue('shortname', null);
					det.dim2Response.dim2Type = dim2Node.getAttributeValue('type', null);
					det.dim2Response.dim2InUse = dim2Node.getAttributeValue('inuse', null);
					det.dim2Response.dim2VatCode = dim2Node.getAttributeValue('vatcode', null);
					det.dim2Response.dim2VatObligatory = dim2Node.getAttributeValue('vatobligatory', null);
					det.dim2Response.message = new TwinfieldResponseMessage(dim2Node.getAttributeValue('msgtype', null), dim2Node.getAttributeValue('msg', null));
				} 			
				if(valueNode != null) {
					det.valueResponse.valueValue = valueNode.getText();
					det.valueResponse.message = new TwinfieldResponseMessage(valueNode.getAttributeValue('msgtype', null), valueNode.getAttributeValue('msg', null));
				} 			
				if(debitCreditNode != null) {
					det.debitCreditResponse.debitCreditValue = debitCreditNode.getText();
					det.debitCreditResponse.message = new TwinfieldResponseMessage(debitCreditNode.getAttributeValue('msgtype', null), debitCreditNode.getAttributeValue('msg', null));
				} 			
				if(rateNode != null) {
					det.rateResponse.rateValue = rateNode.getText();
					det.rateResponse.message = new TwinfieldResponseMessage(rateNode.getAttributeValue('msgtype', null), rateNode.getAttributeValue('msg', null));
				} 			
				if(baseValueNode != null) {
					det.baseValueResponse.baseValueValue = baseValueNode.getText();
					det.baseValueResponse.message = new TwinfieldResponseMessage(baseValueNode.getAttributeValue('msgtype', null), baseValueNode.getAttributeValue('msg', null));
				} 			
				if(matchLevelNode != null) {
					det.matchLevelResponse.matchLevelValue = matchLevelNode.getText();
					det.matchLevelResponse.message = new TwinfieldResponseMessage(matchLevelNode.getAttributeValue('msgtype', null), matchLevelNode.getAttributeValue('msg', null));
				} 			
				if(customerSupplierNode != null) {
					det.customerSupplierResponse.customerSupplierValue = customerSupplierNode.getText();
					det.customerSupplierResponse.message = new TwinfieldResponseMessage(customerSupplierNode.getAttributeValue('msgtype', null), customerSupplierNode.getAttributeValue('msg', null));
				} 			
				if(openValueNode != null) {
					det.openValueResponse.openValueValue = openValueNode.getText();
					det.openValueResponse.message = new TwinfieldResponseMessage(openValueNode.getAttributeValue('msgtype', null), openValueNode.getAttributeValue('msg', null));
				} 			
				if(openBaseValueNode != null) {
					det.openBaseValueResponse.openBaseValueValue = openBaseValueNode.getText();
					det.openBaseValueResponse.message = new TwinfieldResponseMessage(openBaseValueNode.getAttributeValue('msgtype', null), openBaseValueNode.getAttributeValue('msg', null));
				} 			
				if(matchStatusNode != null) {
					det.matchStatusResponse.matchStatusValue = matchStatusNode.getText();
					det.matchStatusResponse.message = new TwinfieldResponseMessage(matchStatusNode.getAttributeValue('msgtype', null), matchStatusNode.getAttributeValue('msg', null));
				} 			
				if(vatTotalNode != null) {
					det.vatTotalResponse.vatTotalValue = vatTotalNode.getText();
					det.vatTotalResponse.message = new TwinfieldResponseMessage(vatTotalNode.getAttributeValue('msgtype', null), vatTotalNode.getAttributeValue('msg', null));
				} 			
				if(vatBaseTotalNode != null) {
					det.vatBaseTotalResponse.vatBaseTotalValue = vatBaseTotalNode.getText();
					det.vatBaseTotalResponse.message = new TwinfieldResponseMessage(vatBaseTotalNode.getAttributeValue('msgtype', null), vatBaseTotalNode.getAttributeValue('msg', null));
				} 	
				if(udtLineNode != null) {
					det.userDefinedTagResponse.userDefinedTagValue = udtLineNode.getText();
					det.userDefinedTagResponse.message = new TwinfieldResponseMessage(udtLineNode.getAttributeValue('msgtype', null), udtLineNode.getAttributeValue('msg', null));
				} 	
				
				tfr.responseLines.add(det);		
			}
			//System.Debug('#### TEST: '+tfr);
			outList.add(tfr);
		}
		
		return outList;
	}
	/* --------------------------------------------------------------------
	// Helper methods
	-------------------------------------------------------------------- */
	public static String appendNode(String nodeName, String nodeValue) {
		String out = '';
		if(nodeValue != null && nodeValue.trim() != '') {
			//out = '<'+nodeName+'>'+EncodingUtil.urlEncode(nodeValue,'UTF-8')+'</'+nodeName+'>';
			out = '<'+nodeName+'>'+nodeValue+'</'+nodeName+'>';
		}
		return out;
	}
	public static String appendNode(String nodeName, String nodeValue, Map<String,String> attributeNameValuePairs) {
		String out = '';
		if(nodeValue != null && nodeValue.trim() != '') {
			out = '<'+nodeName;
			for(String attr : attributeNameValuePairs.keySet()) {
				if(attributeNameValuePairs.get(attr) != null) {
					out += ' '+attr+'="'+attributeNameValuePairs.get(attr).trim()+'"';
				}
			}
			out += '>'+EncodingUtil.urlEncode(nodeValue,'UTF-8')+'</'+nodeName+'>';
		}
		return out;
	}	
	public static String addEnvelope(String bodyIn, String sessionId, String twinfieldNameSpace) {
		String outputText = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XmlSchema-instance" xmlns:xsd="http://www.w3.org/2001/XmlSchema">';
		outputText += '<soap:Header>';
		
		//
		// Add the session Id
		outputText += '<Header MyAttribute="" xmlns="'+twinfieldNameSpace+'">';
		outputText += '<SessionID>';
		outputText += EncodingUtil.urlEncode(sessionId,'UTF-8');
		outputText += '</SessionID>';
		outputText += '</Header>';
		outputText += '</soap:Header>';
		outputText += '<soap:Body>';
		outputText += bodyIn;
		outputtext += '</soap:Body></soap:Envelope>';
		return outputText;
	} 
	public static Dom.Document getResponseData(Dom.Document responseXml,String twinfieldNameSpace,String soapNameSpace) {
		Dom.XmlNode rootElement = responseXml.getRootElement();
		if(rootElement == null) {
			throw new TwinfieldXmlException('Could not find root element for response!');
		}
		Dom.XmlNode responsebody = rootElement.getChildElement('Body',soapNameSpace);
		if(responsebody == null) {
			throw new TwinfieldXmlException('Could not find soap body element in the  response!');
		}
		Dom.XmlNode processXmlStringResponse = responsebody.getChildElement('ProcessXmlStringResponse',twinfieldNameSpace);
		if(processXmlStringResponse == null) {
			throw new TwinfieldXmlException('Could not find ProcessXmlStringResponse element in the response!');
		}	
		Dom.XmlNode processXmlStringResult = processXmlStringResponse.getChildElement('ProcessXmlStringResult',twinfieldNameSpace);
		if(processXmlStringResult == null) {
			throw new TwinfieldXmlException('Could not find processXmlStringResult element in the response!');
		}
		//
		// We found the results. Cast them into a new Dom.Document	
		String encodedXmlText = processXmlStringResult.getText();
		Dom.Document actualDataXml = new Dom.Document();
		actualDataXml.load(encodedXmlText);
		return actualDataXml;
	}
	
	//
	// Exception	
	public class TwinfieldXmlException extends Exception {

	}	
	
}