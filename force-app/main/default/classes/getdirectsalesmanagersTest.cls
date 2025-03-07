@isTest
public class getdirectsalesmanagersTest {
    

	 @isTest static void testmethod1() 
     {
        Direct_Sales_Managers__c dsms = new Direct_Sales_Managers__c();
        dsms.Sales_Manager__c=userinfo.getuserid();
        dsms.Availability_Status__c=true;
        insert dsms;
        Test.startTest();
         getdirectsalesmanagers gdsm = new getdirectsalesmanagers();
         getdirectsalesmanagers.getsalesmanagers();
        Test.stopTest();
     }


}