public class TwinfieldFinancialMutationResponse {
	public TwinfieldFinancialMutationDetailResponse[] responseLines;
	public TransactionResponse transactionResponse;
	public OfficeResponse officeResponse;
	public CodeResponse codeResponse;
	public PeriodResponse periodResponse;
	public CurrencyResponse currencyResponse;
	public DateResponse dateResponse;
	public DueDateResponse dueDateResponse;
	public InvoiceNumberResponse invoiceNumberResponse;
	public DescriptionResponse descriptionResponse;
	public OriginResponse originResponse; 
	public UserResponse userResponse;
	public NumberResponse numberResponse;
	public UserDefinedTagResponse userDefinedTagResponse;
	
	public TwinfieldFinancialMutationResponse() {
		this.transactionResponse = new TwinfieldFinancialMutationResponse.TransactionResponse();
		this.codeResponse = new TwinfieldFinancialMutationResponse.CodeResponse();
		this.currencyResponse = new TwinfieldFinancialMutationResponse.CurrencyResponse();
		this.dateResponse = new TwinfieldFinancialMutationResponse.DateResponse();
		this.descriptionResponse = new TwinfieldFinancialMutationResponse.DescriptionResponse();
		this.dueDateResponse = new TwinfieldFinancialMutationResponse.DueDateResponse();
		this.invoiceNumberResponse = new TwinfieldFinancialMutationResponse.InvoiceNumberResponse();
		this.numberResponse = new TwinfieldFinancialMutationResponse.NumberResponse();
		this.officeResponse = new TwinfieldFinancialMutationResponse.OfficeResponse();
		this.originResponse = new TwinfieldFinancialMutationResponse.OriginResponse();
		this.periodResponse = new TwinfieldFinancialMutationResponse.PeriodResponse();
		this.userDefinedTagResponse = new TwinfieldFinancialMutationResponse.UserDefinedTagResponse();
		this.userResponse = new TwinfieldFinancialMutationResponse.UserResponse();
		//
		// Init the detail lines
		this.responseLines = new List<TwinfieldFinancialMutationDetailResponse>();
	}
	//
	// Transaction header
	public class TransactionResponse {
		public String transactionResult;
		public String transactionRaiseWarning;
		public String transactionAutoBalanceVat;
		public String transactionLocation;
		public TwinfieldResponseMessage message;
		
	}
	public class OfficeResponse {
		public String officeValue;
		public String officeName;
		public String officeShortName;
		public TwinfieldResponseMessage message;
	}
	public class CodeResponse {
		public String codeValue;
		public String codeName;
		public String codeShortName;
		public TwinfieldResponseMessage message;
	}
	public class PeriodResponse {
		public String periodValue;
		public TwinfieldResponseMessage message;
	}
	public class CurrencyResponse {
		public String currencyValue;
		public TwinfieldResponseMessage message;
	}
	public class DateResponse {
		public String dateValue;
		public TwinfieldResponseMessage message;
	}
	public class DueDateResponse {
		public String dueDateValue;
		public TwinfieldResponseMessage message;
	}
	public class InvoiceNumberResponse {
		public String invoiceNumberValue;
		public TwinfieldResponseMessage message;
	}
	public class DescriptionResponse {
		public String descriptionValue;
		public TwinfieldResponseMessage message;
	}	
	public class OriginResponse {
		public String originValue;
		public TwinfieldResponseMessage message;
	}	
	public class UserResponse {
		public String userValue;
		public String userName;
		public String userShortName;
		public TwinfieldResponseMessage message;
	}	
	public class NumberResponse {
		public String numberValue;
		public TwinfieldResponseMessage message;
	}
	public class UserDefinedTagResponse {
		public String userDefinedTagValue;
		public TwinfieldResponseMessage message;
	}

}