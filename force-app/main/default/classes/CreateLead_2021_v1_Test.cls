@isTest
Private class CreateLead_2021_v1_Test {
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"Test":"Test"}');
            return res;
        }
    }
    @isTest
     static void methodName() {
        Lead l = new Lead();
        l.Email = 'pritam.polley@smaartt.com';
        l.Primary_Number__c = '0545549067'; 
        l.LastName = 'Pritam Polley';
         l.Last_Call_Attempt_Status__c = 'Visit Confirmed';
        insert l;
        
        Account acc = new Account();
        acc.LastName = 'Pritam Polley';
        acc.PersonEmail = 'pritam.polley@smaartt.com';
        acc.Phone = '0545549067';
        insert acc;
    }
    // Test method that has access to all data.
    @isTest(SeeAllData=false)
    static void testWithAllDataAccess() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
         List<group> superAgentEnglishQueue = [SELECT ID,Name FROM group WHERE  Name = 'Super Agent - English Language'];
        string queueId = superAgentEnglishQueue[0].id;
        Lead l = new Lead(ownerID = queueID);
         l.Email = 'pritam.polley@smaartt.com';
        l.Primary_Number__c = '00000'; 
        l.LastName = 'Pritam Polley';
        insert l;
    }
    Static TestMethod Void test() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        methodName();
        Project__c p = new Project__c();
        p.name = 'Test';
        p.Project_Code__c = 'p1234';
        insert p;
        String json = '['+
        '   {'+
        '      \"Name\":\"Pritam Polley\",'+
        '      \"Lead_Source\":\"\",'+
        '      \"Web_Source\":\"\",'+
        '      \"Lead_Sub_Source\":\"\",'+
        '      \"AD_Group\":\"\",'+
        '      \"Keyword\":\"\",'+
        '      \"Placement\":\"\",'+
        '      \"Channel_Cluster\":\"\",'+
        '      \"Goal\":\"\",'+
        '      \"Digital_Source\":\"\",'+
        '      \"UTM_Source\":\"\",'+
        '      \"UTM_Medium\":\"\",'+
        '      \"UTM_Campaign\":\"\",'+
        '      \"UTM_Content\":\"\",'+
        '      \"Last_Mile_Conversion\":\"\",'+
        '      \"Bid_Type\":\"\",'+
        '      \"Email\":\"pritam.polley@smaartt.com\",'+
        '      \"Dialing_Country\":\"\",'+
        '      \"Country_Code\":\"\",'+
        '      \"Mobile_Phone\":\"0545549067\",'+
        '      \"Phone\":\"\",'+
        '      \"Website_Language\":\"\",'+
        '      \"Project\":\"'+p.Id+'\",'+
        '      \"Project_Type\":\"\",'+
        '      \"Unit_Type\":\"\"'+
        '   }'+
        ']';
        RestRequest request = new RestRequest();
        request.requestUri ='https://sobharealty--sobhaqa.my.salesforce.com/services/apexrest/pushLead/2021/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        CreateLead_2021_v1.doPost();
    }
    Static TestMethod Void test2() {
        Project__c p = new Project__c();
        p.name = 'Test';
        p.Project_Code__c = 'p123';
        insert p;
        String json = '['+
        '   {'+
        '      \"Name\":\"Pritam Polley\",'+
        '      \"Lead_Source\":\"\",'+
        '      \"Web_Source\":\"\",'+
        '      \"Lead_Sub_Source\":\"\",'+
        '      \"AD_Group\":\"\",'+
        '      \"Keyword\":\"\",'+
        '      \"Placement\":\"\",'+
        '      \"Channel_Cluster\":\"\",'+
        '      \"Goal\":\"\",'+
        '      \"Digital_Source\":\"\",'+
        '      \"UTM_Source\":\"\",'+
        '      \"UTM_Medium\":\"\",'+
        '      \"UTM_Campaign\":\"\",'+
        '      \"UTM_Content\":\"\",'+
        '      \"Last_Mile_Conversion\":\"\",'+
        '      \"Bid_Type\":\"\",'+
        '      \"Email\":\"pritam.polley@smaartt.com\",'+
        '      \"Dialing_Country\":\"\",'+
        '      \"Country_Code\":\"\",'+
        '      \"Mobile_Phone\":\"0545549068\",'+
        '      \"Phone\":\"\",'+
        '      \"Website_Language\":\"\",'+
        '      \"Project\":\"'+p.Id+'\",'+
        '      \"Project_Type\":\"\",'+
        '      \"Unit_Type\":\"\",'+
        '      \"BudgetInAed\":\"\",'+
        '      \"BudgetInUsd\":\"\",'+
        '      \"BedroomType\":\"\",'+
        '      \"GCLID\":\"\",'+
         '      \"leadID\":\"\",'+
        '      \"Nationality\":\"\",'+
        '      \"RDS_Country_Code\":\"\",'+ 
        '      \"Preferre_Method_of_Contact\":\"\",'+
        '      \"News_Offers_subscription\":\"\",'+  
        '      \"Privacy_Policy_Acknowledgement\":\"\",'+
        '      \"Project_Name\":\"\",'+
        '      \"campaign_Code\":\"\",'+  
        '      \"Campaign_Name\":\"\",'+
        '      \"Ad_set_ID\":\"\",'+
        '      \"Time_Spent_before_Form_Submit\":\"\",'+
        '      \"IP_Address\":\"\",'+
        '      \"Landing_Page_URL\":\"\",'+
        '      \"Platform\":\"\",'+
        '      \"Browser\":\"\",'+
        '      \"network\":\"\",'+
        '      \"Resolution\":\"\",'+
        '      \"OS\":\"\",'+
        '      \"Device\":\"\",'+
        '      \"MatchType\":\"\",'+
        '      \"AdPosition\":\"\",'+
        '      \"Web_Banner_Size\":\"\",'+
        '      \"UTM_Term\":\"\",'+
        '      \"LastName\":\"\",'+
        '      \"FirstName\":\"\"'+
        '   }'+
        ']';
        RestRequest request = new RestRequest();
        request.requestUri ='https://sobharealty--sobhaqa.my.salesforce.com/services/apexrest/pushLead/2021/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        CreateLead_2021_v1.doPost();
    }
}