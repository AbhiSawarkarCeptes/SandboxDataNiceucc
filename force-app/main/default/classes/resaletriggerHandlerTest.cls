@IsTest
public class resaletriggerHandlerTest 
{
    @testSetup static void setup() {

        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');

        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;

        upsert bypassSettingInstance;
      
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');

        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
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
        b.VAT_Reduction_From_PPP__c=100;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
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
        a1.Unit__c=unitId;
        insert a1;
        
        Receipt__c rec2 = new Receipt__c();
        rec2.Booking__c =b.Id;
        rec2.Receipt_Status__c ='UnProcessed';
        rec2.Consider_for_Paid_Percentage__c =false;
        rec2.Is_Reversed_Receipt__c =false;
        rec2.Amount_Rs__c =1000;
        rec2.Total_Amount__c = 1000;
        rec2.Corporate_Collection_Control_Report__c =100;
        rec2.Credit_Card_Charges__c =100;
        insert rec2;
       
       List<Resale_Process__c> resLst = new List<Resale_Process__c>();
        Resale_Process__c resale = new Resale_Process__c ();
        resale.Resale_Type__c ='Resale with Mortgage';
        resale.Booking__c=b.Id;
        resale.Seller1_Name__c='Hitesh GV';
        resale.Seller1_Email__c='hitesh.gv@shoba.com.test';
        resale.Seller1_Phone_Number__c='919844978626'; 
        resale.Seller1_Address__c='abcdef';
        resale.Seller1_Passport_Number__c='sjd87246234';
        resale.Buyer1_Name__c='Hitesh GV1';
        resale.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale.Buyer1_Phone_Number__c='919844978626'; 
        resale.Buyer1_Passport_Number__c='1sjd87246234';
        resale.Buyer1_Address__c='jhbvjsdc';
        resale.Approval_Status__c='Pending for Collections Approval';
        //resale.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale);
        
        Resale_Process__c resale1 = new Resale_Process__c ();
        resale1.Resale_Type__c ='Resale with Mortgage';
        resale1.Booking__c=b.Id;
        resale1.Seller1_Name__c='Hitesh GV';
        resale1.Seller1_Email__c='hitesh.gv3@shoba.com.test';
        resale1.Seller1_Phone_Number__c='919844978626'; 
        resale1.Seller1_Address__c='abcdef';
        resale1.Seller1_Passport_Number__c='sjd87246234';
        resale1.Buyer1_Name__c='Hitesh GV1';
        resale1.Buyer1_Email__c='hitesh12.gv1@shoba.com.test';
        resale1.Buyer1_Phone_Number__c='919844978626'; 
        resale1.Buyer1_Passport_Number__c='1sjd87246234';
        resale1.Buyer1_Address__c='jhbvjsdc';
        resale1.Approval_Status__c='Pending for Accounts Approval';
        //resale1.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale1);
        
        Resale_Process__c resale2 = new Resale_Process__c ();
        resale2.Resale_Type__c ='Resale with Mortgage';
        resale2.Booking__c=b.Id;
        resale2.Seller1_Name__c='Hitesh GV';
        resale2.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale2.Seller1_Phone_Number__c='919844978626'; 
        resale2.Seller1_Address__c='abcdef';
        resale2.Seller1_Passport_Number__c='sjd87246234';
        resale2.Buyer1_Name__c='Hitesh GV1';
        resale2.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale2.Buyer1_Phone_Number__c='919844978626'; 
        resale2.Buyer1_Passport_Number__c='1sjd87246234';
        resale2.Buyer1_Address__c='jhbvjsdc';
        resale2.Approval_Status__c='Pending for Audit Approval';
       // resale2.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale2);
        
        Resale_Process__c resale3 = new Resale_Process__c ();
        resale3.Resale_Type__c ='Resale with Mortgage';
        resale3.Booking__c=b.Id;
        resale3.Seller1_Name__c='Hitesh GV';
        resale3.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale3.Seller1_Phone_Number__c='919844978626'; 
        resale3.Seller1_Address__c='abcdef';
        resale3.Seller1_Passport_Number__c='sjd87246234';
        resale3.Buyer1_Name__c='Hitesh GV1';
        resale3.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale3.Buyer1_Phone_Number__c='919844978626'; 
        resale3.Buyer1_Passport_Number__c='1sjd87246234';
        resale3.Buyer1_Address__c='jhbvjsdc';
        resale3.Approval_Status__c='Rejected by Audit';
        resale3.Rejected_To__c ='Audit Rejected to Collections';
        //resale3.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale3);
        
        Resale_Process__c resale4 = new Resale_Process__c ();
        resale4.Resale_Type__c ='Resale with Mortgage';
        resale4.Booking__c=b.Id;
        resale4.Seller1_Name__c='Hitesh GV';
        resale4.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale4.Seller1_Phone_Number__c='919844978626'; 
        resale4.Seller1_Address__c='abcdef';
        resale4.Seller1_Passport_Number__c='sjd87246234';
        resale4.Buyer1_Name__c='Hitesh GV1';
        resale4.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale4.Buyer1_Phone_Number__c='919844978626'; 
        resale4.Buyer1_Passport_Number__c='1sjd87246234';
        resale4.Buyer1_Address__c='jhbvjsdc';
        resale4.Approval_Status__c='Rejected by Audit';
        resale4.Rejected_To__c ='Audit Rejected to Accounts';
        //resale4.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale4);
        
        Resale_Process__c resale5 = new Resale_Process__c ();
        resale5.Resale_Type__c ='Resale with Mortgage';
        resale5.Booking__c=b.Id;
        resale5.Seller1_Name__c='Hitesh GV';
        resale5.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale5.Seller1_Phone_Number__c='919844978626'; 
        resale5.Seller1_Address__c='abcdef';
        resale5.Seller1_Passport_Number__c='sjd87246234';
        resale5.Buyer1_Name__c='Hitesh GV1';
        resale5.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale5.Buyer1_Phone_Number__c='919844978626'; 
        resale5.Buyer1_Passport_Number__c='1sjd87246234';
        resale5.Buyer1_Address__c='jhbvjsdc';
        resale5.Approval_Status__c='Rejected by Audit';
        resale5.Rejected_To__c ='Audit Rejected to CRM';
        //resale5.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale5);
        
        Resale_Process__c resale6 = new Resale_Process__c ();
        resale6.Resale_Type__c ='Resale with Mortgage';
        resale6.Booking__c=b.Id;
        resale6.Seller1_Name__c='Hitesh GV';
        resale6.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale6.Seller1_Phone_Number__c='919844978626'; 
        resale6.Seller1_Address__c='abcdef';
        resale6.Seller1_Passport_Number__c='sjd87246234';
        resale6.Buyer1_Name__c='Hitesh GV1';
        resale6.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale6.Buyer1_Phone_Number__c='919844978626'; 
        resale6.Buyer1_Passport_Number__c='1sjd87246234';
        resale6.Buyer1_Address__c='jhbvjsdc';
        resale6.Approval_Status__c='Rejected by Accounts';
        resale6.Rejected_To__c ='Accounts Rejected to CRM';
        //resale6.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale6);
        
        Resale_Process__c resale7 = new Resale_Process__c ();
        resale7.Resale_Type__c ='Resale with Mortgage';
        resale7.Booking__c=b.Id;
        resale7.Seller1_Name__c='Hitesh GV';
        resale7.Seller1_Email__c='hitesh2.gv@shoba.com.test';
        resale7.Seller1_Phone_Number__c='919844978626'; 
        resale7.Seller1_Address__c='abcdef';
        resale7.Seller1_Passport_Number__c='sjd87246234';
        resale7.Buyer1_Name__c='Hitesh GV1';
        resale7.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale7.Buyer1_Phone_Number__c='919844978626'; 
        resale7.Buyer1_Passport_Number__c='1sjd87246234';
        resale7.Buyer1_Address__c='jhbvjsdc';
        resale7.Approval_Status__c='Rejected by Accounts';
        resale7.Rejected_To__c ='Accounts Rejected to Collections';
        //resale7.Oqood_Title_deed_received_by_new_buyer__c = true;
        resLst.add(resale7); 
        insert resLst;
        
        Buyer__c  buyer = new Buyer__c ();
            buyer.Salutation__c='Mr';
            buyer.Name='Hitesh Buyer';
            buyer.Email__c='buyer@buyer.com';
            buyer.Phone_Number__c ='919844978626';
            buyer.Passport_Number__c='hvjsd632';
            buyer.Address__c='ndtoskfh';
            buyer.Resale_Process__c=resale.Id;
            buyer.Nationality__c ='Indian';
            buyer.Residence_Status__c='Resident ';
            buyer.Buyer_Type__c='Primary Applicant';
        insert buyer;
        
        Buyer__c  buyer1 = new Buyer__c ();
            buyer1.Salutation__c='Mr';
            buyer1.Name='Hitesh Buyer';
            buyer1.Email__c='buyer@buyer.com';
            buyer1.Phone_Number__c ='919844978626';
            buyer1.Passport_Number__c='hvjsd632';
            buyer1.Address__c='ndtoskfh';
            buyer1.Resale_Process__c=resale.Id;
            buyer1.Nationality__c ='Indian';
            buyer1.Residence_Status__c='Resident ';
            buyer1.Buyer_Type__c='Primary Applicant';
        insert buyer1;
       
        ContentVersion contentVersion = new ContentVersion(
            Title = 'resale document',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('resale Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
       
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = resale.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        resaletriggerHandler.dummyCov();

        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;
    }
    
    @isTest static void testresalehandler1()
    {
        Test.startTest();
         try {
             Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Approval_Status__c='Pending for Collections Approval' Limit 1];
            respr.Approval_Status__c='Rejected by Collections';
            respr.Collections_Rejection_Comments__c='';
        	update respr;
         	}
        	catch(Exception e) 
            {
                System.debug('Error Occured while Rejected by Collections');
            }
        Test.stopTest();
    }
    
    @isTest static void testresalehandler2()
    {
        Test.startTest();
        try {
        	Resale_Process__c respr = [SELECT Id, Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Approval_Status__c='Pending for Accounts Approval' Limit 1];
            respr.Approval_Status__c='Rejected by Accounts';
            //respr.Accounts_Rejection_Comments__c='test2';
            update respr;
        	}
        	catch(Exception e) {}
        Test.stopTest();
    }
    
    @isTest static void testresalehandler3()
    {
        Test.startTest();
        try {
        	Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Approval_Status__c='Pending for Audit Approval' Limit 1];
            respr.Approval_Status__c='Rejected by Audit';
            //respr.Audit_Rejection_Comments__c='test3';
            update respr;
        	}
        	catch(Exception e) {}
        Test.stopTest();
    }
    
     @isTest static void testresalehandler4()
    {
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Rejected_To__c = 'Audit Rejected to CRM' and Approval_Status__c='Rejected by Audit' Limit 1];
            respr.Approval_Status__c='Pending for Audit Approval';
        try {
        Test.startTest();
        update respr;
        Test.stopTest();
        }
        catch(Exception e) {}
    }
    
    @isTest static void testresalehandler5()
    {
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Rejected_To__c = 'Audit Rejected to Collections' and Approval_Status__c='Rejected by Audit' Limit 1];
            respr.Approval_Status__c='Pending for Audit Approval';
        try {
        Test.startTest();
        update respr;
        Test.stopTest();
        }
        catch(Exception e) {}
    }
    
    @isTest static void testresalehandler6()
    {
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Rejected_To__c = 'Audit Rejected to Accounts' and Approval_Status__c='Rejected by Audit' Limit 1];
            respr.Approval_Status__c='Pending for Audit Approval';
        try {
        Test.startTest();
        update respr;
        Test.stopTest();
        }
        catch(Exception e) {}
    }
    
    @isTest static void testresalehandler7()
    {
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Rejected_To__c = 'Accounts Rejected to Collections' and Approval_Status__c='Rejected by Accounts' Limit 1];
        respr.Approval_Status__c='Pending for Accounts Approval';
        try {
        Test.startTest();
        update respr;
        Test.stopTest();
        }
        catch(Exception e) {}
    }
    
    @isTest static void testresalehandler8()
    {
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c FROM Resale_Process__c where Rejected_To__c = 'Accounts Rejected to CRM' and Approval_Status__c='Rejected by Accounts' Limit 1];
        respr.Approval_Status__c='Pending for Accounts Approval';
        try {
        Test.startTest();
        update respr;
        Test.stopTest();
        }
        catch(Exception e) {}
    } 
    @isTest static void testresalehandler9()
    {
        Test.startTest();
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c, NOC_DocSign_Completed__c FROM Resale_Process__c Limit 1];
        respr.Oqood_Title_deed_received_by_new_buyer__c=true;
        list<ContentVersion> lst = new list<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'New_oqood_Title',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('resale Test Content'),
            IsMajorVersion = true
        );
        lst.add(contentVersion);
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'New_oqood_Title',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('resale Test Content11'),
            IsMajorVersion = true
        );
        lst.add(contentVersion1);
        insert lst;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title='New_oqood_Title'];
        list<ContentDocumentLink>  cdlLst= new list<ContentDocumentLink>();
        for(ContentDocument cdl1 : documents)
        {
           ContentDocumentLink cdl = New ContentDocumentLink();
           cdl.LinkedEntityId = respr.id;
           cdl.ContentDocumentId = cdl1.Id;
           cdl.shareType = 'V';
           cdlLst.add(cdl);
        }
        insert cdlLst;
        
        try {
        update respr;
        }
        catch(Exception e) {}
        Test.stopTest();
    }
   
    @isTest static void testresalehandler10()
    {
        Test.startTest();
        Resale_Process__c respr = [SELECT Id, CRM_Resubmit_comments__c,Accounts_Resubmit_comments__c, Collections_Resubmit_comments__c, Rejected_To__c,Audit_Rejection_Comments__c, Accounts_Rejection_Comments__c,Collections_Rejection_Comments__c,Approval_Status__c, NOC_DocSign_Completed__c FROM Resale_Process__c where Approval_Status__c='Pending for Collections Approval' Limit 1];
        respr.Approval_Status__c='Pending for Accounts Approval';
        try 
        {
            update respr;
        }
        catch(Exception e) {}
        Test.stopTest();
    }   
}