public with sharing class NotificationController {
@AuraEnabled
public static String getUserExtension() {
	User u = [SELECT Id, BitVoice_Agent_Ext__c FROM User WHERE Id =: UserInfo.getUserId()];
	return u.BitVoice_Agent_Ext__c;
}

@AuraEnabled
public static String getUserExtensionAndLeadId(ID recordID) {
	System.debug('=-=-=-==- '+recordID);
	User u = [SELECT Id, Name, BitVoice_Agent_Ext__c FROM User WHERE Id =: UserInfo.getUserId()];
	String obj = recordID.getSObjectType().getDescribe().getName();
	return u.BitVoice_Agent_Ext__c+'*'+recordID+'*'+obj;
}

@AuraEnabled
public static String showIncomingCallRecord() {
	User u = [SELECT Id, Name, Last_Call_Received__c, BitVoice_Agent_Ext__c FROM User WHERE Id =: UserInfo.getUserId()];

	if(String.isNotBlank(u.Last_Call_Received__c)) {
		Id recordID = u.Last_Call_Received__c;
		String obj = recordID.getSObjectType().getDescribe().getName();
		return u.BitVoice_Agent_Ext__c+'*'+recordID+'*'+obj;
	} else {
		return 'ERROR';
	}
}

@AuraEnabled
public static String loginLogout(String actionType) {

	User u = [SELECT Id, UserName__c, Password__c, BitVoice_Agent_Ext__c, Availability__c FROM User WHERE Id =: UserInfo.getUserId()];

	String ret = '';
	String endPoint = '';

	System.debug('===== *'+ actionType +'*=');

	if(actionType == 'true') {
		BitVoice__c bit = BitVoice__c.getValues('Logout');
		endPoint = bit.URL__c+u.UserName__c;
	}else if(actionType == 'false') {
		BitVoice__c bit = BitVoice__c.getValues('Login');
		endPoint = bit.URL__c+u.UserName__c+'/'+u.Password__c+'/'+u.BitVoice_Agent_Ext__c;
	}
	try {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
		request.setMethod('GET');
		System.debug('Endpoint*** '+endPoint);
		HttpResponse response = http.send(request);
		System.debug('===== '+response);
		response.getBody();
		ResponseWrapper resp = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
		System.debug('******** '+resp.status.toLowerCase());
		if(resp.status.toLowerCase() == 'success' && (actionType == 'false')) {
			u.Availability__c = true;
			u.Status__c = 'AVAILABLE';
			update u;
			ret = 'success';
		}else if(resp.status.toLowerCase() == 'success' && (actionType == 'true')) {
			u.Availability__c = false;
			update u;
			ret = 'success';
		}else {
			ret = resp.status+' ! '+resp.message;
		}

	}catch(Exception ex) {
		ret = 'Failed: '+ex.getMessage();
	}
	return ret;
}

Class ResponseWrapper {
	String status;
	String message;
}

@AuraEnabled
Public Static Boolean checkAgentAvailability() {
	User u = [SELECT Id, Availability__c FROM User WHERE Id =: UserInfo.getUserId()];
	return u.Availability__c;
}

@AuraEnabled
public static String getUserName() {
	return userinfo.getName();
}


@AuraEnabled
Public Static String getAgentStatus() {
	User u = [SELECT Id, Status__c FROM User WHERE Id =: UserInfo.getUserId()];
	if(String.isNotBlank(u.status__c) && u.status__c.equalsIgnoreCase('OUTCALL'))
		return 'PAUSED';
	else
		return u.Status__c;
}

@AuraEnabled
Public Static String setAgentStatus(String curStat) {
	User u = [SELECT Id, Status__c, UserName__c FROM User WHERE Id =: UserInfo.getUserId()];
	if(curStat.equalsIgnoreCase('PAUSED'))
		u.status__c = 'OUTCALL';
	else
		u.Status__c = curStat;
	BitVoice__c bit = BitVoice__c.getValues('Change Status');
	String endPoint = bit.URL__c+u.UserName__c+'/'+curStat;
	try {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
		request.setMethod('GET');
		System.debug('Endpoint*** '+endPoint);
		HttpResponse response = http.send(request);
		System.debug('===== '+response);
		response.getBody();
		ResponseWrapper resp = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
		System.debug('******** '+resp.status.toLowerCase());
		if(resp.status.toLowerCase() == 'success') {
			update u;
			return 'success';
		}else {
			return response.getBody();
		}
	}catch(Exception ex) {
		return ex.getMessage();
	}
}
}