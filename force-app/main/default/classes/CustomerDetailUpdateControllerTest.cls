@isTest
public class CustomerDetailUpdateControllerTest 
{
	@isTest static void test1() 
     {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');

        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;  
 
         // account creation 
             Account objac = new Account();
             objac.FirstName = 'Shock';
             objac.LastName = 'Wave';
             objac.Correspondence_Address__c = 'Delhi';
             objac.Category__c = 'General';
             objac.Unit__c = unitId;
             objac.Phone = '9844978626';
             objac.PersonEmail='test.tet@test.com';
             objac=RDSCommon.CreateAccount(objac);
        
         Opportunity objOpportunity = new Opportunity();
             objOpportunity.Name = 'Test Hitesh';
             objOpportunity.CloseDate = System.today();
             objOpportunity.AccountId = objac.Id; 
             objOpportunity.Status__c = 'Active'; 
             objOpportunity.StageName = 'Opportunity Identified'; 
             objOpportunity.Project__c = recordIdMap.get('PROJECT'); 
             objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Booking__c b = new Booking__c();
        
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test1@test1.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b;

        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'First Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
         
        insert a1;
        
        Test.startTest();
         Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
         CustomerDetailUpdateController.getUnitDetail(String.ValueOf(unitId));
         CustomerDetailUpdateController.getApplicantDetail('Test Name','Test Nat','Test Address','Test Name','Test Address','Test Name','Test Address','Test Name','Test Address','test1.test2@test3.com','919876543210',unitId,'p12345n',date.today(),'e9876t','123'); 
         CustomerDetailUpdateController.addApplicantDetail('Test Name','Test Nat','Test Address','Test Name','Test Address','Test Name','Test Address','Test Name','Test Address','test1.test2@test3.com','919876543210',unitId,'p12345n',date.today(),'e9876t','123'); 
        Test.stopTest();
     }

}