/* --------------------------------------------------------------------------------------
// This class is used to construct Twinfield Salesinvoicelines
-------------------------------------------------------------------------------------- */
public class TwinfieldSalesInvoiceline {
	public String allowDiscountOrPremium {
		//
		// True or False
		get; set;
	}
	public String article {
		get; set;
	}
	public String subArticle {
		get; set;
	}
	public String quantity {
		get; set;
	}
	public String units {
		get; set;
	}
	public String unitsPriceExcl {
		get; set;
	}
	public String unitsPriceInc {
		get; set;
	}
	public String vatCode {
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
	public String description {
		get; set;
	}
	public Date performanceDate {
		get; set;
	}
	//
	// Returns the converted date to Twinfield format (YYYYMMDD)
	public String performanceDateTwinfield {
		get {
			performanceDateTwinfield = '';
			if(this.performanceDate != null) {
				performanceDateTwinfield = TwinfieldConversion.sfDateToTfDate(this.performanceDate);	
			}
			return performanceDateTwinfield;
		}
		private set;
	}
	public String valueExcl {
		get;
	}
	
	public String vatValue {
		get;
	}
	public String valueInc {
		get;
	}
	
	public String userDefinedTag {
		get; set;
	}
	public TwinfieldSalesInvoiceline() {
	}
}