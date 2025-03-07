@isTest
 public class SiteVisitcontrollerTest
 {
     @isTest
         private static void WalkInSearchPageTest() { 
             project__c p = createProject();                        
             
              Account a = createPAAccount();
              Opportunity o = createOpp(a.Id,p.Id);
             test.startTest();
                 pageReference pageRef = page.search;
                 Test.setCurrentPage(pageRef);
                 SVsearch walkInSearch = new SVsearch ();
                 walkInSearch.strProjectId = p.Id;
                 walkInSearch.NewLead.MobilePhone= '1212121213';
                 walkInSearch.NewLead.lastName = 'testlead';
                 walkInSearch.NewLead.Email = 'testlead@test.in';
                 walkInSearch.NewLead.MobilePhone='1212121213'; 
                 walkInSearch.OpportunityId = o.Id;
                 walkInSearch.saveMethod();
                 walkInSearch.searchAllLead();
                 
                 SVsearch walkInSearch1 = new SVsearch ();
                 
                 walkInSearch1.strProjectId = p.Id; 
                 walkInSearch1.NewLead.MobilePhone= '1212121212';
                 walkInSearch1.saveMethod();
                 walkInSearch1.searchAllLead();
               
                 SVsearch walkInSearch11= new SVsearch ();
                 //Lead l = createleadTemplate1();               
             Lead leadObj=new Lead();
             leadObj.LastName='Test Lead';
             leadObj.MobilePhone='9860708789';
             leadObj.Email='test@stetig.in';
           //  leadObj.RDS_Alternate_Email_Address__c='test1@stetig.in';
             leadObj.Project__c =p.Id;
           
            // leadObj.Budget_In_lacs__c=100; 
             insert leadObj;
             
                 walkInSearch11.strProjectId = p.Id;
                 
                 walkInSearch11.NewLead = leadObj;
                 walkInSearch11.saveMethod();
                 walkInSearch11.searchAllLead();
                 walkInSearch11.goBack();
                 
             test.stopTest();
         }
         @isTest
         private static void walkInMainformserachpageTest() {
             project__c p = createProject();
             insert p;
             //Lead l = createleadTemplate1();
             Lead leadObj=new Lead();
             leadObj.LastName='Test Lead';
             leadObj.MobilePhone='9860708788';
             leadObj.Email ='test@test.stetig';
             leadObj.Project__c =p.Id;
             leadObj.Postalcode='411007';
             leadObj.Address_1_and_2_O__c ='test'; //  Neha
             leadObj.Profession__c ='test';
             leadObj.Company_Name__c ='test';
             leadObj.Designation__c ='Army';
             leadObj.Project_Type__c ='test';
             insert leadObj;
             
              SiteVisitcontroller walkInForm10 = new SiteVisitcontroller();
              walkInForm10.strLeadId=leadObj.Id;
                   
             Account a = createPAAccount();
             
             Opportunity o = createOpp(a.Id,p.Id);
             //walkInForm10.strOptyId=o.Id;
             //walkInForm10.strAccountId=a.Id;
             test.startTest();
                 pageReference pageRef = page.CRForm;
                 Test.setCurrentPage(pageRef);
                 ApexPages.currentPage().getParameters().put('Leadid',leadObj.id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
                
                 SiteVisitcontroller walkInForm = new SiteVisitcontroller();
                 pageReference pageRef1 = page.CRForm;
                 Test.setCurrentPage(pageRef1);
                 
                 ApexPages.currentPage().getParameters().put('optyid',o.Id);                 
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
                 SiteVisitcontroller walkInForm1 = new SiteVisitcontroller();
                 
                 pageReference pageRef11 = page.CRForm;
                 Test.setCurrentPage(pageRef11);
                 ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
                 SiteVisitcontroller walkInForm11 = new SiteVisitcontroller();                 
                
                  pageReference pageRef22 = page.CRForm;
                 Test.setCurrentPage(pageRef22);
                 
                 ApexPages.currentPage().getParameters().put('mobile','1111122222');
                  SiteVisitcontroller walkInForm22 = new SiteVisitcontroller();
              
                 pageReference pageRef33 = page.CRForm;
                 Test.setCurrentPage(pageRef33);
                 
                  ApexPages.currentPage().getParameters().put('mobile','2222233333');                 
                  SiteVisitcontroller walkInForm33 = new SiteVisitcontroller();
                  walkInForm33.sv.Mobile_Number__c = '1367890';                  
                 walkInForm33.sv.Email_Address__c = 'test33@testing.in';
                  walkInForm33.sv.LeadSource__c = 'Others';
                   walkInForm33.sv.Date__c = system.today();
                   walkInForm33.sv.How_Did_You_Hear_About_Us__c =  'Digital'; // Added by Neha on 19/1/19
                   walkInForm33.sv.Alternate_Mobile_Number__c = '4589632145'; // Added by Neha on 19/1/19
                   walkInForm33.sv.Nationality__c= 'Indian';
                   walkInForm33.sv.Residential_Status__c= 'UAE Resident';
                   walkInForm33.sv.First_Name__c = 'testing' ;
                   walkInForm33.sv.Last_Name__c = 'lastname' ;
                  walkInForm33.sv.Address__c='test';
                   walkInForm33.sv.Purpose_Of_Purchase__c='End Use';
                  //walkInForm33.sv.Profession__c = 'CA';
                  walkInForm33.sv.Occupation__c='CA';
                   walkInForm33.sv.Sub_Source__c='Facebook LeadGen'; // Added by Neha on 19/01/19
                   walkInForm33.sv.Visit_Next_Action__c='Email';
                   walkInForm33.sv.Site_Visit_Rating__c='hot';
              walkInForm33.save();
                  
                 pageReference pageRef44 = page.CRForm;
                 Test.setCurrentPage(pageRef44);
                 
                  ApexPages.currentPage().getParameters().put('Leadid',LeadObj.Id);                 
                  SiteVisitcontroller walkInForm44 = new SiteVisitcontroller();
                  walkInForm44.sv.Mobile_Number__c = '1467890';
                  walkInForm44.sv.Alternate_Mobile_Number__c = '3334512';
                  walkInForm44.sv.Nationality__c= 'Indian';
                  walkInForm44.sv.Residential_Status__c= 'UAE Resident';
                  walkInForm44.sv.Email_Address__c = 'tes44t@testing.in';
                  walkInForm44.sv.LeadSource__c = 'Others';
                  walkInForm44.sv.Date__c = system.today();
                  walkInForm44.sv.Address__c='test';
                  walkInForm44.sv.How_Did_You_Hear_About_Us__c =  'Digital'; // Added by Neha on 19/1/19
                  walkInForm44.sv.Last_Name__c = 'lastname' ; 
                  walkInForm44.sv.First_Name__c = 'testing' ;
                  walkInForm44.sv.Occupation__c='CA';
                  walkInForm44.sv.Sub_Source__c='Facebook LeadGen';
                  walkInForm44.sv.Visit_Next_Action__c='Email';
                   walkInForm44.sv.Site_Visit_Rating__c='hot';
                  walkInForm44.sv.Project__c = p.Id;
                  walkInForm44.save();                                                 
                  
                  pageReference pageRef55 = page.CRForm;
                 Test.setCurrentPage(pageRef55);
                 
                  ApexPages.currentPage().getParameters().put('Optyid',o.Id);                 
                  SiteVisitcontroller walkInForm55 = new SiteVisitcontroller();
                  //walkInForm55.sv.first_name__c = 'Shahbaz';
                  //walkInForm55.sv.Salutation__c = 'Mr.';
                 // walkInForm55.sv.last_name__c = 'Khan';
         //         walkInForm55.sv.First_Registrant__c='Mr. Aditya Marne';
        //          walkInForm55.sv.Second_Registrant__c='Mr. Aditya Marne';
        //          walkInForm55.sv.Third_Registrant__c='Mr. Aditya Marne';
        //          walkInForm55.sv.Fourth_Registrant__c='Mr. Aditya Marne';
                  walkInForm55.sv.Mobile_Number__c = '1467890';
                  walkInForm55.sv.Nationality__c= 'Indian';
                  walkInForm55.sv.Residential_Status__c= 'UAE Resident';
                  walkInForm55.sv.Alternate_Mobile_Number__c = '4555512';
                  walkInForm55.sv.Email_Address__c = 'test55@testing.in';
                  //walkInForm55.sv.Street_Office__c = 'test';
                  //walkInForm55.sv.Walk_In_Source__c = 'Others';
                  walkInForm55.sv.LeadSource__c = 'Others';
                  //walkInForm55.sv.Walkin_Source_If_Others__c = 'test';
                  //walkInForm55.sv.Walkin_Source_If_Others__c = 'test';
                  //walkInForm55.sv.Street_Res__c = 'test';
                  //walkInForm55.sv.Country_Res__c = 'test';
                  //walkInForm55.sv.City_Res__c = 'test';
                  walkInForm55.sv.Date__c = system.today();
                  walkInForm55.sv.Address__c='test';
                     walkInForm55.sv.How_Did_You_Hear_About_Us__c =  'Digital';
                      walkInForm55.sv.First_Name__c = 'testing' ;      
                        walkInForm55.sv.Last_Name__c = 'lastname' ;
            //      walkInForm55.sv.City__c = 'Pune';
          //        walkInForm55.sv.Country__c = 'India';
         //         walkInForm55.sv.State__c='Maharashtra';
    //              //walkInForm55.sv.Country_Office__c = 'test';
                  //walkInForm55.sv.City_Office__c = 'test';
                  //walkInForm55.sv.Purpose_of_Purchase__c = 'End Use';
                  walkInForm55.sv.Purpose_Of_Purchase__c='End Use';
                  //walkInForm55.sv.Profession__c = 'CA';
                  walkInForm55.sv.Occupation__c='CA';
               
                    walkInForm55.sv.Sub_Source__c='Facebook LeadGen';
                //    walkInForm55.sv.Channel_Partner__c='test';
                   
                    walkInForm55.sv.Visit_Next_Action__c='Email';
             //       walkInForm55.sv.SM_Feedback_Given__c=true;
                   // walkInForm55.sv.SM_Next_Action_Date__c=16/5/2018 3:33 PM;
                    walkInForm55.sv.Site_Visit_Rating__c='hot';
                  //  walkInForm55.sv.Sales_Manager_Name_Signature__c='test';
      //              walkInForm55.sv.RecordTypeId=Schema.SObjectType.Site_Visit__c.getRecordTypeInfosByName().get('Site Visit Form').getRecordTypeId();
                  //walkInForm55.sv.Requirement__c = '1 BHK';
                  //walkInForm55.sv.Apartment_Type__c = '1 BHK';
                 // walkInForm55.sv.Possession_Timelines__c = '0-3';
                  //walkInForm55.sv.Sales__c = 'Test SM';
       //           walkInForm55.strRecordTypeId = Schema.SObjectType.Site_Visit__c.getRecordTypeInfosByName().get('Site Visit Form').getRecordTypeId();
                  
                  walkInForm55.save();
                  
                  pageReference pageRef66 = page.CRForm;
                 Test.setCurrentPage(pageRef66);
                 
                  ApexPages.currentPage().getParameters().put('Accid',a.Id);          
                  List<User> Users   = [Select id, Name, IsActive from User where isActive = True];     
                  
                  Channel_Partner__c cp = New Channel_Partner__c();
                  cp.Contact_Person__c ='test person';
                  cp.Sales_Manager__c = Users[0].id;
                  cp.Channel_Relationship_Manager__c= Users[0].id;
                  cp.Sales_Manager_s_Line_Manager__c= Users[0].id;
                  cp.Channel_Relationship_Head__c= Users[0].id;
                  
                  insert cp;
                  
                  SiteVisitcontroller walkInForm66 = new SiteVisitcontroller();
                 
                  walkInForm66.sv.Mobile_Number__c = '1567890';
                  walkInForm66.sv.Alternate_Mobile_Number__c = '4534512';
                  walkInForm66.sv.Nationality__c= 'Indian';
                  walkInForm66.sv.Residential_Status__c= 'UAE Resident';
                  walkInForm66.sv.Email_Address__c = 'test66@testing.in';
                  //walkInForm66.sv.Street_Office__c = 'test';
                  //walkInForm66.sv.Walk_In_Source__c = 'Others';
                  walkInForm66.sv.LeadSource__c = 'Others';
                  //walkInForm66.sv.Walkin_Source_If_Others__c = 'test';
                  //walkInForm66.sv.Walkin_Source_If_Others__c = 'test';
                  //walkInForm66.sv.Street_Res__c = 'test';
                  //walkInForm66.sv.Country_Res__c = 'test';
                  //walkInForm66.sv.City_Res__c = 'test';
                  walkInForm66.sv.Date__c = system.today();
                  walkInForm66.sv.Address__c='test';
                  walkInForm66.sv.How_Did_You_Hear_About_Us__c =  'Channel Partner';
                  walkInForm66.sv.First_Name__c = 'testing' ;
                  walkInForm66.sv.Last_Name__c = 'lastname' ;
                  walkInForm66.sv.Occupation__c='CA';
                   walkInForm66.sv.Sub_Source__c='Facebook LeadGen';
                   walkInForm66.sv.Channel_Partner__c=cp.id;
                  
                    walkInForm66.sv.Visit_Next_Action__c='Email';
                 
                   // walkInForm66.sv.SM_Next_Action_Date__c=16/5/2018 3:33 PM;
                    walkInForm66.sv.Site_Visit_Rating__c='hot';                  
                  
                  //walkInForm66.sv.Requirement__c = '1 BHK';
                  //walkInForm66.sv.Apartment_Type__c = '1 BHK';
                 // walkInForm66.sv.Possession_Timelines__c = '0-3';
                  //walkInForm66.sv.Sales__c = 'Test SM';
                  walkInForm66.save();  
              test.stopTest();  
             
         }
         @istest
         public static void anotherLead () {
             //project__c p1 = createProject1();
              project__c p = createProject();
             insert p;
             //Lead l = createleadTemplate1();
             Lead leadObj1 =new Lead();
             leadObj1.LastName='Test Lead';
             leadObj1.MobilePhone='9860708728';
             leadObj1.Email ='test@test2.stetig';
             leadObj1.Project__c =p.Id;
             //leadObj1.Budget_In_lacs__c=100; 
            
               leadObj1.Postalcode='411007';
               //leadObj1.Sur__c ='Western Suburb';
               //leadObj1.Zone_s__c ='test';
               leadObj1.Office_Address_Street__c ='test';
               leadObj1.Office_Address_Country__c ='test';
               leadObj1.Office_Address_State__c ='test';
               leadObj1.Office_Address_City__c ='test';
               //leadObj1.Suburb_O__c ='test';
               //leadObj1.Zones__c ='test';
               //leadObj1.Purpose__c='test';
               leadObj1.Profession__c ='test';
               leadObj1.Company_Name__c ='test';
               leadObj1.Designation__c ='Army';
               leadObj1.Project_Type__c ='test';
               //leadObj1.Requirment__c ='test';
               //leadObj1.Budget_In_Crores__c = 10;
               //leadObj1.Budget_In_lacs__c = 11;
              
             insert leadObj1;
             
             pageReference pageRef444 = page.CRForm;
                 Test.setCurrentPage(pageRef444);
                 
                  ApexPages.currentPage().getParameters().put('Leadid',LeadObj1.Id); 
                  ApexPages.currentPage().getParameters().put('projectId',p.Id);                 
                  SiteVisitcontroller walkInForm444 = new SiteVisitcontroller();
                  walkInForm444.sv.Mobile_Number__c = '1267890';
                  walkInForm444.sv.Alternate_Mobile_Number__c = '2267890';
                  walkInForm444.sv.Nationality__c= 'Indian';
                  walkInForm444.sv.Residential_Status__c= 'UAE Resident';
                  walkInForm444.sv.Email_Address__c = 'test444@testing.in';
                  walkInForm444.sv.LeadSource__c = 'Others';
                  walkInForm444.sv.Date__c = system.today();
                  walkInForm444.sv.Address__c='test';
                  walkInForm444.sv.How_Did_You_Hear_About_Us__c =  'Digital'  ;
                  walkInForm444.sv.Last_Name__c = 'lastname' ;
                  walkInForm444.sv.First_Name__c = 'testing' ;
                  walkInForm444.sv.Occupation__c='CA';
                  walkInForm444.sv.Visit_Next_Action__c='Email';
                  walkInForm444.sv.Site_Visit_Rating__c='hot';
              
                  walkInForm444.save();
         }
  
         private static Project__c createProject() {
                Project__c objProject = new Project__c();
                objProject.name = 'test 1';
                objProject.Project_Code__c='test';
               return objProject;
         } 
          private static Project__c createProject1() {
                Project__c objProject = new Project__c();
                objProject.name = 'test';
                objProject.Project_Code__c='test';
             

              //  objProject.RW_Status__c = 'Active';
                insert objProject ;
            return objProject;
         } 
         private static Lead createleadTemplate1 () {
                Project__c p = createProject();                
                Lead objLead = new Lead();
                objLead.LastName = 'test';
                objLead.Status = 'Not Sure';
                objLead.Email = 'test@gmail.com';
                objLead.Rating = 'Hot';
               
                objLead.MobilePhone= '1212121212';
                objLead.LeadSource = 'Digital';
                //objLead.Corporate_Company__c  = 'Other';
                objLead.Lead_Sub_Source__c= 'Facebook';
                //objLead.Walk_in_Source_c__c= 'Digital';
                objLead.LeadSource= 'Digital';
                
                objLead.Lead_Sub_Source__c= 'Facebook';
                //objLead.Remarks__c= 'test remark';
                objLead.Project__c= p.id; 
                objLead.RDS_Country__c= 'India';
                //objLead.State__c = 'Odisha';
            
                insert objLead;
             return objLead;
         }
         private static Account createPAAccount () {
                List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                Account objAcc = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '1212121212', 
                                    RecordType = personAccountRecordType[0],
                                    Occupation__c = 'test',Ethnicity__c = 'test',billingstreet='Test Street',billingcity='Test City',billingstate='Test State',
                                    billingcountry='Test Country',billingpostalcode='411007');
                insert objAcc;
             return objAcc;
         }
         private static Opportunity createOpp (Id accId, Id projId) {
            
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Qualification';//'Unit Booked';
                objopp.Project__c = projId;
                objopp.S_Budget__c = '100';
                objopp.Walk_in_Source__c= 'Digital';
                objopp.Walk_in_Sub_Source__c= 'Facebook';
                insert objOpp;
                Opportunity objOppToreturn = [Select id,Project__c,AccountId ,StageName 
                                                      from Opportunity where id =:objOpp.id];
             return objOppToreturn ;
         }
         
          private static Opportunity createOpp1 (Id accId, Id projId) {
            
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Qualification';//'Unit Booked';
                objopp.Project__c = projId;
                objopp.S_Budget__c = '100';
                objopp.Walk_in_Source__c= 'Digital';
                objopp.Walk_in_Sub_Source__c= 'Facebook';
                insert objOpp;
                Opportunity objOppToreturn = [Select id,Project__c,AccountId ,StageName 
                                                      from Opportunity where id =:objOpp.id];
             return objOppToreturn ;
         }
         
     @isTest
         private static void WalkInSearchPageTest2() { 
             project__c p = createProject();
             //Lead l = createleadTemplate1();
             Account a = createPAAccount();
           //  Opportunity o = createOpp1(a.Id,p.Id);
             test.startTest();
                 pageReference pageRef = page.search;
                 Test.setCurrentPage(pageRef);
                 SVsearch walkInSearch = new SVsearch ();
                 walkInSearch.strProjectId = p.Id;
                 walkInSearch.NewLead.MobilePhone= '';
                 walkInSearch.NewLead.lastName = 'testlead';
                 walkInSearch.NewLead.Email = 'testlead@test.in';
           //      walkInSearch.OpportunityId = o.Id;
                 walkInSearch.saveMethod();
                 walkInSearch.searchAllLead();
                 
                 SVsearch walkInSearch1 = new SVsearch ();
                 
                 walkInSearch1.strProjectId = p.Id; 
                 walkInSearch1.NewLead.MobilePhone= '1212121212';
                 walkInSearch1.saveMethod();
                 walkInSearch1.searchAllLead();
               
                 SVsearch walkInSearch11= new SVsearch ();
                 //Lead l = createleadTemplate1();
                 Lead leadObj=new Lead();
                 leadObj.LastName='Test Lead';
                 leadObj.MobilePhone='9860708780';
                 leadObj.Project__c =p.Id;
                 //leadObj.Budget_In_lacs__c=100; 
                 insert leadObj;
             
                 walkInSearch11.strProjectId = p.Id;
                 //cifSearch1.NewLead.MobilePhone= '1212121212';
                 walkInSearch11.NewLead = leadObj;
                 walkInSearch11.saveMethod();
                 walkInSearch11.searchAllLead();
                 walkInSearch11.goBack();
                 //cifSearch11.createEventOnDuplicateOpty();
             test.stopTest();
         } 
 }