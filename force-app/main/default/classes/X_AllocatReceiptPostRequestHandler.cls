public class X_AllocatReceiptPostRequestHandler {
    static final String REQUEST_NAME = 'AllocatedReceipt_Post';
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
    
    
    //Generate Unallocated Receipt Post Request
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String recId){
        
       
List<Receipt__c> receipt=[SELECT ID, Name,Payment_request__c FROM Receipt__c
                                           	WHERE ID = :recId];
        if(receipt[0].Payment_request__c==NULL)
            return NULL;
        
         //Fetch AllocatedReceipt Details 
                List<Receipt__c > recRecords = [SELECT Id,Name,Receipt_Clearance_Date__c,Total_amount__c,Booking__c,
                                                Booking__r.SF_Xp_Composite_Code__c, Payment_Request__r.Name,
                                                Mode__c,GL_Date__c, Receipt_Status__c,Booking__r.Unit__c
                                       			FROM Receipt__c
                                                WHERE payment_request__c =:receipt[0].Payment_request__c 
                                                AND receipt_status__c='Cleared'
                                               ];
                                                        //WHERE 
        if(recRecords == null || recRecords.size() <= 0)
                return null;
               

        //Create JSON Structure
        String customerEntityCode = X_Utility.getEntityCodeFor(recRecords[0].Booking__c);
        Map<String,String> staticDataMap = new Map<String,String>();
        //get static data optional(if any static data id needed for callout)
		if(staticMetadata != null && staticMetadata.size()>0){
            for(Xpedeon_Static_Data__mdt staticData : staticMetadata){
                if(staticData.Xpedeon_API_Metadata__c == metadataAPI.Id){
                    staticDataMap.put(staticData.Field_Label__c,staticData.Field_Value__c);
                }
            }
        }
        
        //update endpoint with parameters 
        string endPoint = metadataAPI.End_Point__c;
        system.debug('endPoint1:'+endPoint);
        if((recRecords != NULL || recRecords.size() > 0) )
        endPoint = endPoint+'?ReceiptHeaderReference='
            +recRecords[0].Payment_Request__r.Name
            +'&ReceiptHeaderCompany='
            + staticDataMap.get('companyCode');
            
        request.setEndpoint(endPoint);        
            List<X_AllocatedReceiptRequestWrapper.X_AllocatedReceiptJSON> allocatedReceiptListJSON = 
            new List<X_AllocatedReceiptRequestWrapper.X_AllocatedReceiptJSON>();
        for(Receipt__C recRecord: recRecords){
                X_AllocatedReceiptRequestWrapper.X_AllocatedReceiptJSON allocatedReceiptJSON = new X_AllocatedReceiptRequestWrapper.X_AllocatedReceiptJSON();
              
                allocatedReceiptJSON.allocationRef = recRecord.Name;	
                allocatedReceiptJSON.allocationDate = string.valueof(recRecord.Receipt_Clearance_Date__c);	
                allocatedReceiptJSON.allocationType = String.ValueOf( staticDataMap.get('allocationType') );//  'ARLedger';	
                allocatedReceiptJSON.allocationValue = Integer.ValueOf(staticDataMap.get('allocationValue') );//  	0;// recRecord.Total_amount__c;//staticDataMap != null && staticDataMap.containsKey('allocationValue')&& staticDataMap.get('allocationValue') != null ?  Decimal.ValueOf(staticDataMap.get('allocationValue')) : 0;//0;
                allocatedReceiptJSON.entityCode = customerEntityCode;//==null ? recRecord.Booking__r.SF_Xp_Composite_Code__c : customerEntityCode; //X_Utility.getCompositeCodeFor(prRecord.Booking__c); //recRecord.Booking__r.SF_Xp_Composite_Code__c;
                allocatedReceiptJSON.description = recRecords[0].Payment_Request__r.Name
                    +' '+'-'+' '
                    +recRecord.Total_Amount__c;	
                //allocatedReceiptJSON.docGuid = '';	
                allocatedReceiptJSON.allocationMode =  staticDataMap.get('allocationMode') ;//'Details';
                
                /*X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARDetailLines receiptAllocationARDetailLine = new X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARDetailLines();
                
                receiptAllocationARDetailLine.projectCode =prRecord.Unit__r.Tower__r.Xpedeon_Project_code__c;		//recReord.Project__r.Project_Code__c;
                receiptAllocationARDetailLine.invoiceDocumentReference = '';	
                receiptAllocationARDetailLine.invoiceDocGuid = '';	
                receiptAllocationARDetailLine.allocationAmount = 0;
                receiptAllocationARDetailLine.computeResidual = false;
                
                X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARAdvanceLines receiptAllocationARAdvanceLine = new X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARAdvanceLines();
                
                receiptAllocationARAdvanceLine.lineNo = 0;	
                receiptAllocationARAdvanceLine.projectCode =prRecord.Unit__r.Tower__r.Xpedeon_Project_code__c; // '102';	//recReord.Project__r.Project_Code__c;
                receiptAllocationARAdvanceLine.advanceAmount = 0;	
                receiptAllocationARAdvanceLine.description = '';	
                receiptAllocationARAdvanceLine.entityRef = '';	
                receiptAllocationARAdvanceLine.entityDate = '';	
                receiptAllocationARAdvanceLine.vatType = '';	
                receiptAllocationARAdvanceLine.vatCode = '';	
                receiptAllocationARAdvanceLine.amountEligible = 0;	
                receiptAllocationARAdvanceLine.vatAmount = 0;
                
                allocatedReceiptJSON.receiptAllocationARAdvanceLines = new list<X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARAdvanceLines>{receiptAllocationARAdvanceLine};
                allocatedReceiptJSON.receiptAllocationARDetailLines = new list<X_AllocatedReceiptRequestWrapper.X_ReceiptAllocationARDetailLines>{receiptAllocationARDetailLine};*/
                allocatedReceiptListJSON.add(allocatedReceiptJSON);
    }
        //Create JSON
        String AllocatedRecJSON = JSON.serialize(allocatedReceiptListJSON);
        System.debug('AllocatedRecJSON:'+allocatedReceiptListJSON);
        
        //Set Request Body
        request.setBody(AllocatedRecJSON); 
        
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