@isTest
public class Test_MB_Mobile_Case {
    
    @testSetup
    static void setupTestData() {
        
        Assignment_Group_Name__c assignmentGroupName = new Assignment_Group_Name__c();
        assignmentGroupName.Type__c = 'Cases';
        assignmentGroupNamE.Name = 'Test';
        Insert assignmentGroupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.Active__c = 'True';
        assignmentGroup.Name = 'Test';
        assignmentGroup.Rank__c = 1;
        assignmentGroup.Group_Name__c = assignmentGroupName.Id;
        Insert assignmentGroup;
        
        Case c = new Case();
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedPhone = '98765432';
        c.description = 'description';
        insert c;
        
        Mobile_TestUtil.createBooking();
        /*List<booking__c> book = [select id, name from booking__c order by createddate asc limit 1];
        book[0].Handover_Date__c = system.today();
        update book;
        Applicant_Details__c applicant = new Applicant_Details__c ();
        applicant.Name = 'New Man1';
        applicant.Salutation__c = 'Mr.';       
        applicant.DOB__c = system.today();
        applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        applicant.Pincode__c = 444444;
        applicant.Country__c = 'India';
        applicant.City__c = 'Nagpur'; 
        applicant.Applicant_Number__c = 'Primary Applicant';
        applicant.Mailing_Address__c = '101 Kumar Vastu';        
        applicant.Mailing_Country__c= 'India';
        applicant.Mailing_State__c = 'Gujarat';
        applicant.Mailing_City__c = 'Ahmedabad';
        applicant.State__c = 'Gujarat';   
        applicant.Mailing_Pincode__c = 123456;    
        applicant.Mobile_Number__c = '909090901';
        applicant.Email_Address__c = 'test@testre.co'; 
        applicant.Booking__c = book[0].Id;  
        applicant.Valid_Until_Passport__c = System.today().addDays(200);      
        insert applicant; */
    }
    
    @isTest
    static void testMethod1(){
        
        RequestWrapper resWrap= new RequestWrapper();
        resWrap.email='test@testre.co';
        resWrap.emailNew='test1@testre.co';
        resWrap.mobile='1234567890';
        resWrap.mobileNew='0987654321';
        resWrap.Remarks='Test';
        String jsonBody = JSON.serialize(resWrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createCase'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res; 
        
        List<booking__c> book = [select id, name from booking__c order by createddate asc limit 1];
        Applicant_Details__c applicant = new Applicant_Details__c ();
        applicant.Name = 'New Man1';
        applicant.Salutation__c = 'Mr.';       
        applicant.DOB__c = system.today();
        applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        applicant.Pincode__c = 444444;
        applicant.Country__c = 'India';
        applicant.City__c = 'Nagpur'; 
        applicant.Applicant_Number__c = 'Primary Applicant';
        applicant.Mailing_Address__c = '101 Kumar Vastu';        
        applicant.Mailing_Country__c= 'India';
        applicant.Mailing_State__c = 'Gujarat';
        applicant.Mailing_City__c = 'Ahmedabad';
        applicant.State__c = 'Gujarat';   
        applicant.Mailing_Pincode__c = 123456;    
        applicant.Mobile_Number__c = '909090901';
        applicant.Email_Address__c = 'test@testre.co'; 
        applicant.Booking__c = book[0].Id;  
        applicant.Valid_Until_Passport__c = System.today().addDays(200);      
        insert applicant;
        
        book[0].Handover_Date__c=system.today();
        update book;
        
        Test.startTest();
            Mobile_Case.doCreateCase();
        Test.stopTest();
    }
    
    @isTest
    static void testMethodAccount(){
        
        RequestWrapper resWrap= new RequestWrapper();
        resWrap.email='test@testre.co';
        resWrap.emailNew='test@rekeke.cc';
        resWrap.mobile='1234567890';
        resWrap.mobileNew='0987654321';
        resWrap.Remarks='Test';
        String jsonBody = JSON.serialize(resWrap);
        
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        List<booking__c> book = [select id, name from booking__c order by createddate desc Limit 1];
        Account accInsert = new Account( RecordTypeID=RecTypeId,  FirstName='Test FName',  LastName='Test LName',  
                                        PersonMailingStreet='test@testerer.com',  PersonMailingPostalCode='12345',  
                                        PersonMailingCity='SFO',  PersonEmail='test@testre.co',  PersonHomePhone='1234567',  
                                        PersonMobilePhone='1234567890' );
        insert accInsert;
        
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/createCase'; 
            req.httpMethod = 'Post';
            req.addHeader('Content-Type', 'application/json'); 
            req.requestBody = Blob.valueof(jsonBody);
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res; 
        
            Mobile_Case.doCreateCase();
        Test.stopTest();
    }
    
    @isTest
    static void testMethodLead(){
        
        RequestWrapper resWrap= new RequestWrapper();
        resWrap.email='test@testre.co';
        resWrap.emailNew='test@rekeke.cc';
        resWrap.mobile='1234567890';
        resWrap.mobileNew='0987654321';
        resWrap.Remarks='Test';
        String jsonBody = JSON.serialize(resWrap);
        
        
        List<booking__c> book = [select id, name from booking__c order by createddate desc Limit 1];
        Lead leadInsert = new Lead( email='test@testre.co',  MobilePhone='1234567890', LastName='TestLead');
        insert leadInsert;
        
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/createCase'; 
            req.httpMethod = 'Post';
            req.addHeader('Content-Type', 'application/json'); 
            req.requestBody = Blob.valueof(jsonBody);
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res; 
        
            Mobile_Case.doCreateCase();
        Test.stopTest();
    }
    
    public class RequestWrapper{
        public String email;
        public String emailNew;
        public String mobile;
        public String mobileNew;
        public String Remarks;
    }
    
}