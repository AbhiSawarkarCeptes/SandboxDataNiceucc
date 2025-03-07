@isTest
public class LeadRequestPayloadTest {
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"Test":"Test"}');
            return res;
        }
    }
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
    public static testMethod void test1() {
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
        LeadRequestPayload.processLeadCreationRequest(json);
    }
    public static testMethod void test2() {
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
        '      \"LastName\":\"dsfd\",'+
        '      \"FirstName\":\"\"'+
        '   }'+
        ']';
        LeadRequestPayload.processLeadCreationRequest(json);
    }
}