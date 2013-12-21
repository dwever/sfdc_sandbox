/* --------------------------------------------------------------------------------------
// This class is used to construct Salesinvoices with Salesinvoicelines
-------------------------------------------------------------------------------------- */
public class TwinfieldSalesInvoice {
	public List<TwinfieldSalesInvoiceline> invoiceLines {
		get; set;
	}
	//
	// Contains debtor details
	public TwinfieldDebtor debtor {
		get; set;
	}
	public String office {
		get; set;
	}
	public String invoiceType {
		get; set;
	}
	public String invoiceNumber {
		get; set;
	}
	public String status {
		get; set;
	}
	public String customer {
		get {
			String debNum = '';
			if(this.debtor != null) {
				debNum = this.debtor.debtorNumber;
			}
			return debNum;
		}
	}
	public String currencyCode {
		get; set;
	}
	public String period {
		get; set;
	}
	public Date invoiceDate {
		get; set;
	}
	//
	// Returns the converted date to Twinfield format (YYYYMMDD)
	public String invoiceDateTwinfield {
		get {
			invoiceDateTwinfield = '';
			if(this.invoiceDate != null) {
				invoiceDateTwinfield = TwinfieldConversion.sfDateToTfDate(this.invoiceDate);	
			}
			return invoiceDateTwinfield;
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
	
	public String paymentMethod {
		/*
		- cash
		- bank
		- cheque
		- cashondelivery
		- DA; D/A or 'documents against acceptance'		
		*/
		get; set;
	}
	
	public String bank {
		get; set;
	}
	
	public String invoiceAddressNumber {
		get; set;
	}
	
	public String deliveryAddressNumber {
		get; set;
	}
	public String headerText {
		get; set;
	}
	public String footerText {
		get; set;
	}
	public String userDefinedTag {
		get; set;
	}
	public TwinfieldSalesInvoice() {
		
	}
}