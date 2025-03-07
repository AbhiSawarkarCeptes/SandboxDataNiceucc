@isTest
private  Class TestCloneopportunity {
 
 
 @isTest
    private static void CloneopportunityTest() {
        
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        
        
        objpr = createProject('Xa_prj','111');
        List<Cluster__c> cList = TestDataFactory.createClusters(2, objpr.Id);
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
         String p = 'System Administrator';
        Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
         Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        
        User u = [Select id, Name, Isactive from user where Isactive = True Limit 1];
        
        
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
        
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name = 'CP1';
        cp.Contact_Person__c = 'Test1';
        cp.Sales_Manager__c = u1.Id;
        cp.Sales_Manager_s_Line_Manager__c = u1.Id;
        cp.Channel_Relationship_Head__c = u1.Id; 
        cp.Channel_Relationship_Manager__c = u1.Id;
        insert cp;
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=uList[0].id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.Walk_in_Source__c = 'Channel Partner'; 
        objcustomer.Walk_In_CP__c = cp.Id; 
        objcustomer.Channel_Partner_Contact_Person__c = 'Test New'; 
        insert objcustomer;
        
        
        Cloneopportunity clsobj = New Cloneopportunity();
        Cloneopportunity.createOpp(objcustomer.id);
       
    }
       public static Project__c createProject(String ProjName, String ProjectCode)
       {
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
       }     
       
    
    public static User createUserSysAdmin(string fn, string ln, string username, string email) {
    
    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = p.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    insert u;
    return u;
    
  }    
    
    
 }