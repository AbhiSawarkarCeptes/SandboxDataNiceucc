@RestResource(urlMapping = '/getPaymentReceipts')
global class Mobile_PaymentReceipts{
    @HttpPost
    global static void getPaymentReceipts(String bookingId){
        List<ResponseBodyWrapper> paymentReceiptsWrapper = new List<ResponseBodyWrapper>();
        RestResponse res = RestContext.response; 
        String responseString = '';
        String errorMessage = '';
        try{
           /* if(bookingId != null && String.isNotBlank(bookingId)){
                
                 List<Payment_Request__c> PaymentReqList = [select id,name,Mode__c,Amount__c, createddate,Booking__r.Unit__r.Name,booking__r.Project__r.Name  from Payment_Request__c  where Booking__c = :bookingId  and Receipt_Created__c = false ]; 
                  if(PaymentReqList.size() > 0){
                    for(Payment_Request__c paymentRec : PaymentReqList){
                        ResponseBodyWrapper payReceipt = new ResponseBodyWrapper();   
                    	payReceipt.id = paymentRec.Id;
                        payReceipt.name = paymentRec.name;
                        payReceipt.mode = paymentRec.Mode__c;
                        payReceipt.receiptNumber = paymentRec.name;
                        payReceipt.totalAmount = paymentRec.Amount__c;
                        payReceipt.createddate = date.newinstance(paymentRec.createddate.year(), paymentRec.createddate.month(), paymentRec.createddate.day());
                        payReceipt.unitName = paymentRec.Booking__r.Unit__r.Name;
                        payReceipt.projectName = paymentRec.Booking__r.Project__r.Name;
                        payReceipt.prstatus = 'In Progress';
                        paymentReceiptsWrapper.add(payReceipt);
                    }
                  }
                List<Receipt__c> receiptRecList = [select id,name,Mode__c,Receipt_Number__c,Total_Amount__c,createddate,Booking__r.Unit__r.Name,booking__r.Project__r.Name  from Receipt__c where Booking__c = :bookingId and Receipt_Status__c  ='Cleared' ];//include the clear status in the where condition, get confirmation from Abdul
                if(receiptRecList.size() > 0){
                    for(Receipt__c receiptRec : receiptRecList){
                        ResponseBodyWrapper payReceipt = new ResponseBodyWrapper();   
                    	payReceipt.id = receiptRec.Id;
                        payReceipt.name = receiptRec.name;
                        payReceipt.mode = receiptRec.Mode__c;
                        payReceipt.receiptNumber = receiptRec.Receipt_Number__c;
                        payReceipt.totalAmount = receiptRec.Total_Amount__c;
                        payReceipt.createddate = date.newinstance(receiptRec.createddate.year(), receiptRec.createddate.month(), receiptRec.createddate.day());
                        payReceipt.unitName = receiptRec.Booking__r.Unit__r.Name;
                        payReceipt.projectName = receiptRec.Booking__r.Project__r.Name;
                        payReceipt.prstatus = 'Completed';
                        paymentReceiptsWrapper.add(payReceipt);
                    }                
                    // return prepareResponse(paymentReceiptsWrapper,'Operation Successfull','Success',200,true);
                    responseString = (prepareResponse(paymentReceiptsWrapper,'Operation Successfull','Success',200,true)).toString().replace('"','');
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(paymentReceiptsWrapper,'Operation Successfull','Success',200,true)));
                    res.statusCode = 200;  
                }
                else{
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                    res.statusCode = 400;
                }
            }
            else{
                res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                res.statusCode = 400;
            }
        	// return prepareResponse(null,'No data found','No Data Found',400,false);
        	// 
        */
            
        if(bookingId != null && String.isNotBlank(bookingId)){
            Datetime halfHourBack = Datetime.now().addMinutes(-30);
	
              List<Payment_Request__c> PaymentReqList = [select id,name,Mode__c,Amount__c, createddate,Booking__r.Unit__r.Name,booking__r.Project__r.Name, Status__c  from Payment_Request__c  where Booking__c = :bookingId  and Receipt_Created__c = false ]; 
                  if(PaymentReqList.size() > 0){
                    for(Payment_Request__c paymentRec : PaymentReqList){
                        if(paymentRec.mode__c == 'Website' && paymentRec.createddate < halfHourBack) {
                            CONTINUE;
                        }
                        ResponseBodyWrapper payReceipt = new ResponseBodyWrapper();   
                    	payReceipt.id = paymentRec.Id;
                        payReceipt.name = paymentRec.name;
                        payReceipt.mode = paymentRec.Mode__c;
                        payReceipt.receiptNumber = paymentRec.name;
                        payReceipt.totalAmount = paymentRec.Amount__c;
                        payReceipt.createddate = date.newinstance(paymentRec.createddate.year(), paymentRec.createddate.month(), paymentRec.createddate.day());
                        payReceipt.unitName = paymentRec.Booking__r.Unit__r.Name;
                        payReceipt.projectName = paymentRec.Booking__r.Project__r.Name;
                        payReceipt.prstatus = paymentRec.Status__c == 'Rejected by System' || paymentRec.Status__c == 'Rejected by Accounts' || paymentRec.Status__c =='Rejected by Sales Ops' ? 'Rejected' : 'In Progress'; // include the Rejected status here - Aravindan
                        paymentReceiptsWrapper.add(payReceipt);
                    }
                  }
            
             List<Receipt__c> receiptRecList = [select id,name,Mode__c,Receipt_Number__c,Total_Amount__c,createddate,Booking__r.Unit__r.Name,booking__r.Project__r.Name  from Receipt__c where Booking__c = :bookingId and Receipt_Status__c  ='Cleared' ];//include the clear status in the where condition, get confirmation from Abdul
                if(receiptRecList.size() > 0){
                    for(Receipt__c receiptRec : receiptRecList){
                        ResponseBodyWrapper payReceipt = new ResponseBodyWrapper();   
                    	payReceipt.id = receiptRec.Id;
                        payReceipt.name = receiptRec.name;
                        payReceipt.mode = receiptRec.Mode__c;
                        payReceipt.receiptNumber = receiptRec.Receipt_Number__c;
                        payReceipt.totalAmount = receiptRec.Total_Amount__c;
                        payReceipt.createddate = date.newinstance(receiptRec.createddate.year(), receiptRec.createddate.month(), receiptRec.createddate.day());
                        payReceipt.unitName = receiptRec.Booking__r.Unit__r.Name;
                        payReceipt.projectName = receiptRec.Booking__r.Project__r.Name;
                        payReceipt.prstatus = 'Completed';
                        paymentReceiptsWrapper.add(payReceipt);
                    }  
                }
            
            if(receiptRecList.size() > 0 || PaymentReqList.size() > 0){
                responseString = (prepareResponse(paymentReceiptsWrapper,'Operation Successfull','Success',200,true)).toString().replace('"','');
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(paymentReceiptsWrapper,'Operation Successfull','Success',200,true)));
                    res.statusCode = 200; 
            }else{
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                    res.statusCode = 400;
                }            		
            
        }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('getPaymentReceipts','Mobile_getPaymentReceipts',bookingId,responseString,errorMessage,res.statusCode);
    }
    
    public static HttpResponseWrapper prepareResponse(list<responseBodyWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }
    
    public class ResponseBodyWrapper{
        public String id;
        public String name;
        public String mode;
        public String receiptNumber;
        public Decimal totalamount;
        public Date createdDate;
        public String unitName;
        public String projectName;
        public string prstatus;
    }
    
    global class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public List<responseBodyWrapper> data = new list<responseBodyWrapper>();
        public Boolean success;
        public String Message;
    }
}