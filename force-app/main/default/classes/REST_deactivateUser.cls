@RestResource(urlMapping='/DeactivateUser/*')
global with sharing class REST_deactivateUser{

@HttpPost
 global static REST_result deactivateUser(String Username, String Nickname){
  REST_result r = new REST_result();
  
  if(string.isBlank(Username) || string.isBlank(Nickname))
  {
     r.returnCode = 1;
     r.message = 'All fields are mandatory';
     createLog(Username, r.returnCode, r.message);
     return r; 
  }
  else
  {
  
     List <User> u = [SELECT Username, IsActive, CommunityNickname, Id FROM User WHERE Username = :Username AND CommunityNickname = :Nickname];
     
     if(u.size() == 0)
     {
       r.returnCode = 1;
       r.message = 'Username does not exists in the system';
       createLog(Username, r.returnCode, r.message);
       return r;   
     }
     else if(u.size() > 0 && u[0].IsActive == false)
     {
       r.returnCode = 1;
       r.message = 'Username is Already Inactive';
       createLog(Username, r.returnCode, r.message);
       return r;
     }
     else
     {
      try
      {          
          u[0].IsActive = false;
          update u[0];
                
          r.returnCode = 0;
          r.message = 'SUCCESS';
          createLog(Username, r.returnCode, r.message); 
          return r;    
      }    
      catch(Exception e)
      {
          r.returnCode = 1;
          r.message = 'Error while processing the request!!!!' + e;
          System.debug('Exception: ' + e);
          createLog(Username, r.returnCode, r.message);
          return r;   
      }
  }
 } 
}

// Mix dml error occurs when a non setup and setup object updated/inserted in same transaction then mix dml occurs. We can avoid this error using future method.

@future
public static void createLog(String username, Integer returnCode, String message){
 
 API_Log__c a = new API_Log__c();
 a.Username__c = username;
 a.Log_Details__c = 'returnCode: ' + returnCode + '; message: ' + message;
 insert a;
 }
 
 global class REST_result 
 {
        webservice Integer returnCode;
        webservice String message;        
 }   
}