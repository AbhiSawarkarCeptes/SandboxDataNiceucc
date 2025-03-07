/******************************************************
    Class : Nice_AccessTokenUtility
    Test Class : Nice_AccessTokenUtilityTest
    Purpose : NICE - Utility class to handle NICE API token for authentication
    Author : Artee Varma
*******************************************************/

public class Nice_AccessTokenUtility {
    
     Final static String SOURCE = 'Nice_AccessTokenUtility.generateNewToken';
    
    public static Map<String, Boolean> getToken() {
        List<NiceApiAccessSettings__c> settingsList = [Select Access_Token__c, Token_Expiry_Time__c from NiceApiAccessSettings__c];
        Map<String, Boolean> tokenMap = new Map<String, Boolean>();
        
        if(settingsList.isEmpty()) {
            String newToken = generateNewToken();
            tokenMap.put(newToken, true);
            return tokenMap;
        }
        NiceApiAccessSettings__c cSettings = settingsList.get(0);
        TimeZone tz = UserInfo.getTimeZone();
        DateTime dt = Datetime.now();
        Datetime ft = dt.addSeconds((tz.getOffset(dt)/1000));
        Long expiryTime = cSettings.Token_Expiry_Time__c.getTime();
        Long currentTime = ft.getTime();
        Long milliseconds = currentTime - expiryTime;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        
        if (String.isBlank(cSettings.Access_Token__c) && (cSettings.Token_Expiry_Time__c == null)) {
            String newToken = generateNewToken();
            tokenMap.put(newToken, true);
        }
        else if (minutes > 55) {
            String newToken = generateNewToken();
            tokenMap.put(newToken, true);
        }
        else {
            tokenMap.put(cSettings.Access_Token__c, false);
        }
        return tokenMap;
    }
    
    public static String generateNewToken() {
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Nice_API_Basic_Auth/auth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        // Prepare the authorization body in URL-encoded format
        String body = 'grant_type=password'
            + '&username=' + EncodingUtil.urlEncode('UYLJI4B7I2YPPKYZDJ7ILCEBWZ2C4S6V36FSFCZOBJZ2NUGCB3DA====', 'UTF-8')
            + '&password=' + EncodingUtil.urlEncode('BHEFKLSK66SWEFFKYTGBBNTOT7L5WF2XMVGS3XRZ2LWTTUON2TEA====', 'UTF-8');
        
        req.setBody(body);
        
        try {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                String response = res.getBody();
                //Nice_LoggerUtility.createLog(SOURCE, body, 'Access token generated successfully.', res.getStatusCode());
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
                System.debug('Response=> ' + res.getBody());
                System.debug('Response Code=> ' + res.getStatusCode());
                String newToken = (String) responseMap.get('access_token');
                return newToken;
                
            } else if(res.getStatusCode() == 400) {
               // Nice_LoggerUtility.createLog(SOURCE, body, 'Bad request:server was unable to process the request due to invalid information', res.getStatusCode());
                System.debug('Response=> ' + res.getBody());
                System.debug('Response Code=> ' + res.getStatusCode());
            }
        } catch (Exception e) {
            Nice_LoggerUtility.createLog(SOURCE, body, 'Something went wrong',500);
            System.debug('Exception=>' + e.getMessage());
        }
        return null;
    }
    
    public static void saveToken(String access_Token) {
        List<NiceApiAccessSettings__c> settingsList = [Select Id from NiceApiAccessSettings__c LIMIT 1];
        TimeZone tz = UserInfo.getTimeZone();
        DateTime dt = Datetime.now();
        Datetime ft = dt.addSeconds((tz.getOffset(dt)/1000));
        if(settingsList.isEmpty()) {
            insert new NiceApiAccessSettings__c(Access_Token__c = access_Token, Token_Expiry_Time__c = ft);
        }
        else{
            update new NiceApiAccessSettings__c(Access_Token__c = access_Token, Token_Expiry_Time__c = ft,
            Id = settingsList.get(0).Id);
        }
    }
}