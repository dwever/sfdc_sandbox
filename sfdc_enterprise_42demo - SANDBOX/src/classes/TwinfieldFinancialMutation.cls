public class TwinfieldFinancialMutation {
	public String transactionDestiny {
		get; set;
	}
	
	public List<TwinfieldFinancialMutationDetail> detailLines {
		get; set;
	}
	public String office {
		get; set;		
	}
	public String code {
		get; set;
	}
	public String dayBookNumber {
		get; set;
	} 
	public String period {
		get; set;
	}
	public String currencyCode {
		get; set;
	}
	public Date transactionDate {
		get; set;
	}
	//
	// Returns the converted date to Twinfield format (YYYYMMDD)
	public String transactionDateTwinfield {
		get {
			transactionDateTwinfield = '';
			if(this.transactionDate != null) {
				transactionDateTwinfield = TwinfieldConversion.sfDateToTfDate(this.transactionDate);	
			}
			return transactionDateTwinfield;
		}
		private set;
	}
	public Date currencyDate {
		get; set;
	}
	//
	// Returns the converted date to Twinfield format (YYYYMMDD)
	public String currencyDateTwinfield {
		get {
			currencyDateTwinfield = '';
			if(this.currencyDate != null) {
				currencyDateTwinfield = TwinfieldConversion.sfDateToTfDate(this.currencyDate);	
			}
			return currencyDateTwinfield;
		}
		private set;
	}
	public Date dueDate {
		get; set;
	}
	
	//
	// Returns the converted date to Twinfield format (YYYYMMDD)
	public String dueDateTwinfield {
		get {
			dueDateTwinfield = '';
			if(this.dueDate != null) {
				dueDateTwinfield = TwinfieldConversion.sfDateToTfDate(this.dueDate);	
			}
			return dueDateTwinfield;
		}
		private set;
	}
	public String invoiceNumber {
		get; set;
	}
	public String description {
		get; set;
	}
	public String statementNumber {
		get; set;
	}
	public String startValue {
		get; set;
	}
	public String closeValue {
		get; set;
	}
	public String userDefinedTag {
		get; set;
	}
	public String origin {
		get; set;
	}
	public String userCode {
		get; set;
	}
}