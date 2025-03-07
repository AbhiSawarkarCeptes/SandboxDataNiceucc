@istest
public class Test_MB_LeadTriggerHandler {
	
    @TestSetup
    static void setupData() {
        List<Lead> leadInsertList = new List<Lead>();
        for(Integer i=0; i<5; i++){
            //Lead l = new Lead(firstName = 'first' , lastName='TestSobhaPR' + i, Email='TestSobhaPR' +i +'@testSobha.ae' , mobilePhone='123456789' + i);            
            Lead ld = new Lead(lastname = 'TestSobhaPR'+i, MobilePhone='5037483948', 
                               email='testsobhapr'+i+'@testsobha.ae', firstname='firstNameSBPR'+i, RDS_Country__c='United Arab Emirates');
            leadInsertList.add(ld);
        }
        insert leadInsertList;
    }
    
    @isTest
    static void leadInsertTestMethod() {
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Test';
        List<Lead> leadQryList = [SELECT Id, firstName, lastname, email, mobilePhone,RDS_Country__c FROM Lead LIMIT 100];
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        	LeadTriggerHandler.sendToMobileAPI(JSON.serialize(leadQryList),null);
        Test.stopTest();
    }
    
    @isTest
    static void leadUpdateTestMethod() {
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Test';
        
        Map<Id, Lead> mapOldList = new Map<Id, Lead>([SELECT Id, firstName, lastname, email, mobilePhone,RDS_Country__c FROM Lead]);
        List<Lead> leadList = [SELECT Id, firstName, lastname, email, mobilePhone,RDS_Country__c FROM Lead];
        Integer k=5; List<Lead> updateLeadList = new List<Lead>();
        
        //List<Lead> leadList = new List<Lead>(mapOldList.values());
       	
        for(Lead lds: leadList){
            lds.lastname = 'TestsSobhaRP'+k;
            lds.Email = 'TestSobhaPR' +k +'@testSobha.ae';
            lds.firstName = 'firstNameSBRP'+k;
            lds.MobilePhone='5037483748';
            lds.RDS_Country_Code__c = 'India';
            k++;
            updateLeadList.add(lds);
        }
        update updateLeadList;
        
        
        system.debug('~!NewVal: '+updateLeadList);
        system.debug('~!OldVal: '+mapOldList);
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK')); 
        	LeadTriggerHandler.sendToMobileAPI(JSON.serialize(updateLeadList),JSON.serialize(mapOldList));
        Test.stopTest();
        
    } 
    
    
    
}