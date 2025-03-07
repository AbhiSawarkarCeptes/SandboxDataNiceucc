public class X_MockData {

    public static Xpedeon_API_Metadata__mdt metadataAPI;
    public static List<Xpedeon_Metadata_Headers__mdt> metadataHeaders;
    public static List<Xpedeon_Static_Data__mdt> staticMetadata;
    
     // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create response
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('response body');
            return res;
        }
    }
    
    
   /* public static void setupMockData() {
        metadataAPI = new Xpedeon_API_Metadata__mdt(); 
        // Create mock metadata API
        metadataAPI.End_Point__c = 'https://xpedeonsf.sobhaapps.com:2096/XpedeonIntegrationAPI/api/ExternalEntities	'; // Set endpoint
        
        metadataHeaders = new List<Xpedeon_Metadata_Headers__mdt>(); // Mock metadata headers
        metadataHeaders.add(new Xpedeon_Metadata_Headers__mdt(Header_Name__c='Mock Header', Header_value__c='Mock Value'));
        
        staticMetadata = new List<Xpedeon_Static_Data__mdt>(); // Mock static metadata
        staticMetadata.add(new Xpedeon_Static_Data__mdt(Field_Label__c='Mock Label', Field_Value__c='Mock Value'));
    }
    */

}