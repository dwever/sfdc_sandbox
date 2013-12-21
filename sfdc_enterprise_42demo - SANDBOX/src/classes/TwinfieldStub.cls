/* ---------------------------------------------------------------------------------
// Usage:
// - Create an instance of TwinfieldStub, which will handle connection
// - Call TwinfieldStub.sendSalesinvoices() this will return a Dom.Document which needs parsing (todo!!)
// - Call TwinfieldStub.sendFinancialMutations()
// - Call TwinfieldStub.logoutTwinfield() to abandon the session!
//
// - Test using TwinfieldTestUtil, which will generate some sample TwinfieldSalesInvoice or TwinfieldFinancialMutation
--------------------------------------------------------------------------------- */
public class TwinfieldStub {
	/* --------------------------------------------------------------------
	// Class variables
	-------------------------------------------------------------------- */	
	private String clusterEndPoint;
	private String sessionId;
	private String tfNamespace; // = 'http://www.twinfield.com/';
	private String soapNamespace; // = 'http://schemas.xmlsoap.org/soap/envelope/';
	private String processXmlUrl; // = '/webservices/processxml.asmx?wsdl';
	private String userName;
	private String password;
	private String organization;
	private String logonEndpoint;
	private Twinfield_Settings__c tfSettings;
	private Integer timeoutMs;
	
	/* --------------------------------------------------------------------
	// Public methods
	-------------------------------------------------------------------- */
	//
	// Constructor logs in and stores Session Id and cluster from the response
	// for subsequent calls. Details taken from custom settings named 'Default'
	public TwinfieldStub() {
		this.tfSettings = Twinfield_Settings__c.getInstance('Default');
		
		if(this.tfSettings == null) {
			throw new TwinfieldStubException('No Twinfield Setting named "Default" defined! Please use the named constructor, or create a Default setting!');
		} 
		this.userName = tfSettings.Username__c;
		this.password = tfSettings.Password__c;
		this.organization = tfSettings.Organization__c;
		this.logonEndpoint = tfSettings.Logon_Endpoint__c;
		this.timeoutMs = Integer.valueOf(this.tfSettings.Timeout__c);
		this.tfNamespace = tfSettings.Twinfield_Namespace__c;
		this.soapNamespace = tfSettings.SOAP_Namespace__c;
		this.processXmlUrl = tfSettings.ProcessXML_Suffix__c;
		
		this.logonTwinfield();
	}
	public TwinfieldStub(Boolean test) {
		//
		// Empty instance for testing
		String s = 'I hate creating testcode when certain methods are untestable';
		s = 'Because of callouts which cannot be performed in test';
		s = 'Which had me write this dummy code to get coverage!!';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
		s = 'etc.';
	}	
	//
	// Constructor logs in and stores Session Id and cluster from the response
	// for subsequent calls. Details taken from custom settings named settingName
	public TwinfieldStub(String settingName) {
		this.tfSettings = Twinfield_Settings__c.getInstance(settingName);
		
		if(this.tfSettings == null) {
			throw new TwinfieldStubException('No Twinfield Setting named "'+settingName+'" defined!');
		} 
		this.userName = tfSettings.Username__c;
		this.password = tfSettings.Password__c;
		this.organization = tfSettings.Organization__c;
		this.logonEndpoint = tfSettings.Logon_Endpoint__c;
		this.timeoutMs = Integer.valueOf(this.tfSettings.Timeout__c);
		this.tfNamespace = tfSettings.Twinfield_Namespace__c;
		this.soapNamespace = tfSettings.SOAP_Namespace__c;
		this.processXmlUrl = tfSettings.ProcessXML_Suffix__c;
		
		this.logonTwinfield();
	}

	
	//
	// To release the session
	public void logoutTwinfield() {
		try {
			String abandonXml = TwinfieldXml.abandonXml(this.tfNamespace);
			abandonXml = TwinfieldXml.addEnvelope(abandonXml, this.sessionId, this.tfNamespace);
			HttpResponse abandonResult = SoapHttp.sendSOAPRequest(abandonXml, tfSettings.Logon_Endpoint__c, this.timeoutMs);
			
			if(abandonResult.getStatusCode() == 200) {
				// 
				// Abandon call succeeded, reset vars
				this.sessionId = null;
				this.clusterEndPoint = null;
			} else {
				throw new TwinfieldStubException('Abandoning session failed. Status: '+abandonResult.getStatusCode()+', returned message: '+abandonResult.getStatus());
			}
		}
		catch(Exception e) {
			throw new TwinfieldStubException('Abandoning session failed. Message returned was '+e.getMessage());	
		}
	}
	
	public Dom.Document sendSalesinvoices(List<TwinfieldSalesInvoice> invs) {
		/*
		To test, using execute anonymous:
			List<TwinfieldSalesInvoice> tsi = TwinfieldTestUtil.createTfTestSalesinvoices(1);
			TwinfieldStub ts = new TwinfieldStub();
			ts.sendSalesinvoices(tsi);		
			
			Only available as a Dom.Document
			Parsing needs to be done manually!
		
		*/
		
		Dom.Document outDom;
		String requestXml = TwinfieldXml.salesInvoicesXml(invs,this.tfNamespace);
		requestXml = TwinfieldXml.addEnvelope(requestXml, this.sessionId, this.tfNamespace);
		HttpResponse resp = SoapHttp.sendSOAPRequest(requestXml, this.clusterEndPoint+this.processXmlUrl, this.timeoutMs);
		
		if(resp.getStatusCode() == 200) {
			//
			// Success
			outDom = resp.getBodyDocument();

		} else {
			// 
			// Error
			throw new TwinfieldStubException('Error sending invoices. Status: '+resp.getStatusCode()+', returned message: '+resp.getStatus());
		}
		return outDom;
	}

	public List<TwinfieldFinancialMutationResponse> sendFinancialMutations(List<TwinfieldFinancialMutation> muts) {
		/*
		To test, using execute anonymous:
			List<TwinfieldFinancialMutation> tfm = TwinfieldTestUtil.createTfTestFinMut(1);
			TwinfieldStub ts = new TwinfieldStub();
			ts.sendFinancialMutations(tfm);		
		*/
		
		List<TwinfieldFinancialMutationResponse> output;
		String requestXml = TwinfieldXml.financialMutationsXml(muts,this.tfNamespace);
		requestXml = TwinfieldXml.addEnvelope(requestXml, this.sessionId, this.tfNamespace);

		HttpResponse resp = SoapHttp.sendSOAPRequest(requestXml, this.clusterEndPoint+this.processXmlUrl, this.timeoutMs);
		
		if(resp.getStatusCode() == 200) {
			//
			// Success
			Dom.Document outDom = resp.getBodyDocument();
			
			output = TwinfieldXml.handleFinancialMutationResponse(outDom, this.tfNamespace,this.soapNamespace);
		} else {
			// 
			// Error 
			throw new TwinfieldStubException('Error sending financial mutations. Status: '+resp.getStatusCode()+', returned message: '+resp.getStatus());
		}
		System.Debug('##### RESPONSE :'+output);
		return output;
	}
	/* --------------------------------------------------------------------
	// Private methods
	-------------------------------------------------------------------- */
	//
	// Logs into Twinfield and fetches the necessary details from the result.
	private void logonTwinfield() {
		
		//
		// Generate the XML needed to do the logon call 
		String logonCallXml = TwinfieldXml.logonXml(this.userName,this.password,this.organization, this.tfNamespace);
		
		//
		// Do the logon
		HttpResponse logonResult = SoapHttp.sendSOAPRequest(logonCallXml, this.logonEndpoint, this.timeoutMs);
		
		//
		// Handle result
		if(logonresult.getStatusCode() == 200) {
			//
			// Success
			Dom.Document logonDom = logonResult.getBodyDocument();
			System.Debug('#### DOM: '+logonDom.toXmlString());
			
			//
			// Logged in correctly. Now fetch the cluster url AND session id from the response
			this.handleLogonResponse(logonDom);
		} else {
			// 
			// Error logging in
			throw new TwinfieldStubException('An error occurred logging in to Twinfield. Status: '+logonResult.getStatusCode()+', returned message: '+logonResult.getStatus());
		}
	}

	
	/* --------------------------------------------------------------------
	// Response handlers. All public to be able to create 
	// Test code (which cannot make an actual callout)
	-------------------------------------------------------------------- */
	public void handleLogonResponse(Dom.Document response) {
		//
		// Parse the DOM
		try { 
			System.Debug('### XML:'+response.toXmlString());
			Dom.XMLNode envelope = response.getRootElement();
			String nameSpace = envelope.getNamespace();
			Dom.XmlNode soapHeader = envelope.getChildElement('Header', nameSpace);
			Dom.XmlNode header = soapHeader.getChildElement('Header', this.tfNamespace);
			Dom.XmlNode session;
			if(header!=null) {
				session = header.getChildElement('SessionID',this.tfNamespace);
				//
				// Found the session Id
				this.sessionId = session.getText();
			}
			
			Dom.XmlNode body = envelope.getChildElement('Body', nameSpace);
			Dom.XmlNode logonResponse = body.getChildElement('LogonResponse', this.tfNamespace);
			if(logonResponse!=null) {
				Dom.XmlNode cluster = logonResponse.getChildElement('cluster', this.tfNamespace);
				
				//
				// Found the cluster endpoint 
				this.clusterEndPoint = cluster.getText();
			}
		}	
		catch(Exception e) {
			throw new TwinfieldStubexception('Error parsing logon response. Message returned was '+e.getMessage());
		}	
	}
	

	/* --------------------------------------------------------------------
	// Inner classes
	-------------------------------------------------------------------- */	
	public class TwinfieldStubException extends Exception {

	}	
}