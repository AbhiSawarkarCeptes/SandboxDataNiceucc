@isTest
public class EmailUtilClass_Test {
    @isTest
    static void testMethod1(){
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        EmailUtilClass.objectPrefix(cont.Id);
        EmailUtilClass.getFromAddress('contact');
        
        
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        
        List<PropStrength__Application_Booking__c> booklst = new List<PropStrength__Application_Booking__c>(); 
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c();
        booking.PropStrength__Active__c = true;
        booking.PropStrength__Project__c = pro.id;
        booking.PropStrength__Booking_Date__c = Date.valueOf(system.now());
        booking.PropStrength__Applicant_Mobile__c = '124785496';
        booking.PropStrength__Applicant_Email__c = 'someaddress@email.com';
        booking.PropStrength__Primary_Customer__c = cont.id;
        booklst.add(booking); 
        insert booklst; 
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = booking.Id);
        insert appDetail;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        insert enq;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = cont.FirstName;
        enq2.PropStrength__Last_Name__c =cont.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = booklst[0].id;
        enq2.PropStrength__Project__c = pro.id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test Comments : Query Resolved';
        insert enq2;
        
       
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Service_Request__c = enq2.id;
        eml.PropStrength__Subject__c ='Re:test email';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        
        insert eml;
        Test.StartTest();
        EmailUtilClass.displaytoAddress('new','',eml,enq2);
        EmailUtilClass.displaytoAddress('','bookRequest',eml,enq2);
        EmailUtilClass.displaytoAddress('','appDetail',eml,appDetail);
        
        EmailUtilClass.additionalToAddress('bookRequest','new',eml,enq2,'test1@gmail.com');
        
        EmailUtilClass.displayCCAddress('replyToAll',eml);
        EmailUtilClass.displayBCCAddress('contact','test1@gmail.com');
        EmailUtilClass.displySubject(cont,'',eml,'Contact');
        Test.StopTest();
    }
    @isTest
    static void testMethod2(){
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        EmailUtilClass.objectPrefix(cont.Id);
        EmailUtilClass.getFromAddress('contact');
        
        
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        
        List<PropStrength__Application_Booking__c> booklst = new List<PropStrength__Application_Booking__c>(); 
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c();
        booking.PropStrength__Active__c = true;
        booking.PropStrength__Project__c = pro.id;
        booking.PropStrength__Booking_Date__c = Date.valueOf(system.now());
        booking.PropStrength__Applicant_Mobile__c = '124785496';
        booking.PropStrength__Applicant_Email__c = 'someaddress@email.com';
        booking.PropStrength__Primary_Customer__c = cont.id;
        booklst.add(booking); 
        insert booklst; 
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = booking.Id);
        insert appDetail;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        insert enq;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = cont.FirstName;
        enq2.PropStrength__Last_Name__c =cont.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = booklst[0].id;
        enq2.PropStrength__Project__c = pro.id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test Comments : Query Resolved';
        insert enq2;
        
        
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Service_Request__c = enq2.id;
        eml.PropStrength__Subject__c ='test email';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__To_Address__c = 'test1@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        
        insert eml;
        
        Attachment attachment = new Attachment();
        attachment.ParentId = eml.Id;
        attachment.Name = 'POA';
        attachment.Body = Blob.valueOf('Test');
        insert attachment;
        
        Test.StartTest();
        EmailUtilClass.displaytoAddress('new','',eml,enq2);
        EmailUtilClass.displaytoAddress('','bookRequest',eml,enq2);
        EmailUtilClass.displaytoAddress('','appDetail',eml,appDetail);
        EmailUtilClass.displaytoAddress('','contact',eml,cont);
        
        EmailUtilClass.additionalToAddress('bookRequest','replyToAll',eml,enq2,'test1@gmail.com');
        EmailUtilClass.additionalToAddress('contact','replyToAll',eml,cont,'test1@gmail.com');
        EmailUtilClass.displaySubject(enq2,'ReplyToAll',eml,'bookRequest');
        EmailUtilClass.getEmailBody(eml,'detailPage');
        EmailUtilClass.displaySubject(enq2,'ReplyToAll',eml,'bookRequest');
        
        EmailUtilClass.getEmailBody(eml,'ReplyToAll');
        
        EmailUtilClass.blobToString(Blob.valueOf('Test'),'cp437');
        
        EmailUtilClass.composedEmailBody(eml);
        EmailUtilClass.getTemplateName('contact','test@gmail.com');
        
        EmailUtilClass.getAllTemplates('contact');
        EmailTemplate emp = [SELECT Id,Name From EmailTemplate LIMIT 1];
        Map<String,String> mapset = new Map<String,String>();
        mapset.put('bookRequest',enq2.Id);
        mapset.put('contact',cont.Id);
        EmailUtilClass.upsertEmail(eml,'appDetail',String.valueof(enq2.Id),'testOrignal@gmail.com','testselectedFrom@gmail.com','testcc@gmail.com','testbcc@gmail.com',String.valueof(emp.Id),'Test Subject','testtoAddress@gmail.com','testaddtoAddress@gmail.com','reply',mapset);
        
        EmailUtilClass.upsertBodyAttachment(attachment,'TestBody',String.valueof(eml.Id),'TestName');
        EmailUtilClass.getAttachmentNames(eml,'forward');
        EmailUtilClass.substitute('setemail',String.valueof(cont.Id),String.valueof(eml.Id));
        
        List<String> toMail = new List<String>();
        toMail.add('test@gmail.com');
        
        List<Attachment> atch = new List<Attachment>();
        atch.add(attachment);
        
        EmailUtilClass.createEmail(toMail,toMail,toMail,toMail,'Test sub','messbody',atch,eml,String.valueof(cont.Id),'contact','New','Testad@gmail.com','');
        EmailUtilClass.createEmail(toMail,toMail,toMail,toMail,'Test sub','messbody',atch,eml,String.valueof(cont.Id),'contact','','Testad@gmail.com','');
        
        Test.StopTest();
    }
}