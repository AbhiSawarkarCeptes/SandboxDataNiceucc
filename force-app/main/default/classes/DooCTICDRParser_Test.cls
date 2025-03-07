@IsTest
public class DooCTICDRParser_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"caller_id\": \"00919980052221\",'+
		'  \"extension_no\": \"2002\",'+
		'  \"uniqueid\": \"1649938730.602\",'+
		'  \"Call_Status\": \"ANSWER\",'+
		'  \"Talk_Time_Duration\": 7,'+
		'  \"After_Call_Work_Duration\": 120,'+
		'  \"Queue_Duration\": 4,'+
		'  \"Hold_Duration\": 0,'+
		'  \"Date_And_Time_Of_Call\": \"2022-04-14 16:18:49\",'+
		'  \"Call_Recording_Link_Url\": \"https://cti.sobhaapps.com/webphone/login/monitor/20220414/IN-2002-0502083945-20220414-161850-1649938730.601.wav\",'+
		'  \"Queue\": \"801\"'+
		'}';
		DooCTICDRParser obj = DooCTICDRParser.parse(json);
		System.assert(obj != null);
	}
}