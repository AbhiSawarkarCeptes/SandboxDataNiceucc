public class X_PhasePostRequestHandler {
    static final String REQUEST_NAME = 'Phase_Post';
    static Xpedeon_API_Metadata__mdt metadataAPI;
    static List<Xpedeon_Metadata_Headers__mdt> metadataHeaders;
    static List<Xpedeon_Static_Data__mdt> staticMetadata;
    
    static{
        X_RequestMetadata reqMdt = new X_RequestMetadata(REQUEST_NAME);
        metadataAPI = reqMdt.metadataAPI;
        metadataHeaders = reqMdt.metadataHeaders;
        staticMetadata = reqMdt.staticMetadata;
    }
    
    //Generate Receipt post Request
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
    
    
    
    //Generate Phase Post Request
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String phaseId){
        
        //Fetch Phase Details 
        List<Tower__c > towerRecords = [select Id,Name,Xpedeon_Project_Code__c, Tower_Code__c, Cluster__r.Unavailable_for_Inventory_Matrix__c,Cluster__r.Project__r.Unavailable_for_Inventory_Matrix__c
                                        FROM Tower__c  where Id =: phaseId];
        
       
        if(towerRecords == null || towerRecords.size() == 0)
        {
            return null;
            
        }         
        
        //update endpoint with actual projectCode 
        string endPoint = metadataAPI.End_Point__c;
        system.debug('endPoint1:'+endPoint);
        if((towerRecords != NULL || towerRecords.size() > 0) && towerRecords[0].Xpedeon_Project_Code__c  !=NULL)
        endPoint = endPoint.replace('{project_code}',towerRecords[0].Xpedeon_Project_Code__c);
         
        system.debug('endPoint2:'+endPoint);        
       
        request.setEndpoint(endPoint);
        
        
        //Create JSON Structure
      	List<X_PhaseRequestWrapper.X_PhaseJSON> PhaseJSONList = new List<X_PhaseRequestWrapper.X_PhaseJSON>();
        for(Tower__C towerRecord : towerRecords){
            
            if(towerRecord.Cluster__c == NULL || towerRecord.Cluster__r.Unavailable_for_Inventory_Matrix__c || towerRecord.Cluster__r.Project__c == NULL || towerRecord.Cluster__r.Project__r.Unavailable_for_Inventory_Matrix__c) continue;
                
             X_PhaseRequestWrapper.X_PhaseJSON PhaseJSON = new X_PhaseRequestWrapper.X_PhaseJSON();
            
             PhaseJSON.phaseCode=towerRecord.Tower_Code__c;
             PhaseJSON.phaseName=towerRecord.Name;
             PhaseJSON.phaseDescription=towerRecord.Name;
            PhaseJSONList.add(PhaseJSON);
            
        }
       
		        
        //Create JSON
        String PhaseJSONString = JSON.serialize(PhaseJSONList);
        System.debug('PhaseJSON:'+PhaseJSONString);
        
        //Set Request Body
        request.setBody(PhaseJSONString); 
        
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