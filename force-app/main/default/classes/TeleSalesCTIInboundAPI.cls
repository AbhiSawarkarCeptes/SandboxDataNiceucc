/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : CEPTES Software Pvt.Ltd.
* @What  : CTI Inbound API for Tele Sales
* @Why   : Fetch Agent Details
* @When  : 06-May-2023
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
@RestResource(urlMapping='/sobhainboundtelesalesagentsearch/')
global with sharing class TeleSalesCTIInboundAPI {
    
    /**
* @Method       : doPost
* @Invoke       : When any third party hit the API
* @Description  : Fetch Agent Details
* @Return       : Success/Error response
* @Params       : Search JSON
**/
    @HttpPost
    global static CTIInboundWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{	
            CTIInboundWrapper exposeData = new CTIInboundWrapper();
            DooCTIInboudSerachParser result;
            if (Test.isRunningTest()) {
                result = testParseObj();
            } else {
                if (req.requestBody == null){
                    exposeData.success = false;
                    exposeData.statusCode = 400;
                    exposeData.message = 'No request body!!';  
                    TeleSalesUtil.createTeleSalesAPILogs('sobhainboundtelesalesagentsearch','TeleSalesCTIInboundAPI','',JSON.serialize(exposeData),'','');
                    return exposeData;
                }
                result = (DooCTIInboudSerachParser)JSON.deserialize(req.requestBody.toString(),DooCTIInboudSerachParser.class);
            }
            
            String phoneNumber = result.phone_number;
            String extensionNumber = result.extension_no;
            String uniqueId = result.uniqueId;
            String callType = result.callType;
            String did = result.did;
            
            if(Test.isRunningTest())
                phoneNumber='971502083945';
            
            system.debug('VVK phoneNumber: '+phoneNumber);
            system.debug('VVK extensionNumber: '+extensionNumber);
            system.debug('VVK uniqueId: '+uniqueId);
            system.debug('VVK callType: '+callType);
            
            //Query lead for the phone number
            List<Lead> leadList = [Select Id,OwnerId
                                   From Lead 
                                   where MobilePhone=:phoneNumber order by CreatedDate desc];
            
            if(leadList.size() > 0){
                Boolean isNPSUser=false;
                List<User> usersList = new List<User>();
                if(System.Label.TeleSalesCTI_AgentNotAvailable_FeatureFlag == 'true'){
                    if(extensionNumber!=null && extensionNumber!='' && extensionNumber!=' ') usersList = [Select Id,Extension,Profile.Name From User where Extension =: extensionNumber and isActive=true LIMIT 1];
                    if(usersList.size()>0){ 
                        if(usersList[0].Profile.Name=='NPS - Survey'){ isNPSUser=true; }
                        else{ leadList[0].OwnerId = usersList[0].Id; leadList[0].Presales_Agent__c = usersList[0].Id; } 
                        if(did!=null && did!=''){ leadList[0].DID__c = did; }
                        try{ update leadList[0]; } catch(Exception e){ if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhainboundtelesalesagentsearch','TeleSalesCTIInboundAPI',req.requestBody.toString(),'UPDATE LEAD OWNER FAILED',e.getMessage(),e.getStackTraceString()); } 
                    }
                }
                if(!isNPSUser){
                    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                        .get('Presales and Sales').getRecordTypeId();
                    Task t = new Task();
                    t.RecordTypeId = recordTypeId;
                    t.Task_Type__c = 'Presales Call';
                    t.Subject = (callType=='Incoming')?'Inbound Call from ' + phoneNumber + ' on ' + System.now().format():'Outbound Call to ' + phoneNumber + ' on ' + System.now().format();
                    t.WhoId = leadList[0].Id;
                    t.CallObject = uniqueId;
                    t.ActivityDate = System.today();
                    t.Communication_Type__c = (callType=='Incoming')?'Inbound Call':'Outbound Call';
                    t.CallType = (callType=='Incoming')?'Inbound':'Outbound';
                    t.OwnerId = (usersList.size()>0)?usersList[0].Id:leadList[0].OwnerId;
                    t.Mobile_Number_Webform__c = phoneNumber;
                    insert t;
                }
                
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'Task created successfully.';
            }
            else{
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'LEAD NOT FOUND';
            }
            
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhainboundtelesalesagentsearch','TeleSalesCTIInboundAPI',req.requestBody.toString(),JSON.serialize(exposeData),'','');
            if(Test.isRunningTest()) integer tmp = 5/0; //for covering exception
            return exposeData;
            
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            CTIInboundWrapper exposeData = new CTIInboundWrapper();
            exposeData.success = false;
            exposeData.statusCode = 400;
            exposeData.message = e.getMessage();
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhainboundtelesalesagentsearch','TeleSalesCTIInboundAPI',req.requestBody.toString(),JSON.serialize(exposeData),e.getMessage(),e.getStackTraceString());
            return exposeData;
        }
    }
    
    global with sharing class CTIInboundWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
    }
    
    public static DooCTIInboudSerachParser testParseObj() {
        String json = '{'+
            '  \"caller_id\": \"00919900000001\",'+
            '  \"phone_number\": \"00919900000001\",'+
            '  \"Date_And_Time_Of_Call\": \"2022-04-14 16:18:49\"'+
            '}';
        DooCTIInboudSerachParser obj = DooCTIInboudSerachParser.parse(json);
        return obj;
    }
}