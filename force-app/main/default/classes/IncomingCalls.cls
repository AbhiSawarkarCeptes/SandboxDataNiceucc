@RestResource(urlMapping='/incomingCalls')
Global Class IncomingCalls {
  @HttpPost
  Global Static ResponseWrapper pushIncoming() {
    ResponseWrapper response = new ResponseWrapper();
    try {
      RestRequest req = RestContext.request;
      String phoneNumber = '';
      String extn = '';
      Id recordId;
      Boolean newlead = false;
      String json = req.requestBody.toString();
      System.debug('JSON input for incoming call:' + json);
      List<IncomingCallsParser> incomingParserList = new List<IncomingCallsParser>();
      List<Task> taskList = new List<Task>();
      System.debug('JSON request:' + json);
      incomingParserList = IncomingCallsParser.parse(json);
      String formattedPhone = '';
      for(IncomingCallsParser incomingParser : incomingParserList) {
        if(incomingParser.from_Z.startsWith('971')) {
          phoneNumber = '0'+incomingParser.from_Z.subString(3, incomingParser.from_Z.length());
          formattedPhone = incomingParser.from_Z.subString(3, incomingParser.from_Z.length());
        }else if(incomingParser.from_Z.startsWith('0')) {
          phoneNumber = incomingParser.from_Z;
          formattedPhone = incomingParser.from_Z.subString(1, incomingParser.from_Z.length());
        }else {
          phoneNumber ='00'+incomingParser.from_Z;
          formattedPhone = incomingParser.from_Z;
        }
        extn = incomingParser.extension;
        List<Lead> llist = [SELECT Id, MobilePhone, Phone, Name FROM Lead WHERE (MobilePhone = :formattedPhone or MobilePhone =: incomingParser.from_Z OR Phone =: incomingParser.from_Z OR Primary_Number__c = :phoneNumber OR Primary_Number_Formula__c =: phoneNumber) and isConverted = false];
        List<User> agents = [SELECT Id, BitVoice_Agent_Ext__c,Name FROM User WHERE BitVoice_Agent_Ext__c =: extn];

        String customer = '';
        if(llist.size() > 0) {
          customer = llist[0].Name;
          llist[0].is_serviced__c = false;
          update llist[0];
          recordId = llist[0].Id;

        }else {
          List<Account> aList = [Select Id, is_serviced__c from Account where(personMobilePhone = :formattedPhone or personMobilePhone =: incomingParser.from_Z OR Primary_Number__c =: incomingParser.from_Z OR Primary_Number_Formula__c =: phoneNumber) and isPersonAccount = true];
          if (aList != null && !aList.isEmpty() && aList.size() > 0) {
            alist[0].is_serviced__c = false;
            update alist[0];
            recordId = alist[0].Id;

          } else {
            Lead l = new Lead(lastName = 'CTI Incoming Call lead', mobilePhone = formattedPhone, RDS_Country_Code__c ='+' + incomingParser.CountryCode);
            if(l.RDS_Country_Code__c == '91' ||  l.RDS_Country_Code__c == '+91')
              l.RDS_Country__c = 'India';
            if(l.RDS_Country_Code__c == '971' ||  l.RDS_Country_Code__c == '+971')
              l.RDS_Country__c = 'United Arab Emirates';
            if(agents != null && agents.size() ==1) {
              l.ownerId = agents[0].Id;
              l.presales_agent__c = agents[0].Id;
            }
            else {
              if(!Test.isRunningTest()) {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                l.setOptions(dmo);
              }
            }
            
            
            List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Name = : 'Hartland'];  //Added by Priya on 18 March 2020
            If(p.size()>0){
            l.Project__c = p[0].id;}
            //--- Added by Priya on 23 March 2020 ---//
            l.LeadSource = 'Digital';
            l.Lead_Sub_Source__c = 'digital-incoming-call';

            insert l;
            recordId = l.Id;
            newlead = true;

          }
        }

        if (string.isNotBlank(recordId)) {
          System.debug('Record Id for incoming call task creation:' + recordId);
          Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                            .get('New Enquiry Received').getRecordTypeId();

          Task t = new Task();
          t.recordTypeId = recordTypeId;
          if(agents != null  && agents.size() ==1)
            t.ownerId = agents[0].Id;
          t.ActivityDate = system.today();
          t.CallObject =  incomingParser.uid;
          t.Call_Time__c = system.now().format('h:mm a');
          t.Subject = 'New Enquiry Received from:' + phoneNumber;
          t.Mobile_Number_Webform__c = phoneNumber;
          t.status = 'Completed';
          t.Task_Type__c = 'Enquiry Received';
          t.Enquiry_Source__c = 'Digital';
          t.Enquiry_Sub_Source__c = 'digital-incoming-call';
          if(recordId.getSObjectType().getDescribe().getName() == 'Lead') {
            t.whoId = recordId;
          } else if(recordId.getSObjectType().getDescribe().getName() == 'Account') {
            t.whatId = recordId;
          }
          if(newLead)
            t.New_Lead_Created__c = true;
          taskList.add(t);

          Id recordTypeId1 = Schema.SObjectType.Task.getRecordTypeInfosByName()
                             .get('Presales and Sales').getRecordTypeId();

          Task t1 = new Task();
          t1.recordTypeId = recordTypeId1;
          if(agents != null && agents.size() ==1)
            t1.ownerId = agents[0].Id;
          t1.ActivityDate = system.today();
          t1.CallObject =  incomingParser.uid;
          t1.Call_Time__c = system.now().format('h:mm a');
          t1.Communication_Type__c = 'Inbound Call';
          t1.callType = 'Inbound';
          t1.Subject = 'Inbound Call from :' + phoneNumber;
          if(newLead == false){
            t1.Subject = 'Re Enquiry - Inbound Call from :' + phoneNumber;
          }
          t1.Mobile_Number_Webform__c = phoneNumber;
          t1.status = 'Open';
          t1.Task_Type__c = 'Presales Call';
          if(recordId.getSObjectType().getDescribe().getName() == 'Lead') {
            t1.whoId = recordId;
          } else if(recordId.getSObjectType().getDescribe().getName() == 'Account') {
            t1.whatId = recordId;
          }
          taskList.add(t1);


        }
        if(taskList != null & taskList.size() > 0) {
          insert taskList;
          if(newLead) {
            Lead l = [select Id, ownerId from lead where id = :recordId ];
            for(task t : taskList) {
              t.ownerId = l.ownerId;
            }
            update taskList;

          }

        }


        newlead = false;

        List<Screenpop_Notification__e> notifications = new List<Screenpop_Notification__e>();
        notifications.add(new Screenpop_Notification__e(Message__c = 'Incoming Call : '+customer, Agent__c = extn, Phone__c = phoneNumber, recordId__c = recordId));
        If(agents!= null && agents.size() > 0 && agents[0].Id != null) {
          User u = new User();
          u.Id = agents[0].Id;
          u.last_call_received__c = recordId;
          update u;
        }

        List<Database.SaveResult> results = EventBus.publish(notifications);
        // Inspect publishing results
        for (Database.SaveResult result : results) {
          if (!result.isSuccess()) {
            for (Database.Error error : result.getErrors()) {
              System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
            }
          }
        }
        phoneNumber = '';
        recordId = null;

      }

      response.Status = 'Success';
      response.Message = 'Successfully Inserted';

    }catch(Exception ex) {
      Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
      logError.class__c = 'IncomingCalls';
      RestRequest req = RestContext.request;
      String json = req.requestBody.toString();
      logError.Request__c = json;
      insert logError;
      response.Status = 'Failed';
      response.Message = ex.getMessage();
      
      System.debug('*********ex.getMessage()***********'+ex.getMessage());
    }
    return response;
  }

  Global Class ResponseWrapper {
    String Status;
    String Message;
  }
}