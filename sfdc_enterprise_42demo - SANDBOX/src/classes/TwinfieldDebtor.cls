/* --------------------------------------------------------------------------------------
// This class is used to construct Twinfield Debtors
-------------------------------------------------------------------------------------- */
public class TwinfieldDebtor {
	public String debtorName {
		get;
		private set;
	}
	public String debtorNumber {
		get; 
		private set;
	}
	public TwinfieldDebtor(String dName, String dNumber) {
		this.debtorName = dName;
		this.debtorNumber = dNumber;
	}
}