@isTest
public class UserTriggerHelper_Test {
    @TestSetup 
    static void setupData() {
        User u = TestDataFactorySobha.createUser(null);
        u.FirstName = 'Test';
        u.MobilePhone = '1125452';
        insert u;
        
        User u2 = TestDataFactorySobha.createUser(null);
        u2.FirstName = 'Test2';
        u2.MobilePhone = '1125452';
        u2.isActive = FALSE;
        insert u2;  
    }
        
    @isTest 
    static void testUserDeactive() {
        User u = TestDataFactorySobha.createUser(null);
        u.FirstName = 'Testing';
        u.MobilePhone = '1125452';
        insert u;
        
        u.isActive = FALSE;
        update u;
    }
    
    @isTest 
    static void testUserActive() {
        User usr = [SELECT Id FROM User WHERE isActive = FALSE LIMIT 1];
        usr.isActive = TRUE;
        update usr;
    }
    
    
    @isTest
    static void sendToMobileAPIUser() { 
        Id usrId  = [SELECT Id FROM User WHERE isActive = TRUE LIMIT 1].Id;
        Set<Id> usrSet = new Set<Id>();
        usrSet.add(usrId);
        userTriggerHelper.sendToMobileAPIUser(usrSet);
    }
}