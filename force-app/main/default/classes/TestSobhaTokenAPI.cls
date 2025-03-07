@isTest
public class TestSobhaTokenAPI {
    

    static testMethod void testCallout() {
       Channel_Partner__c cp =New Channel_Partner__c();
       
       User u = [Select id, Name, Isactive,ManagerId from user where Isactive = true Limit 1];
       cp.Name = 'Test CP';
       cp.Sales_Manager__c = u.id;
       cp.Contact_Person__c = 'Test Contact Person';
       cp.Channel_Relationship_Manager__c = u.id;
       cp.Sales_Manager_s_Line_Manager__c = u.ManagerId;
       cp.Channel_Relationship_Head__c = u.ManagerId;
       cp.Mobile_No__c = '1334244555';
       cp.Is_Active__c =True;
       cp.Approval_Status__c ='Approved';
       Insert cp;
        
        Test.setMock(HttpCalloutMock.class, new SobhaTokenAPIMock());  
        SobhaTokenAPI.SobhaTokenAPIWrapper strResp = SobhaTokenAPI.doGet();
    }
    
    static testMethod void testCallout2() {
       Channel_Partner__c cp =New Channel_Partner__c();
       
       User u = [Select id, Name, Isactive,ManagerId from user where Isactive = true  Limit 1];
       cp.Name = 'CP';
       cp.Sales_Manager__c = u.id;
       cp.Contact_Person__c = 'Test Contact Person';
       cp.Channel_Relationship_Manager__c = u.id;
       cp.Sales_Manager_s_Line_Manager__c = u.ManagerId;
       cp.Channel_Relationship_Head__c = u.ManagerId;
       cp.Mobile_No__c = '1334244555';
       cp.Is_Active__c =True;
       cp.Approval_Status__c ='Approved';
       Insert cp;
        
        Test.setMock(HttpCalloutMock.class, new SobhaTokenAPIMock());  
        SobhaTokenAPI.SobhaTokenAPIWrapper strResp = SobhaTokenAPI.doGet();
    }
    
    static testMethod void testUserCallout() {
        SobhaTokenUserAPI.coverageMethod();
        Test.setMock(HttpCalloutMock.class, new SobhaTokenAPIMock());  
        SobhaTokenUserAPI.SobhaTokenAPIWrapper strResp = SobhaTokenUserAPI.doGet();
    }
}