@isTest
public class TestclickToCall {
    
      @istest
    public static void testOpportunity() {
                
      Account acc = createPATemplate('TestPA1' , 'testleada@stetig.in', '0564734561', false);
        acc.Country__c= 'United Arab Emirates';
        acc.Country_Code__c = '+971';  
        update acc;
                
        Account acc2 = createPATemplate('TestPA2' , 'testleada2@stetig.in', '0565399529', false);
        acc2.Country__c= 'United States';
        acc2.Country_Code__c = '01';  
        update acc2;
        
        Account acc3 = createPATemplate('TestPA2' , 'testleada23@stetig.in', '0575399529', false);
        acc3.Country__c= 'United States';
        acc3.Country_Code__c = '+1';  
        update acc3;
               
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US',OzoneTel_AgentId__c = 'Agent1', ProfileId = p.Id, 
                                customer__c = 'sobha_realty',
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com');
                
        insert objUser;
        objUser.Enable_International_Calling__c = true;
        objUser.API_Key__c = 'KK62c867af6382c2f02d59ada051728098';
        objUser.customer__c = 'sobha_realty';
        objUser.Campaign_Name__c = 'Inbound_97142049279';
        objUser.OzoneTel_AgentId__c = 'Agent1';    
        update objUser;
                
       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');*/
       Project__c pr = new Project__c();
       pr.Name = 'Sobha Hartland';
       pr.Project_Code__c = '001';
  //   pr.Cluster__c = 'Thane';
       insert pr;
                
                
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, pr.Id, 1);
        List<Opportunity>  oList2 = createOpptyForAccount(acc2.Id, pr.Id, 1);
        List<Opportunity>  oList3 = createOpptyForAccount(acc3.Id, pr.Id, 1);

              
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(oList[0]);
        CallActionControllerForOpportunity ue = new CallActionControllerForOpportunity(sc);
        CallActionControllerForOpportunity.getPhoneFields(oList[0].id);              
        //CallActionControllerForOpportunity.click2CallCloudagent (oList[0].id,'0564734561'); 
        CallActionControllerForOpportunity.click2CallCloudagent (oList[0].id);
               
        ApexPages.StandardController sc2 = new ApexPages.StandardController(oList2[0]);
        CallActionControllerForOpportunity ue2 = new CallActionControllerForOpportunity(sc2);
        CallActionControllerForOpportunity.getPhoneFields(oList2[0].id);   
        //CallActionControllerForOpportunity.click2CallCloudagent (oList[0].id,'0564734561');            
        CallActionControllerForOpportunity.click2CallCloudagent(oList2[0].id);   
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(oList2[0]);
        CallActionControllerForOpportunity ue3 = new CallActionControllerForOpportunity(sc2);
        CallActionControllerForOpportunity.getPhoneFields(oList3[0].id);   
        //CallActionControllerForOpportunity.click2CallCloudagent (oList[0].id,'0564734561');            
        CallActionControllerForOpportunity.click2CallCloudagent(oList3[0].id);   
        test.stoptest();
   }
    
    
    @istest
    public static void testLead() {
    
        Lead le = createLeadTemplate('TestLead1' , 'testlead2a@test.com', '9876544442', false);
        le.RDS_Country__c = 'United Arab Emirates';
        le.RDS_Country_Code__c = '+971';
        update le;
                
        Lead le2 = createLeadTemplate('TestLead2' , 'testleada2@test.com', '9873544442', false);
        le2.RDS_Country__c = 'United States';
        le2.RDS_Country_Code__c = '01';
        update le2; 
        
        Lead le3 = createLeadTemplate('TestLead2' , 'testleada23@test.com', '9873544642', false);
        le3.RDS_Country__c = 'United States';
        le3.RDS_Country_Code__c = '+1';
        update le3; 
               
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US',customer__c = 'Sobha_Realty', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com');
        insert objUser;
        objUser.Enable_International_Calling__c = true;
        objUser.API_Key__c = 'KK8fdef9562d2825864abd4467f8534c68';
        objUser.customer__c = 'Sobha_Realty';
        objUser.Campaign_Name__c = 'Inbound_918068442370';
        objUser.OzoneTel_AgentId__c = 'Agent1';    
        update objUser;
                
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(le);
        CallActionControllerForLead ue = new CallActionControllerForLead(sc);
        CallActionControllerForLead.getPhoneFields(le.id);               
        CallActionControllerForLead.click2CallCloudagent(le.id);
        //CallActionControllerForLead.click2CallCloudagent('9876544442');
        
                
        ApexPages.StandardController sc2 = new ApexPages.StandardController(le2);
        CallActionControllerForLead ue2 = new CallActionControllerForLead(sc2);
        CallActionControllerForLead.getPhoneFields(le2.id);
        CallActionControllerForLead.click2CallCloudagent(le2.id);
        //CallActionControllerForLead.click2CallCloudagent('9876544442');
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(le2);
        CallActionControllerForLead ue3 = new CallActionControllerForLead(sc2);
        CallActionControllerForLead.getPhoneFields(le3.id);
        CallActionControllerForLead.click2CallCloudagent(le3.id);
        //CallActionControllerForLead.click2CallCloudagent('9876544442');
        test.stoptest();
  }
    
    // creates  a person account with the basic parameters
  public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
    
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' 
                                               and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, personEmail = email, personMobilePhone  = Mobile, 
                                RecordType = personAccountRecordType, MasterRecord__c = isMaster, Country__c = 'test');
        
       insert a;
       return a;
   }  
   
  public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
    
        Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , Mobilephone = mobile, MasterRecord__c = isMaster);
        insert l;
        //l.RDS_Country__c = 'India';
       // l.RDS_Country_Code__c= '+91';
       // update l;
        return l;  
    }   
     
    public static Project__c createProject(String ProjName, String ProjectCode){
                
        Project__c objProject = new Project__c(Name = ProjName);
        insert objProject;
        return objProject;
    }
    
    public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
            
        List<Opportunity> oList = new List<Opportunity>();
        Date closeDate; 
        
        for(Integer i =0;i<numOfOpp; i++){
          closeDate = Date.newInstance(2015, 8,29);
            Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', Project__c = ProjId,closeDate=System.today()); //S_Budget_In_lacs__c = 5000000,Phone__c = '9876544442'
            oList.add(o);            
        }
        
        insert oList;
        return oList;
  }
}