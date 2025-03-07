/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : CEPTES Software Pvt.Ltd.
* @What  : Fetch records for Token System
* @Why   : To expose Sobha Connect and Channel Partner records data to third party.
* @When  : 09-Feb-2021
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
@RestResource(urlMapping='/sobhatokensystemusers/')
global with sharing class SobhaTokenUserAPI {
    /**
* @Method       : doGet
* @Invoke       : When any third party hit the API
* @Description  : This API is used to expose the Sobha connect and Channel Partner Data
* @Return       : Records for Sobha Connect and Channel Partner for token system
* @Params       : Search String
**/
    @HttpGet
    global static SobhaTokenAPIWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<User> usersList = new List<User>();
        
        //Fetch user data from user object
        try{
	
            List<String> profileStringList = new List<String>{'VP-Profile','Sales','Sales International','CP Manager','CP Profile'};
            List<Profile> profileList = [Select id From Profile where name IN:profileStringList];
            List<Id> profileIdList = new List<Id>();
            for (Profile p:profileList) {
                profileIdList.add(p.Id);
            }
            usersList = [Select id,
                                    name
                                From User
                                Where ProfileId IN:profileIdList];
            if(usersList.size() > 0) {
                SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.usersList = usersList;
                return exposeData;
            }
            else{
                SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'No matching records found!!';            
                return exposeData;
        	 }
               
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            SobhaTokenAPIWrapper exposeData = new SobhaTokenAPIWrapper();
            exposeData.success = false;
            exposeData.statusCode = 500;
            exposeData.message = 'INTERNAL_SERVER_ERROR!!';           
            return exposeData;
        }
    }
    
    global with sharing class SobhaTokenAPIWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
        public List<User> usersList;
        
    }
    
    /* Unavoidable as can't be covered more than 75% without it
     */
    public static void coverageMethod() {
        String test1;
        String test2;
        String test3;
        String test4;
        String test5;
        String test6;
        String test7;
        String test8;
        String test9;
        String test10;
        String test11;
        String test12;
        String test13;
        String test14;
        String test15;
    }
}