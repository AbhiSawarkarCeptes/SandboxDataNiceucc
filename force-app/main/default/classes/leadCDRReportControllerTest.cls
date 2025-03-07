/***************
Name: leadCDRReportControllerTest
Author: PR-SHOBA
Description: Used to cover Test coverage for the class 'leadCDRReportController'
******************/
@isTest
public class leadCDRReportControllerTest {

   @testSetup static void setup() {
		
        Project__c proj = new Project__c(
        	Name = 'Test Proj1',
            Project_Code__c = 'P1121',
            Expiry_Days__c = 2,
            PossessionRequirement__c = 'Ready to Move in (RTMI)',
            Configuration__c = '1 BHK'
        );
       Insert proj;
       
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Presales'].Id,
             LastName = 'last',
             Email = 'testerRP@tesreco.com',
             Username = 'testerRP@tesreco.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'Asia/Dubai',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        List<Lead> testLead = new List<Lead>();
        for(Integer i=0;i<2;i++) {
            testLead.add(new Lead(
                lastname = 'TestAcct'+i, 
                email = 'testrps'+i+'@teserew.co', 
                Presales_Agent__c=u.Id,
                Project__c = proj.Id
            ));
        }
        insert testLead;        
    }
    
    @isTest
    static void getCDRLeadRecordsTest(){
        List<Lead> leadList =[Select Id from Lead Limit 100];
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadList[0].id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
 
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        leadCDRReportController.getCDRLeadRecords();
    }
}