//Test Class: TestLeadTrigger
/* Handler for Web Engage Sync of Tasks */
public class WebEngageTaskHandler {
    
    public static HttpRequest createHttpRequest(){
        //Create Request
        HTTPRequest request = new HTTPRequest();
      
        WebEng_API_Metadata__mdt metadataAPI = WebEng_API_Metadata__mdt.getInstance('Event_Post')  ;
        //Set Method and Endpoint
        request.setEndpoint(metadataAPI.End_Point__c);
        request.setMethod(metadataAPI.Method_Name__c);
        
        List<WebEng_Metadata_Headers__mdt> metadataHeaders  = webEng_Metadata_Headers__mdt.getAll().values();
       for(WebEng_Metadata_Headers__mdt metadataHeader : metadataHeaders){
            if(String.isNotBlank(metadataHeader.Header_Name__c)){
                request.setHeader(metadataHeader.Header_Name__c,metadataHeader.Header_value__c);
                 system.debug('requestHeaderLabel:'+metadataHeader.Header_Name__c+' Value:'+metadataHeader.Header_value__c);
            }
        }
        
        system.debug('requestwith Header:'+request);
        return request;
    }
    
    //Generate POST Request
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String leadJSON,String eventName){
        
        Lead leadRecord = (Lead)JSON.deserialize(leadJSON, Lead.class);
        //Create JSON Structure
        String reqBody = getBody(leadRecord,eventName);
        
        //Set Request Body
        request.setBody(reqBody);
        system.debug('requestwith body:'+request);
        return request;
    }
    
    public static String getBody(Lead leadRec,String eventName) {
      List<WebEng_Sync_Fields__mdt> webEngageSyncList =  [SELECT Id, Weg_Engage_Key__c, 
                                                           SF_Lead_API__c,needTransformation__c,
                                                           Payload_Section__c,Field_Type__c
                                                           FROM WebEng_Sync_Fields__mdt
                                                           WHERE SF_Object__c ='Event'];
        List<WebEng_Sync_Fields__mdt> mainFieldList = new List<WebEng_Sync_Fields__mdt>();
        List<WebEng_Sync_Fields__mdt> attribFieldList = new List<WebEng_Sync_Fields__mdt>();
        String jsonString;
        
        for(WebEng_Sync_Fields__mdt singleMap : webEngageSyncList) {
            if(singleMap.Payload_Section__c == 'Main') {
                mainFieldList.add(singleMap);
            }
            else {
                attribFieldList.add(singleMap);
            }
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
       
       
             gen.writeStringField('eventName', eventName);
       
        for (WebEng_Sync_Fields__mdt singleMap : mainFieldList) {
            
             String fieldValue = leadRec.get(singleMap.SF_Lead_API__c) != null ? String.valueof(leadRec.get(singleMap.SF_Lead_API__c)) : '';
            if(!singleMap.needTransformation__c){               
           	 	 if(singleMap.Field_Type__c == 'Boolean'  )
                 { 
                     gen.writeBooleanField(singleMap.Weg_Engage_Key__c, fieldValue!=''?Boolean.valueOf(fieldValue):false);
                 }
                 else if(singleMap.Field_Type__c == 'Number' )
                 {
                     If(fieldValue!='')
                     gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(fieldValue));
                 }
                     
                 else
           	 		gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue);             
            }
                
           
                
        }
        
        gen.writeFieldName('eventData');
        gen.writeStartObject();
        for (WebEng_Sync_Fields__mdt singleMap : attribFieldList) {
             String fieldValue = String.IsNotBlank(String.valueof(leadRec.get(singleMap.SF_Lead_API__c)))? 
                   			        String.valueof(leadRec.get(singleMap.SF_Lead_API__c)) :'';
            if(!singleMap.needTransformation__c ){                
           		 if(singleMap.Field_Type__c == 'Boolean'  )
                 { 
                     gen.writeBooleanField(singleMap.Weg_Engage_Key__c,fieldValue!=''? Boolean.valueOf(fieldValue):false);
                 }
                 else if(singleMap.Field_Type__c == 'Number')
                 {
                     If(fieldValue!='')
                     gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(fieldValue));
                 }
                 else if(singleMap.Field_Type__c == 'Date'  )
                 {
                     If(fieldValue!='')
                         gen.writeDateField(singleMap.Weg_Engage_Key__c, Date.ValueOf(fieldValue));
                 }
                     
                 else
           	 		gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue);             
             }else
             {
                String transformedValue = WebEngageUtility.getTransformedValue(singleMap,fieldValue);
                
                   if(singleMap.Field_Type__c == 'Boolean')
                      {
                         gen.writeBooleanField(singleMap.Weg_Engage_Key__c,transformedValue!=''? Boolean.valueOf(transformedValue): false);
                      }
                  else if(singleMap.Field_Type__c == 'Number')
                     { 
                     	If(transformedValue!='')
                    	 gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(transformedValue));
                     }
                
                     
                 else
           	 		gen.writeStringField(singleMap.Weg_Engage_Key__c, transformedValue); 
                
            }
                       
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
       
        jsonString = gen.getAsString();
        system.debug('requestBody:'+jsonString);
         return(jsonString);
    }
    
   }