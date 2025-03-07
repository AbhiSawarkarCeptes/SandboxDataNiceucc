public class CancelPaymentRequest1Hr {
    @InvocableMethod
    public static void email1Hr(List<payment_request__c> prList) {
        List<Id> PrIdList = new List<Id>();
        Payment_Request__c firstPr = [SELECT ID,Email__c,Sales_Manager__c,Status__c,Unit__c,Name__c,CreatedBy.Name,
                                      Unit__r.Name,Payment_Request__c,OwnerId
                                      FROM Payment_Request__c where id =: prList[0].id
                                     ];
        
        if(firstPr.payment_request__c == null){
            PrIdList.add(firstPr.id);
        }else{
            Payment_Request__c secondPr  = [select id,Email__c,Sales_Manager__c,Status__c,Unit__c,Name__c,CreatedBy.Name,
                                      Unit__r.Name,Payment_Request__c,OwnerId from Payment_Request__c where ID =: firstPr.payment_request__c];
            if((firstPr.Status__c == 'Approved' || firstPr.Status__c == 'Submitted to Accounts for Amount Confirmation') && (secondPr.Status__c == 'Approved' || secondPr.Status__c == 'Submitted to Accounts for Amount Confirmation')){
                
            }else{
                PrIdList.add(firstPr.Id);
                PrIdList.add(secondPr.Id);
            }
        }

        List<Payment_Request__c> prToReject = [SELECT ID,Email__c,Sales_Manager__c,Status__c,Unit__c,Name__c,CreatedBy.Name,Name,
                                               Unit__r.Name,Payment_Request__c,Owner.Email,OwnerId
                                               FROM Payment_Request__c where id IN : PrIdList order by createddate asc
                                              ];

        if(prToReject.size()>0){
             if(prToReject.size()>0){
                List<ProcessInstance> pendingAprrovalProcessList = [Select Id, TargetObjectId, Status From ProcessInstance Where Status='Pending' and TargetObjectId IN : prToReject];
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
                for(Payment_Request__c p : prToReject){
                    p.Status__c = 'Rejected by System';
                }
                update prToReject;
            }
             Unit__c unitList = [SELECT ID,Unit_Status__c,Booking__c,Booking__r.Status__c,Customers__c FROM Unit__c Where id =: prToReject[0].Unit__c];
            if(unitList !=null && (unitList.Booking__c == null || unitList.Booking__r.Status__c == 'Cancelled')){        
                unitList.Unit_Status__c = 'Available';  
                unitList.Reason_for_Cancellation__c = 'Non-submission of secondary mode payment request for '+ prToReject[0].Name +' within 3 hours.';                       
                update unitList;   

                user u = [select id,email,Manager.email,Manager.Manager.email from User where Id =: prToReject[0].OwnerId];
    
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Unit '+ prToReject[0].Unit__r.Name +', released to availability in Sales Force');
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();

                String body =  'Dear ' +prToReject[0].Name__c+ ',<br/><br/>' +                        
                    
                    'Please note that your request to hold unit '+prToReject[0].Unit__r.Name+
                    '  has elapsed 3 hours. Due to non-submission of secondary mode payment request in 3 hours, this unit has been released back to availability.<br/><br/>'+
                    'Kindly check Sales Force for unit availability.<br/><br/>'+
                    'Regards,<br/><br/>'+
                    'Salesforce';	
                
                if(prToReject[0].Owner.Email != null && prToReject[0].Owner.Email != ''){   
                    lstStringtoaddress.add(prToReject[0].Owner.Email);  
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
                if(prToReject[0].Owner.Email != null && prToReject[0].Owner.Email != ''){
                    Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
                }  
            }
        }
    }
}