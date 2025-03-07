Global Class ClickToDial {

	//======================To Handle Recursion in Trigger==============================
	Public Static Set<Id> SetOfBeforeIDs = new Set<Id>();
	Public Static Set<Id> SetOfAfterIDs = new Set<Id>();
	//==================================================================================

	//=============Call From Lead / Account / Opportunity Detail Page Button============
	@AuraEnabled
	Webservice Static String callById(String recordID) {

		String obj = findObjectAPIName(recordID);

		String phone = '';
		Opportunity o = new Opportunity();
		Account a  = new Account();
		Lead l = new lead();
		if(obj.toLowerCase() == 'lead') {
			l = [SELECT Id, Primary_Number_Formula__c FROM Lead WHERE Id =: recordID LIMIT 1];
			phone = l.Primary_Number_Formula__c;
		}else if(obj.toLowerCase() == 'account') {
			a = [SELECT Id, Primary_Number_Formula__c FROM Account WHERE Id =: recordID LIMIT 1];
			phone = a.Primary_Number_Formula__c;
		}else if(obj.toLowerCase() == 'opportunity') {
			o = [SELECT Id, Primary_Number_Formula__c, Account.personcontactId FROM Opportunity WHERE Id =: recordID LIMIT 1];
			phone = o.Primary_Number_Formula__c;
		}

		User u = [SELECT Id, Name, BitVoice_Agent_Ext__c, Status__c FROM User WHERE Id =: UserInfo.getUserId()];
		if(u.Status__c != null && !u.Status__c.equalsIgnoreCase('OutCall')) {
			System.debug('In agent status check:' + u.Status__c);
			return 'To dial out customers from here, place yourself on Outcall mode.';
		}
		BitVoice__c bit = BitVoice__c.getValues('Make Calls');
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
		                  .get('Presales and Sales').getRecordTypeId();
		String endPoint = bit.URL__c+u.BitVoice_Agent_Ext__c+'/'+phone;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
		request.setMethod('GET');
		HttpResponse response = http.send(request);

		CallByIdResponseWrapper resp = (CallByIdResponseWrapper)JSON.deserialize(response.getBody(), CallByIdResponseWrapper.class);
		if(resp.sucess) {
			Task t = new Task();
			t.recordTypeId = recordTypeId;
			t.task_type__c = 'Presales Call';
			t.Subject = 'Outbound Call to ' + phone + ' on ' + System.now().format() + ' by ' + u.Name;
			if(obj.toLowerCase() == 'lead') {
				t.whoId = recordID;
			}else if(obj.toLowerCase() == 'account') {
				t.whoID = recordID;
			}else if(obj.toLowerCase() == 'opportunity') {
				t.whatId = recordID;
				t.whoId = o.Account.personcontactId;
			}
			t.CallObject = resp.uid;
			t.ActivityDate = System.today();
			t.communication_type__c = 'Outbound Call';
			t.CallType = 'Outbound';
			t.ownerId = u.Id;
			t.Mobile_Number_Webform__c = phone;

			insert t;
			System.debug('CDR:' + t);

			return 'success';
		}else {
			System.debug('In else part:' + resp.message);
			return resp.message;
		}
	}

	Class CallByIdResponseWrapper {
		Boolean sucess;
		String uid;
		String message;
	}
	//==================================================================================

	//========================Fetch Object Name By Record ID============================
	Public Static String findObjectAPIName(String recordId) {
		if(recordId == null) {
			return null;
		}
		String objectAPIName = '';
		String keyPrefix = recordId.substring(0,3);
		for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()) {
			String prefix = obj.getDescribe().getKeyPrefix();
			if(prefix == keyPrefix) {
				objectAPIName = obj.getDescribe().getName();
				break;
			}
		}
		return objectAPIName;
	}
	//==================================================================================

	//===================Fetch CDR Information On Record Update=========================
	@Future(callout=true)
	Public Static Void fetchCRD(String recordID, String phone) {

		String obj = findObjectAPIName(recordID);
		List<CDR_Temp__c> cdrTempList = new List<CDR_Temp__c>();

		if(obj.toLowerCase() == 'lead') {
			cdrTempList = [SELECT UID__c FROM CDR_Temp__c WHERE (Lead__c =: recordID OR Phone_Number__c =: phone) AND Completed__c = False];
		}else if(obj.toLowerCase() == 'account') {
			cdrTempList = [SELECT UID__c FROM CDR_Temp__c WHERE (Account__c =: recordID OR Phone_Number__c =: phone) AND Completed__c = False];
		}else if(obj.toLowerCase() == 'opportunity') {
			cdrTempList = [SELECT UID__c FROM CDR_Temp__c WHERE (Opportunity__c =: recordID OR Phone_Number__c =: phone) AND Completed__c = False];
		}

		if(cdrTempList.size() > 0) {

			BitVoice__c bit = BitVoice__c.getValues('CDR');
			List<User> agents = [SELECT Id, BitVoice_Agent_Ext__c FROM User WHERE BitVoice_Agent_Ext__c != ''];
			List<CDR__c> cdrList = new List<CDR__c>();

			for(CDR_Temp__c cdrTemp : cdrTempList) {

				Http http = new Http();
				HttpRequest request = new HttpRequest();
				request.setEndpoint(bit.URL__c+cdrTemp.UID__c);
				request.setMethod('GET');
				HttpResponse response = http.send(request);

				List<CDRparser> cdrParserList = CDRparser.parse(response.getBody());

				for(CDRparser cdrP : cdrParserList) {

					CDR__c cdr = new CDR__c();
					cdr.Call_Recording__c = cdrP.recordingurl;
					cdr.Date_Time__c = ((cdrP.calldate != null) && (cdrP.calldate != '')) ? DateTime.valueOf(cdrP.calldate) : System.Now();
					cdr.Destination__c = cdrP.dst;
					cdr.Duration__c = cdrP.duration;

					if(obj.toLowerCase() == 'lead') {
						cdr.Lead__c = recordID;
					}else if(obj.toLowerCase() == 'account') {
						cdr.Account__c = recordID;
					}else if(obj.toLowerCase() == 'opportunity') {
						cdr.Opportunity__c = recordID;
					}

					cdr.Status__c = cdrP.xdispo;

					//======Check Incoming or Outgoing=========
					String type = '';
					if(cdrP.direction == 'INBOUND') {
						type = 'Incoming';
						cdr.Extension__c = cdrP.dst;
					}else if(cdrP.direction == 'OUTBOUND') {
						type = 'Outgoing';
						cdr.Extension__c = cdrP.src;
					}
					//=========================================

					cdr.Call_Type__c = type; //cdrP.callType;
					for(User usr : agents) {
						if(cdr.Extension__c == usr.BitVoice_Agent_Ext__c) {
							cdr.Agent__c = usr.Id;
						}
					}
					cdrList.add(cdr);
				}
				cdrTemp.Completed__c = True;
			}

			if(cdrList.size() > 0) {
				insert cdrList;
			}

			update cdrTempList;
		}
	}
	//==================================================================================

	//==============================Push Calls in Bulk==================================
	Public Static Boolean pushBulkCalls(String bulkCalls) {

		BitVoice__c bulkCall = BitVoice__c.getValues('Bulk Call');

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(bulkCall.URL__c);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setBody(bulkCalls);
		HttpResponse response = http.send(request);

		if(response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
			return false;
		}else {
			System.debug('response.getBody - '+response.getBody());
			ResponseWrapper resp = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
			if(resp.status.toLowerCase() == 'success') {
				System.debug('Pushed to BitVoice...!');
				return true;
			}else {
				return false;
			}
		}
	}
	Class ResponseWrapper {
		String status;
		String message;
	}
	//==================================================================================

	//===============================Auto-Convert Leads================================
	@Future(Callout=true)
	Public Static Void autoConvertLead(ID leadId) {
		Map<String, Lead_Auto_Convert_Status__c> allStatus = Lead_Auto_Convert_Status__c.getAll();
		if(allStatus.size() > 0) {
			LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
			List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
			List<Lead> leadList = [SELECT Id, Name, isConverted, Status, Last_Call_Attempt_Status__c FROM Lead WHERE Id =: leadId];
			for(Lead l: leadList) {
				if(!l.isConverted) { // && l.Status == 'Open'
					if(allStatus.keySet().contains(l.Last_Call_Attempt_Status__c.toLowerCase())) {
						Database.LeadConvert lc = new Database.LeadConvert();
						String opportunityName = l.Name;
						lc.setLeadId(l.Id);
						lc.setSendNotificationEmail(true);
						lc.setOpportunityName(opportunityName);
						//lc.setDoNotCreateOpportunity(true);
						lc.setConvertedStatus(convertStatus.MasterLabel);
						leadConverts.add(lc);
					}
				}
			}
			if(!leadConverts.isEmpty()) {
				List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
			}
		}
	}
	//================================================================================
}