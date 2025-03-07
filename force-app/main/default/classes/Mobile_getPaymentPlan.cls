@RestResource(urlMapping = '/getPaymentPlan')
global class Mobile_getPaymentPlan{

    @HttpPost
    global static void getPaymentPlan(String bookingId) {
        List<responseBodyWrapper> paymentPlanWrapper = new List<responseBodyWrapper>();
        RestResponse res = RestContext.response; 
        String responseString = '';
        String errorMessage = '';
        try {
            if(bookingId != null && String.isNotBlank(bookingId)){
                List<Booking__c> bookingRec = [Select id, Quotation__c from Booking__c where Id = :bookingId LIMIT 1];
                if(bookingRec.size() > 0 && bookingRec[0].Quotation__c != null){
                    paymentPlanWrapper = getPaymentMilestones(bookingRec[0].Quotation__c);    
                    //return prepareResponse(bookingJourneyWrapper,'Operation Successfull','Success',200,true);
                    responseString = (prepareResponse(paymentPlanWrapper,'Operation Successfull','Success',200,true)).toString().replace('"','');
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(paymentPlanWrapper,'Operation Successfull','Success',200,true)));
                    res.statusCode = 200;  
                }
                else{
                    //return prepareResponse(null,'No data found','No Data Found',400,false);
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                    res.statusCode = 400;
                }
                //return prepareResponse(paymentPlanWrapper,'Operation Successfull','Success',200,true);
            }
            else{
                //return prepareResponse(null,'No data found','No Data Found',400,false);
                res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                res.statusCode = 400;
            }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('getPaymentPlan','Mobile_getPaymentPlan',bookingId,responseString,errorMessage,res.statusCode);
    }

    public static List<responseBodyWrapper> getPaymentMilestones(String quotationId){
        List<responseBodyWrapper> paymentPlanWrapper = new List<responseBodyWrapper>();
        String queryString = '';
        List<Quotation__c> qList = new List<Quotation__c>(); 
        List<Payment_Milestones__c> pmList  = new List<Payment_Milestones__c>();
        if(quotationId != null){
            qList = [Select id, Unit__r.Project__r.Name, Unit__r.Tower__c from Quotation__c where Id = :quotationId];
            Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__c);
            Map<String,Integer> avChargesSeqMap = new Map<String, Integer>();
            
            if(projChargesMap.size() > 0){
                Integer seq = 1;
                String chgName = '';
                //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
                for(String chargeName : projChargesMap.keySet()) {
                    chgName = projChargesMap.get(chargeName).ChargeBucket__c;
                    if(chgName.equalsIgnoreCase('Agreement Value')) {
                        avChargesSeqMap.put(chargeName, Seq);                    
                    }                              
                    seq++;
                }
                avChargesSeqMap.put('Interest On Common Area Charges',seq);
                
                for(Integer i = 1; i<=25; i++) {
                    queryString += 'Charge' + i + 'Name__c'   + ',';
                    queryString += 'Charge' + i + 'Percentage__c'  + ',';
                    queryString += 'C' + i + '_Amount__c' + ','; 
                    queryString += 'C' + i + '_CGST__c'   + ','; 
                    queryString += 'C' + i + '_SGST__c'   + ','; 
                }
                queryString = 'SELECT ' + queryString  + ' Id, Name,Installment__c, Project_Construction_Stages__c, Project_Construction_Stages__r.Name , Milestone_Name__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c FROM Payment_Milestones__c WHERE Quotation__c = \'' + quotationId + '\' order by Name ASC' ;                                                                     
                pmList = Database.Query(queryString);
            }
            if(pmList.size() > 0){
              /*  Decimal totalAmt = 0;
                String amtString = '';*/
                for(Payment_Milestones__c pm: pmList){
                     Decimal totalAmt = 0; //Added by Ananth reverify Aravindan
               		 String amtString = '';
                    for(Integer i : avChargesSeqMap.values()){
                        totalAmt += (Decimal)pm.get('C' +i + '_Amount__c' );
                        amtString = InventoryCostServices.InFormat(totalAmt);  
                        //totalTax += (Decimal)pm.get('C' + i + '_CGST__c' ) + (Decimal)pm.get('C' + i + '_SGST__c' );                            
                    }
                    responseBodyWrapper payplanWrap = new responseBodyWrapper();
                    payplanWrap.Name = pm.Name;
                    payplanWrap.installment = pm.Installment__c;
                    payplanWrap.amount = amtString;
                    payplanWrap.description = pm.Milestone_Name__c;
                    payplanWrap.dueDate = pm.Milestone_Due_Date__c;
                    payplanWrap.chargePercent = pm.Charge1Percentage__c;
                    //payplanWrap.paymentDate = Need Discussions
                    //payplanWrap.paymentStatus = 'Paid'; // Need to fix this. 
                    paymentPlanWrapper.add(payplanWrap);
                }
            }
        }

        return paymentPlanWrapper;
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
    
    public class responseBodyWrapper{
        public String name;
        public String description;
        public String amount;
        public Date dueDate;
        public String installment;
        public Decimal chargePercent;
       // public Date paymentDate;
        public String paymentStatus;
    }
    
    global class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public List<responseBodyWrapper> data = new list<responseBodyWrapper>();
        public Boolean success;
        public String Message;
    }

}