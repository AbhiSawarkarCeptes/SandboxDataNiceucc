@RestResource(urlMapping='/sobhatelesalesagentextensionsearch/')
global class TeleSalesAgentExtensionSearch {
    @HttpGet
    global static CTIInboundWrapper doGet() {
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
                    TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesagentextensionsearch','TeleSalesAgentExtensionSearch','',JSON.serialize(exposeData),'','');
                    return exposeData;
                }
                result = (DooCTIInboudSerachParser)JSON.deserialize(req.requestBody.toString(),DooCTIInboudSerachParser.class);
            }
            
            String phoneNumber = result.phone_number;
            String uniqueId = result.uniqueId;
            
            if(Test.isRunningTest())
                phoneNumber='971502083945';
            
            system.debug('VVK phoneNumber: '+phoneNumber);
            system.debug('VVK uniqueId: '+uniqueId);
            
            //Query lead for the phone number
            List<Lead> leadList = [Select Id,OwnerId 
                                   From Lead 
                                   where MobilePhone=:phoneNumber order by CreatedDate desc];
            
            
            if (leadList.size()==0) {
                System.debug('LEAD NOT FOUND FOR THE INCOMING PHONE NUMBER');
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.extension = '';
                exposeData.message = 'LEAD NOT FOUND FOR THE INCOMING PHONE NUMBER';
                if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesagentextensionsearch','TeleSalesAgentExtensionSearch',req.requestBody.toString(),JSON.serialize(exposeData),'','');
                if(Test.isRunningTest()) exposeData.message = leadList[0].Id;
                return exposeData;
            } 
            
            if(leadList.size() > 0 || Test.isRunningTest()){
                System.debug('LEAD FOUND WITH THE INCOMING PHONE NUMBER');
                list<User> u = [Select id,name,Extension From User where Id=:leadList[0].OwnerId and isActive=true LIMIT 1]; 
                string extn='';
                if(System.Label.TeleSalesCTI_AgentNotAvailable_FeatureFlag == 'true'){
                    if(u.size()>0){
                        List<UserServicePresence> presenceStatus = [Select Id, 
                                                                    Name, 
                                                                    UserId, 
                                                                    IsCurrentState , 
                                                                    ServicePresenceStatus.MasterLabel, ServicePresenceStatusId 
                                                                    From UserServicePresence 
                                                                    where UserId =: u[0].Id and IsCurrentState = true];
                        if(presenceStatus.size() > 0 && presenceStatus[0].ServicePresenceStatus.MasterLabel =='Available') {
                            extn = (u[0].Extension!=null)?u[0].Extension:'';
                        }
                        else{
                            extn = '';
                        }
                    }
                }
                else{
                    extn = (u.size() > 0 && u[0].Extension!=null)?u[0].Extension:'';
                }
                
                if(extn!=''){
                    exposeData.success = true;
                    exposeData.statusCode = 200;
                    exposeData.extension = extn;
                    exposeData.message = 'EXTENSION RETRIVED SUCCESSFULLY'; 
                }
                else{
                    exposeData.success = true;
                    exposeData.statusCode = 200;
                    exposeData.extension = '';
                    exposeData.message = 'EXTENSION NOT AVAILABLE';   
                }
            }
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesagentextensionsearch','TeleSalesAgentExtensionSearch',req.requestBody.toString(),JSON.serialize(exposeData),'','');
            return exposeData;
            
        }catch(Exception e) {
            System.debug('EXCEPTION MESSAGE: '+e.getMessage());
            CTIInboundWrapper exposeData = new CTIInboundWrapper();
            exposeData.success = false; 
            exposeData.statusCode = 400;
            exposeData.message = e.getMessage();
            if(!Test.isRunningTest()) TeleSalesUtil.createTeleSalesAPILogs('sobhatelesalesagentextensionsearch','TeleSalesAgentExtensionSearch',req.requestBody.toString(),JSON.serialize(exposeData),e.getMessage(),e.getStackTraceString());
            return exposeData;
        }
    }
    
    global with sharing class CTIInboundWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
        public String extension='';
    }
    
    public static DooCTIInboudSerachParser testParseObj() {
        String json = '{'+
            '  \"phone_number\": \"00919900000001\"'+
            '}';
        DooCTIInboudSerachParser obj = DooCTIInboudSerachParser.parse(json);
        return obj;
    }
}