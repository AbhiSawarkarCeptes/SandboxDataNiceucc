public class WebEngageEnquiryHandler {
	public static HttpRequest createHttpRequestForUser(){
        //Create Request
        HTTPRequest request = new HTTPRequest();
        
        WebEng_API_Metadata__mdt metadataAPI = WebEng_API_Metadata__mdt.getInstance('Lead_Post')  ;
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
        system.debug('request with Header:'+request);
        return request;
    }
    public static HttpRequest createHttpRequestForEnquiry(){
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
    public static HTTPREQUEST createHttpRequestBodyUser(HttpRequest request, String enqJson){
        PropStrength__Request__c enqRecord = (PropStrength__Request__c)JSON.deserialize(enqJson, PropStrength__Request__c.class);
        //Create JSON Structure
        String reqBody = getBodyForUser(enqRecord);
        //Set Request Body
        request.setBody(reqBody);
        system.debug('request with body:'+request);
        return request;
    }
     public static String getBodyForUser(PropStrength__Request__c EnqRecord) {
        List<Web_Eng_Sync_Enquiry_Field__mdt> webEngageSyncList = [SELECT Weg_Engage_Key__c, 
                                                        SF_Field_API__c, needTransformation__c, SF_Object__c,
                                                           Payload_Section__c, Field_Type__c
                                                           FROM Web_Eng_Sync_Enquiry_Field__mdt
                                                           WHERE (SF_Object__c ='Enquiry' OR SF_Object__c = 'Contact') 
                                                           AND 	Data_For__c = 'User'];
        List<Web_Eng_Sync_Enquiry_Field__mdt> mainFieldList = new List<Web_Eng_Sync_Enquiry_Field__mdt>();
        List<Web_Eng_Sync_Enquiry_Field__mdt> attribFieldList = new List<Web_Eng_Sync_Enquiry_Field__mdt>();
        String jsonString;
        
        /* Fetch sync fields from custom metadata */
        for(Web_Eng_Sync_Enquiry_Field__mdt singleMap : webEngageSyncList) {
            if(singleMap.Payload_Section__c == 'Main') {
                mainFieldList.add(singleMap);
            }
            else {
                attribFieldList.add(singleMap);
            }
        }
        system.debug('fields::'+attribFieldList);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        String userValue = EnqRecord.Legacy_ID__c != null ? 
            	EnqRecord.Legacy_ID__c : EnqRecord.PropStrength__Primary_Contact__r.Legacy_ID__c != null ? EnqRecord.PropStrength__Primary_Contact__r.Legacy_ID__c 
                : EnqRecord.PropStrength__Primary_Contact__c;
        gen.writeStringField('userId', userValue);  
         /* Construct main section in API payload */
        for (Web_Eng_Sync_Enquiry_Field__mdt singleMap : mainFieldList) {
            String fieldValue;
            system.debug('singleMap::'+singleMap);
            if(singleMap.Weg_Engage_Key__c == 'phone' 
               && singleMap	.SF_Field_API__c != NULL) {
                if(singleMap.SF_Object__c == 'Contact') {
                    fieldValue = '+';
                    fieldValue = fieldValue+ EnqRecord.PropStrength__Primary_Contact__r.get(singleMap.SF_Field_API__c);}else if(singleMap.SF_Object__c == 'Enquiry') { fieldValue = '+'+EnqRecord.get(singleMap.SF_Field_API__c);}
                system.debug('mobile::'+fieldValue);
            }
            
            else {
                if(singleMap.SF_Object__c == 'Contact') {
                    fieldValue = '';
                    fieldValue = fieldValue + EnqRecord.PropStrength__Primary_Contact__r.get(singleMap.SF_Field_API__c);
                }
                else if(singleMap.SF_Object__c == 'Enquiry') {
                    fieldValue = '';
                    fieldValue = fieldValue + EnqRecord.get(singleMap.SF_Field_API__c);
                }
            }
            if(!singleMap.needTransformation__c){    
                if(singleMap.Field_Type__c == 'Boolean'  ) { try{gen.writeBooleanField(singleMap.Weg_Engage_Key__c, fieldValue!=''?Boolean.valueOf(fieldValue): false);}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Boolean format so skipped');}
                }     
                else {
                    gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue); }  } else {String transformedValue = WebEngageEnquiryHandler.getTransformedValueEnquiryApi(singleMap,fieldValue);if(singleMap.Field_Type__c == 'Boolean'){gen.writeBooleanField(singleMap.Weg_Engage_Key__c,transformedValue!=''? Boolean.valueOf(transformedValue):false);}else if(singleMap.Field_Type__c == 'Number' ){If(transformedValue!='')gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(transformedValue));}else gen.writeStringField(singleMap.Weg_Engage_Key__c, transformedValue); }
        }
        /* Construct Attribute section in API payload */
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        for (Web_Eng_Sync_Enquiry_Field__mdt singleMap : attribFieldList) {
            String fieldValue;
            if(singleMap.SF_Object__c == 'Contact') {
                fieldValue = ''+ EnqRecord.PropStrength__Primary_Contact__r.get(singleMap.SF_Field_API__c);
            }
            else if(singleMap.SF_Object__c == 'Enquiry') {
                fieldValue = ''+EnqRecord.get(singleMap.SF_Field_API__c);
            }
            if(!singleMap.needTransformation__c ){                
                if(singleMap.Field_Type__c == 'Boolean'  ) { try{gen.writeBooleanField(singleMap.Weg_Engage_Key__c,fieldValue!=''? Boolean.valueOf(fieldValue): false);}catch(Exception e){ System.debug(singleMap.SF_Field_API__c+' is not in proper Boolean format so skipped'); }}   else if(singleMap.Field_Type__c == 'Date'  ) { If(fieldValue!=''){try{ gen.writeDateField(singleMap.Weg_Engage_Key__c, Date.ValueOf(fieldValue));}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Date format so skipped');}}
                }  
                
                else
                    gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue);    
            }else{
                String transformedValue = WebEngageEnquiryHandler.getTransformedValueEnquiryApi(singleMap,fieldValue);
                if(singleMap.Field_Type__c == 'Boolean')
                {
                    gen.writeBooleanField(singleMap.Weg_Engage_Key__c,transformedValue!=''? Boolean.valueOf(transformedValue):false); } else if(singleMap.Field_Type__c == 'Number' ){ If(transformedValue!='') gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(transformedValue));}else {                    gen.writeStringField(singleMap.Weg_Engage_Key__c, transformedValue); }
            }
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
        
        jsonString = gen.getAsString();
        system.debug('requestBody:'+jsonString);
        return(jsonString);
    }
    //Generate POST Request
    public static HTTPREQUEST createHttpRequestBodyForEnquiry(HttpRequest request, String enqJson, String eventName){
        
        PropStrength__Request__c enqRecord = (PropStrength__Request__c)JSON.deserialize(enqJson, PropStrength__Request__c.class);
        //Create JSON Structure
        String reqBody = getBodyForEnquiry(enqRecord, eventName);
        
        //Set Request Body
        request.setBody(reqBody);
        system.debug('requestwith body:'+request);
        return request;
    }
    
    public static String getBodyForEnquiry(PropStrength__Request__c enqRecord, String eventName) {
        List<Web_Eng_Sync_Enquiry_Field__mdt> webEngageSyncList =  [SELECT Id, Weg_Engage_Key__c, 
                                                            SF_Field_API__c, needTransformation__c,
                                                            Payload_Section__c,Field_Type__c, SF_Object__c
                                                            FROM Web_Eng_Sync_Enquiry_Field__mdt
                                                            WHERE SF_Object__c = 'Enquiry' 
                                                            AND Data_For__c = 'Event'];
        List<Web_Eng_Sync_Enquiry_Field__mdt> mainFieldList = new List<Web_Eng_Sync_Enquiry_Field__mdt>();
        List<Web_Eng_Sync_Enquiry_Field__mdt> attribFieldList = new List<Web_Eng_Sync_Enquiry_Field__mdt>();
        String jsonString;
        
        for(Web_Eng_Sync_Enquiry_Field__mdt singleMap : webEngageSyncList) {
            if(singleMap.Payload_Section__c == 'Main') {  mainFieldList.add(singleMap);
            }
            else {
                attribFieldList.add(singleMap);
            }
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        String userValue = EnqRecord.Legacy_ID__c != null ? EnqRecord.Legacy_ID__c : EnqRecord.PropStrength__Primary_Contact__r.Legacy_ID__c != null ? EnqRecord.PropStrength__Primary_Contact__r.Legacy_ID__c  : EnqRecord.PropStrength__Primary_Contact__c;
        gen.writeStringField('userId', userValue); 
        gen.writeStringField('eventName', eventName);
        
        for (Web_Eng_Sync_Enquiry_Field__mdt singleMap : mainFieldList) { String fieldValue = enqRecord.get(singleMap.SF_Field_API__c) != null ? String.valueof(enqRecord.get(singleMap.SF_Field_API__c)) : ''; if(!singleMap.needTransformation__c){if(singleMap.Field_Type__c == 'Boolean'  ){ try{ gen.writeBooleanField(singleMap.Weg_Engage_Key__c, fieldValue!=''?Boolean.valueOf(fieldValue):false);}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Boolean format so skipped');                     }}else if(singleMap.Field_Type__c == 'Number' ){If(fieldValue!=''){try{gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(fieldValue));}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Integer format so skipped');}}}  else{gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue);             }
            }
            
            
            
        }
        
        gen.writeFieldName('eventData');
        gen.writeStartObject();
        for (Web_Eng_Sync_Enquiry_Field__mdt singleMap : attribFieldList) {
            String fieldValue = String.IsNotBlank(
                String.valueof(enqRecord.get(singleMap.SF_Field_API__c)))
                ?String.valueof(enqRecord.get(singleMap.SF_Field_API__c)
                ) :'';
            if(!singleMap.needTransformation__c ){                
                if(singleMap.Field_Type__c == 'Boolean'  ) { try{gen.writeBooleanField(singleMap.Weg_Engage_Key__c,fieldValue!=''? Boolean.valueOf(fieldValue):false);}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Boolean format so skipped');                 }
                } else if(singleMap.Field_Type__c == 'Number'){ If(fieldValue!=''){ try{gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(fieldValue));}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper Integer format so skipped');                         }
                    }
                }
                else if(singleMap.Field_Type__c == 'Date'  ) { If(fieldValue!=''){try{gen.writeDateField(singleMap.Weg_Engage_Key__c, Date.ValueOf(fieldValue));}catch(Exception e){System.debug(singleMap.SF_Field_API__c+' is not in proper date format so skipped');}
                    }
                }
                
                else
                    gen.writeStringField(singleMap.Weg_Engage_Key__c, fieldValue);             
            }else
            {
                String transformedValue = WebEngageEnquiryHandler.getTransformedValueEnquiryApi(singleMap,fieldValue);
                
                if(singleMap.Field_Type__c == 'Boolean'){
                    gen.writeBooleanField(
                        				singleMap.Weg_Engage_Key__c,transformedValue!=''? 
                                          Boolean.valueOf(transformedValue)
                        				: false);
                } else if(singleMap.Field_Type__c == 'Number') { 
                    If(transformedValue!='')
                        gen.writeNumberField(singleMap.Weg_Engage_Key__c, Integer.valueOf(transformedValue));}else{ gen.writeStringField(singleMap.Weg_Engage_Key__c, transformedValue); }
                
            }
            
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
        
        jsonString = gen.getAsString();
        system.debug('requestBody:'+jsonString);
        return(jsonString);
    }
    public static String getTransformedValueEnquiryApi(Web_Eng_Sync_Enquiry_Field__mdt  singleMap, String actualFieldValue){
        List<WebEng_Enquiry_Contact_Transformation__mdt> transformationMap = new List<WebEng_Enquiry_Contact_Transformation__mdt>();
        
        transformationMap = [SELECT Transformed_Value__c,Transform_Key__c, Web_Eng_Sync_Enquiry_Field__c  
                             FROM WebEng_Enquiry_Contact_Transformation__mdt 
                             WHERE Web_Eng_Sync_Enquiry_Field__c = :singleMap.Id 
                             AND Transform_Key__c = :actualFieldValue LIMIT 1];
        
        
        system.debug('transformationMap::'+transformationMap);
        // system.debug('transformationMap.Transformed_Value__c::'+transformationMap.Transformed_Value__c);
        system.debug('actualFieldValue::'+actualFieldValue);
        return (!transformationMap.isEmpty())  ? transformationMap[0].Transformed_Value__c : '' ;
    }
}