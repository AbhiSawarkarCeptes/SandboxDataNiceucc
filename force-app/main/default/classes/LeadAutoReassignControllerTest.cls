@isTest
public class LeadAutoReassignControllerTest {
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
            
            User user1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvasdstron1@radius.com', 'galvdsdatron1@radius.com');
            User user2 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galscsdcvatron14566@radius.com', 'galvscscatron12345@radius.com');
            
            Assignment_Group_Name__c groupName = new Assignment_Group_Name__c();
            groupName.Name = 'Chennai Feb 2024';
            insert groupName;
            
            Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
            assignmentGroup.User__c = user1.Id;
            assignmentGroup.Rank__c = 1;
            assignmentGroup.Active__c = 'True';
            assignmentGroup.Name = myCS1.Value__c;
            assignmentGroup.Group_Name__c = groupName.Id;
            
            Assignment_Groups__c assignmentGroup1 = new Assignment_Groups__c();
            assignmentGroup1.User__c = user2.Id;
            assignmentGroup1.Rank__c = 2;
            assignmentGroup1.Active__c = 'True';
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
    static void test1() {
        Lead l = [select Id from lead limit 1];
        l.Last_Call_Attempt_Status__c = 'Not Actioned';
        l.Last_Processing_DateTime__c = system.now();
        l.IsReenquire__c = false;
        l.UTM_Campaign__c = 'RS-Chennai';
        update l;
        Test.startTest();
        LeadAutoReassignController.reassignLead(new list<Lead>{l});
        Test.stopTest();
    }
    
    @isTest
    static void test2() {
        Lead l = [select Id from lead limit 1];
        l.Last_Call_Attempt_Status__c = 'Not Actioned';
        l.Last_Processing_DateTime__c = system.now();
        l.IsReenquire__c = false;
        l.Route_To_Saturday_Queue1__c = true;
        update l;
        Test.startTest();
        LeadAutoReassignController.reassignLead(new list<Lead>{l});
        Test.stopTest();
    }
    
    @isTest
    static void test3() {
        Lead l = [select Id from lead limit 1];
        l.Last_Call_Attempt_Status__c = 'Not Actioned';
        l.Last_Processing_DateTime__c = system.now();
        l.IsReenquire__c = false;
        l.Route_To_Sunday_Queue1__c = true;
        update l;
        Test.startTest();
        LeadAutoReassignController.reassignLead(new list<Lead>{l});
        Test.stopTest();
    }
    
    @isTest
    static void test4() {
        Lead l = [select Id from lead limit 1];
        l.Last_Call_Attempt_Status__c = 'Not Actioned';
        l.Last_Processing_DateTime__c = system.now();
        l.IsReenquire__c = false;
        l.Web_Source__c = 'Facebook';
        update l;
        Test.startTest();
        LeadAutoReassignController.reassignLead(new list<Lead>{l});
        LeadAutoReassignController.reassignLead(new list<Lead>{new lead()});
        Test.stopTest();
    }
    
    @isTest
    static void test5() {
        Lead l = [select Id from lead limit 1];
        Test.startTest();
        LeadAutoReassignController.updateLeadToProcessing(l.Id);
        LeadAutoReassignController.updateLeadToProcessing('123');
        LeadAutoReassignController.insertErrorLog('test','test','test','test','test');
        map<string,string> leadShuffleConfigs = LeadAutoReassignController.getLeadShuffleConfigs();
        String utmCampaignCountries = string.valueOf(leadShuffleConfigs.get('UTM_Campaign_Countries'));
        LeadAutoReassignController.getCountryOrCityName(utmCampaignCountries,'Chennai');
        Test.stopTest();
    }
}