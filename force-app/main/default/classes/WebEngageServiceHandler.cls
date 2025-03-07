//Test Class: TestLeadTrigger
/* Common Handler for Web Engage Sync of Leads & Tasks */
public class WebEngageServiceHandler {
    
    /* Syncs Leads & Tasks to the Web Engage API */
    public static void handleAPI(List<SObject> recordList, map<Id,SObject> oldMap,Boolean isInsert){
        Id recId=NULL;
        sobjectType sObjectName = Id.valueOf(recordList[0].Id).getSObjectType();
        String ObjectName = String.valueOf(sObjectName);
        try{
            for (SObject thisRecord : recordList) {
                recId = thisRecord.Id;
                if(sObjectName == Lead.sObjectType){
                    
                    if(isInsert){
                        
                        leadPostAPI(JSON.serialize(thisRecord));
                        eventPostAPI(JSON.serialize(thisRecord),'Lead Created');
                    }
                    else{
                        
                        Lead oldLead =(Lead)oldMap.get(String.ValueOf(thisRecord.get('Id')));
                        
                        Schema.FieldSet fieldSet = Schema.SObjectType.Lead.FieldSets.Web_Engage;
                        // Get the field names from the field set
                        Set<String> fieldSetFields = new Set<String>();
                        for (Schema.FieldSetMember field : fieldSet.getFields()) {
                            fieldSetFields.add(field.getFieldPath());
                        }
                        
                        // Check if any of the fields in the field set have been updated
                        for (String field : fieldSetFields) {
                            if (thisRecord.get(field) != oldLead.get(field)) {
                                system.debug('In Lead:'+thisRecord.get(field));
                                leadPostAPI(JSON.serialize(thisRecord));
                                break;
                            }
                        }
                        
                        if (thisRecord.get('Re_Enquiry_Count__c')!=oldLead.Re_Enquiry_Count__c){
                            eventPostAPI(JSON.serialize(thisRecord),'Re-enquiry');
                        }
                        
                        
                        if (thisRecord.get('Status')!=oldLead.Status && (thisRecord.get('Status')=='Qualified' || thisRecord.get('Status')=='UnQualified' || thisRecord.get('Status')=='Lost' )){
                            system.debug('In status change:'+thisRecord.get('status'));
                            eventPostAPI(JSON.serialize(thisRecord),WebEngageUtility.getEventName(String.ValueOf(thisRecord.get('Status') )));
                            
                        }
                        
                        if (thisRecord.get('Last_Call_Attempt_Status__c')!=oldLead.Last_Call_Attempt_Status__c){
                            system.debug('In Last_Call_Attempt_Status__c change:'+thisRecord.get('Last_Call_Attempt_Status__c'));
                            eventPostAPI(JSON.serialize(thisRecord),'Lead Disposition');
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
            
        }catch (Exception e) {
            System.debug('Exception in handleAPI: ' + e.getMessage());
            WebEngageUtility.createLog(e.getMessage(),recId,'WebEngageServiceHandler.handleAPI:'+ObjectName);
            
        }
    }
    
    /* Future Method to Sync Leads(user) from SF to Web Engage */
    @Future(callout=true)
    public static Void leadPostAPI(String leadJSON){
        
        HTTPResponse postAPIResponse;
        HttpRequest hReq = WebEngageLeadHandler.createHttpRequest();
        try{
            hReq = WebEngageLeadHandler.createHttpRequestBody(hReq,leadJSON);
            system.debug('RequestBody:'+hReq.getBody());
            postAPIResponse = new HTTP().send(hReq);
            WebEngageUtility.createLog(hreq, postAPIResponse,'WebEngageServiceHandler.leadPostAPI','');
            
            system.debug('responseBody'+postAPIResponse.getBody());
            
            
        } catch (Exception e) {
            
            System.debug('Exception in leadPostAPI: ' + e.getMessage());
          
            WebEngageUtility.createLog(hreq, postAPIResponse,'WebEngageServiceHandler.leadPostAPI', e.getMessage());
        }
        
    }
    
    /* Future Method to Sync Tasks(events) from SF to Web Engage */
    @Future(callout=true)
    public static Void eventPostAPI(String leadJSON,String eventName){
        
        HTTPResponse postAPIResponse;
        HttpRequest hReq = WebEngageTaskHandler.createHttpRequest();
        try{
            hReq = WebEngageTaskHandler.createHttpRequestBody(hReq,leadJSON,eventName);
            system.debug('RequestBody:'+hReq.getBody());
            postAPIResponse = new HTTP().send(hReq);
            WebEngageUtility.createLog(hreq, postAPIResponse,'WebEngageServiceHandler.eventPostAPI','');
            system.debug('responseBody'+postAPIResponse.getBody());
            
        } catch (Exception e) {
            System.debug('Exception in leadPostAPI: ' + e.getMessage());
            WebEngageUtility.createLog(hreq, postAPIResponse,'WebEngageServiceHandler.eventPostAPI',e.getMessage());
        }
        
    }
    
}