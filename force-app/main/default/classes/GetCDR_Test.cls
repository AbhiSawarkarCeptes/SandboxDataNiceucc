@IsTest
public class GetCDR_Test {

static testMethod void testGetCDR() {
	Test.startTest();
	Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
	User u1 = createUser('Test1', 'Testsobha', 'testabcde1234@stetig.in', 'testabcde1234@stetig.in', p1);
	u1.BitVoice_Agent_Ext__c = '007';
	update u1;
	String json = '['+
	              '    {'+
	              '        \"calldate\": \"2019-04-24 19:24:47\",'+
	              '        \"src\": \"007\",'+
	              '        \"direction\": \"OUTBOUND\",'+
	              '        \"dst\": \"0545549067\",'+
	              '        \"duration\": \"15\",'+
	              '        \"uniqueid\": \"1556119481.14\",'+
	              '        \"recordingfile\": \"20190424-192447-101.wav\",'+
	              '        \"xdispo\": \"CANCEL\",'+
	              '        \"recordingurl\": \"http://10.150.5.230/recordings/2019/04/24/20190424-192447-101.wav\"'+
	              '    }'+
	              ']';
	RestRequest req = new RestRequest();
	RestResponse res = new RestResponse();

	req.requestURI = '/services/apexrest/Integration/GetCDR'; //Request URL
	req.httpMethod = 'POST';//HTTP Request Type
	req.addHeader('Content-Type', 'application/x-www-form-urlencoded');     // Add a JSON Header as it is validated
	req.requestBody = Blob.valueof(json);
	req.addParameter('data', json);
	RestContext.request = req;
	RestContext.response = res;
	REST_GetCDR.ResponseWrapper response = new REST_GetCDR.ResponseWrapper();
	response = REST_GetCDR.createActivity();
	Test.stopTest();
}
public static User createUser(string fn, string ln, string username, string email, Profile pro) {

	Id umanager = UserInfo.getUserId();

	User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = pro.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8',
	                  LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230', ManagerId = umanager);
	insert u;
	return u;

}
}