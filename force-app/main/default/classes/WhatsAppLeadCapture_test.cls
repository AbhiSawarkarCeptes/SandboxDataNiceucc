@isTest
public class WhatsAppLeadCapture_test {
    @isTest
    static void testInsertContactAndEnquiry() {
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/WhatsAppLeadCapture/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{' +
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
            '"project": "Project Alpha",' +
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
        '}');

        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        WhatsAppLeadCapture.MobileToSFDC();
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
}