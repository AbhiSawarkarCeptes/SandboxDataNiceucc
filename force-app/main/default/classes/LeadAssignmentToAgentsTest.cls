@isTest
public class LeadAssignmentToAgentsTest {
    
    @testSetup
    static void dataSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Lead l = TestDataFactory.createLeadTemplate('test','test@gmail.com','12345678765',true);
            Lead_Hoping_Settings__c myCS2 = new Lead_Hoping_Settings__c();
            myCS2.Name='Lead hoping Queue Name';
            myCS2.Value__c ='TestQueue';
            Lead_Hoping_Settings__c myCS1 = new Lead_Hoping_Settings__c();
            myCS1.Name='Lead Assignment Group Name';
            myCS1.Value__c ='TestQueue';
            insert new List<Lead_Hoping_Settings__c>{myCS2,myCS1};
                Group g1 = new Group(Name=myCS2.Value__c, type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            l.ownerId = g1.Id;
            l.Lead_Sub_Source__c = 'social-facebook-instagram-uk-en';	
            
            User user1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');
            User user2 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron14566@radius.com', 'galvatron12345@radius.com');
            
            Assignment_Group_Name__c groupName = new Assignment_Group_Name__c();
            groupName.Name = myCS1.Value__c;
            insert groupName;
            
            Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
            assignmentGroup.User__c = user1.Id;
            assignmentGroup.Active__c = 'true';
            assignmentGroup.Name = myCS1.Value__c;
            assignmentGroup.Group_Name__c = groupName.Id;
            
            Assignment_Groups__c assignmentGroup1 = new Assignment_Groups__c();
            assignmentGroup1.User__c = user2.Id;
            assignmentGroup1.Active__c = 'true';
            assignmentGroup1.Name = 'Presales Agent';
            assignmentGroup1.Group_Name__c = groupName.Id;
            insert new List<Assignment_Groups__c>{assignmentGroup,assignmentGroup1};
                
                Assignment_Group_Queues__c gq = new Assignment_Group_Queues__c();
            gq.Active__c = 'True';
            gq.QueueId__c = g1.Id;
            gq.Assignment_Group_Name__c = groupName.id;
            insert gq;
            
            update l;
        }
    } 
    
    @isTest
    static void method1() {
        Database.executeBatch(new LeadAssignmentToAgents(),1); 
    }
    @isTest
    static void method2() {
        List<Assignment_Groups__c> assignmentGroup = [select id from Assignment_Groups__c];
        assignmentGroup[0].Is_Assigned__c = true;
        Update assignmentGroup;
        Database.executeBatch(new LeadAssignmentToAgents(),1); 
    }
    @isTest
    static void method3() {
        List<Assignment_Groups__c> assignmentGroup = [select id,user__c from Assignment_Groups__c ];
        List<Lead> leadList = new List<Lead>();
        leadList = [select id from Lead];
        LeadList[0].Round_Robin_Assigned_User_Id__c = assignmentGroup[0].user__c;
        update leadList;
        Database.executeBatch(new LeadAssignmentToAgents(),1); 
    }
    
    
}