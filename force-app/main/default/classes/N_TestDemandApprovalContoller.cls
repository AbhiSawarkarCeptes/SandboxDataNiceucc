@isTest
public class N_TestDemandApprovalContoller {

@isTest
private static void testDemandsApproval(){

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Collection'];
    User u1 = createUser('Test1', 'Testsobha', 'testabcde1234@stetig.in', 'testabcde1234@stetig.in', p);
    
    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Finance'];
    User u2 = createUser('Test1', 'Testsobha1', 'testabcde123@stetig.in', 'testabcde123@stetig.in', p1);
    
    Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Audit'];
    User u3 = createUser('Test1', 'Testsobha2', 'testabcde12@stetig.in', 'testabcde12@stetig.in', p2);
    
    Profile p3 = [SELECT Id FROM Profile WHERE Name = 'CFO'];
    User u4 = createUser('Test1', 'Testsobha3', 'testabcde1@stetig.in', 'testabcde1@stetig.in', p3);
    
    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerid = recordMap.get('TOWER');
    
    Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
    
    Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
    
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    pm1.Charge_1_Lookup__c =  recordMap.get('BASIC');
    update pm1;
    
     Booking__c b = new Booking__c();
     b.Booking_Date__c = system.now().addDays(-10);
     b.Project__c = recordMap.get('PROJECT');
     b.Opportunity__c = optyId;
     b.Unit__c = unitId;
     b.status__c = 'Processed';
     b.Quotation__c = quote.Id;
     b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
     b.Future_Correspondence_Contact__c = 'First Applicant';
     b.Agreement_Value__c = 6000000;
     b.Stage_of_Booking__c = 'Booked';
     insert b;
     
     quote.Booking__c = b.Id;
     update quote;
     
     Opportunity opp = [SELECT Id, StageName FROM Opportunity  WHERE Id = :optyId];
     opp.StageName = 'Booking confirmed';
     opp.S_Active__c = true;
     opp.Unit__c = unitId;
     update opp;
     
     Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
     u.Unit_Status__c = 'Sold';
     u.Booking__c = b.Id;
     u.Customers__c = opp.Id;
     update u;
   
    Test.startTest();  
    System.runAs(u1){      
      PageReference pRef1 = Page.DemandApprovalPage;
      Test.setcurrentPage(pRef1);
      DemandApprovalContoller d1 = new DemandApprovalContoller();
      Apexpages.currentPage().getParameters().put('towerName', tower.Name);
      Apexpages.currentPage().getParameters().put('projectName', 'Sobha');
      d1.getCustomersTowerWise();
      d1.singleDemandPreviewId = [Select Id, Name from Payment_Milestones__c LIMIT 1].Id;
      d1.groupDemandPreviewId = unitId;
      PageReference previewPage = d1.showPreview();
      Test.setCurrentPage(previewPage);
      DemandViewNew dView = new DemandViewNew();
      d1.CustomerWrapperMap.get(unitId).groupSelect = true;
      d1.SubmitMultipleDemands();   
      d1.Beginning();
      d1.Next();
      d1.Previous();     
      d1.End();
      d1.getDisablePrevious();
      d1.getDisableNext();
      d1.getTotal_size();
      d1.getPageNumber();
      d1.getTotalPages();
    }
    
    pm1.Collection_Status__c = 'Submitted';
    update pm1;
    
    System.runAs(u2){     
      PageReference pRef2 = Page.DemandApprovalPage;
      Test.setcurrentPage(pRef2);
      DemandApprovalContoller d2 = new DemandApprovalContoller();
      Apexpages.currentPage().getParameters().put('towerName', tower.Name);
      Apexpages.currentPage().getParameters().put('projectName', 'Sobha');
      d2.getCustomersTowerWise();
      d2.CustomerWrapperMap.get(unitId).groupSelect = true;
      d2.AcceptMultipleDemands();
    }
    
    pm1.Finance_Status__c = 'Accepted';
    update pm1;
    
     System.runAs(u3){     
      PageReference pRef3 = Page.DemandApprovalPage;
      Test.setcurrentPage(pRef3);
      DemandApprovalContoller d3 = new DemandApprovalContoller();
      Apexpages.currentPage().getParameters().put('towerName', tower.Name);
      Apexpages.currentPage().getParameters().put('projectName', 'Sobha');
      d3.getCustomersTowerWise();
      d3.CustomerWrapperMap.get(unitId).groupSelect = true;
      d3.AcceptMultipleDemands();
    }
    
    pm1.Audit_Status__c = 'Accepted';
    update pm1;
    
     System.runAs(u4){     
      PageReference pRef4 = Page.DemandApprovalPage;
      Test.setcurrentPage(pRef4);
      DemandApprovalContoller d4 = new DemandApprovalContoller();
      Apexpages.currentPage().getParameters().put('towerName', tower.Name);
      Apexpages.currentPage().getParameters().put('projectName', 'Sobha');
      d4.getCustomersTowerWise();
      d4.CustomerWrapperMap.get(unitId).groupSelect = true;  
      d4.CustomerWrapperMap.get(unitId).Remarks = 'Rejected';    
      d4.RejectMultipleDemands();  
    }        
    Test.stopTest();
 }
 
  private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
       
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
               
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    }
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Milestone_Due_Date__c = System.today().addDays(10);
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';        
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 0;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;
     }
     
    public static User createUser(string fn, string ln, string username, string email, Profile pro) {
    
    Id umanager = UserInfo.getUserId();

    User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = pro.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230', ManagerId = umanager);
    insert u;
    return u;
    
  }
}