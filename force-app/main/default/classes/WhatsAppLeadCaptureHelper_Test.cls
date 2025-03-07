@isTest
public class WhatsAppLeadCaptureHelper_Test {
    @isTest 
    public static void TestWhatsAppLeadCaptureHelperCase1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/WhatsAppLeadCapture';
        PropStrength__Projects__c propProjects = TestDataFactorySobha.createProject(null);
        insert propProjects;
        String jsonString = '{' +
            '"FirstName": "John",' +
            '"LastName": "Doe",' +
            '"Nationality": "American",' +
            '"Email": "john.doe@example.com",' +
            '"RDS_Country_Code": "US",' +
            '"Mobile_Phone": "1234567890",' +
            '"Website_Language": "en",' +
            '"Preferre_Method_of_Contact": "Email",' +
            '"News_Offers_subscription": "Yes",' +
            '"Privacy_Policy_Acknowledgement": "Yes",' +
            '"Project_Name": "Project Alpha",' +
            '"campaign_Code": "CMP123",' +
            '"Campaign_Name": "Campaign Alpha",' +
            '"Ad_set_ID": "AD123",' +
            '"Ad_group": "Group A",' +
            '"Time_Spent_before_Form_Submit": "10",' +
            '"IP_Address": "192.168.1.1",' +
            '"Landing_Page_URL": "http://example.com",' +
            '"Platform": "Web",' +
            '"Browser": "Chrome",' +
            '"network": "4G",' +
            '"project": "'+propProjects.Id+'",' +
            '"Resolution": "1920x1080",' +
            '"OS": "Windows",' +
            '"Device": "Desktop",' +
            '"MatchType": "Broad",' +
            '"AdPosition": "Top",' +
            '"Web_Banner_Size": "728x90",' +
            '"Digital_Source": "Google",' +
            '"Lead_Source": "Ads",' +
            '"Goal": "Lead Generation",' +
            '"Channel_Cluster": "Cluster A",' +
            '"Last_Mile_Conversion": "Yes",' +
            '"Bid_Type": "CPC",' +
            '"UTM_Source": "google",' +
            '"UTM_Term": "term123",' +
            '"UTM_Medium": "cpc",' +
            '"UTM_Campaign": "campaign123",' +
            '"UTM_Content": "content123",' +
            '"utm_company": "company123",' +
            '"utm_adset": "adset123",' +
            '"utm_creative": "creative123",' +
            '"utm_country": "US",' +
            '"utm_language": "en",' +
            '"UTM_CampaignId": "campId123",' +
            '"utm_adsetid": "adsetId123",' +
            '"utm_adid": "adId123",' +
            '"utm_adgroup": "adgroup123",' +
            '"GCLID": "gclid123",' +
            '"Meta_Lead_ID": "metaLeadId123",' +
            '"BedroomType": "Master",' +
            '"areYouLookingFor": "Buy",' +
            '"Project_Type": "Residential",' +
            '"Time_of_Visit": "2023-07-30T12:34:56Z"' +
        '}';
		Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String mobileNum = (String) jsonMap.get('Mobile_Phone');
        String resol = (String) jsonMap.get('Resolution');
         Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        con.mobilePhone = mobileNum ;
        insert con;
        PropStrength__Assignment_Group_Name__c propAssign = TestDataFactorySobha.createAssignmentGroup(null);
        insert propAssign;
        Project__c p =new Project__c();
        p.Name='Test Project';
        p.City__c = 'Test ProjectCity';
        p.PossessionRequirement__c = 'Ready to Move in';
        p.Configuration__c = '3 BHK';
        p.Max_Budget__c = 100;
        p.Min_Budget__c = 10;
        p.Project_Code__c = 'Test';
        p.Expiry_Days__c = 10;
        insert p;
        Sobha_Connect__c sobhaCon = TestDataFactorySobha.createSobhaConnect(null);
        insert sobhaCon;
        PropStrength__Request__c propReq = TestDataFactorySobha.createEnquiry(null);
        propReq.PropStrength__Project__c = propProjects.Id;
        propReq.Resolution__c = resol;
        insert propReq;
		request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;
        List<Contact> conList = [SELECT ID , MobilePhone FROM Contact WHERE MobilePhone =: mobileNum];
        Test.startTest();
        WhatsAppLeadCapture.MobileToSFDC();
        Test.stopTest();
    }
    @isTest
    static void testInsertContactAndEnquiry_MissingLastName() {
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/WhatsAppLeadCapture/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{' +
            '"FirstName": "John",' +
            '"Mobile_Phone": "1234567890",' +
            '"Project_Name": "Project Alpha"' +
        '}');

        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WhatsAppLeadCapture.MobileToSFDC();
    }

    @isTest
    static void testInsertContactAndEnquiry_MissingMobilePhone() {
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/WhatsAppLeadCapture/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{' +
            '"FirstName": "John",' +
            '"LastName": "Doe",' +
            '"Project_Name": "Project Alpha"' +
        '}');

        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WhatsAppLeadCapture.MobileToSFDC();
    }

    @isTest
    static void testInsertContactAndEnquiry_ExistingContact() {
        Contact existingContact = new Contact(LastName='Doe', MobilePhone='1234567890');
        insert existingContact;

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/WhatsAppLeadCapture/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{' +
            '"FirstName": "John",' +
            '"LastName": "Doe",' +
            '"Mobile_Phone": "1234567890",' +
            '"Project_Name": "Project Alpha"' +
        '}');

        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WhatsAppLeadCapture.MobileToSFDC();
    }
     @isTest 
    public static void TestWhatsAppLeadCaptureHelperCase2(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/WhatsAppLeadCapture';
        PropStrength__Projects__c propProjects = TestDataFactorySobha.createProject(null);
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        con.mobilePhone = '1234567890' ;
        insert con;
        insert propProjects;
        String jsonString = '{' +
            '"FirstName": "John",' +
            '"LastName": "Doe",' +
            '"Nationality": "American",' +
            '"Email": "john.doe@example.com",' +
            '"RDS_Country_Code": "US",' +
            '"Mobile_Phone": "909087878",' +
            '"Website_Language": "en",' +
            '"Preferre_Method_of_Contact": "Email",' +
            '"News_Offers_subscription": "Yes",' +
            '"Privacy_Policy_Acknowledgement": "Yes",' +
            '"Project_Name": "Project Alpha",' +
            '"campaign_Code": "CMP123",' +
            '"Campaign_Name": "Campaign Alpha",' +
            '"Ad_set_ID": "AD123",' +
            '"Ad_group": "Group A",' +
            '"Time_Spent_before_Form_Submit": "10",' +
            '"IP_Address": "192.168.1.1",' +
            '"Landing_Page_URL": "http://example.com",' +
            '"Platform": "Web",' +
            '"Browser": "Chrome",' +
            '"network": "4G",' +
            '"project": "'+propProjects.Id+'",' +
            '"Resolution": "1920x1080",' +
            '"OS": "Windows",' +
            '"Device": "Desktop",' +
            '"MatchType": "Broad",' +
            '"AdPosition": "Top",' +
            '"Web_Banner_Size": "728x90",' +
            '"Digital_Source": "Google",' +
            '"Lead_Source": "Ads",' +
            '"Goal": "Lead Generation",' +
            '"Channel_Cluster": "Cluster A",' +
            '"Last_Mile_Conversion": "Yes",' +
            '"Bid_Type": "CPC",' +
            '"UTM_Source": "google",' +
            '"UTM_Term": "term123",' +
            '"UTM_Medium": "cpc",' +
            '"UTM_Campaign": "campaign123",' +
            '"UTM_Content": "content123",' +
            '"utm_company": "company123",' +
            '"utm_adset": "adset123",' +
            '"utm_creative": "creative123",' +
            '"utm_country": "US",' +
            '"utm_language": "en",' +
            '"UTM_CampaignId": "campId123",' +
            '"utm_adsetid": "adsetId123",' +
            '"utm_adid": "adId123",' +
            '"utm_adgroup": "adgroup123",' +
            '"GCLID": "gclid123",' +
            '"Meta_Lead_ID": "metaLeadId123",' +
            '"BedroomType": "Master",' +
            '"areYouLookingFor": "Buy",' +
            '"Project_Type": "Residential",' +
            '"Time_of_Visit": "2023-07-30T12:34:56Z"' +
        '}';
		Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String mobileNum = (String) jsonMap.get('Mobile_Phone');
        String resol = (String) jsonMap.get('Resolution');
         
        PropStrength__Assignment_Group_Name__c propAssign = TestDataFactorySobha.createAssignmentGroup(null);
        insert propAssign;
        Project__c p =new Project__c();
        p.Name='Test Project';
        p.City__c = 'Test ProjectCity';
        p.PossessionRequirement__c = 'Ready to Move in';
        p.Configuration__c = '3 BHK';
        p.Max_Budget__c = 100;
        p.Min_Budget__c = 10;
        p.Project_Code__c = 'Test';
        p.Expiry_Days__c = 10;
        insert p;
        Sobha_Connect__c sobhaCon = TestDataFactorySobha.createSobhaConnect(null);
        insert sobhaCon;
        PropStrength__Request__c propReq = TestDataFactorySobha.createEnquiry(null);
        propReq.PropStrength__Project__c = null;
        propReq.Resolution__c = resol;
        insert propReq;
		request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;
        //List<Contact> conList = [SELECT ID , MobilePhone FROM Contact WHERE MobilePhone =: '908765435'];
        Test.startTest();
        WhatsAppLeadCapture.MobileToSFDC();
        Test.stopTest();
    }
}