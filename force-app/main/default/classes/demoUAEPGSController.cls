public with sharing class demoUAEPGSController {
    public demoUAEPGSController() {

    }

    @AuraEnabled
    public static String sendPaymentRequest() {
        try {
            // Define the endpoint URL
            String endpoint = 'https://pgt.cbuaepay.ae/PGCustomerPortalBkp/transactionmanagement/merchantform';
            
            // Prepare request parameters
            Map<String, String> params = new Map<String, String>{
                'pp_Version' => '1.1',
                'pp_TxnType' => 'DD',
                'pp_MerchantID' => 'TestMerc0003',
                'pp_Language' => 'EN',
                'pp_SubMerchantID' => '',
                'pp_Password' => '0123456789',
                'pp_BankID' => 'TBNK',
                'pp_ProductID' => 'RETL',
                'pp_TxnRefNo' => 'T20150222091951',
                'pp_Amount' => '10000',
                'pp_TxnCurrency' => 'AED',
                'pp_TxnDateTime' => '20150222091951',
                'pp_TxnExpiryDateTime' => '-1',
                'pp_BillReference' => 'billRef',
                'pp_Description' => 'Descriptionof transaction',
                'pp_ReturnURL' => 'https://pgt.cbuaepay.ae/MerchantSimulator/HttpRequestDemoServer/Index',
                'ppmpf_1' => '1',
                'ppmpf_2' => '2',
                'ppmpf_3' => '3',
                'ppmpf_4' => '4',
                'ppmpf_5' => '5',
                'ppmbf_1' => '1',
                'ppmbf_2' => '2',
                'ppmbf_3' => '3',
                'ppmbf_4' => '4',
                'ppmbf_5' => '5'
            };

            // Generate Secure Hash
            String secureHash = generateSecureHash(params);
            System.debug('##$$ secureHash : '+secureHash);
            params.put('pp_SecureHash', secureHash);
            
            // Convert params to URL encoded string
            String requestBody = '';
            for (String key : params.keySet()) {
                requestBody += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8') + '&';
            }
            requestBody = requestBody.substring(0, requestBody.length() - 1); // Remove last '&'

            System.debug('##$$ requestBody : '+requestBody);
            // Create HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(requestBody);

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Return response
            return response.getBody();
            
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    // Method to generate Secure Hash
    private static String generateSecureHash(Map<String, String> params) {
        // Order parameters as specified
        String hashData = '0123456789' + 
                          params.get('pp_Amount') + 
                          params.get('pp_BankID') + 
                          params.get('pp_BillReference') + 
                          params.get('pp_Description') + 
                          params.get('pp_Language') + 
                          params.get('pp_MerchantID') + 
                          params.get('pp_Password') + 
                          params.get('pp_ProductID') + 
                          params.get('pp_ReturnURL') + 
                          params.get('pp_SubMerchantID') + 
                          params.get('pp_TxnCurrency') + 
                          params.get('pp_TxnDateTime') + 
                          params.get('pp_TxnExpiryDateTime') + 
                          params.get('pp_TxnRefNo') + 
                          params.get('pp_TxnType') + 
                          params.get('pp_Version') + 
                          params.get('ppmbf_1') + 
                          params.get('ppmbf_2') + 
                          params.get('ppmbf_3') + 
                          params.get('ppmbf_4') + 
                          params.get('ppmbf_5') + 
                          params.get('ppmpf_1') + 
                          params.get('ppmpf_2') + 
                          params.get('ppmpf_3') + 
                          params.get('ppmpf_4') + 
                          params.get('ppmpf_5');

        Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(hashData));
        return EncodingUtil.convertToHex(hashBlob).toUpperCase();
    }
}