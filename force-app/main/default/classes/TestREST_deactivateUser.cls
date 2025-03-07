@isTest
public class TestREST_deactivateUser{

@isTest
public static void deactivateUser(){ // To inactivate User

   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/DeactivateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
   
    String p = 'System Administrator';
    Profile pro = [SELECT Name, Id FROM Profile WHERE Name = :p];  
    
    User u = [SELECT Id, Name FROM User WHERE Username = 'Ankur.pd@stetig.in'];
 
        User u1 = new User();
        u1.LastName = 'Test123';
        u1.Email = 'test123@gmail.com';
        u1.Username = 'test12345610223@stetig.in';
        u1.Alias = 'tes1';
        u1.CommunityNickname = 'Test1209';                            
        u1.MobilePhone = '1234567894';
        u1.ProfileId = pro.Id;
        u1.Phone = '1234567894';              
        u1.IsActive = true; 
        u1.TimeZoneSidKey = 'Asia/Kolkata';   
        u1.LocaleSidKey = 'en_IN';      
        u1.LanguageLocaleKey = 'en_US'; 
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ManagerId = u.Id;
        
        insert u1;          
   
   Test.startTest();
   REST_deactivateUser.deactivateUser('test12345610223@stetig.in', 'Test1209');
   Test.stopTest(); 
}

@isTest
public static void deactivateUser1(){ // For Username does not exist

   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/DeactivateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
   
   String p = 'System Administrator';
   Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
   
   User u = [SELECT Id, Name FROM User WHERE Username = 'Ankur.pd@stetig.in'];

        User u1 = new User();
        u1.LastName = 'Test123';
        u1.Email = 'test123@gmail.com';
        u1.Username = 'test12345610@stetig.in';
        u1.Alias = 'tes1';
        u1.CommunityNickname = 'Test1209';                            
        u1.MobilePhone = '1234567894';
        u1.ProfileId = pro.Id;
        u1.Phone = '1234567894';              
        u1.IsActive = true; 
        u1.TimeZoneSidKey = 'Asia/Kolkata';   
        u1.LocaleSidKey = 'en_IN';      
        u1.LanguageLocaleKey = 'en_US'; 
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ManagerId = u.Id;
        
        insert u1;          
   
   Test.startTest();
   REST_deactivateUser.deactivateUser('test12345610223@stetig.in', 'Test1209');
   Test.stopTest(); 
}

@isTest
public static void deactivateUser2(){ // For Inactive user

   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/DeactivateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
   
   String p = 'System Administrator';
   Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
   
   User u = [SELECT Id, Name FROM User WHERE Username = 'Ankur.pd@stetig.in'];

        User u1 = new User();
        u1.LastName = 'Test123';
        u1.Email = 'test123@gmail.com';
        u1.Username = 'test12345610@stetig.in';
        u1.Alias = 'tes1';
        u1.CommunityNickname = 'Test1209';                            
        u1.MobilePhone = '1234567894';
        u1.ProfileId = pro.Id;
        u1.Phone = '1234567894';              
        u1.IsActive = false; 
        u1.TimeZoneSidKey = 'Asia/Kolkata';   
        u1.LocaleSidKey = 'en_IN';      
        u1.LanguageLocaleKey = 'en_US'; 
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ManagerId = U.Id;
        
        insert u1;          
   
   Test.startTest();
   REST_deactivateUser.deactivateUser('test12345610@stetig.in', 'Test1209');
   Test.stopTest(); 
}
}