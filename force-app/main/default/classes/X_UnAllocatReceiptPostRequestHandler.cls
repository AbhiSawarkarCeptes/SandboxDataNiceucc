public class X_UnAllocatReceiptPostRequestHandler {
    static final String REQUEST_NAME = 'UnallocatedReceipt_Post';
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
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String prId){
        List<Payment_Request__C> prRecords=[SELECT ID, Name,Booking__r.Name,From_Booking__c,
                                            Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,
                                            DP_Amount__c,DLD_Amount_in_New_Sale__c,DP_Amount_2__c,DLD_Amount_2__c,Secondary_Mode__c,
                                            Unit__r.Name,Name__c, Booking__r.Unit__r.Name,                                            
                                            Amount__c,Instrument_Date__c,Mode__c, Booking__r.Opportunity__r.Name,
                                            Account_Received_Date__c,Account_Master__r.Is_Foreign_Currency__c,
                                            Date_of_Initiation__c,Instrument_Number__c,Account_Master__r.Account_Number__c
                                            FROM Payment_Request__c
                                           	WHERE ID = :prId];
          Payment_Request__C prRecord;
        if(prRecords == null || prRecords.size() == 0)
        {
            return null;
            
        }else{
            prRecord =  prRecords[0];   
            
        }
        
        //Fetch Receipt Details 
        List<Receipt__c > recRecords = [SELECT Id,GL_Date__c,Debit_Account__r.Xpedeon_Account_Number__c,Cheque_DD__c
                                        FROM Receipt__c  WHERE payment_request__c =: prId AND
                                        Receipt_Status__c='Cleared' and GL_Date__c!=NULL AND Debit_Account__r.Xpedeon_Account_Number__c != NULL];
        Receipt__c  recRecord;
        if(recRecords == null || recRecords.size() <= 0)
        {
            return null;
        }else{
            recRecord = recRecords[0];
        }
           
        //Create JSON Structure      
        Map<String,String> staticDataMap = new Map<String,String>();
        if(staticMetadata != null && staticMetadata.size()>0){
            for(Xpedeon_Static_Data__mdt staticData : staticMetadata){
                if(staticData.Xpedeon_API_Metadata__c == metadataAPI.Id){
                    staticDataMap.put(staticData.Field_Label__c,staticData.Field_Value__c);
                }
            }
        }
        
        
        X_UnallocatedReceiptRequestWrapper.X_unallocatedReceiptJSON unAllocatedReceiptJSON = new X_UnallocatedReceiptRequestWrapper.X_unallocatedReceiptJSON();
        X_Utility.X_ReceiptMode mode=X_Utility.getModeType(PrRecord.Mode__c);
       
        unAllocatedReceiptJSON.typeOfReceipt = (prRecord.Mode__c != null && prRecord.Mode__c != '' && prRecord.Mode__c.contains('OTC')) ? 'Cash' : 'Bank';	
        unAllocatedReceiptJSON.totalAllocationAmount = Integer.ValueOf(staticDataMap.get('totalAllocationAmount'));//0;
        						/* X_Utility.getTotalAllocationAmt(prRecord.Towards_Other_Charges_Amount__c,
                                                                                       prRecord.Towards_Pre_Registration_Amount__c,
                                                                                       prRecord.Towards_Unit_Price_Amount__c);*/
           
        unAllocatedReceiptJSON.sourceCurrencyCode = staticDataMap.get('sourceCurrencyCode')==NULL ? '' : staticDataMap.get('sourceCurrencyCode') ;// '';
       	unAllocatedReceiptJSON.amountInSourceCurrency = staticDataMap.get('amountInSourceCurrency')==NULL ? '' : staticDataMap.get('amountInSourceCurrency') ;// ''; 
        
        unAllocatedReceiptJSON.receivedFrom = 'Received from '+prRecord.Name__c+' for '+ prRecord.Booking__r.Unit__r.Name;
        unAllocatedReceiptJSON.receiptHeaderRef =prRecord.Name;
        unAllocatedReceiptJSON.receiptHeaderDate =  String.valueOf(recRecord.GL_Date__c); //String.valueOf(prRecord.Account_Received_Date__c); //'2024-03-29';
        if(prRecord.From_Booking__c){unAllocatedReceiptJSON.receiptAmount = X_Utility.getTotalAllocationAmt(prRecord.Towards_Other_Charges_Amount__c,prRecord.Towards_Pre_Registration_Amount__c,prRecord.Towards_Unit_Price_Amount__c);}
        else{unAllocatedReceiptJSON.receiptAmount = String.isBlank(prRecord.Secondary_Mode__c) ? X_Utility.getTotalAllocationAmt(prRecord.DP_Amount__c,null,prRecord.DLD_Amount_in_New_Sale__c,null) : X_Utility.getTotalAllocationAmt(null,prRecord.DP_Amount_2__c,null,prRecord.DLD_Amount_2__c);}
        
		
        unAllocatedReceiptJSON.projectCode = staticDataMap.get('projectCode'); //'102';
        unAllocatedReceiptJSON.postDated =  staticDataMap.get('postDated');//'NO'; 
        
       // unAllocatedReceiptJSON.modeNo = prRecord.Instrument_Number__c;//'4567';	
        unAllocatedReceiptJSON.modeNo = String.isNotBlank(prRecord.Instrument_Number__c) ? prRecord.Instrument_Number__c : recRecord.Cheque_DD__c;//'4567';	
        
        unAllocatedReceiptJSON.otherType = mode.modeSubType;
        unAllocatedReceiptJSON.modeType = mode.ModeType; //prRecord.Mode__c;
        unAllocatedReceiptJSON.modeDate = String.valueOf(recRecord.GL_Date__c); //'2024-03-29';
       
        unAllocatedReceiptJSON.extRef =  staticDataMap.get('extRef')==NULL ? '' : staticDataMap.get('extRef') ;// '';
        unAllocatedReceiptJSON.docGuid = staticDataMap.get('docGuid')==NULL ? '' : staticDataMap.get('docGuid') ;// '';
        unAllocatedReceiptJSON.companyCode =  staticDataMap.get('CompanyCode');// '102';
	    unAllocatedReceiptJSON.branchCode = staticDataMap.get('branchCode')==NULL ? '' : staticDataMap.get('branchCode') ;// '';
        
        unAllocatedReceiptJSON.bankOrCashAccountNumber =  recRecord.Debit_Account__r?.Xpedeon_Account_Number__c;//prRecord.Account_Master__r.Account_Number__c;
        	
               
        
        //Create JSON
        String UnAllocatedRecJSON = JSON.serialize(unAllocatedReceiptJSON);
        System.debug('UnAllocatedRecJSON:'+UnAllocatedRecJSON);
        
        //Set Request Body
        request.setBody(UnAllocatedRecJSON); 
        
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