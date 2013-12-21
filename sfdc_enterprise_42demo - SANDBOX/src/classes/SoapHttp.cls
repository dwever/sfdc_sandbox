/* --------------------------------------------------------------------------------------
// This class contains methods to call a SOAP service using Http classes.
-------------------------------------------------------------------------------------- */
public class SoapHttp {
	
	//
	// Send SOAP request over HTTP
	public static HttpResponse sendSOAPRequest(String body, String endPoint, Integer timeOut) {

		HTTP http = new HTTP();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
     	request.setMethod('POST');
		request.setTimeout(timeOut);
		request.setHeader('Content-Type' , 'text/xml; charset=utf-8');
		request.setBody(body);
		
		HttpResponse response = http.send(request);
		return response;
	}
}