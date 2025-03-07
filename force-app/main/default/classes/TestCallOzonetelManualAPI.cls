@isTest
public class TestCallOzonetelManualAPI {
    
    @isTest
    public static void testOzonetelCallout(){
        
        Set<Id> leadIdSet = new Set<Id>();
      
        
        Project__c p = new Project__c(Name = 'Test Pro', Project_Code__c = 'te02');
        insert p;
        
        Project__c p1 = new Project__c(Name = 'Test Pr', Project_Code__c = 'te01');
        insert p1;
        
        Lead l = new lead();
        l.LastName = 'CTI Missed Call lead';
        l.MobilePhone = '7880026529';
        l.Project__c = p.Id;  
      //  l.RecordTypeId = [Select Id, Name, sObjectType from RecordType where sObjectType='Lead' AND Name='New lead'].Id;
        l.auto_assign__c = true;
        l.Campaign_Code__C = 'camp';
        l.Is_Auto_Calling__c = true;
        insert l;
        leadIdSet.add(l.Id);
        
        Lead l1 = new lead();
        l1.LastName = 'Test without Proj';
        l1.Phone = '9876543210';
        l1.auto_assign__c = true;
        insert l1;
        leadIdSet.add(l1.Id);
        
        l1.Campaign_Code__C = 'camp';
        update l1;
        
        Lead l2 = new lead();
        l2.LastName = 'Test UAE';
        l2.RDS_Country_Code__c = '+971';
        l2.RDS_Country__c = 'United Arab Emirates';
        l2.MobilePhone = '545823865';
        l2.Project__c = p.Id;  
        l2.auto_assign__c = true;
        l2.Campaign_Code__C = 'camp';
        l2.Website_Language__c ='en';
        insert l2;
        leadIdSet.add(l2.id);
        
        Lead l4 = new lead();
        l4.LastName = 'Test India local';
        l4.RDS_Country_Code__c = '091';
        l4.RDS_Country__c = 'India';
        l4.MobilePhone = '1158238652';
        l4.Project__c = p.Id;  
        l4.auto_assign__c = true;
        l4.Campaign_Code__C = 'camp';
        l4.Website_Language__c ='en';
        insert l4;
        leadIdSet.add(l4.id);
        
        
        Lead l3 = new lead();
        l3.LastName = 'Test Global';
        l3.RDS_Country_Code__c = '++92';
        l3.RDS_Country__c = 'Pakistan';
        l3.MobilePhone = '3423467600';
        l3.Project__c = p.Id;  
        l3.auto_assign__c = true;
        l3.Campaign_Code__C = 'camp';
        insert l3;
        leadIdSet.add(l3.Id);
        
        
        Lead l6 = new lead();
        l6.LastName = 'Test Default';       
        l6.MobilePhone = '1158238552';
        l6.RDS_Country__c = '';
        l6.RDS_Country_Code__c = '';
        l6.Project__c = p.Id;  
        l6.auto_assign__c = true;
        l6.Campaign_Code__C = 'camp';
        insert l6;
        leadIdSet.add(l6.Id);
      
             
        Lead l9 = new lead();
        l9.LastName = 'Test Missed Call';
        l9.RDS_Country__c = 'United States';
        l9.MobilePhone = '7758234452';
        l9.Project__c = p.Id;  
        l9.auto_assign__c = true;
        l9.Campaign_Code__C = 'camp';
        l9.New_Missed_Call_Lead__c = True;
        insert l9;
        leadIdSet.add(l9.Id);
        
        
        Language_based_Ozonetel__c ol = New Language_based_Ozonetel__c();
        ol.Name = 'Local';
        ol.api_key__c = '123';
        ol.country__c = 'United Arab Emirates';
        ol.skill__c = 'en';
        ol.Priority__c = '1';
        ol.ozonetel_outbound_campaign__c = 'testcampaign';
        
        insert ol;
        
        Language_based_Ozonetel__c ol3 = New Language_based_Ozonetel__c();
        ol3.Name = 'Local';
        ol3.api_key__c = '123';
        ol3.country__c = 'India';
        ol3.skill__c = 'en';
        ol3.Priority__c = '1';
        ol3.ozonetel_outbound_campaign__c = 'testcampaign';
        
        insert ol3;
        
        Language_based_Ozonetel__c ol1 = New Language_based_Ozonetel__c();
        ol1.Name = 'Default';
        ol1.api_key__c = '123';
        //ol1.country__c = 'United Arab Emirates';
        ol1.skill__c = 'en';
        ol1.Priority__c = '1';
        ol1.ozonetel_outbound_campaign__c = 'testcampaign';
        
        insert ol1;
        
        Language_based_Ozonetel__c ol2 = New Language_based_Ozonetel__c();
        ol2.Name = 'Global English';
        ol2.api_key__c = '123';       
        ol2.skill__c = 'en';
        ol2.Priority__c = '1';
        ol2.ozonetel_outbound_campaign__c = 'testcampaign';
        
        insert ol2;
           
                
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CallOzonetelMockImp()); 
        
       
        
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        callOzonetelManualAPI.makeaCall(leadIdSet);
        
         // Verify that a fake result is returned
        //System.assertEquals('Mock response', output); 
    }
}