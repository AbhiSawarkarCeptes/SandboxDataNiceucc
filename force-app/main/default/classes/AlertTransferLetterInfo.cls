public with sharing class AlertTransferLetterInfo {
    @AuraEnabled
    public static PropStrength__Transaction_Requests__c getRecordInfo(Id recordId) {
        try {
            return [SELECT Id, Name, Transfer_Assigment_Agreement_Uploaded__c, Transfer_Assignment_Document_Signed__c, PropStrength__Customer_Transfer_Type__c, Transfer_Charges_Raised_to_Customer__c, Transfer_Letter_Signed__c, PropStrength__Status__c, New_Buyer_s_Documents_Received__c, Transfer_Letter_Uploaded__c, SPA_DSPA_Sent_to_New_Customer__c, PropStrength__Application_Booking__r.PCC_Document_Approved__c, PropStrength__Application_Booking__r.PropStrength__Total_Paid_Percent__c FROM PropStrength__Transaction_Requests__c WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getRecordInfoCount(Id recId) {
        try {
            PropStrength__Transaction_Requests__c tr = [SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id = :recId];
            Id recTypeIncDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
            return String.valueOf([SELECT Id FROM PropStrength__Received_Payment__c WHERE RecordTypeId = :recTypeIncDueId AND PropStrength__Amount_Due_Type__c = 'Transfer Fee' AND PropStrength__Balance__c > 0 AND PropStrength__Application_Booking__c = :tr.PropStrength__Application_Booking__c].size());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String nocForResaleOqood(String recId) {
        try {
            if(recId != null && recId != '') {
                PropStrength__Transaction_Requests__c tranReq = [SELECT Id, PropStrength__Status__c FROM PropStrength__Transaction_Requests__c WHERE Id = :recId];

                SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'NOCforReSaleOqood');
                
                if(tranReq.PropStrength__Status__c == 'Audit Approved for NOC Generation'){
                    tranReq.PropStrength__Status__c = 'NOC Generated';
                    update tranReq;
                }

                return 'Success';
            } else {
                return ' Record Id is missing';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String nocTitleDeed(String recId) {
        try{
            if(recId != null && recId != '') {
                PropStrength__Transaction_Requests__c tranReq = [SELECT Id, PropStrength__Status__c FROM PropStrength__Transaction_Requests__c WHERE Id = :recId];

                SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'NOCTitleDeed');
                
                if(tranReq.PropStrength__Status__c == 'SPA/DSPA Sent to New Customer'){
                    tranReq.PropStrength__Status__c = 'NOC Generated';
                    update tranReq;
                }
                return 'Success';
            } else {
                return ' Record Id is missing';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String transferNAssignmentAgreement(String recId) {
        try{
            if(recId != null && recId != '') {
                PropStrength__Transaction_Requests__c tranReq = [Select id, PropStrength__Customer_Transfer_Type__c, PropStrength__Status__c, Transfer_Charges_Raised_to_Customer__c FROM PropStrength__Transaction_Requests__c WHERE Id =:recId];

                List<Attachment> allAttachment = new List<Attachment>();
                allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: recId];

                List<Attachment> deleteAtt = new List<Attachment>();

                for(Attachment abc : allAttachment){
                    if(abc.Name == 'Transfer & Assignment Agreement.pdf'){
                        deleteAtt.add(abc);
                    } 
                }

                if(!deleteAtt.isEmpty()){
                    delete deleteAtt;
                }
            
                string aName ;
        
                if(tranReq.PropStrength__Status__c == 'Assignment: Update Applicants & Verify Applicants'){
                    if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer') {
                        tranReq.PropStrength__Status__c = 'Transfer & Assignment Agreement Generated';
                        aName= 'Transfer & Assignment Agreement';
                    }
                    update tranReq;
                }

                String frmsrc = '';
                if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer'){
                    frmsrc = '/apex/TransferAndAssignmentAgreement?id='+recId;
                }
        
                PageReference p1 = new PageReference(frmsrc);   
                Attachment a1 = new Attachment();
                a1.parentid = recId;
                a1.name = aName + '.pdf';
                if (Test.IsRunningTest()) {
                    a1.body =Blob.valueOf('UNIT.TEST');
                } else{
                    a1.body = p1.getContent();
                }
                insert a1;
        
                return 'Success';
            } else {
                return ' Record Id is missing';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String transferLetter(String recId) {
        try{
            if(recId != null && recId != '') {
                PropStrength__Transaction_Requests__c tranReq = [Select id, PropStrength__Customer_Transfer_Type__c, PropStrength__Status__c, Transfer_Charges_Raised_to_Customer__c FROM PropStrength__Transaction_Requests__c WHERE Id =:recId];

                List<Attachment> allAttachment = new List<Attachment>();
                allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: recId];

                List<Attachment> deleteAtt = new List<Attachment>();

                for(Attachment abc : allAttachment){
                    if(abc.Name == 'Transfer Letter.pdf'){
                        deleteAtt.add(abc);
                    } 
                }

                if(!deleteAtt.isEmpty()){
                    delete deleteAtt;
                }
            
                string aName ;
        
                if(tranReq.PropStrength__Status__c == 'Assignment: Update Applicants & Verify Applicants'){
                    if(tranReq.PropStrength__Customer_Transfer_Type__c == 'Title Transfer') {
                        tranReq.PropStrength__Status__c = 'Transfer Letter Generated';
                        aName= 'Transfer Letter';
                    }
                    update tranReq;
                }

                String frmsrc = '';
                if(tranReq.PropStrength__Customer_Transfer_Type__c == 'Title Transfer'){
                    frmsrc = '/apex/TransferLetter_TR?id='+recId;
                }
        
                PageReference p1 = new PageReference(frmsrc);   
                Attachment a1 = new Attachment();
                a1.parentid = recId;
                a1.name = aName + '.pdf';
                if (Test.IsRunningTest()) {
                    a1.body =Blob.valueOf('UNIT.TEST');
                } else{
                    a1.body = p1.getContent();
                }
                insert a1;
                return 'Success';
            } else {
                return ' Record Id is missing';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}