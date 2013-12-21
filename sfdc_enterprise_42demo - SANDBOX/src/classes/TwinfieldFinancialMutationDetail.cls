public class TwinfieldFinancialMutationDetail {
	public String lineType {
		get; set;
	}
	public String destOffice {
		get; set;
	}
	public String dim1 {
		get; set;
	}
	public String dim2 {
		get; set;
	}
	public String dim3 {
		get; set;
	}
	public String dim4 {
		get; set;
	}
	public String dim5 {
		get; set;
	}
	public String dim6 {
		get; set;
	}
	public String invNumber {
		get; set;
	}	
	public String freeChar {
		get; set;
	}
	public String freeText1 {
		get; set;
	}
	public String freeText2 {
		get; set;
	}
	public String freeText3 {
		get; set;
	}
	public String debitcredit {
		get; set;
	}
	public String description {
		get; set;
	}
	public Date dueDate {
		get; set;
	}
	public String lineValue {
		get; set;
	}
	public Integer lineNum {
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
	public String vatCode {
		get; set;
	}	
	public String userDefinedTag {
		get; set;
	}
}