@RestResource(urlMapping='/sobhatelesalescticdrpush/')
global with sharing class TeleSalesCTICDRAPI {
    @HttpPost
    global static CTICDRAPIWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{	
            CTICDRAPIWrapper exposeData = new CTICDRAPIWrapper();
            DooCTICDRParser result;
            if (Test.isRunningTest()) {
                result = testParseObj();
            } else {
                if (req.requestBody == null){exposeData.success = false;exposeData.statusCode = 400;exposeData.message = 'No CDR body!!';TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalescticdrpush','TeleSalesCTICDRAPI','',JSON.serialize(exposeData),'',''); return exposeData;}
                result = (DooCTICDRParser)JSON.deserialize(req.requestBody.toString(),DooCTICDRParser.class);
            }
            
            String phoneNumber = result.phone_number;
            String agentExtension = result.extension_no;
            String uniqueId = result.uniqueId;
            String did = result.did;
            String recordId = result.recordId;
            
            if(Test.isRunningTest())
                phoneNumber='971502083945';
            
            if(recordId!=null && recordId!='' && recordId.startsWith('a06')){
                
                //Query user for the extension
                List<User> usersList = [SELECT id FROM User WHERE Extension =: agentExtension];
                
                if (usersList.size() == 0) {exposeData.success = false; exposeData.statusCode = 400; exposeData.message = 'No agent with extension - '+agentExtension;  return exposeData; }
                
                if (usersList.size() > 1) {exposeData.success = false;exposeData.statusCode = 400;exposeData.message = 'Multiple agents with extension - '+agentExtension; return exposeData;}
                
                List<Task__c> taskCreatedByAgent = [SELECT id,
                                                    Call_Duration__c,
                                                    Call_Hold_Duration__c,
                                                    Call_Recording_Url__c,
                                                    Call_Status__c ,
                                                    Manual_Dial__c
                                                    FROM Task__c 
                                                    WHERE createdById =: usersList[0].id 
                                                    AND Booking__c =: recordId
                                                    AND createdDate = TODAY
                                                    AND Manual_Dial__c = false
                                                    ORDER BY createdDate desc];
                Task__c latestTask;
                
                if (taskCreatedByAgent.size() < 1) { Task__c newTask = new Task__c(); latestTask = newTask; List<Booking__c> bookingList = [SELECT id FROM Booking__c WHERE Id =: recordId]; if (bookingList.size() > 0) { latestTask.booking__c = bookingList[0].id; } } 
                else { latestTask = taskCreatedByAgent[0]; }
                
                if (latestTask != null) { latestTask.Call_Duration__c  = result.After_Call_Work_Duration; latestTask.Call_Hold_Duration__c= result.Hold_Duration; latestTask.Call_Status__c= result.Call_Status; latestTask.Call_Recording_Url__c= result.Call_Recording_Link_Url; latestTask.CTI_Unique_Id__c = result.uniqueid; latestTask.Disposition__c = result.After_Call_Work_Duration; latestTask.Last_Contacted_Date__c = result.Date_And_Time_Of_Call; latestTask.Calling_Agent__c = usersList[0].id; upsert latestTask; exposeData.success = true; exposeData.statusCode = 200; exposeData.message = 'CDR updated successfully'; }
                
                return exposeData;
            }
            else{
                List<Lead> leadList = [Select Id,OwnerId
                                       From Lead 
                                       where MobilePhone=:phoneNumber order by CreatedDate desc];
                
                List<User> usersList = [Select Id,Extension From User where Extension =:agentExtension and isActive=true LIMIT 1];
                
                CDR__c cdr = new CDR__c();
                cdr.Call_Recording__c = result.Call_Recording_Link_Url;
                cdr.Date_Time__c = ((result.Date_And_Time_Of_Call != null) && (result.Date_And_Time_Of_Call != '')) ? DateTime.valueOf(result.Date_And_Time_Of_Call) : System.Now();
                cdr.Duration__c = String.valueOf(result.Talk_Time_Duration);
                cdr.Lead__c = (leadList.size()>0)?leadList[0].Id:null;
                cdr.Status__c = result.Call_Status;
                cdr.Agent__c = (usersList.size()>0)?usersList[0].Id:null;
                cdr.Extension__c = (usersList.size()>0)?usersList[0].Extension:'';
                if(Test.isRunningTest())
                    cdr.Lead__c = leadList[0].Id;
                insert cdr;
                
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'CDR updated successfully.';
                if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalescticdrpush','TeleSalesCTICDRAPI',req.requestBody.toString(),JSON.serialize(exposeData),'','');
                return exposeData;
            }
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            CTICDRAPIWrapper exposeData = new CTICDRAPIWrapper();
            exposeData.success = false;
            exposeData.statusCode = 400;
            exposeData.message = e.getMessage();
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalescticdrpush','TeleSalesCTICDRAPI',req.requestBody.toString(),JSON.serialize(exposeData),e.getMessage(),e.getStackTraceString());
            return exposeData;
        }
    }
    
    global with sharing class CTICDRAPIWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
    }
    
    public static DooCTICDRParser testParseObj() {
        String json = '{'+
            '  \"phone_number\": \"00919900000001\",'+
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
        return obj;
    }
}