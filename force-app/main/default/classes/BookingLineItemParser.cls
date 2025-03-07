public class BookingLineItemParser {

	public String amountPaidByCustomer;
	public String auditapproveddate;
	public String bookingDate;
	public String bookingId;
	public String bookingIdVal;
	public String bookingName;
	public String bucketColor;
	public String cancellationAllocation;
	public String category;
	public String collected;
	public Double collectedpercentage;
	public String commentsHistory;
	public String customerName;
	public String demands;
	public String due;
	public Double duepercentage;
	public String finalNoticeReceivedDate;
	public String finalNoticeReviewLink;
	public String finalNoticeSentDate;
	public String finalNoticeSentDateCourier;
	public String finalNoticeStatus;
	public Integer forfeitedAmount;
	public String forfeitureNoticeSentDateCourier;
	public String forfeitureNoticeSentDate;
	public String fullDue;
	public String lastCallAttemptStatus;
	public String milestoneDue;
	public String primaryMobileNumber;
	public String saleValue;
	public String soaLink;
	public String spaexecuted;
	public String unitId;
	public String unitName;
    public String commentsremarks;
    public String terminationremarks;
	public String customerNameArabic;
	public String customerAddressArabic;
	public String projectCompletionPercentageArabic;
	public String developerFinalNoticeSentDateCourier;
	public String developerFinalNoticeStatus;
	public String terminationProcessStatus;
	public String terminationCompletionDate;
	public String label;
	public String value;
	public String dldNoticeStatus;
	public Boolean allowPR;
	public String dldNoticeStatusCategory;

	public static List<BookingLineItemParser> parse(String json) {
		return (List<BookingLineItemParser>) System.JSON.deserialize(json, List<BookingLineItemParser>.class);
	}
}