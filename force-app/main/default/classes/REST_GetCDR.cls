@RestResource(urlMapping='/Integration/GetCDR/*')
global with sharing class REST_GetCDR {

@HttpPost
global static ResponseWrapper  createActivity(){
	ResponseWrapper response = new ResponseWrapper();
	String data = '';
	System.debug('Request:' + RestContext.request);
	data = RestContext.request.params.get('data');
	List<CDRparser> cdrParserList = CDRparser.parse(data);
	// based on the UID in the CDR we identify the task and update it with details coming in the CDR
	// while making an outbound call we get a response from CTI system with the UID details which is
	// being inserted in CDR temp object in old implementation. In this new implementation, we will
	// create a task of type outbound using that information. The same task will be updated after we
	// get the CDRs post hang up
	List<Task> taskList = new List<Task>();
	Boolean existingTask = false;
	String customerNumber = '';
	String AgentExtn = '';
	String AgentName = '';
	Id recordId;
	System.debug('CDR JSON:' + cdrParserList[0]);
	for(CDRparser cdrP : cdrParserList) {
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
		                  .get('Presales and Sales').getRecordTypeId();
		List<Task> existingTaskList = [Select Id from Task where CallObject = :cdrP.uniqueid and recordTypeId = :recordTypeId];


		Task t = new Task();
		if(existingTaskList != null && existingTaskList.size() ==1) {
			t.Id = existingTaskList[0].Id;
			existingTask = true;
			System.debug('task id:' + t.Id);
		}

		t.Call_Recording_URL__c = cdrP.recordingurl;
		t.ActivityDate = ((cdrP.calldate != null) && (cdrP.calldate != '')) ? Date.valueOf(cdrP.calldate) : system.today();
		// t.CallObject = crd.UID; // CTI team has to send the UID parameter
		if( (cdrP.calldate != null) && (cdrP.calldate != '') ) {
			List<String> temp = cdrP.callDate.split (' ');
			if(String.isNotBlank(temp[1])) {
				List<String> timeArr = temp[1].split(':');
				if(String.isNotBlank(timeArr[0]) && String.isNotBlank(timeArr[1])  ) {
					t.Call_Time__c = timeArr[0] + ' : '  + timeArr[1];
				}
			}
		}
		t.CallDurationInSeconds = Integer.valueOf(cdrP.duration);
		t.CallDisposition = cdrP.xdispo;
		t.Formatted_Duration__c = cdrP.formattedDuration;
		//======Check Incoming or Outgoing=========
		if(cdrP.direction == 'INBOUND') {
			t.Communication_Type__c = 'Inbound Call ';
			t.callType = 'Inbound ';
			AgentExtn = cdrP.dst;
			customerNumber = cdrP.src;
		}else if(cdrP.direction == 'OUTBOUND') {
			t.Communication_Type__c = 'Outbound Call ';
			t.callType = 'Outbound ';
			AgentExtn = cdrP.src;
			customerNumber = cdrP.dst;
		}
		List<User> agents = [SELECT Id, Name, BitVoice_Agent_Ext__c FROM User WHERE BitVoice_Agent_Ext__c = :AgentExtn];
		if(agents != null && agents.size() > 0) {
			t.OwnerId = agents[0].Id;
			agentName = agents[0].Name;
		}
		System.debug('Direction:' + cdrP.direction  + ': communication type: ' + t.Communication_Type__c + ': customer number:' + customerNumber);
		if(!existingTask) {
			// create subject, record type and task type if its an existing task
			t.Subject = t.Communication_Type__c + ' to ' + customerNumber + ' on ' + System.now().format() + ' by ' + agentName;
			t.recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
			                 .get('Presales and Sales').getRecordTypeId();
			t.Task_Type__c = 'Presales Call';
			t.CallObject = cdrP.uniqueid;
			List < Lead > llist = [SELECT Id, Primary_Number_Formula__c, Agent_Extension__c FROM Lead WHERE(MobilePhone =: customerNumber OR Primary_Number__c =: customerNumber OR Primary_Number_Formula__c =: customerNumber) and isConverted = false];
			if (llist != null && !llist.isEmpty() && llist.size() > 0) {
				recordId = llist[0].Id;

			} else {
				List<Account> aList = [Select Id, is_serviced__c from Account where(personMobilePhone = : customerNumber OR Primary_Number__c =:customerNumber OR Primary_Number_Formula__c =: customerNumber) and isPersonAccount = true];
				if (aList != null && !aList.isEmpty() && aList.size() > 0) {
					recordId = alist[0].Id;
				} else {
					System.debug('CDR for a non-existent customer record:');

				}

			}
			if (string.isNotBlank(recordId)) {
				if(recordId.getSObjectType().getDescribe().getName() == 'Lead') {
					t.whoId = recordId;
				} else if(recordId.getSObjectType().getDescribe().getName() == 'Account') {
					t.whatId = recordId;
				}

			}

			recordId = null;
		}
		//=========================================
		taskList.add(t);
		customerNumber = '';
		existingTask = false;
		AgentExtn = '';
		agentName = '';
	}
	if(taskList.size() > 0) {
		upsert taskList;
		System.debug('tasklist:' +taskList);
	}
	response.Status = 'Success';
	response.Message = 'Successfully Inserted';
	return response;
}
Global Class ResponseWrapper {
	String Status;
	String Message;
}
}