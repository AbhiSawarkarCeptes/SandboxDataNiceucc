public class LatePaymentWaiverController {
    
    @InvocableMethod (label='Send Notification')
    public static void sendNotification (List<Id> lpWaiverList){
        EmailTemplate e = [select id, HtmlValue, subject from EmailTemplate where DeveloperName =: 'LP_Waiver_Notification'];
        LP_Waiver__c lp = [select id,Booking__r.Unit__r.Name,Booking__r.Primary_Applicant_Name__c,
                           Booking__r.Total_On_Account_Money_With_Registration__c,Amount_Towards_Late_Penalty__c, 
                           LP_Amount_To_Be_Waived__c,Approved_Amount__c, CreatedDate, CreatedBy.Name, CreatedBy.Email from LP_Waiver__c where id =: lpWaiverList[0]];
        long ammountAllocatedTowardsDue = 0;
        
        DateTime dt = lp.CreatedDate;
        Date d = Date.newinstance(dt.year(), dt.month(), dt.day());
        string body = e.HtmlValue;
        if(lp.CreatedBy.Name != null){
        	body = body.replace('#CollectionExecutive#', lp.CreatedBy.Name);
        }
        if(lp.Booking__r.Unit__r.Name != null){
        	body = body.replace('#Unit#', lp.Booking__r.Unit__r.Name);
        }
        if(lp.Booking__r.Primary_Applicant_Name__c != null){
        	body = body.replace('#CustomerName#', lp.Booking__r.Primary_Applicant_Name__c);
        }
        if(lp.Booking__r.Total_On_Account_Money_With_Registration__c != null){
        	body = body.replace('#TotalCollectedAmount#', lp.Booking__r.Total_On_Account_Money_With_Registration__c.format());
        }
        if(lp.Booking__r.Total_On_Account_Money_With_Registration__c != null && lp.Amount_Towards_Late_Penalty__c != null){
            if(lp.Booking__r.Total_On_Account_Money_With_Registration__c > lp.Amount_Towards_Late_Penalty__c){
                ammountAllocatedTowardsDue = (long)lp.Booking__r.Total_On_Account_Money_With_Registration__c - (long)lp.Amount_Towards_Late_Penalty__c;
                body = body.replace('#AmountAllocatedTowardsDue#', ammountAllocatedTowardsDue.format());
            }
        }
        
        if(lp.Amount_Towards_Late_Penalty__c != null){
        	body = body.replace('#AmountTowardsLatePenalty#', lp.Amount_Towards_Late_Penalty__c.format());
        }
        if(lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0){
            body = body.replace('#LPWaiverRequested#', lp.Approved_Amount__c.format());
        }else if(lp.LP_Amount_To_Be_Waived__c != null){
        	body = body.replace('#LPWaiverRequested#', lp.LP_Amount_To_Be_Waived__c.format());
        }

        body = body.replace('#LPNoticeRaisedDate#', String.valueOf(d));
        string subject = e.subject;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setSubject(subject); 
        mail.setHtmlBody(body);
        list<string> toAddress = new list<string>{lp.CreatedBy.Email};
        mail.setToAddresses(toAddress);
        mail.setSaveAsActivity(false); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @AuraEnabled
    public static string createReceipt(string lpWaiverId){
        Account_Master__c amCredit = [select Id, Name from Account_Master__c where Name = 'Trade Receivable' LIMIT 1];
        Account_Master__c amDebit = [select Id, Name from Account_Master__c where Name = 'Discount/rebate credit note' LIMIT 1];
        LP_Waiver__c lp = [select id,Booking__c,Booking__r.Unit__r.Name,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__c,Booking__r.Unit__c,
                           Booking__r.Total_On_Account_Money_With_Registration__c,Amount_Towards_Late_Penalty__c,Booking__r.Opportunity__c, 
                           LP_Amount_To_Be_Waived__c,Approved_Amount__c, CreatedDate, CreatedBy.Name from LP_Waiver__c where id =: lpWaiverId];
        Receipt__c r = new Receipt__c();
        r.Debit_Account__c = amDebit.Id;
        r.Credit_Account__c = amCredit.Id;
        r.Booking__c  = lp.Booking__c;
        r.GL_Date__c = system.today();
        r.Receipt_Date__c = system.today();
        r.Cheque_DD_Date__c = system.today();
        r.Payment_Towards__c = 'Corporate Account';
        r.Banking__c = 'Payment Successful';
        r.Receipt_Status__c = 'Cleared';
        r.Registration_Collection_Control_Report__c = 0;
        r.Credit_Card_Charges__c =  (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Total_Amount__c = (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Amount_Rs__c = (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Mode__c = 'Credit Note';
        r.RemarksText__c = '';
        r.Project__c = lp.Booking__r.Project__c;
        r.Project_Unit__c = lp.Booking__r.Unit__c;
        r.Opportunity__c = lp.Booking__r.Opportunity__c;
        try{
            insert r;
            lp.Receipt__c = r.Id;
            update lp;
            return r.Id;
        }
        catch(Exception e){
            return 'Failure';
        }
    }
    
    @future
    public static void updateComments(List<Id> lpIds, List<Id> lpIdsToCheck){
        List<LP_Waiver__c> lpWaiverList = New List <LP_Waiver__c>();
        List<ProcessInstance> instances = [select Id, TargetObjectId from ProcessInstance where TargetObjectId in : lpIds];
        Map<Id,Id> lpProcessMap = new Map<Id,Id>();
        lpIds = new List<Id>();
        for(ProcessInstance pi : instances){
            lpProcessMap.put(pi.TargetObjectId,pi.Id); 
            lpIds.add(pi.Id);
        }
        
        List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId,CreatedDate from ProcessInstanceStep where ProcessInstanceId in : lpIds order by createddate asc];
        system.debug('VVK: '+instancesSteps.size());
        Map<Id,String> lpProcessStepMap = new Map<Id,String>();
        for(ProcessInstanceStep pis:instancesSteps){
            if(pis.Comments != null){
                string comment = pis.CreatedDate + ' -- ' + pis.Comments;
                lpProcessStepMap.put (pis.ProcessInstanceId, comment); 
            }
        }
        
        list<LP_Waiver__c> lpToUpdate = new list<LP_Waiver__c>();
        for(LP_Waiver__c l : [select Id,Description__c from LP_Waiver__c where Id IN: lpIdsToCheck]){
            if(lpProcessStepMap.get(lpProcessMap.get(l.Id)) != null){
                string descrip = l.Description__c;
                if(descrip != null && !descrip.contains(lpProcessStepMap.get(lpProcessMap.get(l.Id)))){
                    l.Description__c = l.Description__c + ' \n' + lpProcessStepMap.get(lpProcessMap.get(l.Id));
                    lpToUpdate.add(l);
                }
                if(descrip == null){
                    l.Description__c = lpProcessStepMap.get(lpProcessMap.get(l.Id));
                    lpToUpdate.add(l);
                }
            }
        } 
        if(lpToUpdate.size() > 0){
            update lpToUpdate;
        }
    }
}