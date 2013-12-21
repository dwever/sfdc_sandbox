public class TwinfieldFinancialMutationDetailResponse {
	public LineResponse lineResponse;
	public Dim1Response dim1Response;
	public Dim2Response dim2Response;
	public ValueResponse valueResponse;
	public DebitCreditResponse debitCreditResponse;
	public RateResponse rateResponse;
	public BaseValueResponse baseValueResponse;
	public MatchLevelResponse matchLevelResponse;
	public CustomerSupplierResponse customerSupplierResponse;
	public OpenValueResponse openValueResponse;
	public OpenBaseValueResponse openBaseValueResponse;
	public MatchStatusResponse matchStatusResponse;
	public VatTotalResponse vatTotalResponse;
	public VatBaseTotalResponse vatBaseTotalResponse;
	public UserDefinedTagResponse userDefinedTagResponse;
	
	public TwinfieldFinancialMutationDetailResponse() {
		this.baseValueResponse = new BaseValueResponse(); 
		this.customerSupplierResponse = new CustomerSupplierResponse();
		this.debitCreditResponse = new DebitCreditResponse();
		this.dim1Response = new Dim1Response();
		this.dim2Response = new Dim2Response();
		this.lineResponse = new LineResponse();
		this.matchLevelResponse = new MatchLevelResponse();
		this.matchStatusResponse = new MatchStatusResponse();
		this.openBaseValueResponse = new OpenBaseValueResponse();
		this.openValueResponse = new OpenValueResponse();
		this.rateResponse = new RateResponse();
		this.valueResponse = new ValueResponse();
		this.vatBaseTotalResponse = new VatBaseTotalResponse();
		this.vatTotalResponse = new VatTotalResponse();
		this.userDefinedTagResponse = new UserDefinedTagResponse();
	}
	
	public class LineResponse {
		public String lineId;
		public String lineType;
		public TwinfieldResponseMessage message;
		
	}
	public class Dim1Response {
		public String dim1Value;
		public String dim1Name;
		public String dim1ShortName;
		public String dim1Type;
		public String dim1InUse;
		public String dim1VatCode;
		public String dim1VatObligatory;
		public TwinfieldResponseMessage message;
	}
	public class Dim2Response {
		public String dim2Value;
		public String dim2Name;
		public String dim2ShortName;
		public String dim2Type;
		public String dim2InUse;
		public String dim2VatCode;
		public String dim2VatObligatory;
		public TwinfieldResponseMessage message;
	}
	public class ValueResponse {
		public String valueValue;
		public TwinfieldResponseMessage message;
	}
	public class DebitCreditResponse {
		public String debitCreditValue;
		public TwinfieldResponseMessage message;
	}		
	public class RateResponse {
		public String rateValue;
		public TwinfieldResponseMessage message;
	}
	public class BaseValueResponse {
		public String baseValueValue;
		public TwinfieldResponseMessage message;
	}
	public class MatchLevelResponse {
		public String matchLevelValue;
		public TwinfieldResponseMessage message;
	}
	public class CustomerSupplierResponse {
		public String customerSupplierValue;
		public TwinfieldResponseMessage message;
	}
	public class OpenValueResponse {
		public String openValueValue;
		public TwinfieldResponseMessage message;
	}
	public class OpenBaseValueResponse {
		public String openBaseValueValue; 
		public TwinfieldResponseMessage message;
	}
	public class MatchStatusResponse {
		public String matchStatusValue;
		public TwinfieldResponseMessage message;
	}
	public class VatTotalResponse {
		public String vatTotalValue;
		public TwinfieldResponseMessage message;
	}
	public class VatBaseTotalResponse {
		public String vatBaseTotalValue;
		public TwinfieldResponseMessage message;
	}
	public class UserDefinedTagResponse {
		public String userDefinedTagValue;
		public TwinfieldResponseMessage message;
	}
	
}