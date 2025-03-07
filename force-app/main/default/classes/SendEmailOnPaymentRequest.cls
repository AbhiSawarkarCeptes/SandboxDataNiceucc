public class SendEmailOnPaymentRequest {
    
    @InvocableMethod
    public static void insertBookings(List<Id> pr) {
        
        List<Payment_Request__c> paymentRequest = [SELECT ID,Email__c,Sales_Manager__c,Status__c,Unit__c,Name__c,CreatedBy.Name,Name,
                                             Unit__r.Name,Owner.Email,OwnerId,Sales_Manager__r.managerid,createdby.manager.Id
                                             FROM Payment_Request__c where id =:pr[0] OR Payment_Request__c =:pr[0]
                                            ];
        
        if(paymentRequest.size()>0){
            
            user u = [select id,email,Manager.email,Manager.Manager.email from User where ID =: paymentRequest[0].OwnerId];
            
            Unit__c unitList = [SELECT ID,Unit_Status__c,Booking__c,Booking__r.Status__c,Customers__c,Puchase_Price__c,Unit_Hold_min_percentage__c FROM Unit__c Where id =: paymentRequest[0].Unit__c];
            List<Unit_Hold_Min_Percentage_Mapping__mdt> minPercentageListMdt = [SELECT ID,Max_Purchase_Price__c,
            Unit_Hold_Min_Percentage__c
            FROM Unit_Hold_Min_Percentage_Mapping__mdt];

            
            unit_hold__c uh = new unit_hold__c();
            uh.sales_director__c = paymentRequest[0].Sales_Manager__r.managerid != null ? 
            paymentRequest[0].Sales_Manager__r.managerid : (paymentRequest[0].Sales_Manager__c != null ? paymentRequest[0].Sales_Manager__c : (paymentRequest[0].createdby.manager.Id != null ? paymentRequest[0].createdby.manager.Id : paymentRequest[0].createdbyId));
            uh.unit__c = paymentRequest[0].Unit__c;
            uh.status__c = 'active';
            uh.Payment_Request__c = paymentRequest[0].id;
            uh.Reason__c = 'NSA not submitted in 24 hours';
            
            insert uh;
            
            if(paymentRequest.size()>0){
                List<ProcessInstance> pendingAprrovalProcessList = [Select Id, TargetObjectId, Status From ProcessInstance Where Status='Pending' and TargetObjectId IN : paymentRequest];
                List<Id> processInstanceIDs = new List<Id>();
                for(ProcessInstance processIns : pendingAprrovalProcessList){
                    processInstanceIDs.add(processIns.Id);
                }
                
                List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId  FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :processInstanceIDs ];
                List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
                for(ProcessInstanceWorkitem work : workItems){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('Rejected by System'); 
                    req.setAction('Reject');
                    req.setWorkitemId(work.id);
                    allReq.add(req);
                }
                Approval.ProcessResult[] result =  Approval.process(allReq);
                for(Payment_Request__c p : paymentRequest){
                    p.Status__c = 'Rejected by System';
                }
                update paymentRequest;
            }

            if(unitList !=null && (unitList.Booking__c == null || unitList.Booking__r.Status__c == 'Cancelled')){        
                unitList.Unit_Status__c = 'Available';  
                unitList.Reason_for_Cancellation__c = 'Non-submission of New Sale Approval for payment request '+ paymentRequest[0].Name +' within 24 hours.';     
                if(!minPercentageListMdt.isEmpty()
                && unitList.Puchase_Price__c <= minPercentageListMdt[0].Max_Purchase_Price__c)   {
                    unitList.Unit_Hold_min_percentage__c = minPercentageListMdt[0].Unit_Hold_Min_Percentage__c;                   
                }           
                update unitList;
            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Unit '+ paymentRequest[0].Unit__r.Name +', released to availability in Sales Force');
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                
                String body =  'Dear ' +paymentRequest[0].Name__c+ ',<br/><br/>' +                        
                'Please note that your request to hold unit '+paymentRequest[0].Unit__r.Name+'  has elapsed 24 hours. Due to non-submission of new sale email in 24 hours, this unit has been released back to availability.<br/><br/>'+
                'Kindly check Sales Force for unit availability.<br/><br/>'+
                'Regards,<br/><br/>'+
                'Salesforce';   
                
                /*if(paymentRequest[0].Email__c!=null && paymentRequest[0].Email__c!=''){
                    lstStringtoaddress.add(paymentRequest[0].Email__c); 
                }*/
                
                if(u.Email != null && u.Email != ''){
                    lstStringtoaddress.add(u.Email);  
                }                   
                if(u.Manager.Email != null && u.Manager.Email != ''){
                    lstStringccaddress.add(u.Manager.Email);  
                }  
                if(u.Manager.Manager.Email != null && u.Manager.Manager.Email != ''){
                    lstStringccaddress.add(u.Manager.Manager.Email);  
                }  
                
                email.setToAddresses(lststringtoaddress);
                email.setccAddresses(lstStringccaddress);            
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');    
                if(paymentRequest[0].Email__c!=null && paymentRequest[0].Email__c!=''){
                    Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
                }
            }
        }
    }
    
}