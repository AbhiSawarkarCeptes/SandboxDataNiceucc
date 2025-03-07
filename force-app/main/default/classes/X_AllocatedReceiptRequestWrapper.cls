public class X_AllocatedReceiptRequestWrapper {
	public class X_AllocatedReceiptJSON {
		public String allocationRef;	
		public String allocationDate;	
		public String allocationType;	
		public Decimal allocationValue;
		public String entityCode;	
		public String description;	
		//public String docGuid;	
		public String allocationMode;
		//public X_ReceiptAllocationARDetailLines[] receiptAllocationARDetailLines;
		//public X_ReceiptAllocationARAdvanceLines[] receiptAllocationARAdvanceLines;
	}
	/*public class X_ReceiptAllocationARDetailLines {
		public String projectCode;	
		public String invoiceDocumentReference;	
		public String invoiceDocGuid;	
		public Decimal allocationAmount;
		public boolean computeResidual;
	}
	public class X_ReceiptAllocationARAdvanceLines {
		public Integer lineNo;	
		public String projectCode;	
		public Decimal advanceAmount;	
		public String description;	
		public String entityRef;	
		public String entityDate;	
		public String vatType;	
		public String vatCode;	
		public Decimal amountEligible;	
		public Decimal vatAmount;
	}*/
}