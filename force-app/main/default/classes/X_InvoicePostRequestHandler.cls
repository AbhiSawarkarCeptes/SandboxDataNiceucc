public class X_InvoicePostRequestHandler {
    static final String REQUEST_NAME = 'Invoice_Post';
    static Xpedeon_API_Metadata__mdt metadataAPI;
    static List<Xpedeon_Metadata_Headers__mdt> metadataHeaders;
    static List<Xpedeon_Static_Data__mdt> staticMetadata;
    static List<Xpedeon_Static_Value_Mapping__mdt> staticValueMetadata;
    
    static{
        X_RequestMetadata reqMdt = new X_RequestMetadata(REQUEST_NAME);
        metadataAPI = reqMdt.metadataAPI;
        metadataHeaders = reqMdt.metadataHeaders;
        staticMetadata = reqMdt.staticMetadata;
        staticValueMetadata = reqMdt.staticValueMetadata;
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
	   //Generate Invoice Post Request
	
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String demandId){
        
        //Fetch Applicant Details 
        List<Demand__c> demandRecords = [SELECT id,name,Receipt__c,Xpedeon_Document_Date__c,Demand_Status__c,Xpedeon_Doc_Type__c,CreatedDate,Tower__c,Unit__r.Name,Due_Date__c,Total_Amount_Demanded__c,Unit__r.Xpedeon_Phase_Code__c,
                                         Booking__r.Unit__r.Name,Booking__C,Booking__r.Unit__r.Tower__r.Name,Booking__r.SF_Xp_Composite_Code__c,Booking__r.Unit__c,
                                         Booking__r.Unit__r.Tower__r.Xpedeon_Project_Code__c,Total_Tax_Demanded__c,Total_Amount_with_Tax_Demanded__c,
                                         Booking__r.Unit__r.Tower__r.Tower_Code__c,unit__r.Xpedeon_Unit_Type__c,Milestone_Name__c,Unit__r.Xpedeon_Project_Code__c,
                                         Booking__r.Primary_Applicant_Name__c,Booking__r.unit__r.Xpedeon_Unit_Type__c,Payment_Milestones__c,Other_Charges_Type__c,
                                         Unit__r.Xpedeon_Unit_Code__c,Booking__r.Unit__r.Unit_No__c,Booking__r.Unit__r.Xpedeon_Project_Code__c,Debit_Type__c,Booking__r.Unit__r.Xpedeon_Phase_Code__c,Booking__r.Unit__r.Tower__r.Xpedeon_Phase_Code__c
                                         FROM Demand__c WHERE id =: demandId];
        Demand__c demandRecord;
        if(demandRecords == null || demandRecords.size() == 0)
        {
            return null;
            
        }else{
			demandRecord =  demandRecords[0];   
        }

        
        //Create JSON Structure
        Id userId =UserInfo.getUserId();
        String customerEntityCode = X_Utility.getEntityCodeFor(demandRecord.Booking__c);
        Map<String,String> staticDataMap = new Map<String,String>();
        if(staticMetadata != null && staticMetadata.size()>0){
            for(Xpedeon_Static_Data__mdt staticData : staticMetadata){
                if(staticData.Xpedeon_API_Metadata__c == metadataAPI.Id){
                    if(staticData.Field_Value__c == null){
                        staticDataMap.put(staticData.Field_Label__c,'');
                    }else{
                        staticDataMap.put(staticData.Field_Label__c,staticData.Field_Value__c);
                    }  
                }
            }
        }
        
        Map<String,String> staticValueDataMap = new Map<String,String>();
        if(staticValueMetadata != null && staticValueMetadata.size()>0){
            for(Xpedeon_Static_Value_Mapping__mdt staticValueData : staticValueMetadata){
                if(staticValueData.Xpedeon_API_Metadata__c == metadataAPI.Id){
                    if(staticValueData.Value__c == null){
                        staticValueDataMap.put(staticValueData.Key__c,'');
                    }else{
                        staticValueDataMap.put(staticValueData.Key__c,staticValueData.Value__c);
                    } 
                }
            }
        }
        
        X_DemandRequestWrapper.X_DemandJSON demandJSON = new X_DemandRequestWrapper.X_DemandJSON();
        X_DemandRequestWrapper.X_invoiceLine invoiceLine = new X_DemandRequestWrapper.X_invoiceLine();
        X_DemandRequestWrapper.X_invoiceVAT invoiceVAT = new X_DemandRequestWrapper.X_invoiceVAT();
        String docType = X_Utility.getDemandType(demandRecord);
        String vatCode = staticValueDataMap.get(X_Utility.getOtherType('VATCode',docType,demandRecord.Booking__r.unit__r.Xpedeon_Unit_Type__c));//staticValueDataMap.get(demandRecord.Booking__r.unit__r.Xpedeon_Unit_Type__c);
        Decimal vatRate = Integer.ValueOf(staticValueDataMap.get(vatCode));
		
        //Decimal amountDemanded = demandRecord.Total_Amount_with_Tax_Demanded__c - (demandRecord.Total_Amount_with_Tax_Demanded__c * (vatRate/100.0));
        Decimal amountDemanded = demandRecord.Total_Amount_with_Tax_Demanded__c / (1+vatRate/100.0);
        amountDemanded = (amountDemanded.intValue() == amountDemanded) ? amountDemanded : (Math.round(amountDemanded*100)/100.00);
        Decimal vatDemanded = demandRecord.Total_Amount_with_Tax_Demanded__c - amountDemanded;
        vatDemanded = (vatDemanded.intValue() == vatDemanded) ? vatDemanded : (Math.round(vatDemanded*100)/100.00);
        
        request.setEndpoint(request.getEndpoint().replace('{invoicetype}',docType));
        String monthComponent =  demandRecord.Xpedeon_Document_Date__c != NULL ? ((demandRecord.Xpedeon_Document_Date__c.date().month() < 10 ? '0' : '' ) + demandRecord.Xpedeon_Document_Date__c.date().month()) : ((demandRecord.CreatedDate.date().month() < 10 ? '0' : '' ) + demandRecord.CreatedDate.date().month());
        String yearComponent = Math.mod(demandRecord.CreatedDate.date().year(),2000)+'';
        demandJSON.CompanyCode = staticDataMap.get('CompanyCode');//demandRecord.Company__c;
        demandJSON.BranchCode = staticDataMap.get('BranchCode') != null ? staticDataMap.get('BranchCode') : '';
        demandJSON.ProjectCode = String.IsNotBlank(demandRecord.Unit__r.Xpedeon_Project_Code__c	) ? String.ValueOf(demandRecord.Unit__r.Xpedeon_Project_Code__c) : demandRecord.Booking__r.Unit__r.Tower__r.Xpedeon_Project_Code__c; //'102S17';
        demandJSON.entityCode = customerEntityCode;//==null ? demandRecord.Booking__r.SF_Xp_Composite_Code__c : customerEntityCode;//X_Utility.getCompositeCodeFor(demandRecord.Booking__c);
        demandJSON.DocumentReference = docType+'-'+demandJSON.ProjectCode+'-'+monthComponent+'-'+yearComponent+'-'+demandRecord.name;//demandRecord.name;
        demandJSON.DocumentDate = demandRecord.Xpedeon_Document_Date__c != NULL ? demandRecord.Xpedeon_Document_Date__c : demandRecord.CreatedDate;
        demandJSON.DocCurrencyCode = staticDataMap.get('DocCurrencyCode');//'AED';
        demandJSON.ClientInvoiceRef = customerEntityCode;
        demandJSON.ClientInvoiceDate = demandRecord.Xpedeon_Document_Date__c != NULL ? demandRecord.Xpedeon_Document_Date__c : demandRecord.CreatedDate;
        demandJSON.PaymentTermsCode = staticDataMap.get('PaymentTermsCode');//'C030';
        demandJSON.DueDate = demandRecord.Due_Date__c;
        demandJSON.Remarks = staticDataMap.get('Remarks') != null ? staticDataMap.get('Remarks') : '';
        
        invoiceLine.lineNo = Integer.valueOf(staticDataMap.get('lineNo'));
        invoiceLine.lineType = staticDataMap.get('lineType');
        invoiceLine.LineDescription = demandRecord.Milestone_Name__c + ' raised for ' + demandRecord.Unit__r.Name + ' ' + demandRecord.Booking__r.Primary_Applicant_Name__c;
        invoiceLine.ResourceCode = staticDataMap.get('ResourceCode') != null ? staticDataMap.get('ResourceCode') : '';
        invoiceLine.AccountNumber = Integer.valueOf(staticValueDataMap.get(docType));//420117;
        invoiceLine.SubledgerAccount = '';//docType == 'PSI' ? demandRecord.Booking__r.Unit__r.Name : '';
        invoiceLine.UOM = null;//staticDataMap.get('UOM');
        invoiceLine.Quantity = Integer.valueOf(staticDataMap.get('Quantity'));
        invoiceLine.UnitPrice = Integer.valueOf(staticDataMap.get('UnitPrice'));
        invoiceLine.LineAmount =  amountDemanded;//Integer.valueOf(demandRecord.Total_Amount_Demanded__c);//100;
        invoiceLine.AdditionalInfo = staticDataMap.get('AdditionalInfo');
        invoiceLine.RevenueHead = X_Utility.getOtherType('RevenueHead',docType,null) !=null ? staticValueDataMap.get(X_Utility.getOtherType('RevenueHead',docType,null)) : '';
        
        
        invoiceLine.RevenueCode = X_Utility.getOtherType('RevenueCode',docType,null) !=null ? staticValueDataMap.get(X_Utility.getOtherType('RevenueCode',docType,null)) : '';
        if(docType == 'ASI' && (demandRecord.Milestone_Name__c == 'Late Payment Charges' || demandRecord.Other_Charges_Type__c == '1% Delayed Handover Charges' || demandRecord.Other_Charges_Type__c == 'Plot - Construction Commencement/ Completion Delay Penalty')){
            invoiceLine.RevenueCode = '420714';
        }
        if(docType == 'ASI' && demandRecord.Other_Charges_Type__c == 'Cheque Dishonoured Charges'){
            invoiceLine.RevenueCode = '420715';
        }
        
        //invoiceLine.PhaseCode = (String.IsNotBlank(demandRecord.Unit__r.Xpedeon_Phase_Code__c) ) ? String.ValueOf(demandRecord.Unit__r.Xpedeon_Phase_Code__c) : demandRecord.Booking__r.Unit__r.Tower__r.Tower_Code__c;//'TOWER-C';
        if(String.isNotBlank(demandRecord.Booking__r.Unit__r.Xpedeon_Phase_Code__c)){
            invoiceLine.PhaseCode = demandRecord.Booking__r.Unit__r.Xpedeon_Phase_Code__c;
        }else if(String.isNotBlank(demandRecord.Booking__r?.Unit__r?.Tower__r?.Xpedeon_Phase_Code__c)){
            invoiceLine.PhaseCode = demandRecord.Booking__r.Unit__r.Tower__r.Xpedeon_Phase_Code__c;
        }else{
            invoiceLine.PhaseCode = demandRecord.Booking__r?.Unit__r?.Tower__r?.Tower_Code__c;
        }

        // demandRecord.Booking__r.Unit__r.Tower__r.Tower_Code__c;//'TOWER-C';
        invoiceLine.BlockCode = staticDataMap.get('BlockCode');
        invoiceLine.UnitCode = (String.IsNotBlank(demandRecord.Unit__r.Xpedeon_Unit_Code__c) ) ? String.ValueOf(demandRecord.Unit__r.Xpedeon_Unit_Code__c) : demandRecord.Booking__r.Unit__r.Unit_No__c;
        demandJSON.invoiceLines = new list<X_DemandRequestWrapper.X_invoiceLine>{invoiceLine};
        
		invoiceVAT.LineNo = Integer.ValueOf(staticDataMap.get('LineNo'));
        invoiceVAT.Description = demandRecord.Milestone_Name__c + ' raised for ' + demandRecord.Unit__r.Name + ' ' + demandRecord.Booking__r.Primary_Applicant_Name__c;
        invoiceVAT.VATType = staticDataMap.get('VATType');
        invoiceVAT.VATCode = vatCode; //staticValueDataMap.get(demandRecord.Booking__r.unit__r.Xpedeon_Unit_Type__c);
        invoiceVAT.VATRate = vatRate; //Integer.ValueOf(staticValueDataMap.get(invoiceVAT.VATCode));
        invoiceVAT.AmountEligible = amountDemanded;//String.valueOf((demandRecord.Total_Amount_with_Tax_Demanded__c * (Decimal.valueOf(invoiceVAT.VATRate)/100)));//String.valueOf(demandRecord.Total_Amount_Demanded__c);//'100';
        invoiceVAT.VatAmount = vatDemanded;//Integer.valueOf((demandRecord.Total_Amount_with_Tax_Demanded__c * (Decimal.valueOf(invoiceVAT.VATRate)/100)));//Integer.valueOf(X_Utility.populateVatAmount(demandRecord));
        invoiceVAT.AdditionalInfo = staticDataMap.get('AdditionalInfo') != null ? staticDataMap.get('AdditionalInfo') : '';
        
        
        demandJSON.documentValue = amountDemanded;//Integer.valueOf((demandRecord.Total_Amount_with_Tax_Demanded__c * (Decimal.valueOf(invoiceVAT.VATRate)/100)));//105;
        demandJSON.invoiceVAT = new list<X_DemandRequestWrapper.X_invoiceVAT>{invoiceVAT};
        demandJSON.TotalLineAmount = 0;
        demandJSON.TotalVATAmount = 0;
        
        //for(X_DemandRequestWrapper.X_invoiceVAT invVat : demandJSON.invoiceVAT){
        demandJSON.TotalVATAmount = vatDemanded;//+= invVat.VatAmount;
        //}
        //for(X_DemandRequestWrapper.X_invoiceLine invLine : demandJSON.invoiceLines){
        demandJSON.TotalLineAmount = amountDemanded;//+= invLine.LineAmount;
        System.debug('amountDemanded3:'+amountDemanded);
        //}
        //Create JSON
        String customerJSON = JSON.serialize(demandJSON);
        System.debug('CustomerJSON:'+customerJSON);
        
        //Set Request Body
        request.setBody(customerJSON); 
        
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