@isTest
public class S_CollectionsDashboardNewCont_PS_Test {
	@isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User usr = TestDataFactorySobha.createUser(NULL);
        insert usr;
        Test.startTest();
        Account testAccount = TestDataFactorySobha.createAccount(null);
        insert testAccount;
        
        //contact testContact = TestDataFactorySobha.createContact(null);
        Contact testContact = new Contact();
        testContact.FirstName = 'Test' + DateTime.now();
        testContact.LastName = 'testKYCForm';
        testContact.Email = 'test@test.com';
        testContact.MobilePhone = '1234567891';
        testContact.MailingStreet = 'Test';
        testContact.Passport_No__c = '12346';
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testContact;
        
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Payment_Plan__c ppd = TestDataFactorySobha.createPaymentPlan(null);
        insert ppd;
        
        PropStrength__Request__c enq  = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c ptower = TestDataFactorySobha.createTower(null);
        insert ptower;
        
        PageReference pRef = Page.S_CollectionsDashboardNew_PS;
        Test.setCurrentPage(pRef);
        S_CollectionsDashboardNewController_PS cd1 = new S_CollectionsDashboardNewController_PS();
        List <SelectOption> proList1 = cd1.lstProjects;
        cd1.selectedProjectId = proj.Id;     
        List<SelectOption> towerList1 = cd1.lstTowers;     
        cd1.selectedTowerId = ptower.Id;
        List<SelectOption> rmList1 = cd1.getRMs;
        cd1.selectedRM = 'All';
        cd1.getDemandReciepts();
        
        cd1.searchByName = 'Test';
        cd1.getDemandReciepts();
        cd1.Next();
        cd1.getDisableNext();
        cd1.Previous();
        cd1.getDisablePrevious();
        cd1.End();        
        cd1.Beginning();       
        cd1.clearSearch();
        Test.stopTest(); 
        /* Second Tab */
        cd1.selectedProjectIdF = proj.Id;
        List<SelectOption> towerListF1 = cd1.lstTowersF;
        cd1.selectedTowerIdF = ptower.Id;
        List<SelectOption> rmListF1 = cd1.getRMsF;
        cd1.selectedRMF = 'All';
        
        cd1.selectedRadioOption = 'Today';
        cd1.getRadioPanel(); 
        cd1.followupsearchByName = 'Test';
        cd1.clearSearchFollowUp();
        
        cd1.selectedRadioOption = 'Pending';
        cd1.getRadioPanel(); 
        cd1.NextF();
        cd1.getDisableNextF();
        cd1.PreviousF();
        cd1.getDisablePreviousF();
        cd1.EndF();
        cd1.BeginningF();        
        cd1.followupsearchByName = 'Test';
        cd1.clearSearchFollowUp();
        
        cd1.selectedRadioOption = 'PendingDLD';
        cd1.getRadioPanel(); 
        cd1.followupsearchByName = 'Test';
        cd1.clearSearchFollowUp();
        cd1.getTotal_size();
        cd1.getPageNumber();
        cd1.getTotalPages();
        cd1.getTotal_sizeF();
        cd1.getPageNumberF();
        cd1.getTotalPagesF();
    }
}