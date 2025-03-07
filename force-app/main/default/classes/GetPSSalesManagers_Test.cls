@isTest
public class GetPSSalesManagers_Test {
    @isTest
    static void testMethod1(){
        Profile prof = [SELECT id FROM Profile WHERE name = 'Sales'];
        UserRole ur = new UserRole(Name = 'Sales Manager 4');
        insert ur;
        Test.StartTest();
        User u = TestDataFactorySobha.createUser(null);
        u.ProfileId = prof.Id;
        u.UserRoleId = ur.Id;
        insert u;
        GetPSSalesManagers.GetPSSalesManagersData();
        Test.StopTest();
        
    }
}