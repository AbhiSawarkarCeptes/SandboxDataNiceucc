@RestResource(urlMapping = '/getStatementOfAccount')
global class Mobile_getStatementOfAccount{

    @HttpPost
    global static HttpResponseWrapper getStatementOfAccount(String bookingId){
        ResponseBodyWrapper statementOfAccountWrapper = new ResponseBodyWrapper();
        try {

            List<Booking__c> bookingList = [Select id, Agreement_Value__c,Total_On_Account_Money__c,Registration_Amount_Paid__c,DLD_Amount__c,Credit_Card_Charges_Colleceted__c, VAT_Reduction_From_PPP__c from Booking__c where id= :bookingId LIMIT 1];
            if(bookingList.size() > 0){
                statementOfAccountWrapper.purchasePrice = bookingList[0].Agreement_Value__c != null ? bookingList[0].Agreement_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
                statementOfAccountWrapper.regAmountPaid = bookingList[0].Registration_Amount_Paid__c != null ? bookingList[0].Registration_Amount_Paid__c.setScale(2, RoundingMode.HALF_UP) : 0;
                statementOfAccountWrapper.totalAmount = statementOfAccountWrapper.purchasePrice + (bookingList[0].DLD_Amount__c != null ? bookingList[0].DLD_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0);
                statementOfAccountWrapper.paidAmount = bookingList[0].Total_On_Account_Money__c != null ? bookingList[0].Total_On_Account_Money__c.setScale(2, RoundingMode.HALF_UP) : 0;
                List<PayWrapper> demandWrapperList = new List<PayWrapper>();
                List<PayWrapper> receiptWrapperList = new List<PayWrapper>();
                for(Demand__c demandRec : [SELECT Id, Name, Total_Amount_Demanded__c, Demand_Status__c, Milestone_Name__c, GL_Date__c, Due_Date__c, Invoice_Date__c, Debit_Type__c, Payment_Milestones__c, Total_Tax_Demanded__c,Installment__c 
                                            FROM Demand__c WHERE Debit_Type__c != 'DLD Charges' and Booking__c = :bookingId ORDER BY GL_Date__c]){
                    PayWrapper demandWrapRec = new PayWrapper();
                    demandWrapRec.name = demandRec.Name;
                    demandWrapRec.createdDate = demandRec.Invoice_Date__c;
                    demandWrapRec.dueDate = demandRec.Due_Date__c;
                    demandWrapRec.isReversed = demandRec.Demand_Status__c != null ? true : false ;
                    if(demandRec.Total_Amount_Demanded__c != null && demandRec.Total_Tax_Demanded__c != null) { 
                        demandWrapRec.amount = (Decimal)demandRec.Total_Amount_Demanded__c + (Decimal)demandRec.Total_Tax_Demanded__c;
                    }
                    demandWrapRec.installment = demandRec.Installment__c != null && String.isNotBlank(demandRec.Installment__c) ? demandRec.Installment__c : null;
                    demandWrapRec.milesstoneName = demandRec.Milestone_Name__c != null && String.isNotBlank(demandRec.Milestone_Name__c) ? demandRec.Milestone_Name__c : null;
                    demandWrapRec.debitType = demandRec.Debit_Type__c != null && String.isNotBlank(demandRec.Debit_Type__c) ? demandRec.Debit_Type__c : null;
                    
                    demandWrapperList.add(demandWrapRec);
                }
                if(demandWrapperList.size() > 0){
                    statementOfAccountWrapper.demandList = demandWrapperList;
                }
                for(Receipt__c receiptRec : [SELECT Id, Name, CreatedDate, Mode__c, Cheque_DD_Date__c, GL_Date__c, Cheque_DD__c, DraweeBank__c,Currency__c, Amount_Rs__c, Receipt_Number__c, Receipt_Status__c, Demand__c, Demand__r.Name, Description__c,Registration_Collection_Control_Report__c,Debit_Account__r.Name FROM Receipt__c 
                                    WHERE Booking__c = :bookingId AND Receipt_Status__c IN('Cleared') AND (Mode__c !='Credit Note' or Debit_Account__r.Name in ('Commission Adjustment Credit','Credit Card Transactions','Discount/rebate credit note','Receipt transfer credit (swap)','RECEIVABLE/PAYABLE ADJUSTMENT','Unearned Revenue','Interest charges','Broker underwriting adjustment','Cheque Dishonored charges (Miscellaneous Income)','DIB–AED–ES–CV–Main A/c–SLLC - 001582194865001')) ORDER BY GL_Date__c]){
                    PayWrapper receiptWrapRec = new PayWrapper();  
                    receiptWrapRec.name = receiptRec.Name;   
                    receiptWrapRec.createdDate = Date.newInstance(receiptRec.CreatedDate.year(), receiptRec.CreatedDate.month(), receiptRec.CreatedDate.day());
                    receiptWrapRec.amount = receiptRec.Amount_Rs__c != null ? receiptRec.Amount_Rs__c.setScale(2, RoundingMode.HALF_UP) : 0;
                    receiptWrapperList.add(receiptWrapRec);
                }
                if(receiptWrapperList.size() > 0){
                    statementOfAccountWrapper.receiptList = receiptWrapperList;
                }

                return prepareResponse(statementOfAccountWrapper,'Operation Successfull','Success',200,true);             
            }

            return prepareResponse(null,'No data found','No Data Found',400,false);
        } catch (Exception ex) {
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'Mobile_getStatementOfAccount';
            insert logError;
            return prepareResponse(null,ex.getMessage(),'Error',400,false);
        }

    }

    public static HttpResponseWrapper prepareResponse(ResponseBodyWrapper rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }
    
    public class ResponseBodyWrapper{
        public Decimal purchasePrice;
        public Decimal regAmountPaid;
        public Decimal totalAmount;
        public Decimal paidAmount;
        public List<PayWrapper> demandList;
        public List<PayWrapper> receiptList;
    }

    public class PayWrapper{
        public String name;
        public Date createdDate;
        public Date dueDate;
        public Decimal amount;
        public String milesstoneName;
        public String installment;
        public Boolean isReversed;
        public String debitType;
    }
    
    global class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public ResponseBodyWrapper data;
        public Boolean success;
        public String Message;
    }

}