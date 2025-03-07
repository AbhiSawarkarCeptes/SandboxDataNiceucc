@isTest
public class reEnquiryLayoutForTSAController_isTest {
    
    @isTest  
  static void TaskTest() {
    Project__c p = createProject('Xa_prj','111');
    Account acc = createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
               
    List<Lead> llist = createLead(3);
    List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 3);
   
      task t = new task();
      t.Subject = 'New Task';
      t.Task_Type__c = 'Sales Call';
      t.Call_Attempt_Status__c = 'No Contact';
      t.Next_Action_Date__c = System.today().adddays(5);
      t.activityDate = System.Today();
      t.whatId = oList[0].Id;
      t.UTM_Campaign__c = 'test';
      t.call_time__c = TaskManagementServices.FormatTime(system.now());
      insert t;
      
      reEnquiryLayoutForTSAController.getTaskData(lList[0].Id);

}
    
    public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
    }
    public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
    List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster);
    insert a;
    return a;
  }
    public static List<Lead> createLead(Integer numofLeads) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<numofLeads; i++) {            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i);            
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
    public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, Project__c = ProjId,closeDate=System.today());
      oList.add(o);            
    }
    insert oList;
    return oList;
  }
}