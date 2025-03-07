@isTest
public class TestREST_createUser{

@isTest
 public static void testCreateUser(){ // To create User
 
   String p = 'System Administrator';
   Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
   
   User u = [SELECT Id, Name FROM User WHERE Username = 'Ankur.pd@stetig.in'];              
 
   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/CreateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
   
   Test.startTest();  
   REST_createUser.createUser('Test', 'test@gmail.com', 'test1234561022@stetig.in', 'tes', 'Test1208', 'System Administrator', '1234567893');
   Test.stopTest(); 
 }
 
 @isTest
 public static void testCreateUser1(){ // For duplicate username
 
        String p = 'System Administrator';
        Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
        
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
 
   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/CreateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
  
   Test.startTest();  
   REST_createUser.createUser( 'Test123', 'test123@gmail.com', 'test12345610223@stetig.in', 'tes1', 'Test1209', 'System Administrator', '1234567894');
   Test.stopTest(); 
 }
 
 @isTest
 public static void testCreateUser2(){ // For duplicate Nickname
 
        String p = 'System Administrator';
        Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
        
        User u = [SELECT Id, Name FROM User WHERE Username = 'Ankur.pd@stetig.in'];
 
        User u1 = new User();
        u1.LastName = 'Test123';
        u1.Email = 'test123@gmail.com';
        u1.Username = 'test12345@stetig.in';
        u1.Alias = 'tes1';
        u1.CommunityNickname = 'Test12098';                            
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
 
   RestRequest req = new RestRequest();
  
   req.requestURI = '/services/apexrest/CreateUser/'; 
   req.httpMethod = 'POST';
   
   RestContext.request = req;
  
   Test.startTest(); 
   REST_createUser.createUser( 'Test123', 'test123@gmail.com', 'test12345753@stetig.in', 'tes1', 'Test12098', 'System Administrator', '1234567894');
   Test.stopTest(); 
 }
}