@isTest
public class UndertakingDocusignHandler_Test {
     @testSetup 
    static void testData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User usr = TestDataFactorySobha.createUser(NULL);
        Insert usr;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=usr.id,Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.MobilePhone = '9999999999';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        cont.PropStrength__Account_Type__c = '  Individual';
        insert cont;


          PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
        insert prop;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
       PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
        PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
        MOU_Transaction_Exception__c = true,Title_Deed_Process_Exception__c = true,CRM_Executive__c=usr.id, Handover_will_be_taken_by__c = 'Owner – Individual', POA_Email_Address__c = 'book@mail.co', POA_Mobile_Number__c = '9988655665', POA_Name__c = 'POA Name');
        insert book;

        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        

        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=FALSE, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10, PropStrength__Project__c = proj.Id, MOU_Executed__c = TRUE);
        insert book1;
        
        PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        insert appDetail1;
        
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
//trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer', PropStrength__Refund_Type__c = 'Advance Refund'));
       // trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer', DLD_Certificate_Uploaded__c = FALSE));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval',DCR_Created__c = false,DSPA_Created__c = false, RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'Title Transfer'));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book1.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'No Title Transfer'));
        
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
       
       
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
       // trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
        
        System.debug('trList :' + trList);
        insert trList;
    }

    @isTest
    static void sendEnvelopeMethodTest1(){
        List<PropStrength__Application_Booking__c> bookRec = [Select Id, PropStrength__Primary_Customer__c, Handover_will_be_taken_by__c, 
                        PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, 
                        PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, POA_Name__c, POA_Mobile_Number__c, POA_Email_Address__c 
                        FROM PropStrength__Application_Booking__c WHERE Handover_will_be_taken_by__c = 'Owner – Individual'];
        Test.startTest();
        List<Id> bookIds = new List<Id>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'UndertakingDocuments.pdf';
        cv.PathOnClient = 'UndertakingDocuments.pdf';
        cv.VersionData = Blob.valueOf('Sample PDF Content');
        insert cv;
        for (PropStrength__Application_Booking__c rec : bookRec) {
            bookIds.add(rec.Id);
        }
        UndertakingDocusignHandler.sendEnvelopeMethod(bookIds);
        Test.stopTest();                                                      
    }

    @isTest
    static void sendEnvelopeMethodTest2(){
        Contact con = [SELECT Id, Name, PropStrength__Account_Type__c FROM Contact WHERE Email = 'test@test.com'];
        con.PropStrength__Account_Type__c = 'Company';
        con.Authorised_Representative_Name__c = 'Test';
        con.Authorised_Representative_Passport_No__c =  '123';
        update con;
        List<PropStrength__Application_Booking__c> bookRec = [Select Id, PropStrength__Primary_Customer__c, Handover_will_be_taken_by__c, 
                        PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, 
                        PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, POA_Name__c, POA_Mobile_Number__c, POA_Email_Address__c 
                        FROM PropStrength__Application_Booking__c WHERE Handover_will_be_taken_by__c = 'Owner – Individual'];
        bookRec[0].Handover_will_be_taken_by__c = 'Owner – Company';
        update bookRec;               
        Test.startTest();
        List<Id> bookIds = new List<Id>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'UndertakingDocuments.pdf';
        cv.PathOnClient = 'UndertakingDocuments.pdf';
        cv.VersionData = Blob.valueOf('Sample PDF Content');
        insert cv;
        for (PropStrength__Application_Booking__c rec : bookRec) {
            bookIds.add(rec.Id);
        }
        UndertakingDocusignHandler.sendEnvelopeMethod(bookIds);
        Test.stopTest();                                                      
    }

    @isTest
    static void sendEnvelopeMethodTest3(){
        List<PropStrength__Application_Booking__c> bookRec = [Select Id, PropStrength__Primary_Customer__c, Handover_will_be_taken_by__c, 
                        PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, 
                        PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, POA_Name__c, POA_Mobile_Number__c, POA_Email_Address__c 
                        FROM PropStrength__Application_Booking__c WHERE Handover_will_be_taken_by__c = 'Owner – Individual'];
        bookRec[0].Handover_will_be_taken_by__c = 'POA – Owner';
        update bookRec;               
        Test.startTest();
        List<Id> bookIds = new List<Id>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'UndertakingDocuments.pdf';
        cv.PathOnClient = 'UndertakingDocuments.pdf';
        cv.VersionData = Blob.valueOf('Sample PDF Content');
        insert cv;
        for (PropStrength__Application_Booking__c rec : bookRec) {
            bookIds.add(rec.Id);
        }
        UndertakingDocusignHandler.sendEnvelopeMethod(bookIds);
        Test.stopTest();                                                      
    }

    @isTest
    static void sendEnvelopeMethodTest4(){
        List<PropStrength__Application_Booking__c> bookRec = [Select Id, PropStrength__Primary_Customer__c, Handover_will_be_taken_by__c, 
                        PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, 
                        PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, POA_Name__c, POA_Mobile_Number__c, POA_Email_Address__c 
                        FROM PropStrength__Application_Booking__c WHERE Handover_will_be_taken_by__c = 'Owner – Individual'];
        bookRec[0].Handover_will_be_taken_by__c = 'POA – Company';
        update bookRec;               
        Test.startTest();
        List<Id> bookIds = new List<Id>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'UndertakingDocuments.pdf';
        cv.PathOnClient = 'UndertakingDocuments.pdf';
        cv.VersionData = Blob.valueOf('Sample PDF Content');
        insert cv;
        for (PropStrength__Application_Booking__c rec : bookRec) {
            bookIds.add(rec.Id);
        }
        UndertakingDocusignHandler.sendEnvelopeMethod(bookIds);
        Test.stopTest();                                                      
    }
}