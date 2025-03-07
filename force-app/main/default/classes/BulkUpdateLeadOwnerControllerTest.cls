@isTest
public class BulkUpdateLeadOwnerControllerTest {
    @isTest public static void validateReassignOwner(){
        Project__c p =new Project__c();
        p.Name='Test Project';
        p.City__c = 'Test ProjectCity';
        p.PossessionRequirement__c = 'Ready to Move in';
        p.Configuration__c = '3 BHK';
        p.Max_Budget__c = 100;
        p.Min_Budget__c = 10;
        p.Project_Code__c = 'Test';
        p.Expiry_Days__c = 10;
        insert p;
        
        Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        insert c;
        User user1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');
        List<group> superAgentEnglishQueue = [SELECT ID,DeveloperName  FROM group WHERE  DeveloperName = 'Telesales_Agent'];
        string queueId = superAgentEnglishQueue[0].id;
        Assignment_Group_Name__c agn = new Assignment_Group_Name__c();
        agn.Name = 'test';
        agn.Type__c = 'lead';
        insert agn;
        
        Assignment_Group_Queues__c ag = new Assignment_Group_Queues__c();
        ag.Name = 'telesales';
        ag.QueueId__c = queueId;
        ag.Type__c = 'Lead';
        ag.Active__c = 'true';
        ag.Assignment_Group_Name__c = agn.Id;
        insert ag;
        
        Assignment_Groups__c agr = new Assignment_Groups__c();
        agr.Group_Name__c = agn.id;
        agr.Active__c = 'true';
        agr.Millisecond__c = 34;
        agr.User__c = user1.id;
        insert agr;
        
        Lead l1 = new Lead();
        l1.lastname='Test1';
        l1.MobilePhone = '1234567891';
        l1.Project__c =p.ID;
        l1.RDS_Country__c ='Test India';
        l1.Campaign_Code__c='Test Campaign';
        l1.ownerId = queueId;
        insert l1;
        
        list<Lead> l = [select id,Lead_Id__c from Lead where Id=:l1.Id];
        
        PageReference pRef = Page.BulkUpdateLeadOwner;
        Test.setCurrentPage(pRef); 
        BulkUpdateLeadOwnerController con = new BulkUpdateLeadOwnerController(null);
        con.inputLeadIds=l[0].Lead_Id__c;
        con.selectedLead = l;
        con.save();
        con.cancel();
    }
}