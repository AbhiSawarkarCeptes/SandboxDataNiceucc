@isTest
public class ExternalReferenceRegisterUtil_Test {
    @IsTest
    static void createExternalReferenceTest() {
        String document = 'Payment';
        String internalReference = 'Test Reference';
        Test.startTest();
        ExternalReferenceRegisterUtil_Copy.createExternalReference(document,internalReference);
        Test.stopTest();
    }
    
    @IsTest
    static void createERRTest() {
        String errString = '{"Internal_Reference__c" : "0012v00000GzZ2sAAB",' +
            '"External_Reference__c" : "testReference",'+
            '"Verification_Code__c" : "123456",';
        
        Test.startTest();
        // ExternalReferenceRegisterUtil_Copy.createERR(errString);
        Test.stopTest();
    }
    
    @IsTest
    static void isValidReferenceTest() {
        Blob aesKey = Crypto.generateAesKey(128); // Example key size
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', aesKey, Blob.valueOf('001XXXXXXXXXXXXXXX')); // Example ID
        String externalReference = EncodingUtil.convertToHex(encrypted);
        
        External_Reference_Register__c err = new External_Reference_Register__c(
            Internal_Reference__c = '0012v00000GzZ2sAAB', // This is a text field
            External_Reference__c = 'testReference',
            Verification_Code__c = '123456',
            Encryption_Key_Size__c = 128, // Example key size
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(1) // Example expiration
        ); 
        insert err;    
        Test.startTest();
        ExternalReferenceRegisterUtil_Copy.isValidReference('testReference');
        Test.stopTest();
    }
    
    @IsTest
    static void challengeTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User usr = TestDataFactorySobha.createUser(NULL);
        Insert usr;
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=usr.id,Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
        insert prop;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
                                                                                             PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
                                                                                             MOU_Transaction_Exception__c = true,Title_Deed_Process_Exception__c = true,CRM_Executive__c=usr.id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        Blob aesKey = Crypto.generateAesKey(128); // Example key size
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', aesKey, Blob.valueOf('001XXXXXXXXXXXXXXX')); // Example ID
        String externalReference = EncodingUtil.convertToHex(encrypted);
        PropStrength__Received_Payment__c recvpay = TestDataFactorySobha.createPayment(null);
        insert recvpay;
        External_Reference_Register__c err = new External_Reference_Register__c(
            Internal_Reference__c = String.valueOf(recvpay.Id),
            External_Reference__c = 'testReference',
            Verification_Code__c = '123456',
            Encryption_Key_Size__c = 128, // Example key size
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(1) // Example expiration
        ); 
        insert err;
        Test.startTest();
        ExternalReferenceRegisterUtil_Copy.challenge('testReference');
        Test.stopTest();
    }
    
     @IsTest
    static void verifyChallengeTest() {
        Blob aesKey = Crypto.generateAesKey(128); // Example key size
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', aesKey, Blob.valueOf('001XXXXXXXXXXXXXXX')); // Example ID
        String externalReference = EncodingUtil.convertToHex(encrypted);
        
        External_Reference_Register__c err = new External_Reference_Register__c(
            Internal_Reference__c = '0012v00000GzZ2sAAB', // This is a text field
            External_Reference__c = 'testReference',
            Verification_Code__c = '123456',
            Encryption_Key_Size__c = 128, // Example key size
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(1) // Example expiration
        ); 
        insert err;    
        Test.startTest();
        ExternalReferenceRegisterUtil_Copy.verifyChallenge('testReference', '123456');
        Test.stopTest();
    }
}