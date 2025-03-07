@RestResource(urlMapping = '/Integration/MissedCall/*')
global with sharing class REST_MissedCall {

@HttpPost
global static ResponseWrapper createActivity() {
    ResponseWrapper response = new ResponseWrapper();
    String data = '';
    System.debug('Request:' + RestContext.request);
    data = RestContext.request.params.get('data');
    List < Task > taskList = new List < Task > ();
    List < User > agents = [SELECT Id, Name, BitVoice_Agent_Ext__c FROM User WHERE BitVoice_Agent_Ext__c != ''];
    List < MissedCallsParser > parserList = MissedCallsParser.parse(data);
    List < String > phoneNumbers = new List < String > ();
    Id recordId;
    Boolean newLead = false;
    String phoneNumber ='';
    String formattedPhone = '';
    for (MissedCallsParser mParser: parserList) {
        // for each call check if the lead or account exists in the system.If not create a new lead and add a new enqnuiry task
        // if lead exists then add an enquiry task against the existing lead or account
        if(mParser.number_Z.startsWith('971')) {
            phoneNumber = '0'+mParser.number_Z.subString(3, mParser.number_Z.length());
            formattedPhone = mParser.number_Z.subString(3, mParser.number_Z.length());
        }else if(mParser.number_Z.startsWith('0')) {
            phoneNumber = mParser.number_Z;
            formattedPhone = mParser.number_Z.subString(1, mParser.number_Z.length());
        }else {
            phoneNumber ='00'+mParser.number_Z;
            formattedPhone = mParser.number_Z;
        }

        phoneNumbers.add(formattedPhone);
        phoneNumbers.add(phoneNumber);
        System.debug('Phone Numbers:' + phoneNumbers);


        List < Lead > llist = [SELECT Id, Primary_Number_Formula__c, Agent_Extension__c FROM Lead WHERE(MobilePhone IN: phoneNumbers OR Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers) and isConverted = false];
        if (llist != null && !llist.isEmpty() && llist.size() > 0) {
            llist[0].is_serviced__c = false;
            update llist[0];
            recordId = llist[0].Id;

        } else {
            List<Account> aList = [Select Id, is_serviced__c from Account where(personMobilePhone IN: phoneNumbers OR Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers) and isPersonAccount = true];
            if (aList != null && !aList.isEmpty() && aList.size() > 0) {
                alist[0].is_serviced__c = false;
                update alist[0];
                recordId = alist[0].Id;

            } else {
                Lead l = new Lead(lastName = 'CTI Missed Call lead', mobilePhone = phoneNumbers[0]);
                List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Name = : 'Hartland'];  //Added by Priya on 18 March 2020
                If(p.size()>0){
                l.Project__c = p[0].id;}
                //--- Added by Priya on 23 March 2020 ---//
                l.LeadSource = 'Digital';
                l.Lead_Sub_Source__c = 'digital-incoming-call';
    
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                l.setOptions(dmo);
                insert l;
                recordId = l.Id;
                newlead = true;

            }

        }

        if (string.isNotBlank(recordId)) {
            System.debug('Record Id for missed call task creation:' + recordId);
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                              .get('New Enquiry Received').getRecordTypeId();

            Task t = new Task();

            t.ActivityDate = system.today();
            t.CallObject = mParser.MID;
            t.Call_Time__c = system.now().format('h:mm a');
            t.CallDisposition = 'Unanswered';
            t.Communication_Type__c = 'Inbound Call';
            t.callType = 'Inbound';
            t.Subject = 'New Enquiry Received from:' + phoneNumbers[0];
            t.Mobile_Number_Webform__c = phoneNumbers[0];
            t.status = 'Completed';
            t.Task_Type__c = 'Enquiry Received';
            t.Enquiry_Source__c = 'Digital';
            t.Enquiry_Sub_Source__c = 'digital-incoming-call';
            t.recordTypeId = recordTypeId;
            if(recordId.getSObjectType().getDescribe().getName() == 'Lead') {
                t.whoId = recordId;
            } else if(recordId.getSObjectType().getDescribe().getName() == 'Account') {
                t.whatId = recordId;
            }
            if(newLead) {
                t.New_Lead_Created__c = true;
                Lead l = [select Id, ownerId from lead where id = :recordId ];
                // t.ownerId = l.ownerId;
            }
            taskList.add(t);
        }
        newlead = false;
        phoneNumbers = new List < String > ();
        recordId = null;
        formattedPhone = '';
        phoneNumber = '';

    }
    try{
        insert taskList;
        response.Status = 'Success';
        response.Message = 'Successfully Inserted';
        return response;
    } catch (Exception ex) {
        System.debug('Task could not be created for missed call:' + ex.getMessage());
        response.Status = 'Failed';
        response.Message = ex.getMessage();
        return response;
    }

}
Global Class ResponseWrapper {
    String Status;
    String Message;
}
}