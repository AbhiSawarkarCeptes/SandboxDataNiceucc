public class X_DemandRequestWrapper {
    public class X_DemandJSON{
        public String companyCode; 	//No Mapping
        public String branchCode;	//Branch_Code__c in Demand Object
        public String projectCode;	//No Mapping
        public String entityCode;	//No Mapping
        public String documentReference;	// ? need Clarity
        public Datetime documentDate;	// createdDate in Demand Object
        public String docCurrencyCode; // No Mapping
        public Decimal totalLineAmount; // No Mapping
        public Decimal totalVATAmount;	// No Mapping (Mentioned as to be calculated)
        public String clientInvoiceRef;	//Need clarity
        public Datetime clientInvoiceDate;	// CreatedDate in Demand object
        public String paymentTermsCode;	// No Mapping
        public Date dueDate;	//Due_Date__c in Demand Object
        public String remarks;	//No Mapping
        public Decimal documentvalue;
        public X_invoiceLine[] invoiceLines;
        public X_invoiceVAT[] invoiceVAT;
    }
   public class X_invoiceLine {
        public Integer lineNo;	// Need Clarity
        public String lineType;	// Default Value : Item
        public String lineDescription;	//No Mapping
        public String resourceCode;	// No Mapping
        public Integer accountNumber;	//Need clarity
        public String subledgerAccount;	
        public String uom;	
        public Integer quantity;	
        public Integer unitPrice;	
        public Decimal lineAmount;	
        public String additionalInfo;	
        public String revenueHead;	
        public String revenueCode;	// Default Value : 420117
        public String phaseCode;	
        public String blockCode;	
        public String unitCode;	
    }
    public class X_invoiceVAT {
        public Integer lineNo;	
        public String description;	//Concatenation – Customer Name + Milestone Description + Booking Ref + Unit
        public String vatType;	//VATD
        public String vatCode;	//VAT_Code__c in Demand object
        public Decimal vatRate;	
        public Decimal vatAmount;	
        public String additionalInfo;	
        public Decimal AmountEligible;
    }
}