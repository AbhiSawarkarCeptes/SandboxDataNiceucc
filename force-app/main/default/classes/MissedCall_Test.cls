@IsTest
public class MissedCall_Test {

static testMethod void testMissedCall() {
	Test.startTest();

	String json = '[{\"mid\":\"100\",\"number\":\"042924333\",\"mtime\":\"1557313211\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"},{\"mid\":\"101\",\"number\":\"043555582\",\"mtime\":\"1557641699\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"1\"},{\"mid\":\"102\",\"number\":\"0564017612\",\"mtime\":\"1558000832\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"}]';

	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();

	req.requestURI = '/services/apexrest/Integration/MissedCall'; //Request URL
	req.httpMethod = 'POST';//HTTP Request Type
	req.addHeader('Content-Type', 'application/x-www-form-urlencoded');     // Add a JSON Header as it is validated
	req.requestBody = Blob.valueof(json);
	req.addParameter('data', json);
	RestContext.request = req;
	RestContext.response = res;
	REST_MissedCall.ResponseWrapper response = new REST_MissedCall.ResponseWrapper();
	response = REST_MissedCall.createActivity();

	Test.stopTest();
}
}