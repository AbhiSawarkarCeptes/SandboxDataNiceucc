@IsTest
public class PSUploadDocumentMobilePOJO_UT {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
		String json = '{'+
		'\"base64Data\":\"Base 64 Data\",'+
		'\"parentId\":\"'+acc.Id+'\",'+
		'\"fileName\":\"File Name\",'+
		'\"isthirdpartydoc\":\"True\"'+
		'}';
        RestContext.response = res;
        req.requestURI = '/services/apexrest/uploadDocument_Dummy/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
		PSUploadDocumentMobile.MobileToSFDC();
		
		PSUploadDocumentMobilePOJO r = PSUploadDocumentMobilePOJO.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PSUploadDocumentMobilePOJO objJSON2Apex = new PSUploadDocumentMobilePOJO(System.JSON.createParser(json));
		System.assert(objJSON2Apex != null);
		System.assert(objJSON2Apex.base64Data == null);
		System.assert(objJSON2Apex.parentId == null);
		System.assert(objJSON2Apex.fileName == null);
		System.assert(objJSON2Apex.isthirdpartydoc == null);

	}
    static testMethod void testParse2() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
		String json = '{'+
		'\"base64Data\":\"Base 64 Data\",'+
		'\"parentId\":\"165564\",'+
		'\"fileName\":\"File Name\",'+
		'\"isthirdpartydoc\":\"True\"'+
		'}';
        RestContext.response = res;
        req.requestURI = '/services/apexrest/uploadDocument_Dummy/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
		PSUploadDocumentMobile.MobileToSFDC();
    }
}