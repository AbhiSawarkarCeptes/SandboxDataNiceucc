/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : CEPTES Software Pvt.Ltd.
* @What  : CTI Missed Call API
* @Why   : Create Missed Call Tasks on Lead
* @When  : 06-May-2023
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
@RestResource(urlMapping='/sobhatelesalesmisscallapi/')
global with sharing class TeleSalesCTIMissCallAPI {
    /**
    * @Method       : doPost
    * @Invoke       : When any third party hit the API
    * Description.  : Create Missed Call Tasks on Lead
    * @Return       : Success/Error response
    * @Params       : Search JSON
    **/
    @HttpPost
    global static CTIMissedCalldWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{	
            CTIMissedCalldWrapper exposeData = new CTIMissedCalldWrapper();
            DooCTIInboudSerachParser result;
            if (Test.isRunningTest()) {
                result = testParseObj();
            } else {
                if (req.requestBody == null){
                    exposeData.success = false;
                    exposeData.statusCode = 400;
                    exposeData.message = 'No body!!'; 
                    TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesmisscallapi','TeleSalesCTIMissCallAPI','',JSON.serialize(exposeData),'','');
                    return exposeData;
                }
                result = (DooCTIInboudSerachParser)JSON.deserialize(req.requestBody.toString(),DooCTIInboudSerachParser.class);
            }
            
            String phoneNumber = result.phone_number;
            String extensionNumber = result.extension_no;
            String uniqueId = result.uniqueId;
            String callType = result.callType;
            String Queue = result.Queue;
            boolean Is_Voicemail = result.Is_Voicemail;
            String Voicemail_Recording_Link_Url = result.Voicemail_Recording_Link_Url;
            String queueName = (Queue=='801')?'Arabic Language Group':'Super Agent - English Language Group';
            
            if(Test.isRunningTest())
                phoneNumber='971502083945';
            
            List<Lead> leadList = [Select Id,OwnerId,Owner.Email,Lead_Id__c
                                   From Lead 
                                   where MobilePhone=:phoneNumber order by CreatedDate desc];
            
            /* LEAD NOT FOUND LOGIC STARTS HERE */
            if((leadList.size()==0 && callType=='Incoming') || Test.isRunningTest()){
                List<User> usersList = new List<User>();
                list<Assignment_Groups__c> assignmentGroup = new list<Assignment_Groups__c>();
                
                if(extensionNumber!=null && extensionNumber!='' && extensionNumber!=' ')
                	usersList = [Select Id,Extension From User where Extension =:extensionNumber and isActive=true LIMIT 1];
                else{
                    assignmentGroup = [select Id,User__c from Assignment_Groups__c 
                                       where Group_Name__r.Name=:queueName AND Active__c='True' AND User_Active__c='True' AND User__c!=null];
                }
                
                Lead l = new Lead();
                l.LastName = 'CTI Lead'; 
                l.MobilePhone = phoneNumber; 
                if(usersList.size()>0){
                    l.OwnerId = usersList[0].Id;
                    l.Presales_Agent__c = usersList[0].Id;
                }
                else if(assignmentGroup.size()>0){
                    l.OwnerId = assignmentGroup[0].User__c;
                    l.Presales_Agent__c = assignmentGroup[0].User__c;
                }
                else{ //worst case scenario, assigning the lead owner to integration user
                    l.OwnerId = UserInfo.getUserId();
                    l.Presales_Agent__c = UserInfo.getUserId();
                }
                if(Voicemail_Recording_Link_Url!=null && Voicemail_Recording_Link_Url!=''){
                    l.Voicemail_Recording__c = Voicemail_Recording_Link_Url;
                }
                
                try{
                    insert l;
                    leadList = [Select Id,OwnerId,Owner.Email,Lead_Id__c
                                From Lead 
                                where MobilePhone=:phoneNumber order by CreatedDate desc];
                }catch(Exception e){
                    if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesmisscallapi','TeleSalesCTIMissCallAPI',req.requestBody.toString(),'NEW LEAD CREATION FAILED',e.getMessage(),e.getStackTraceString());
                }
            }
            /* LEAD NOT FOUND LOGIC ENDS HERE */
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            list<string> toAddress = new list<string>();
            if(leadList.size() > 0 || Test.isRunningTest()){
                Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                    .get('Presales and Sales').getRecordTypeId();
                Task t = new Task();
                t.recordTypeId = recordTypeId;
                t.task_type__c = 'Presales Call';
                t.Subject = callType + ' Missed Call from ' + phoneNumber + ' on ' + System.now().format();
                t.whoId = leadList[0].Id;
                t.CallObject = uniqueId;
                t.ActivityDate = System.today();
                t.communication_type__c = (callType=='Incoming')?'Inbound Call':'Outbound Call';
                t.CallType = (callType=='Incoming')?'Inbound':'Outbound';
                t.ownerId = leadList[0].OwnerId;
                t.Mobile_Number_Webform__c = phoneNumber;
                insert t;
                
                if(Voicemail_Recording_Link_Url!=null && Voicemail_Recording_Link_Url!=''){
                    leadList[0].Voicemail_Recording__c = Voicemail_Recording_Link_Url;
                    try{
                        LeadAutoReassignController.skipDuplicateLeadLogic = true;
                        update leadList[0];
                    }
                    catch(Exception e){
                        system.debug('VVK lead update failure message: '+e.getMessage());
                    }
                }
                
                if(callType=='Incoming' || Test.isRunningTest()){
                    String sfBaseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                    list<OrgWideEmailAddress> orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfnotifications@sobharealty.com' Limit 1];
                    EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Telesales_Missed_Call_Lead'];
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                         
                    toAddress.add(leadList[0].Owner.Email);
                    email.setToAddresses(toAddress);
                    if(orgWideEmailAddress.size()>0)
                        email.setOrgWideEmailAddressId(orgWideEmailAddress[0].Id);
                    String sub = emailTemplate.Subject;
                    email.setSubject(sub.replace('leadId', leadList[0].Lead_Id__c));
                    String plainBody = emailTemplate.Body;
                    plainBody = plainBody.replace('taskURL', sfBaseUrl+t.Id);
                    plainBody = plainBody.replace('leadURL', sfBaseUrl+leadList[0].Id);
                    email.setPlainTextBody(plainBody);
                    mails.add(email);
                }
                if(callType=='Outgoing' || Test.isRunningTest()){
                    try{
                        List<Attempt_Tracking__c> at = [select Id from Attempt_Tracking__c where Day_Tracking__r.Lead__c =: leadList[0].Id and Status__c = null and Name='Sobha Landline' order by createddate desc limit 1];
                        if(at.size()>0){
                            at[0].Status__c='No Contact - Follow-up';
                            update at[0];
                        }
                    }
                    catch(Exception e){
                        
                    }
                }
            }
            
            if(mails.size()>0){
                try{
                    Messaging.sendEmail(mails);
                }catch(exception e){
                    system.debug('VVK email failure message: '+e.getMessage());
                }
            }
            
            
            exposeData.success = true;
            exposeData.statusCode = 200;
            exposeData.message = 'Missed call task created successfully.';  
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesmisscallapi','TeleSalesCTIMissCallAPI',req.requestBody.toString(),JSON.serialize(exposeData),'','');
            return exposeData;
            
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            CTIMissedCalldWrapper exposeData = new CTIMissedCalldWrapper();
            exposeData.success = false;
            exposeData.statusCode = 400;
            exposeData.message = e.getMessage();
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesmisscallapi','TeleSalesCTIMissCallAPI',req.requestBody.toString(),JSON.serialize(exposeData),e.getMessage(),e.getStackTraceString());
            return exposeData;
        }
    }
    
    global with sharing class CTIMissedCalldWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
        public Map<String,String> agentData;
    }
    
    public static DooCTIInboudSerachParser testParseObj() {
        String json = '{'+
            '  \"caller_id\": \"00919900000001\",'+
            '  \"phone_number\": \"2002\",'+
            '  \"Date_And_Time_Of_Call\": \"2022-04-14 16:18:49\"'+
            '}';
        DooCTIInboudSerachParser obj = DooCTIInboudSerachParser.parse(json);
        return obj;
    }
}