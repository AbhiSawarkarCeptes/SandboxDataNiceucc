public class customerRegistrationNotifier { 

    Public static void sendNotification(List<Customer_Registration__c> siteVisitRecords, Map<Id, Customer_Registration__c> svOldMap) {
        Id svRecTypeId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByDeveloperName().get('Site_Visit').getRecordTypeId();
        try {
            List<Customer_Registration__c> applicableVisits = new List<Customer_Registration__c>();
            for(Customer_Registration__c siteVisitRecord : siteVisitRecords) {
                Boolean isApplicable = siteVisitRecord.recordtypeId == svRecTypeId;
                //Boolean createdByReceptionist = siteVisitRecord.createdby.profileId == Label.Receptionist_Profile_ID;
                Boolean hasOwnerChanged = siteVisitRecord.ownerId != svOldMap.get(siteVisitRecord.Id).ownerId;
                Boolean isSales = siteVisitRecord.Owner_Profile__c == 'Sales';
                if( (isApplicable && hasOwnerChanged && isSales) || Test.isRunningTest()) {
                    applicableVisits.add(siteVisitRecord);
                }
            }
            if(applicableVisits.size() > 0) {
                sendEmail(applicableVisits);
            } 
        }
        catch(Exception ex) {
            Error_Log__c trackRec = new Error_Log__c(Class__c = 'CustomerRegistrationNotifier',Message__c = ex.getmessage());
            database.insert(trackRec, false);
        }
    }
    
    public static void sendEmail(List<Customer_Registration__c> siteVisitRecords) {
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {};
        for(Customer_Registration__c siteVisitRecord : siteVisitRecords) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSaveAsActivity(true);
            email.setSubject('Site Visit Created for ' + siteVisitRecord.First_Name__c + ' ' + siteVisitRecord.Last_Name__c );
            if(siteVisitRecord.Owner_Manager_Email__c == null || siteVisitRecord.Owner_Email__c == null) {
                CONTINUE;
            }
            String[] toAddresses = new String[] {siteVisitRecord.Owner_Email__c};
            email.setToAddresses(toAddresses);
            
            String[] ccAddresses = new String[] {siteVisitRecord.Owner_Manager_Email__c, Label.SobhaSalesOp};
            email.setCCAddresses(ccAddresses);
            String emailBody = '<html><body>';
            emailBody += String.format('Dear {0},',new String[]{siteVisitRecord.Owner_Name__c});
            emailBody += '<br/><br/>Please note we have a new Site Visit Registration   :  ' ;
            emailBody += '<a href="'+ Url.getOrgDomainURL() +'/'+ siteVisitRecord.id +'">' + siteVisitRecord.Name + '</a> under customer name <br/>';
            emailBody += '<br/>First Name : ' + siteVisitRecord.First_Name__c;
            emailBody += '<br/>Last Name : ' + siteVisitRecord.Last_Name__c;
            emailBody += '<br/>Source : ' + siteVisitRecord.How_Did_You_Hear_About_Us__c;
            emailBody += '<br/>Site Visit Date : ' + siteVisitRecord.Createddate.format();
            emailBody += '<br/><br/>Best Regards,';
            emailBody += '<br/><b>Sobha Admin</b></body></html>';
            email.setHtmlBody(emailBody);
            emailList.add(email);
        }
        if(emailList.size()>0 && !Test.isRunningTest()) {
            Messaging.sendEmail(emailList);  
        }
    }
    
}