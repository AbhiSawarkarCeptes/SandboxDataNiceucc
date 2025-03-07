public with sharing class CTIManagementServices {



//  what's the difference between fresh lead, re-enquiry  an existing lead,
public static Map<Integer,List<callQueueWrapper> > getFreshLeads(String UserId, Boolean allRecs){
	List<Lead> ll = new List<Lead>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// Anything that is unserviced is a fresh lead and no calls made till date is a fresh lead
	if(!allRecs)
		ll = [Select id, name, createdDate, mobilePhone, Email,Primary_Number_Formula__c, Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c from Lead
		      where isConverted = false and priority_bucket__c = 'FRESH' and ownerId = :userId order by Date_and_Time_of_Unserviced_Lead__c asc];
	else
		ll = [Select id, name, createdDate, mobilePhone, Email,Primary_Number_Formula__c, Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c from Lead
		      where isConverted = false and priority_bucket__c = 'FRESH' order by Date_and_Time_of_Unserviced_Lead__c asc];
	if(!ll.isEmpty() && ll.size() > 0) {
		for(Lead l : ll) {
			callQueueWrapper cqw = new callQueueWrapper(l.Id, 'LEAD',l.priority_bucket__c,l.mobilePhone, l.Primary_Number_Formula__c,l.email, l.Name, calling_priority__c.getValues(l.priority_bucket__c).priority__c, null,l.Date_and_Time_of_Unserviced_Lead__c, l.Owner.Name);
			cqwList.add(cqw);
		}
	}
	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('FRESH').priority__c), cqwList);
	return cqwMap;
}

public static Map<Integer,List<callQueueWrapper> > getFollowupLeads(String UserId, Boolean allRecs){
	List<Lead> ll = new List<Lead>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// follow ups are rolled up in the latest next date field.
	if(!allRecs)
		ll = [Select id, name, createdDate, mobilePhone, Email, Primary_Number_Formula__c,Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c,Latest_Next_Action_Date__c from Lead
		      where
		      isConverted = false and priority_bucket__c IN ('FOLLOW UP', 'NO CONTACT - FOLLOW UP')
		                    and ownerId = :userId order by Latest_Next_Action_Date__c asc];
	else
		ll = [Select id, name, createdDate, mobilePhone, Email, Primary_Number_Formula__c,Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c,Latest_Next_Action_Date__c from Lead
		      where
		      isConverted = false and priority_bucket__c IN ('FOLLOW UP', 'NO CONTACT - FOLLOW UP')
		                    order by Latest_Next_Action_Date__c asc];
	if(!ll.isEmpty() && ll.size() > 0) {
		for(Lead l : ll) {
			callQueueWrapper cqw = new callQueueWrapper(l.Id, 'LEAD',l.priority_bucket__c,l.mobilePhone,l.Primary_Number_Formula__c, l.email, l.Name, calling_priority__c.getValues(l.priority_bucket__c).priority__c,l.Latest_Next_Action_Date__c, null, l.Owner.Name);
			cqwList.add(cqw);
		}
	}
	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('FOLLOW UP').priority__c), cqwList);
	return cqwMap;
}

public static Map<Integer,List<callQueueWrapper> > getNoConactFollowupLeads(String UserId, Boolean allRecs){
	List<Lead> ll = new List<Lead>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// follow ups are rolled up in the latest next date field.
	if(!allRecs)
		ll = [Select id, name, createdDate, mobilePhone, Email, Primary_Number_Formula__c,Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c,Latest_Next_Action_Date__c from Lead
		      where
		      isConverted = false and priority_bucket__c = 'NO CONTACT - FOLLOW UP'
		                                                   and ownerId = :userId order by Latest_Next_Action_Date__c asc];
	else
		ll = [Select id, name, createdDate, mobilePhone, Email, Primary_Number_Formula__c,Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c,Latest_Next_Action_Date__c from Lead
		      where
		      isConverted = false and priority_bucket__c = 'NO CONTACT - FOLLOW UP'
		                                                   order by Latest_Next_Action_Date__c asc];
	if(!ll.isEmpty() && ll.size() > 0) {
		for(Lead l : ll) {
			callQueueWrapper cqw = new callQueueWrapper(l.Id, 'LEAD',l.priority_bucket__c,l.mobilePhone,l.Primary_Number_Formula__c, l.email, l.Name, calling_priority__c.getValues(l.priority_bucket__c).priority__c,l.Latest_Next_Action_Date__c, null, l.Owner.Name);
			cqwList.add(cqw);
		}
	}
	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('NO CONTACT - FOLLOW UP').priority__c), cqwList);
	return cqwMap;
}



public static Map<Integer,List<callQueueWrapper> > getReenquiryLeads(String UserId, Boolean allRecs){
	List<Lead> ll = new List<Lead>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// Anything that is unserviced is a fresh lead and no calls made till date is a fresh lead
	if(!allRecs)
		ll = [Select id, name, createdDate, mobilePhone, Email,Primary_Number_Formula__c, Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c from Lead
		      where isConverted = false and priority_bucket__c = 'REENQUIRY' and ownerId = :userId order by Date_and_Time_of_Unserviced_Lead__c asc];
	else
		ll = [Select id, name, createdDate, mobilePhone, Email,Primary_Number_Formula__c, Date_and_Time_of_Unserviced_Lead__c, Owner.Id, Owner.Name,priority_bucket__c from Lead
		      where isConverted = false and priority_bucket__c = 'REENQUIRY' order by Date_and_Time_of_Unserviced_Lead__c asc];
	if(!ll.isEmpty() && ll.size() > 0) {
		for(Lead l : ll) {
			callQueueWrapper cqw = new callQueueWrapper(l.Id, 'LEAD',l.priority_bucket__c,l.mobilePhone,l.Primary_Number_Formula__c, l.email, l.Name, calling_priority__c.getValues(l.priority_bucket__c).priority__c, null, l.Date_and_Time_of_Unserviced_Lead__c, l.Owner.Name);
			cqwList.add(cqw);
		}
	}
	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('REENQUIRY').priority__c), cqwList);
	return cqwMap;
}
public static Map<Integer, List<callQueueWrapper> > getFollowupOpportunities(String UserId, Boolean allRecs){
	List<Opportunity> ol = new List<Opportunity>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// follow ups are rolled up in the latest next date field.
	if(!allRecs)
		ol = [Select id, name, createdDate, Account.PersonMobilePhone, Account.PersonEmail, Account.Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c,Next_Action_Date__c from Opportunity
		      where priority_bucket__c IN ('FOLLOW UP', 'NO CONTACT - FOLLOW UP') and presales_agent__c = :userId order by Next_Action_Date__c asc];
	else
		ol = [Select id, name, createdDate, Account.PersonMobilePhone, Account.PersonEmail, Account.Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c,Next_Action_Date__c from Opportunity
		      where priority_bucket__c IN ('FOLLOW UP', 'NO CONTACT - FOLLOW UP') order by Next_Action_Date__c asc];
	if(!ol.isEmpty() && ol.size() > 0) {
		for(Opportunity o : ol) {
			callQueueWrapper cqw = new callQueueWrapper(o.Id, 'OPPORTUNITY',o.priority_bucket__c,o.Account.PersonMobilePhone, o.Account.Primary_Number_Formula__c, o.Account.PersonEmail, o.Name, calling_priority__c.getValues(o.priority_bucket__c).priority__c, o.Next_Action_Date__c, null, o.presales_agent__r.Name);
			cqwList.add(cqw);
		}
	}

	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('FOLLOW UP').priority__c), cqwList);

	return cqwMap;
}
public static Map<Integer, List<callQueueWrapper> > getNoContactFollowupOpportunities(String UserId, Boolean allRecs){
	List<Opportunity> ol = new List<Opportunity>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// no contact follow ups are rolled up in the latest next date field.
	if(!allRecs)
		ol = [Select id, name, createdDate, Account.PersonMobilePhone, Account.PersonEmail, Account.Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c,Next_Action_Date__c from Opportunity
		      where priority_bucket__c = 'NO CONTACT - FOLLOW UP' and presales_agent__c = :userId order by Next_Action_Date__c asc];
	else
		ol = [Select id, name, createdDate, Account.PersonMobilePhone, Account.PersonEmail, Account.Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c,Next_Action_Date__c from Opportunity
		      where priority_bucket__c = 'NO CONTACT - FOLLOW UP' order by Next_Action_Date__c asc];
	if(!ol.isEmpty() && ol.size() > 0) {
		for(Opportunity o : ol) {
			callQueueWrapper cqw = new callQueueWrapper(o.Id, 'OPPORTUNITY',o.priority_bucket__c,o.Account.PersonMobilePhone, o.Account.Primary_Number_Formula__c, o.Account.PersonEmail, o.Name, calling_priority__c.getValues(o.priority_bucket__c).priority__c, o.Next_Action_Date__c, null, o.presales_agent__r.Name);
			cqwList.add(cqw);
		}
	}

	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('NO CONTACT - FOLLOW UP').priority__c), cqwList);

	return cqwMap;
}
public static Map<Integer, List<callQueueWrapper> > getReenquiryAccounts(String UserId, Boolean allRecs){
	List<Account> al = new List<Account>();
	List<callQueueWrapper> cqwList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > cqwMap = new Map<Integer, List<callQueueWrapper> >();
	// Anything that is unserviced is a fresh lead and no calls made till date is a fresh lead
	if(!allRecs)
		al = [Select id, name, createdDate, PersonMobilePhone, PersonEmail,Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c, Time_Of_New_Enquiry__c from Account
		      where priority_bucket__c = 'REENQUIRY' and presales_agent__c = :userId order by Time_Of_New_Enquiry__c asc];
	else
		al = [Select id, name, createdDate, PersonMobilePhone, PersonEmail,Primary_Number_Formula__c, presales_agent__r.Id, presales_agent__r.Name,priority_bucket__c, Time_Of_New_Enquiry__c from Account
		      where priority_bucket__c = 'REENQUIRY' order by Time_Of_New_Enquiry__c asc];
	if(!al.isEmpty() && al.size() > 0) {
		for(Account a : al) {
			callQueueWrapper cqw = new callQueueWrapper(a.Id, 'ACCOUNT',a.priority_bucket__c,a.PersonMobilePhone,a.Primary_Number_Formula__c, a.PersonEmail,a.Name, calling_priority__c.getValues(a.priority_bucket__c).priority__c, a.Time_Of_New_Enquiry__c, null, a.presales_agent__r.Name);
			cqwList.add(cqw);
		}
	}
	cqwMap.put(Integer.valueOf(calling_priority__c.getValues('REENQUIRY').priority__c), cqwList);
	return cqwMap;
}


@AuraEnabled(cacheable=true)
public static List<callQueueWrapper> priortiseDialingQueue(String userId){
	List<callQueueWrapper> consolidatedCallingList = new List<callQueueWrapper>();
	List<callQueueWrapper> consolidatedCallingFinalList = new List<callQueueWrapper>();
	Map<Integer, List<callQueueWrapper> > freshLeads = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > reenquiryLeads = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > followupLeads = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > ncfollowupLeads = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > followupOpportunities = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > ncfollowupOpportunities = new Map<Integer, List<callQueueWrapper> >();
	Map<Integer, List<callQueueWrapper> > reenquiryAccounts = new Map<Integer, List<callQueueWrapper> >();
	Boolean showAllRecords = false;
	List<User> uList = [Select Id, Profile.Name from User where Id =:userId];
	if(uList != null && uList.size() ==1) {
		if(uList[0].Profile.Name == 'System Administrator') {
			showAllRecords = true;
		}
	}
	System.debug('I am here:' + uList);
	freshLeads = getFreshLeads(userId, showAllRecords);
	reenquiryLeads = getReenquiryLeads(userId, showAllRecords);
	followupLeads = getFollowupLeads(userId, showAllRecords);
	// ncfollowupLeads = getNoConactFollowupLeads(userId, showAllRecords);
	followupOpportunities = getFollowupOpportunities(userId, showAllRecords);
	// ncfollowupOpportunities = getNoContactFollowupOpportunities(userId, showAllRecords);
	reenquiryAccounts = getReenquiryAccounts(userId, showAllRecords);
	List<Integer> prioritySort = new List<Integer>();
	for(calling_priority__c cp : calling_priority__c.getAll().values()) {
		prioritySort.add(Integer.valueOf(cp.priority__c));
	}
	prioritySort.sort();
	// follow up on leads and opportunity should be a merged list and they should contain both followups and no contact follow ups
	// based on the follow up time system.
	// since lists for opp and lead are separately, the below code creates a common map,
	// group them by follow up time. To arrange the map in the order follow up asc, we sorted the maps keyset [follow up time data]
	List<callQueueWrapper> followupCommonList = new List<callQueueWrapper>();
	for (List<callQueueWrapper> fLeads : followupLeads.values())
		followupCommonList.addAll(fleads);
	for (List<callQueueWrapper> fOpp : followupOpportunities.values())
		followupCommonList.addAll(fOpp);
	Map<DateTime, List<callQueueWrapper> > followUpTimeMap = new Map<DateTime,  List<callQueueWrapper> >();
	for(callQueueWrapper cw: followupCommonList) {
		if(followUpTimeMap.containsKey(cw.followupDateTime)) {
			followUpTimeMap.get(cw.followupDateTime).Add(cw);
		} else {
			List<callQueueWrapper> temp = new List<callQueueWrapper>();
			temp.add(cw);
			followUpTimeMap.put(cw.followupDateTime, temp);
		}
	}
	List<DateTime> followUpTimeList = new List<DateTime>();
	followUpTimeList.addAll(followUpTimeMap.keySet());
	system.debug('Follow up times unsorted:' + followUpTimeList);
	followUpTimeList.sort();
	system.debug('Follow up times sorted:' + followUpTimeList);
	List<callQueueWrapper> followupCommonSortedList = new List<callQueueWrapper>();
	for(DateTime dt : followUpTimeList) {
		if(followUpTimeMap.containsKey(dt)) {
			followupCommonSortedList.addAll(followUpTimeMap.get(dt));
		}
	}
	Map<Integer, List<callQueueWrapper> >  followupCommonSortedMap = new Map<Integer, List<callQueueWrapper> >();
	followupCommonSortedMap.put(3,followupCommonSortedList);
	for(Integer i : prioritySort) {
		if(!freshLeads.isEmpty() && freshLeads.size() > 0 && freshLeads.containsKey(i)) {
			consolidatedCallingList.addAll(freshLeads.get(i));
		}
		if(!reenquiryLeads.isEmpty() && reenquiryLeads.size() > 0 && reenquiryLeads.containsKey(i)) {
			consolidatedCallingList.addAll(reenquiryLeads.get(i));
		}
		if(!followupCommonSortedMap.isEmpty() && followupCommonSortedMap.size() > 0 && followupCommonSortedMap.containsKey(i)) {
			consolidatedCallingList.addAll(followupCommonSortedMap.get(i));
		}
		/* if(!followupLeads.isEmpty() && followupLeads.size() > 0 && followupLeads.containsKey(i)) {
		        consolidatedCallingList.addAll(followupLeads.get(i));
		   }
		   if(!ncfollowupLeads.isEmpty() && ncfollowupLeads.size() > 0 && ncfollowupLeads.containsKey(i)) {
		                consolidatedCallingList.addAll(ncfollowupLeads.get(i));
		        }
		   if(!followupOpportunities.isEmpty() && followupOpportunities.size() > 0 && followupOpportunities.containsKey(i)) {
		        consolidatedCallingList.addAll(followupOpportunities.get(i));
		   }
		    if(!ncfollowupOpportunities.isEmpty() && ncfollowupOpportunities.size() > 0 && ncfollowupOpportunities.containsKey(i)) {
		            consolidatedCallingList.addAll(ncfollowupOpportunities.get(i));
		    }
		 */
		if(!reenquiryAccounts.isEmpty() && reenquiryAccounts.size() > 0 && reenquiryAccounts.containsKey(i)) {
			consolidatedCallingList.addAll(reenquiryAccounts.get(i));
		}
	}
	consolidatedCallingFinalList.addAll(consolidatedCallingList);

/** Integer count = 0;
        Integer movedUpCount = 0;
        for(callQueueWrapper cqw : consolidatedCallingList) {
                if(String.isNotBlank(cqw.priorityBucket) && cqw.priorityBucket.equalsIgnoreCase('FOLLOW UP')) {
                        if(cqw.followupDateTime != null && (cqw.followupDateTime <= system.now() || cqw.followupDateTime <=  system.now().addMinutes(5))) {

                                System.debug('current index:' + consolidatedCallingFinalList.indexOf(cqw));
                                Integer currentIndex = consolidatedCallingFinalList.indexOf(cqw);
                                consolidatedCallingFinalList.remove(currentIndex);
                                consolidatedCallingFinalList.add(movedUpCount, cqw);         // move it up the list,
                                movedUpCount++;         // so the second followup gets added under the first follow up that was moved up
                        }
                }
                count++;
        } **/

	if(!consolidatedCallingFinalList.isEmpty() && consolidatedCallingFinalList.size() >0)
		consolidatedCallingFinalList[0].disableMakeCall = false;
	/* for(callQueueWrapper cqw : consolidatedCallingFinalList) {
	        System.debug('Calling list:' + cqw.Name + ':' + cqw.recordId + ':' + cqw.objectType  + ':' + cqw.priority + cqw.followTimeFormatted);
	   } */
	//allow calling only on the first record from the list
	return consolidatedCallingFinalList;
}
@AuraEnabled(cacheable = true)
public static List<PresalesUserName> getUserNamePicklist() {
	List<PresalesUserName> pList = new List<PresalesUserName>();
	List<User> uList = [Select Id, Name from User where Profile.Name = 'Presales'];
	if(uList != null && uList.size() >=1) {
		for(User u : uList) {
			PresalesUserName p = new PresalesUserName(u.Id, u.Name);
			pList.add(p);
		}
	}
	System.debug('presales user list:' + pList);
	return pList;
}
// if cacheable is true, the method has to be immutable
// we cant have any data changes in the methods, like performing a DML
@AuraEnabled
public Static String callById(Id recordID) {

	String obj = recordID.getSObjectType().getDescribe().getName();

	String phone = '';
	Opportunity o = new Opportunity();
	Account a  = new Account();
	Lead l = new lead();
	Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
	                  .get('Presales and Sales').getRecordTypeId();

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

	User u = [SELECT Id, Name, BitVoice_Agent_Ext__c FROM User WHERE Id =: UserInfo.getUserId()];
	BitVoice__c bit = BitVoice__c.getValues('Make Calls');

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
		t.task_type__c = 'Presales Call';

		insert t;
		System.debug('CDR:' + t);

		return 'success';
	}else {
		return resp.message;
	}
}
@AuraEnabled
public static string reassignLeads(List<callQueueWrapper> callingList, Id newOwner){
	List<Account> accList = new List<Account>();
	List<Lead> leadList = new List<Lead>();
	List<Opportunity> oppList = new List<Opportunity>();
	if(newOwner != null ) {
		if( !newOwner.getSObjectType().getDescribe().getName().equalsIgnoreCase('User')) {
			return 'Invalid User Selected:';
		} else {
			if(callingList != null && callingList.size() > 0) {
				System.debug('calling list selected for reassignment:' + callingList);
				for(callQueueWrapper cw: callingList) {
					if(cw.objectType == 'ACCOUNT') {
						Account a = new Account(Id = cw.recordId,presales_agent__c=newOwner );
						accList.add(a);
					} else if (cw.objectType == 'OPPORTUNITY') {
						Opportunity o = new Opportunity(Id=cw.recordId, presales_agent__c = newOwner);
						oppList.add(o);
					} else if(cw.objectType == 'LEAD') {
						Lead l = new Lead(Id = cw.recordId, ownerId = newOwner);
						leadList.add(l);
					}
				}
				try{
					if(!accList.isEmpty())
						update accList;
					if(!leadList.isEmpty())
						update leadList;
					if(!oppList.isEmpty())
						update oppList;
					return 'success';
				} catch (exception ex) {
					return ex.getMessage();
				}

			} else {
				return 'No records selected:';
			}
		}
	} else {
		return 'Invalid User Selected:';
	}
}
@InvocableMethod
Public Static void changeAgentStatusAfterCallHangup() {
	setAgentStatus();

}

@future(callout=true)
Public Static void setAgentStatus() {
	User u = [SELECT Id, Status__c,BitVoice_Agent_Ext__c, UserName__c, Availability__c FROM User WHERE Id =: UserInfo.getUserId()];
	if(String.isNotBlank(u.BitVoice_Agent_Ext__c) && String.isNotBlank(u.Status__c) && u.Availability__c) {
		BitVoice__c bit = BitVoice__c.getValues('Change Status');
		String curStatus;
		if(u.status__c != null
		   && string.isNotBlank(u.status__c) && u.Status__c.equalsIgnoreCase('OUTCALL'))
			curStatus = 'PAUSED';
		else
			curStatus = u.status__c;

		String endPoint = bit.URL__c+u.UserName__c+'/'+curStatus;
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
				system.debug('status updated for agent:' + u);

			}else {
				system.debug('status couldnot be updated:' + u);
			}
		}catch(Exception ex) {
			system.debug('status couldnot be updated:' + u + ':exception occurred:' + ex.getMessage());
		}
	} else {
		System.debug('Not calling the status change API for this user:' + u);
	}
}
public class ResponseWrapper {
String status;
String message;
}



public class CallByIdResponseWrapper {
@AuraEnabled
public Boolean sucess {get; set;}
@AuraEnabled
public String uid {get; set;}
@AuraEnabled
public String message {get; set;}
}
public class PresalesUserName {
@AuraEnabled
public String sValue {get; set;}
@AuraEnabled
public String sLabel {get; set;}
public PresalesUserName(String val, String label){
	this.sLabel = label;
	this.sValue = val;
}
}
public class callQueueWrapper {
@AuraEnabled
public Id recordId {get; set;}
@AuraEnabled
public String objectType {get; set;}
@AuraEnabled
public String priorityBucket {get; set;}
@AuraEnabled
public String mobilePhone {get; set;}
@AuraEnabled
public String formattedPhone {get; set;}
@AuraEnabled
public String email {get; set;}
@AuraEnabled
public String Name {get; set;}
@AuraEnabled
public Integer priority {get; set;}
@AuraEnabled
public String priorityString {get; set;}
@AuraEnabled
public DateTime followupDateTime {get; set;}
@AuraEnabled
public String followTimeFormatted {get; set;}
@AuraEnabled
public DateTime unservicedDateTime {get; set;}
@AuraEnabled
public String unservicedDateTimeFormatted {get; set;}
@AuraEnabled
public boolean disableMakeCall {get; set;}
@AuraEnabled
public String ownerName {get; set;}
public callQueueWrapper(){

}

public callQueueWrapper(Id recId, String objectType, String priorityBucket, String mobilePhone, String formattedPh, String email, String name, Decimal priority, DateTime fdt, Datetime udt, String ownerName) {
	this.recordId = recId;
	this.objectType = objectType;
	this.priorityBucket = priorityBucket;
	this.mobilePhone = mobilePhone;
	this.formattedPhone = formattedPh;
	this.email = email;
	this.Name = name;
	this.priority = Integer.valueOf(priority);
	this.priorityString = String.valueOf(this.priority);
	this.followupDateTime = fdt;
	this.ownerName = ownerName;
	if(fdt != null)
		this.followTimeFormatted = fdt.format();
	this.unservicedDateTime = udt;
	if(udt != null)
		this.unservicedDateTimeFormatted = udt.format();
	this.disableMakeCall = true;
}
}
}