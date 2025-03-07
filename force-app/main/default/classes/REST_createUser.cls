@RestResource(urlMapping='/CreateUser/*')
global with sharing class REST_createUser{

 @HttpPost
 global static REST_result createUser(String Lastname, String Email, String Username, String Alias, String Nickname, String Profile, String Mobile){
 
  REST_result r = new REST_Result();
  
  if(string.isBlank(Lastname) || string.isBlank(Email) || string.isBlank(Username) || string.isBlank(Alias) || string.isBlank(Nickname) || string.isBlank(Profile) || string.isBlank(Mobile))
  {
         
     r.returnCode = 1;
     r.message = 'All fields are mandatory';
     createLog(Username, r.returnCode, r.message);
     return r;     
  }
  else
  {
   List <User> u = [SELECT Username FROM User WHERE Username = :Username]; // To check duplicate Username
   List <User> u2 = [SELECT CommunityNickname FROM User WHERE CommunityNickname = :Nickname]; // To check duplicate Nickname

   if(u != null && u.size() > 0)
   {
     r.returnCode = 1;
     r.message = 'Username already exists in the system';
     createLog(Username, r.returnCode, r.message);
     return r;   
   }
   else if(u2 != null && u2.size() > 0)
   {
     r.returnCode = 1;
     r.message = 'Nickname already exists in the system';
     createLog(Username, r.returnCode, r.message);
     return r;
   }
   else
   {
    try
    {
     Profile p = [SELECT Name, Id FROM PROFILE WHERE Name = :Profile];    
     System.debug('p::::' + p);
        User u1 = new User();
        u1.LastName = Lastname;
        u1.Email = Email;
        u1.Username = Username;
        u1.Alias = Alias;
        u1.CommunityNickname = Nickname;
        
        if(p != null)
        u1.ProfileId = p.Id; 
              
        u1.MobilePhone = Mobile;
        u1.Phone = Mobile;              
        u1.IsActive = true; 
        u1.TimeZoneSidKey = 'Asia/Kolkata';   
        u1.LocaleSidKey = 'en_IN';      
        u1.LanguageLocaleKey = 'en_US'; 
        u1.EmailEncodingKey = 'ISO-8859-1';
                  
        insert u1;   
        System.resetPassword(u1.id,true); // To send link to reset Password        
        
     r.returnCode = 0;
     r.message = 'SUCCESS';
     createLog(Username, r.returnCode, r.message);
     return r;        
    }
    catch(Exception e)
    {
        r.returnCode = 1;
        r.message = 'Error while processing the request!!!!';
        createLog(Username, r.returnCode, r.message);
        return r;    
    }        
   }
  }
 }
 
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