global class PCCDocumentGenerateBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id paymentDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        String query = 'SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,Total_Interest_Received_Till_Date__c,'+
            'PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,Total_Interest_Due_Till_Date__c,' +
            'PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.DLD_Executive__c,'+
            'PropStrength__Project__r.DLD_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c ,'+
            '(SELECT Id, PropStrength__Approval_Status__c, PropStrength__Is_Milestone_Completed__c, PropStrength__Balance__c FROM PropStrength__Payment_Plan_Details__r), '+
            '(SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :paymentDueRT)' +
            ' FROM PropStrength__Application_Booking__c ' +
            'WHERE SPA_Executed__c = true AND ' +
            'PropStrength__Active__c = true AND PCC_Document_Generated__c = false AND Pre_Registration_Completed__c = TRUE ';
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> scope) {
        system.debug('scope::'+scope);
        if(!scope.isEmpty()) {
            
            List<Attachment> insertList = new List<Attachment>();
            List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
            for(PropStrength__Application_Booking__c book : scope) {
                Decimal totInt = book.Total_Interest_Due_Till_Date__c != null ? book.Total_Interest_Due_Till_Date__c : 0;
                if((totInt-book.Total_Interest_Received_Till_Date__c) <= 0) {
                    Boolean ppdEntry = TRUE;
                    Boolean payEntry = TRUE;
                    
                    if(!book.PropStrength__Payment_Plan_Details__r.isEmpty()) {
                        System.debug('book*---'+book.Id);
                        for(PropStrength__Payment_Plan_Details__c ppd : book.PropStrength__Payment_Plan_Details__r) {
                            
                            if(!(ppd.PropStrength__Approval_Status__c == 'Approved' && ppd.PropStrength__Is_Milestone_Completed__c && ppd.PropStrength__Balance__c <= 100)) {
                                System.debug(ppd.Id+'--book*--Abc-'+book.Id);
                                ppdEntry = FALSE;
                                break;
                            }
                        }
                    } else {
                        ppdEntry = FALSE;
                    }
                    System.debug(book.PropStrength__Payments_Cheques__r.isEmpty()+'---book*--42-'+book.Id);
                    if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                        System.debug('---book*--43-'+book.Id);
                        for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                            if(!pay.PropStrength__Demand_Generated__c) {
                                System.debug(pay.Id+'---book*--44-'+book.Id);
                                payEntry = FALSE;
                                break;
                            }
                        }
                    } else {
                        payEntry = FALSE;
                    }
                    
                    System.debug('Entry:::::::'+ppdEntry);
                    System.debug('Entry:::::::'+payEntry);
                    
                    if(ppdEntry && payEntry) {
                        System.debug('book*--AAA-'+book.Id);
                        PageReference pdf;
                        pdf =  Page.PaymentCompletionCertificate;
                        pdf.getParameters().put('id', book.Id);
                        Blob b ;
                        if(!Test.isRunningTest()){
                             b= pdf.getContent();
                        }
                        else{
                            b = blob.valueOf('Unit.Test');
                        }
                        
                        Attachment att = new Attachment();
                        att.ParentId = book.Id;
                        att.Name = 'PCC Document.pdf';
                        att.Body = b;
                        insertList.add(att);
                        
                        PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                        oneBook.Id = book.id;
                        oneBook.PCC_Document_Generated__c = true;
                        //oneBook.PCC_Document_Submitted_to_Accounts__c = true;
                        //oneBook.PCC_Document_Submitted_to_Accounts_Date__c = Date.today();
                        oneBook.PCC_Document_Generated_Date__c = Date.today();
                        updateList.add(oneBook);
                        
                        if(!insertList.isEmpty()) {
                            insert insertList;
                            system.debug('insertList::'+insertList);
                        }
                        if(!updateList.isEmpty()){
                            update updateList;
                        }
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}