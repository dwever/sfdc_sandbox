public class TwinfieldConversion {
	public static String sfDateToTfDate(Date inDate) {
		String outDate = '';
		String year = String.valueOf(inDate.year());
		String month = (String.valueOf(inDate.month()).length() == 2) ? String.valueOf(inDate.month()) : '0'+String.valueOf(inDate.month());
		String day = (String.valueOf(inDate.day()).length() == 2) ? String.valueOf(inDate.day()) : '0'+String.valueOf(inDate.day());
		outDate = year+month+day;
		return outDate;
	}
}