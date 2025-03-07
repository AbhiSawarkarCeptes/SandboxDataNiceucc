public class X_UnitPostRequestHandler {
    static final String REQUEST_NAME = 'Unit_Post';
    static Xpedeon_API_Metadata__mdt metadataAPI;
    static List<Xpedeon_Metadata_Headers__mdt> metadataHeaders;
    static List<Xpedeon_Static_Data__mdt> staticMetadata;
    
    static{
        X_RequestMetadata reqMdt = new X_RequestMetadata(REQUEST_NAME);
        metadataAPI = reqMdt.metadataAPI;
        metadataHeaders = reqMdt.metadataHeaders;
        staticMetadata = reqMdt.staticMetadata;
    }
    
    public static HttpRequest createHttpRequest(){
        //Create Request
        HTTPRequest request = new HTTPRequest();
        
        //Set Method and Endpoint
        request.setEndpoint(metadataAPI.End_Point__c);
        request.setMethod(metadataAPI.Method_Name__c);
        for(Xpedeon_Metadata_Headers__mdt metadataHeader : metadataHeaders){
            if(String.isNotBlank(metadataHeader.Header_Name__c)){
                request.setHeader(metadataHeader.Header_Name__c,metadataHeader.Header_value__c);
            }
        }
        return request;
    }   
    
    //Generate Unit POST RequestBody
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String objId){
        
        //Fetch Unit Details
        List<Unit__c> unitRecords = new List<Unit__c>();
        sobjectType sObjectName = Id.valueOf(objId).getSObjectType();
        if(sObjectName == Unit__c.sObjectType){
            unitRecords = [SELECT Id,Name,Tower__r.Name,Tower__r.Tower_code__c,Xpedeon_Project_Code__c,
                           Tower__r.Xpedeon_Project_Code__c,Tower__r.Xpedeon_Phase_Code__c,Xpedeon_Phase_Code__c,Unit_Status__c,Not_Available_for_Sales__c,Unavailable_for_Inventory_Matrix__c
                           FROM Unit__c 
                           WHERE Id =: objId];
        }

        if(unitRecords == null || unitRecords.size() == 0){
            return null;
            
        }
        
        //Set Headers if any static data has to be refered in body Creation can add this block
        Map<String,String> staticDataMap = new Map<String,String>();
        if(staticMetadata != null && staticMetadata.size()>0){
            for(Xpedeon_Static_Data__mdt staticData : staticMetadata){
                if(staticData.Xpedeon_API_Metadata__c == metadataAPI.Id){
                    staticDataMap.put(staticData.Field_Label__c,staticData.Field_Value__c);
                }
            }
        }
        
        //update endpoint with actual projectCode 
        string endPoint = metadataAPI.End_Point__c;
        String projectCode = String.IsNotBlank(unitRecords[0].Xpedeon_Project_Code__c) ? String.ValueOf(unitRecords[0].Xpedeon_Project_Code__c) :  unitRecords[0].Tower__r.Xpedeon_Project_Code__c;
        
        if((unitRecords != NULL || unitRecords.size() > 0) && projectCode!=NULL)
            endPoint = endPoint.replace('{project_code}',projectCode );
        request.setEndpoint(endPoint);
        system.debug('modifiedendPoint:'+endPoint);
        
        //Create JSON Structure
        List<X_UnitRequestWrapper.X_UnitJSON> unitListJSON = new List<X_UnitRequestWrapper.X_UnitJSON>();
        for(Unit__c unitRecord : unitRecords){
            
            if(unitRecord.Unit_Status__c == 'Unreleased' || unitRecord.Unavailable_for_Inventory_Matrix__c) continue;
            
            X_UnitRequestWrapper.X_UnitJSON unitJSON = new X_UnitRequestWrapper.X_UnitJSON();
            if(String.isNotBlank(unitRecord.Xpedeon_Phase_Code__c)){
                unitJSON.phaseCode = unitRecord.Xpedeon_Phase_Code__c;
            }else if(String.isNotBlank(unitRecord.Tower__r?.Xpedeon_Phase_Code__c)){
                unitJSON.phaseCode = unitRecord.Tower__r.Xpedeon_Phase_Code__c;
            }else{
                unitJSON.phaseCode = unitRecord.Tower__r.Tower_code__c;
            }
            //unitJSON.phaseCode = String.IsNotBlank(unitRecord.Xpedeon_Phase_Code__c) ? unitRecord.Xpedeon_Phase_Code__c : unitRecord.Tower__r.Tower_code__c;
            
            unitJSON.unitCode = unitRecord.Name;
            unitJSON.unitDescription =unitRecord.Name+'-'+ unitRecord.Tower__r.Name+'-' + projectCode;//Plot Code + Phase Name+ Project Code
            unitJSON.unitType =staticDataMap.get('unitType');// SalablePlot

            unitListJSON.add(unitJSON);
        }
        
        //Create JSON
        String unitJSONBody = !unitListJSON.isEmpty() ? JSON.serialize(unitListJSON) : '';
        System.debug('UnitJSON: '+unitJSONBody);
        
        //Set Request Body
        request.setBody(unitJSONBody); 
        
        return request;
    }
    
    public static Map<String,String> getRequestHeaders(){
        Map<String,String> retMap = new Map<String,String>();
        for(Xpedeon_Metadata_Headers__mdt rHeader : metadataHeaders){
            retMap.put(rHeader.Header_Name__c,rHeader.Header_value__c);
        }
        return retMap;
    }
    
    
}