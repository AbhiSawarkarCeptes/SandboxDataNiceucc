@isTest
public class CaseRoundRobinTriggerHandlerTest {

    @testSetup
    public static void createRecords(){
        Assignment_Group_Name__c assignmentGroupName = new Assignment_Group_Name__c();
        assignmentGroupName.Type__c = 'Cases';
        assignmentGroupNamE.Name = 'Test';
        Insert assignmentGroupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.Active__c = 'True';
        assignmentGroup.Name = 'Test';
        assignmentGroup.Rank__c = 1;
        assignmentGroup.Group_Name__c = assignmentGroupName.Id;
        Insert assignmentGroup;
        
        Case c = new Case();
        c.Status = 'New';
        // c.CurrencyIsoCode = 'AED';
        c.Origin = 'Email';
        insert c;
        
    }
    
    @isTest
    public static void updateCaseOwnerWithGroupMembersTest(){
        List<Assignment_Group_Name__c> activeGroupMembers = [select Id, 
                                                           (select Id,User__c,Rank__c,User__r.Name from Assignment_Groups__r where Active__c='True'
                                                            AND User_Active__c='True' AND Rank__c!=null Order By Rank__c ASC) 
                                                           from Assignment_Group_Name__c where Name LIKE 'Test' LIMIT 1];
        System.debug('activeGroupMembers:'+activeGroupMembers);
        
        List<Case> cases = [SELECT id,CaseNumber,CreatedDate,OwnerId,Origin  FROM Case];
        CaseRoundRobinTriggerHandler.updateCaseOwnerWithGroupMembers(cases,true);
        
    }
    @isTest
    public static void updateCaseOwnerWithGroupMembersTest2(){
        Test.startTest();
        // Start the batch process
        CaseRoundRobinBatch ob = new CaseRoundRobinBatch();
        ob.execute(null);
        
        CaseRoundRobinBatch batch = new CaseRoundRobinBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    } 
    
    @isTest
    public static void updateNextIndex(){
        CaseRoundRobinTriggerHandler.updateNextIndex(1);
        CaseRoundRobinTriggerHandler.getNextIndex();
    } 
    
    @isTest
    public static void isWorkingHour(){
        CaseRoundRobinTriggerHandler.isWorkingHour(System.now());
    }
}