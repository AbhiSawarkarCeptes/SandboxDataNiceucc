@isTest
public class PaymentRequestFormControllerCopy_Test {
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Enquiry_Source__c = 'Web';
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', Max_Cap_AED__c = 1000, PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        String fileName = 'TestFile.txt';
                
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        test.starttest();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.checkifUnitIsBlocked(prop.Id);
        PaymentRequestFormControllerCopy.searchPrimaryContact(enq.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        PaymentRequestFormControllerCopy.getPOPImgFile(cv.Id);
        PaymentRequestFormControllerCopy.getPOPPdfFile(cv.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot(prop.Id);
        PaymentRequestFormControllerCopy.checkAllocatedSmRec(prop.Id);
        PaymentRequestFormControllerCopy.getAllowedAmountVal('',book.Id,true);
        PaymentRequestFormControllerCopy.checkEnquiryAvailability(enq.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailability(prop.Id);
        PaymentRequestFormControllerCopy.checkPrCanCreateOrNot(prop.Id);
        PaymentRequestFormControllerCopy.getCurrencyRate();
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678##Direct';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
        String bookingId = book.Id+'##'+offer.Id;
        String bookingId1 = offer.Id;
        String modeOption = 'Single Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '5';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, mode, curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue 
        );
        
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'OTC Deposits(Cash counter)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId1, 'Multi Mode', secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
        test.stoptest();
        
    }
    
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        test.starttest();
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
		uh1.Enquiry_Source__c = 'Web';
	    insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.getCurrencyRate();
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Multi Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '500';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, mode, curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue 
        );
        
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'OTC Deposits(Cash counter)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, 'Multi Mode', secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'IWT(International)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            true, isThirdParty, category,
            mortgageValue
        );
        test.stoptest();
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
       
    }
    
    @isTest
    static void testMethod3() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Enquiry_Source__c = 'Web';
        uh.Currency__c ='AED';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Enquiry_Source__c = 'Web';
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.getCurrencyRate();
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Multi Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '500';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Offer__c##'+offer.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        test.starttest();
       
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'OTC Deposits(Cash counter)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, 'Multi Mode', secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        ); 
        isThirdParty = 'false##PropStrength__Property__c##'+prop.Id;
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'OTC Deposits(Cash counter)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, 'Multi Mode', secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );  
    }
    
    @isTest
    static void testMethod4() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Enquiry_Source__c = 'Web';
        uh.Currency__c ='AED';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Enquiry_Source__c = 'Web';
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        test.starttest();
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.getCurrencyRate();
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Multi Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '500';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Offer__c##'+offer.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
       
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Website', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, 'Multi Mode', secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        ); 
        
        test.stopTest();
    }
    
    @isTest
    static void testMethod5() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Enquiry_Source__c = 'Web';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh1.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Enquiry_Source__c = 'Web';
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = u.Id
        );
        Test.startTest();
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.checkifUnitIsBlocked(prop.Id);
        PaymentRequestFormControllerCopy.searchPrimaryContact(enq.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        PaymentRequestFormControllerCopy.getPOPImgFile(cv.Id);
        
        PaymentRequestFormControllerCopy.getPOPPdfFile(cv.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot(prop.Id);
        PaymentRequestFormControllerCopy.checkAllocatedSmRec(prop.Id);
        PaymentRequestFormControllerCopy.getAllowedAmountVal('',book.Id,true);
        PaymentRequestFormControllerCopy.checkEnquiryAvailability(enq.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailability(prop.Id);
        PaymentRequestFormControllerCopy.checkPrCanCreateOrNot(prop.Id);
        PaymentRequestFormControllerCopy.getCurrencyRate();
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Single Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '5';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'IWT(International)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
        test.stoptest();
        
    }
    
    @isTest
    static void testMethod6() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
        uh1.Enquiry_Source__c = 'Web';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        Test.startTest();
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = u.Id
        );
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.checkifUnitIsBlocked(prop.Id);
        PaymentRequestFormControllerCopy.searchPrimaryContact(enq.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        
        PaymentRequestFormControllerCopy.getPOPImgFile(cv.Id);
        PaymentRequestFormControllerCopy.getPOPPdfFile(cv.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot(prop.Id);
        PaymentRequestFormControllerCopy.checkAllocatedSmRec(prop.Id);
        PaymentRequestFormControllerCopy.getAllowedAmountVal('',book.Id,true);
        PaymentRequestFormControllerCopy.checkEnquiryAvailability(enq.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailability(prop.Id);
        
        PaymentRequestFormControllerCopy.checkPrCanCreateOrNot(prop.Id);
        PaymentRequestFormControllerCopy.getCurrencyRate();
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Single Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '5';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Website', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            new List<String>(), bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
        test.stoptest();
        
    }
    
    @isTest
    static void testMethod7() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Enquiry_Source__c = 'Web';
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = u.Id
        );
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.checkifUnitIsBlocked(prop.Id);
        PaymentRequestFormControllerCopy.searchPrimaryContact(enq.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        test.starttest();
        PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        PaymentRequestFormControllerCopy.getPOPImgFile(cv.Id);
        PaymentRequestFormControllerCopy.getPOPPdfFile(cv.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot(prop.Id);
        PaymentRequestFormControllerCopy.checkAllocatedSmRec(prop.Id);
        PaymentRequestFormControllerCopy.getAllowedAmountVal('',book.Id,true);
        PaymentRequestFormControllerCopy.checkEnquiryAvailability(enq.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailability(prop.Id);
        PaymentRequestFormControllerCopy.getCurrencyRate();
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
        String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Single Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '5';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'OTC Deposits(Cash counter)', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
        test.stoptest();
        
    }
    
    @isTest
    static void testMethod8() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 10000;
        uh.Total_Amount__c = 10000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Enquiry_Source__c = 'Web';
        uh1.Amount__c = 10000;
        uh1.Total_Amount__c = 10000;
        uh1.Currency__c ='AED';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = u.Id
        );
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.checkifUnitIsBlocked(prop.Id);
        PaymentRequestFormControllerCopy.searchPrimaryContact(enq.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        test.starttest();
        PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        PaymentRequestFormControllerCopy.getPOPImgFile(cv.Id);
        PaymentRequestFormControllerCopy.getPOPPdfFile(cv.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot(prop.Id);
        PaymentRequestFormControllerCopy.checkAllocatedSmRec(prop.Id);
        PaymentRequestFormControllerCopy.checkEnquiryAvailability(enq.Id);
        PaymentRequestFormControllerCopy.checkPropertyAvailability(prop.Id);
        PaymentRequestFormControllerCopy.getCurrencyRate();
        PaymentRequestFormControllerCopy.getAllowedAmountVal('',book.Id,true);
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
            String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Single Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '5';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Cheque', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            new List<String>(), bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            isCorporate, isThirdParty, category,
            mortgageValue
        );
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
        test.stoptest();
        
    }
    
    @isTest
    static void testMethod222() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        PaymentRequestFormControllerCopy.unitDetails(prop.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromBooking(book.Id);
        
        PaymentRequestFormControllerCopy.getContactRecFromOffer(offer.Id);
        
        PaymentRequestFormControllerCopy.getUnitId(book.Id);
        
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        test.starttest();
        insert uh;
        
        Payment_Request__c uh1 = new Payment_Request__c();
        uh1.mode__C = 'Credit Card';
        uh1.Property__c = prop.Id;
        uh1.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh1.Sales_Manager__c = UserInfo.getUserId();
        uh1.Amount__c = 100000;
        uh1.Total_Amount__c = 100000;
        uh1.Currency__c ='AED';
        uh1.Enquiry_Source__c = 'Web';
        insert uh1;
        
        PaymentRequestFormControllerCopy.updateUnit(new List<Id>{uh.Id});
        
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        PaymentRequestFormControllerCopy.getCurrencyRate();
        PaymentRequestFormControllerCopy.getPaymentRequestDetails(uh.Id);
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'};
         String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Multi Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '500';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = uh.Id;
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Cheque', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, null, popComments, 
            true, isThirdParty, category,
            mortgageValue
        );
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Website', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            false, isThirdParty, category,
            mortgageValue
        );
        test.stoptest();
        
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: uh.id LIMIT 1];
        
        PaymentRequestFormControllerCopy.rejectWebsiteRequests(new List<String>{uhw.Id});
       
    }
    @isTest
    static void testMethod10() {
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        PropStrength__Application_Booking__c book = PaymentRequestFormControllerCopy.getContactRecFromBooking('');
        PropStrength__Offer__c off = PaymentRequestFormControllerCopy.getContactRecFromOffer('');
        String st = PaymentRequestFormControllerCopy.checkEnquiryAvailability('');
        String st1 = PaymentRequestFormControllerCopy.checkPropertyAvailability('');
        Attachment attachment = new Attachment();
    	attachment.ParentId = cont.Id;
    	attachment.Name = 'Passport Check';
    	attachment.Body = Blob.valueOf('Test');
        attachment.contentType = 'application/pdf';
    	insert attachment;
        Test.startTest();
        String st3 = PaymentRequestFormControllerCopy.getContactRecPassport(cont.Id);
        String st6 = PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        ContentVersion cv = new ContentVersion(
            Title = 'Passport',
            PathOnClient = 'Passport.pdf',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument WHERE Title = 'Passport'
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = cont.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        String st4 = PaymentRequestFormControllerCopy.getContactRecPassport2(cont.Id);
        String st5 = PaymentRequestFormControllerCopy.getContactRecPassport3(cont.Id);
        Test.stopTest();
    }
     @isTest
    static void testMethod11() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        Test.startTest();
        String fileName = 'TestFile.txt';
        ContentVersion cv = new ContentVersion(
            Title = 'OriginalFileName.txt',
            PathOnClient = 'OriginalFileName.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        
        User u = new User(LastName = 'Test',
                          FirstName='Test1 User',
                          Alias = 'tstU1',
                          Email = 'testUsr1@stetig.in',
                          Username = 'testUsr1@stetig.in',
                          ProfileId = profileId.id,
                          OzoneTel_AgentId__c = 'test.test1',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = book.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdId];
        PaymentRequestFormControllerCopy.updateUploadedFileName(fileName, cd.Id);
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(); 
        insert acc;
        
        
        String name = 'John Doe';
        String email = 'john@example.com';
        String mobile = '1234567890';
        String passportNumber = 'AB123456##1234';
        String mode = 'Credit Card';
        String curr = 'USD##Web##'+enq.Id;
        String curr1 = 'USD##Web##';
        String instrumentNumber = '1234';
        String chequeNo = '5678';
        String chequeDate = String.valueOf(System.Today());
        String accountNo = acc.Id;
        String amount = '1000';
        String dateOfInitiation = String.valueOf(System.Today());
        String countryOfInitiation = 'Albania';
        Integer uploadedFileLength = 1;
        List<String> units = new List<String>{prop.Id+'##AED##1000'+'ESCROW'};
        String bookingId = book.Id+'##'+offer.Id;
        String modeOption = 'Multi Mode';
        String secondaryMode = 'Cheque';
        String instrumentDate = String.valueOf(System.Today());
        String referenceNo = 'Ref123';
        String is3rdParty = 'true###true###true###true';
        String amountTowards = 'Unit Price';
        String amountTowardsUnit = '500';
        String amountTowardsPreReg = '300';
        String amountTowardsOther = '200';
        String others = 'Transaction Fee';
        String prId = '';
        String popComments = 'Comments';
        Boolean isCorporate = true;
        String isThirdParty = 'false##PropStrength__Application_Booking__c##'+book.Id;
        String category = 'Category';
        String mortgageValue = '500000';
        Unit_Hold__c un = new Unit_Hold__c(Sales_Manager__c = UserInfo.getUserId(), Unit_No__c = prop.Id, Status__c = 'Active', Unit_Hold_Approval_Status__c = 'Approved');
        insert un;
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Cheque', curr1, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, null, popComments, 
            true, isThirdParty, category,
            mortgageValue
        );
        
        PaymentRequestFormControllerCopy.createPaymentRequest(
            name, email, mobile, passportNumber, 'Website', curr, instrumentNumber, chequeNo, chequeDate,
            accountNo, amount, dateOfInitiation, countryOfInitiation, uploadedFileLength,
            units, bookingId, modeOption, secondaryMode, instrumentDate,
            referenceNo, is3rdParty, amountTowards, amountTowardsUnit, 
            amountTowardsPreReg, amountTowardsOther, others, prId, popComments, 
            false, isThirdParty, category,
            mortgageValue
        );
        test.stoptest();    
    }
}