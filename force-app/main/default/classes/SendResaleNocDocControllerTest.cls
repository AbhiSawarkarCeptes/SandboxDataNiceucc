@IsTest
public class SendResaleNocDocControllerTest {

    @IsTest
    public static void sendNocToApplicantsTest(){
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Account acc = new Account(Name='test acc');
        insert acc;
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = objOpportunity.id;
        // b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';  
        b.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        insert b;
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = b.Id;
        Insert ad1; 
        Resale_Process__c resale = new Resale_Process__c(Booking__c = b.Id,Seller1_Name__c='TEST', Seller1_Phone_Number__c='12', Seller1_Email__c='TEST@TEST.COM', Buyer1_Name__c='TEST', Buyer1_Phone_Number__c='12', Buyer1_Email__c='TEST@TEST.COM');
   	    Insert resale;
        ContentVersion content=new ContentVersion(); 
        content.Title='NOC_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=resale.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        SendResaleNocDocController.sendEmail(resale.Id);
    }
}