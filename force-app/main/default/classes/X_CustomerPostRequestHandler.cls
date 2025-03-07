//UPDATE : non-mandatory wrapper fields commented by Pulkit
public class X_CustomerPostRequestHandler {
    static final String REQUEST_NAME = 'Customer_Post';
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
    
    //Generate Customer POST Request
    public static HTTPREQUEST createHttpRequestBody(HttpRequest request,String applicantId){
        
        //Fetch Applicant Details 
        List<Applicant_Details__c> applicantRecords = [select id, Opportunity__r.Account.Code__c, 
                                                       Mobile_Number__c,Email_Address__c,Salutation__c,Fax__c,name,Booking__r.SF_Xp_Composite_Code__c,
                                                       Booking__c
                                                       FROM Applicant_Details__c where id =: applicantId];
        Applicant_Details__c applicantRecord;
        if(applicantRecords == null || applicantRecords.size() == 0)
        {
            return null;
            
        }else{
            applicantRecord =  applicantRecords[0];   
            
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
        
        String customerCode = X_utility.getEntityCodeFor(applicantRecord.Booking__c);
        X_CustomerRequestWrapper.X_ApplicantDetailsJson applicantJSON = new X_CustomerRequestWrapper.X_ApplicantDetailsJson();
        applicantJSON.entityName.Title= applicantRecord.Salutation__c;
        //applicantJSON.EntityName.LastName = applicantRecord.Booking__r.SF_Xp_Composite_Code__c+' '+applicantRecord.name;
        applicantJSON.EntityName.LastName = customerCode+' '+applicantRecord.name;
        //applicantJSON.EntityName.DisplayName = applicantRecord.Booking__r.SF_Xp_Composite_Code__c+' '+applicantRecord.name;
        applicantJSON.EntityName.DisplayName = customerCode+' '+applicantRecord.name;
        applicantJSON.EntityRoleID = Integer.valueOf(staticDataMap.get('EntityRoleID'));
        //applicantJSON.TradingAs = applicantRecord.Booking__r.SF_Xp_Composite_Code__c+' '+applicantRecord.name;
        applicantJSON.TradingAs = customerCode+' '+applicantRecord.name;
        applicantJSON.Type = Integer.valueOf(staticDataMap.get('Type'));
        applicantJSON.Code = customerCode;//applicantRecord.Booking__r.SF_Xp_Composite_Code__c; //applicantRecord.opportunity__r.Account.Code__c;
        applicantJSON.EntityScope.ScopeDescriptor = Integer.valueOf(staticDataMap.get('ScopeDescriptor'));
        applicantJSON.EntityScope.CompanyCode = staticDataMap.get('CompanyCode');//null;
        applicantJSON.EntityScope.SharedMasterGroupCode = staticDataMap.get('SharedMasterGroupCode');
        applicantJSON.PrimaryEntity =staticDataMap.get('PrimaryEntity');
        applicantJSON.EntityAddress.AddressId = Integer.valueOf(staticDataMap.get('AddressID'));
        applicantJSON.EntityAddress.AddressLine1 = staticDataMap.get('AddressLine1');
        applicantJSON.EntityAddress.AddressLine2 = staticDataMap.get('AddressLine2');
        applicantJSON.EntityAddress.AddressLine3 = staticDataMap.get('AddressLine3');
        applicantJSON.EntityAddress.City = staticDataMap.get('City');
        applicantJSON.EntityAddress.CountryCode = staticDataMap.get('CountryCode');
        applicantJSON.EntityAddress.StateCode =  staticDataMap.get('StateCode');
        applicantJSON.EntityAddress.PostCode = staticDataMap.get('PostCode');
        applicantJSON.Telephone_1 = applicantRecord.Mobile_Number__c;
        applicantJSON.Telephone_2 = applicantRecord.Mobile_Number__c;
        applicantJSON.Fax = applicantRecord.Fax__c;
        applicantJSON.Mobile = applicantRecord.Mobile_Number__c;
        applicantJSON.Email = applicantRecord.Email_Address__c;
        applicantJSON.CurrencyCode = staticDataMap.get('CurrencyCode');
        applicantJSON.Status = Integer.ValueOf(staticDataMap.get('Status'));
        applicantJSON.DUNS = staticDataMap.get('DUNS');
        applicantJSON.IndustryRefNumber = staticDataMap.get('IndustryRefNumber');
        applicantJSON.URL = staticDataMap.get('URL');
        applicantJSON.FinancialLimit = Integer.ValueOf(staticDataMap.get('FinancialLimit'));
        applicantJSON.BlockForPayment = Integer.ValueOf(staticDataMap.get('BlockForPayment'));
        applicantJSON.RetentionPercent = Integer.ValueOf( staticDataMap.get('RetentionPercent'));
        applicantJSON.DiscountPercent = Integer.ValueOf(staticDataMap.get('DiscountPercent'));
        applicantJSON.VAT.MemberState = staticDataMap.get('MemberState');
        applicantJSON.VAT.VATType = staticDataMap.get('VATType');
        applicantJSON.VAT.VATCode = staticDataMap.get('VATCode');
        applicantJSON.VAT.VATRegistrationNo = staticDataMap.get('VATRegistrationNo');
        
        
        //Create JSON
        String customerJSON = JSON.serialize(applicantJSON);
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