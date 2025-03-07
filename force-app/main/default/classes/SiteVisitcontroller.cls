public class SiteVisitcontroller {
    public Customer_Registration__c sv {get;set;}
    public boolean isSaved {get;set;}
    public string strLeadId {get;set;}
    public string strOptyId {get;set;}
    public string strAccountId {get;set;}
    public String strprojectId {get;set;}
    public string strProjectName{get;set;}
    public string strRecordTypeId{get;set;}
    public string checkCP{get;set;}
    Public Project__c projObj {get;set;}    
    public Lead objLead {get;set;}
    public Opportunity objOpty {get;set;}
    public Account objAcc {get;set;}
    public String strMobile {get;set;}
    public String stremail {get;set;}   
    public String strError {get;set;}
    public boolean isChannelPartner{get;set;}
       
    /*constructor*/
    public SiteVisitcontroller ()
    {
        isChannelPartner = false;
        sv = new Customer_Registration__c ();
        projObj = new Project__c();
        isSaved = false;
           If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();} 
        
        if (Apexpages.Currentpage().getParameters().get('Leadid') != null && Apexpages.Currentpage().getParameters().get('Leadid') != '')
            strLeadId = Apexpages.Currentpage().getParameters().get('Leadid');
        if (Apexpages.Currentpage().getParameters().get('optyid') != null && Apexpages.Currentpage().getParameters().get('optyid') != '')
            strOptyId = Apexpages.Currentpage().getParameters().get('optyid');
        if (Apexpages.Currentpage().getParameters().get('Accid') != null && Apexpages.Currentpage().getParameters().get('Accid') != '')
            strAccountId = Apexpages.Currentpage().getParameters().get('Accid');
        if (Apexpages.Currentpage().getParameters().get('projectId') != null && Apexpages.Currentpage().getParameters().get('projectId') != '')
            strprojectId = Apexpages.Currentpage().getParameters().get('projectId');
        if (Apexpages.Currentpage().getParameters().get('mobile') != null && Apexpages.Currentpage().getParameters().get('mobile') != '')
            strMobile = Apexpages.Currentpage().getParameters().get('mobile');        
        if (Apexpages.Currentpage().getParameters().get('email') != null && Apexpages.Currentpage().getParameters().get('email') != '')
            stremail = Apexpages.Currentpage().getParameters().get('email');
        
        strRecordTypeId=Apexpages.Currentpage().getParameters().get('RecordTypeId');
        System.debug('strprojectId:::'+strprojectId);
       
         if (strprojectId == null || strprojectId == '' || strprojectId == 'null') {
             strprojectId = System.label.Sobha_Hartland_Project_Id;
         }
        System.debug('Inside If strprojectId:::'+strprojectId);
        if(!Test.isRunningTest()) {
            projObj = [Select Id, name from Project__c where id = : strprojectId];
        }
        else {
            projObj = [Select Id, name from Project__c limit 1];
        }
            strProjectName=projObj.Name;
        if(strMobile != null && strMobile != '') {
            sv.Mobile_Number__c = strMobile;
            sv.Project__c = projObj.Id;
            sv.Email_Address__c = stremail;              
        } 
        else if (strLeadId != null && strLeadId != '') {
         
            objLead = [Select Id, firstname, lastname, Email, pin_code__c, MobilePhone, Project__r.Name, RDS_Email__c, Birthdate__c,
                       Phone, Company_Name__c, RDS_Budget__c, Possession_Timeframe__c, LeadSource,
                       Profession__c, Project_Type__c, Designation__c, Budget_In_Lacs__c, RDS_Unit_type_configuration__c,
                       RDS_Alternate_Email_Id__c, Alternate_Mobile_Number__c, middlename, Address_1_and_2_O__c, Address_1_and_2_R__c, 
                       Reason_For_Purchase__c, Possession_Requirement__c, Lead_Sub_Source__c, Nationality__c                     
                       from Lead where Id=:strLeadId];
                         
            sv.first_Name__c = objLead.firstname;
            sv.Middle_Name__c =  objLead.middlename;
            sv.last_name__c = objlead.lastname;
            sv.Address__c = objLead.Address_1_and_2_R__c;
            sv.LeadSource__c = objLead.LeadSource;
            sv.Mobile_Number__c = objLead.MobilePhone;
            sv.Alternate_Mobile_Number__c = objLead.Phone;
            sv.Email_Address__c = objLead.Email;
            sv.Alternate_Email_Id__c =objLead.RDS_Alternate_Email_Id__c;
            sv.Birth_Date__c=objLead.Birthdate__c;                                 
            sv.Project__c = projObj.Id;
            sv.Purpose_Of_Purchase__c = objLead.Reason_For_Purchase__c;
            sv.Occupation__c = objLead.Profession__c; 
            sv.Company_Business_Name__c=objLead.Company_Name__c;    
            sv.Designation__c=objLead.Designation__c;
            sv.Company_Business_Location__c = objLead.Address_1_and_2_O__c;                     
            sv.Configuration__c = objLead.RDS_Unit_type_configuration__c ;
            sv.Property_Type__c = objLead.Project_Type__c;
            sv.Budget_in_cr__c = objLead.Budget_In_Lacs__c;
            sv.Possessiom_Timeline__c = objLead.Possession_Requirement__c;
            sv.Nationality__c = objLead.Nationality__c;   
             If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();}           
                       
             ////// Added by Neha on 19/01/19 Starts Here    
     /*        sv.How_Did_You_Hear_About_Us__c = objLead.LeadSource; 
             sv.Sub_Source__c = objLead.Lead_Sub_Source__c; */
           ////// Added by Neha on 19/01/19 Ends Here                                      
        }
        
        else if(strAccountId != null && strAccountId != '') {
            objAcc = [Select Id, PersonMobilePhone, Alternate_Email__c, Phone, MiddleName,
                      Gender__c, Birth_Date__c, Alternate_Mobile_No__c, PersonEmail, firstname, lastname,
                      Designation_Permanent__c, Residential_Street__c, Office_Street__c,
                      Company_Name__c,Designation__c,Postal_Code__c,
                      profession__c, S_PReason_for_Purchase__c,Nationality__c
                      from Account where Id =:strAccountId];
                                              
            sv.first_Name__c = objAcc.firstname;
            sv.Middle_Name__c = objAcc.MiddleName;
            sv.last_name__c = objAcc.lastname;
            sv.Address__c  = objAcc.Residential_Street__c;
            sv.Mobile_Number__c = objAcc.PersonMobilePhone;
            sv.Alternate_Mobile_Number__c = objAcc.Phone;
            sv.Email_Address__c= objAcc.personEmail;
            sv.Alternate_Email_Id__c = objAcc.Alternate_Email__c;
            sv.Birth_Date__c= objAcc.Birth_Date__c; 
            sv.Project__c = projObj.Id;  
            sv.Purpose_Of_Purchase__c = objAcc.S_PReason_for_Purchase__c;  
            sv.Occupation__c = objAcc.profession__c; 
            sv.Company_Business_Name__c=objAcc.Company_Name__c;                             
            sv.Designation__c=objAcc.Designation__c;
            sv.Company_Business_Location__c = objAcc.Office_Street__c;         
            sv.Nationality__c = objAcc.Nationality__c;     
            If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();}  
     
        }
        if(strOptyId!=null)
        {
            objOpty=[select Name, Account.FirstName, Account.LastName, Account.MiddleName, Account_Mobile_Number__c,Walk_In_Referred_By__c,
                     Walk_in_Source__c, Walk_in_Sub_Source__c, Walk_In_CP__c, Referred_By__c, Account.Birth_Date__c,
                     Account.Alternate_Email__c, Email__c, Project__c,Configuration__c,
                     AccountId, Account.PersonEmail, Budget_In_Cr__c, Date_Of_Visit__c, Date_Of_Site_Visit__c,
                     Account.Residential_Street__c, Account.Designation__c, Account.Company_Name__c,
                     Account.profession__c, Account.Office_Street__c, Account.Phone, Reason_For_Purchase__c,
                     Budget_Site_Visit_In_Lacs__c, Purchase_Timeframe__c, Project_Type__c, S_Budget__c, LeadSource, Lead_Sub_Source__c 
                     from Opportunity where Id=:strOptyId];                    
            
            sv.first_Name__c = objOpty.Account.firstname;
            sv.Middle_Name__c = objOpty.Account.MiddleName;
            sv.last_name__c = objOpty.Account.Lastname;  
            sv.Address__c = objOpty.Account.Residential_Street__c; 
            sv.LeadSource__c = objOpty.LeadSource;        
            sv.Mobile_Number__c = objOpty.Account_Mobile_Number__c;
            sv.Alternate_Mobile_Number__c = objOpty.Account.Phone;
            sv.Email_Address__c=objOpty.Account.PersonEmail;
            sv.Alternate_Email_Id__c=objOpty.Account.Alternate_Email__c;            
            sv.Birth_Date__c = objOpty.Account.Birth_Date__c;
            sv.Project__c=objOpty.Project__c != null ? objOpty.Project__c : projObj.Id ;
            sv.Purpose_Of_Purchase__c = objOpty.Reason_For_Purchase__c;            
            sv.Opportunity__c=objOpty.Id;  
            sv.Occupation__c = objOpty.Account.profession__c; 
            sv.Company_Business_Name__c = objOpty.Account.Company_Name__c;          
            sv.Designation__c = objOpty.Account.Designation__c;           
            sv.Company_Business_Location__c = objOpty.Account.Office_Street__c; 
            sv.Property_Type__c = objOpty.Project_Type__c;         
            sv.Budget_in_cr__c = objOpty.S_Budget__c;
            sv.Configuration__c = objOpty.Configuration__c;                                   
            sv.Possessiom_Timeline__c = objopty.Purchase_Timeframe__c;
            
            If(String.isBlank(string.valueOf(sv.Date__c))){
            sv.Date__c = System.Today();}
            
           ////// Added by Neha on 19/01/19 Starts Here    
        /*     sv.How_Did_You_Hear_About_Us__c = objOpty.LeadSource; 
             sv.Sub_Source__c = objOpty.Lead_Sub_Source__c;*/
           ////// Added by Neha on 19/01/19 Ends Here   
        }
    }
    
    public PageReference save()
    {
        PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
        system.debug('inside save method');
         Savepoint sp = Database.setSavepoint();
         try
        {
              strError = '';
            if(sv.First_Name__c == null || sv.First_Name__c == '')
            {
                strError='Please Enter First Name';
                return null;
            }
             if(sv.How_Did_You_Hear_About_Us__c == null || sv.How_Did_You_Hear_About_Us__c == '')
            {
                strError='Please Let Us Know Walk-In Source';
                return null;
            }               
            if(sv.Last_Name__c == null || sv.Last_Name__c=='')
            {
                strError='Please Enter Last Name';
                return null;
            }                        
         if(sv.How_Did_You_Hear_About_Us__c != null || sv.How_Did_You_Hear_About_Us__c != '')
         {
             if(sv.How_Did_You_Hear_About_Us__c == 'Channel Partner')
             {
                 isChannelPartner=true;
             }
         }
         system.debug('sv.Alternate_Mobile_Number__c :'+sv.Alternate_Mobile_Number__c);
      ///// Added by Neha on 19/01/19 Starts Here   
         if(sv.Alternate_Mobile_Number__c != '' && sv.Alternate_Mobile_Number__c != null){
             String mobile = sv.Alternate_Mobile_Number__c;
             if(mobile.startsWith('971') || mobile.startsWith('0') || mobile.startsWith('+971')  )
             {
               strError = 'Mobile Number should not start with Country code';
               return null;   
              }
        }  
         if(sv.Residential_Status__c == null || sv.Residential_Status__c == '')
            {
                strError='Please Enter Residential Status';
                return null;
            } 
         if(sv.Nationality__c == null || sv.Nationality__c == '')
            {
                strError='Please Enter Nationality';
                return null;
            } 
       ///// Added by Neha on 19/01/19 Ends Here   
       system.debug('strMobile'+strMobile);  
            if(strMobile!='' && strMobile!=null)
            {               
                System.debug('Inside Mobile Check and New Lead');
                Lead newLead=new Lead();
                newLead.firstname=sv.First_Name__c;
                newLead.middlename=sv.Middle_Name__c;
                newLead.lastname=sv.Last_Name__c;
                newLead.Address_1_and_2_R__c = sv.Address__c;      
                newLead.MobilePhone = sv.Mobile_Number__c;
                newLead.Phone = sv.Alternate_Mobile_Number__c;
                newLead.Email = sv.Email_Address__c;
                newLead.RDS_Alternate_Email_Id__c = sv.Alternate_Email_Id__c;                                          
                newLead.Birthdate__c=sv.Birth_Date__c; 
                newLead.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;                              
   ////// Added by Neha Starts Here on 03/01/19 
                newLead.Profession__c  = sv.Occupation__c;  
                newLead.Company_Name__c= sv.Company_Business_Name__c;          
                newLead.Address_1_and_2_O__c = sv.Company_Business_Location__c;
                newLead.Designation__c= sv.Designation__c;
                newLead.Project_Type__c = sv.Property_Type__c;
                newLead.Budget_In_Lacs__c = sv.Budget_in_cr__c;
                newLead.RDS_Unit_type_configuration__c = sv.Configuration__c;
                newLead.Possession_Requirement__c = sv.Possessiom_Timeline__c;
                newlead.Site_Visit_Lead__c = True; 
                newlead.Nationality__c = sv.Nationality__c;   // on 19/1/19         
   ////// Added by Neha Ends Here on 03/01/19                                   
                insert newLead;
                
                System.debug('Insert Lead Successfull');                
                List < Lead > leadListToconvert = new List < Lead > ();
                List < Lead > ConvertedLeadlist = new List < Lead > ();
                Opportunity optyObjToupdate = new Opportunity();
                
                leadListToconvert.add(newLead);
                System.debug('Added For convert');
                System.debug(+leadListToconvert);
                  if (leadListToconvert != null)
                    convertCIFLeads(leadListToconvert);
                    
                System.debug('Convert Method Call');
                
               ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Project__c from Lead
                        where Id = : newLead.Id and Isconverted = true
                        order by LastModifiedDate Desc limit 1];
                
                optyObjToupdate = [Select Id,Name,Project__c,Walk_in_Source__c, Walk_in_Sub_Source__c, Date_Of_Site_Visit__c,
                                   Walk_In_Referred_By__c, Walk_In_CP__c, Sales_Manager__c, Unique_SVF_Number__c, Channel_Partner_Contact_Person__c,
                                   Walk_In_SC__c, Residential_Status__c, Walk_in_Employee_Id__c, Walk_in_Name_of_Person__c
                                   from Opportunity where Id =: ConvertedLeadlist[0].ConvertedOpportunityId];
                
                sv.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                optyObjToupdate.Project__c = sv.Project__c;                
                optyObjToupdate.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                optyObjToupdate.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                optyObjToupdate.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;                
                optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c; 
                
       ////// Added by Neha on 18/01/19 Starts Here                       
                optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                
      ///////// Added by Neha on 18/01/19 Ends Here                 
               if(sv.Channel_Partner__c != null)
               {
                 optyObjToupdate.Walk_In_CP__c = sv.Channel_Partner__c;
               } 
                if(sv.Sobha_Connect__c != null)
               {
                 optyObjToupdate.Walk_In_SC__c = sv.Sobha_Connect__c;
               }
                 optyObjToupdate.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;         
                update optyObjToupdate;
                
                system.debug('sv.Date__c::'+sv.Date__c);
                insert sv;
               
                Pagereference objReference = new Pagereference('/' + sv.Opportunity__c); //objLead.Id
                objReference.setRedirect(true);
                return objReference;
                
            }
              else if (strLeadId != null && strLeadId != '') {
                if(objLead.Project__c == projObj.Id)
                {                  
                   System.debug('Inside Same Project');                                          
                   objLead.firstname = sv.first_Name__c;                  
                   objLead.middlename = sv.Middle_Name__c;
                   objlead.lastname = sv.last_name__c;
                   objLead.Address_1_and_2_R__c= sv.Address__c;                                                                    
                   objLead.MobilePhone = sv.Mobile_Number__c;
                   objLead.Phone = sv.Alternate_Mobile_Number__c;
                   objLead.Email = sv.Email_Address__c;                   
                   objLead.RDS_Alternate_Email_Id__c=sv.Alternate_Email_Id__c;
                   objLead.Birthdate__c=sv.Birth_Date__c;
                   objLead.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
     ////// Added by Neha Starts Here on 03/01/19  
                   objLead.Profession__c=sv.Occupation__c;
                   objLead.Company_Name__c= sv.Company_Business_Name__c;                                   
                   objLead.Designation__c= sv.Designation__c;
                   objLead.Address_1_and_2_O__c = sv.Company_Business_Location__c;
                   objLead.Budget_In_Lacs__c = sv.Budget_in_cr__c;                                
                   objLead.RDS_Unit_type_configuration__c = sv.Configuration__c;
                   objLead.Project_Type__c = sv.Property_Type__c;
                   objLead.Possession_Requirement__c = sv.Possessiom_Timeline__c;
                   objLead.Nationality__c = sv.Nationality__c; // on 19/01/19
      ////// Added by Neha Ends Here on 03/01/19             
                   objLead.Site_Visit_Lead__c=True;
                    update objLead;
                    System.debug('Insert Lead Successfull');                
                List < Lead > leadListToconvert = new List < Lead > ();
                List < Lead > ConvertedLeadlist = new List < Lead > ();
                Opportunity optyObjToupdate = new Opportunity();
                
                leadListToconvert.add(objLead);
                System.debug('Added For convert');
                System.debug(+leadListToconvert);
                  if (leadListToconvert != null)
                    convertCIFLeads(leadListToconvert);
                    
                System.debug('Convert Method Call');
                
               ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Project__c from Lead
                        where Id = : objLead.Id and Isconverted = true
                        order by LastModifiedDate Desc limit 1];
                
                optyObjToupdate = [Select Id,Name,Project__c,Walk_in_Source__c,Walk_in_Sub_Source__c, Walk_In_Referred_By__c,
                                   Walk_In_CP__c, Sales_Manager__c, Unique_SVF_Number__c, Walk_In_SC__c, Residential_Status__c,
                                    Walk_in_Employee_Id__c, Walk_in_Name_of_Person__c, 
                                   Channel_Partner_Contact_Person__c from Opportunity
                                   where Id =: ConvertedLeadlist[0].ConvertedOpportunityId];
                sv.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                optyObjToupdate.Project__c=sv.Project__c;
                
                optyObjToupdate.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                optyObjToupdate.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                optyObjToupdate.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;
          ///// Added by Neha on 18/01/19 StartsHere      
                optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
        /////// Added by Neha on 18/01/19 Ends Here                        
                if(sv.Channel_Partner__c != null)
               {
                 optyObjToupdate.Walk_In_CP__c = sv.Channel_Partner__c;
               }
               if(sv.Sobha_Connect__c != null)
               {
                 optyObjToupdate.Walk_In_SC__c = sv.Sobha_Connect__c;
               }
                 optyObjToupdate.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;
                 optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
                update optyObjToupdate;
                
                insert sv;
                
                Pagereference objReference = new Pagereference('/' + sv.Opportunity__c); //objLead.Id
                objReference.setRedirect(true);
                return objReference;
                    
                }
                  else
                  {                                        
                    System.debug('Inside Different Project:::: ' +objLead.Project__c);
                    objLead.Firstname = sv.First_Name__c;                  
                    objLead.Middlename = sv.Middle_Name__c;
                    objlead.Lastname = sv.Last_name__c;  
                    objLead.Address_1_and_2_R__c=sv.Address__c; 
                    objLead.MobilePhone = sv.Mobile_Number__c;
                    objLead.Phone = sv.Alternate_Mobile_Number__c;
                    objLead.Email=sv.Email_Address__c;
                    objLead.RDS_Alternate_Email_Id__c=sv.Alternate_Email_Id__c;
                    objLead.Project__c = projObj.Id;              
                    objLead.Birthdate__c=sv.Birth_Date__c;
                    objLead.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
                    objLead.Project_Type__c = sv.Property_Type__c;
                    objLead.Budget_In_Lacs__c = sv.Budget_in_cr__c;
                    objLead.RDS_Unit_type_configuration__c = sv.Configuration__c;
                    objLead.Possession_Requirement__c = sv.Possessiom_Timeline__c;
                    objLead.Profession__c=sv.Occupation__c;
                    objLead.Designation__c = sv.Designation__c;
                    objLead.Company_Name__c = sv.Company_Business_Name__c;           
                    objLead.Address_1_and_2_O__c = sv.Company_Business_Location__c;
                    objLead.Site_Visit_Lead__c = True;
                    objLead.Nationality__c = sv.Nationality__c; // on 19/1/19
                    update objLead;  // Added By Neha on 4/1/19
                    System.debug('Updated lead with different project:::: ' + objLead.Project__c);
                        List < Lead > leadListToconvert = new List < Lead > ();
                        List < Lead > ConvertedLeadlist = new List < Lead > ();
                        Opportunity objOptyToInsert = new Opportunity();
                        leadListToconvert.add(objLead);
                       if (leadListToconvert != null) 
                            convertCIFLeads(leadListToconvert);
                      ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId,Project__c from Lead
                            where Id = : objLead.Id and Isconverted = true
                            order by LastModifiedDate Desc limit 1];
                      objOptyToInsert.Name =sv.First_Name__c;
                      objOptyToInsert.Project__c =sv.Project__c;
                      objOptyToInsert.stagename = 'Opportunity Identified';
                      objOptyToInsert.CloseDate=System.today().addDays(60);
                      
                      objOptyToInsert.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                      objOptyToInsert.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                      objOptyToInsert.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;
                      objOptyToInsert.Date_Of_Site_Visit__c = sv.Date__c;
                      objOptyToInsert.Project_Type__c = sv.Property_Type__c;
                      objOptyToInsert.Configuration__c = sv.Configuration__c;
                      objOptyToInsert.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
                      objOptyToInsert.S_Budget__c = sv.Budget_in_cr__c;
                      objOptyToInsert.Purchase_Timeframe__c = sv.Possessiom_Timeline__c;
                 ////// Added by Neha on 18/01/19 Starts Here
                      objOptyToInsert.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                      objOptyToInsert.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                      objOptyToInsert.Residential_Status__c = sv.Residential_Status__c;
                                     
                      if(sv.Channel_Partner__c != null)
                       {
                         objOptyToInsert.Walk_In_CP__c=sv.Channel_Partner__c;
                       }
                        if(sv.Sobha_Connect__c != null)
                       {
                         objOptyToInsert.Walk_In_SC__c = sv.Sobha_Connect__c;
                       }
                       objOptyToInsert.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;
                ////// Added by Neha on 18/01/19 Ends Here
                      objOptyToInsert.AccountId=ConvertedLeadlist[0].ConvertedAccountId;
                      
                      insert objOptyToInsert;
                                           
                      sv.Opportunity__c = objOptyToInsert.Id;                                                             
                      insert sv;                    
                  }
            }
            
            else if(strAccountId != null && strAccountId != '')
            {             
                System.debug('Inside Account');                
                objAcc.PersonMobilePhone=sv.Mobile_Number__c;
                objAcc.Phone = sv.Alternate_Mobile_Number__c;
                objAcc.PersonEmail=sv.Email_Address__c;
                objAcc.Alternate_Email__c=sv.Alternate_Email_Id__c;                          
                objAcc.Birth_Date__c = sv.Birth_Date__c;           
                objAcc.Residential_Street__c = sv.Address__c;
                objAcc.Designation__c= sv.Designation__c;
                objAcc.Company_Name__c= sv.Company_Business_Name__c;          
                objAcc.Profession__c=sv.Occupation__c;
                objAcc.Office_Street__c = sv.Company_Business_Location__c;
                objAcc.S_PReason_for_Purchase__c = sv.Purpose_Of_Purchase__c;
                objAcc.Nationality__c = sv.Nationality__c;
                
                try{
                    ApplicantTriggerHandler.applicationTriggerProcess = true;
                    update objAcc;
                }
                catch(Exception e){
                    ApplicantTriggerHandler.insertErrorLog(
                        e.getMessage(),
                        e.getStackTraceString(),
                        'Account',
                        'SiteVisitcontroller',
                        'save'
                    );
                }
                
                System.debug('In Account Check Opty insert');
                
                Opportunity objOptyToInsert = new Opportunity(); 
                objOptyToInsert.Name = sv.First_Name__c +' '+  sv.Middle_Name__c +' '+ sv.last_name__c;
                objOptyToInsert.Project__c = projObj.Id;
                objOptyToInsert.CloseDate=System.today().addDays(60);                
                objOptyToInsert.stagename = 'Opportunity Identified';
                objOptyToInsert.AccountId =objAcc.Id;                
                objOptyToInsert.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                objOptyToInsert.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                objOptyToInsert.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;              
         
         ////// Added by Neha Starts Here on 03/01/19                               
                objOptyToInsert.Configuration__c = sv.Configuration__c;
                objOptyToInsert.S_Budget__c = sv.Budget_in_cr__c;
                objOptyToInsert.Purchase_Timeframe__c = sv.Possessiom_Timeline__c;
                objOptyToInsert.Project_Type__c = sv.Property_Type__c;
                objOptyToInsert.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
                objOptyToInsert.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                objOptyToInsert.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                objOptyToInsert.Residential_Status__c = sv.Residential_Status__c; 
                objOptyToInsert.Date_Of_Site_Visit__c = sv.Date__c;                               
                if(sv.Channel_Partner__c != null)
               {
                 objOptyToInsert.Walk_In_CP__c = sv.Channel_Partner__c;
               } 
                if(sv.Sobha_Connect__c != null)
               {
                 objOptyToInsert.Walk_In_SC__c = sv.Sobha_Connect__c;
               }
                objOptyToInsert.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;   
           ////// Added by Neha Ends Here on 03/01/19           
                objOptyToInsert.Date_Of_Site_Visit__c = sv.Date__c;
                insert objOptyToInsert;
                sv.Opportunity__c = objOptyToInsert.Id;
                insert sv;
                
            }
            else if(strOptyId!=null)
            {
                
                sv.Opportunity__c = strOptyId;
                Opportunity optyObjToupdate = new Opportunity();
                optyObjToupdate=[Select Id,Walk_in_Source__c, Walk_in_Sub_Source__c,Walk_In_Referred_By__c, Walk_In_CP__c, Sales_Manager__c,
                                 Name, Project__c, Date_Of_Site_Visit__c, Budget_In_Cr__c, Configuration__c, Purchase_Timeframe__c,
                                  Project_Type__c, S_Budget__c, Reason_For_Purchase__c,AccountId, Channel_Partner_Contact_Person__c, Walk_In_SC__c,
                                  Residential_Status__c, Walk_in_Name_of_Person__c, Walk_in_Employee_Id__c                               
                                  from Opportunity where Id=:strOptyId];                                                
                
                If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();}
                
                optyObjToupdate.Name = sv.First_Name__c;
                optyObjToupdate.Project__c = sv.Project__c;
                optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
                optyObjToupdate.Budget_In_Cr__c = sv.Budget_in_cr__c;
                optyObjToupdate.Walk_in_Source__c = sv.How_Did_You_Hear_About_Us__c;
                optyObjToupdate.Walk_in_Sub_Source__c = sv.Sub_Source__c;
                optyObjToupdate.Walk_In_Referred_By__c = sv.Please_specify_Source_Name__c;               
                
                 ////// Added by Neha Starts Here on 03/01/19                               
                optyObjToupdate.Configuration__c = sv.Configuration__c;
                optyObjToupdate.Purchase_Timeframe__c = sv.Possessiom_Timeline__c;
                optyObjToupdate.Project_Type__c = sv.Property_Type__c;
                optyObjToupdate.S_Budget__c = sv.Budget_in_cr__c;
                optyObjToupdate.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
                optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                
                ///// Updating the Account record
                Account acForUpdate = new account();
                acForUpdate.id = optyObjToupdate.AccountId;                 
                acForUpdate.Phone = sv.Alternate_Mobile_Number__c;
                acForUpdate.PersonMobilePhone = sv.Mobile_Number__c;
                acForUpdate.PersonEmail = sv.Email_Address__c;
                acForUpdate.Alternate_Email__c = sv.Alternate_Email_Id__c;
                acForUpdate.Birth_Date__c = sv.Birth_Date__c;
                acForUpdate.S_PReason_for_Purchase__c = sv.Purpose_Of_Purchase__c;
                acForUpdate.Profession__c = sv.Occupation__c;
                acForUpdate.Company_Name__c = sv.Company_Business_Name__c;
                acForUpdate.Designation__c = sv.Designation__c;
                acForUpdate.Residential_Street__c = sv.Address__c;
                acForUpdate.Office_Street__c = sv.Company_Business_Location__c;
                acForUpdate.Nationality__c = sv.Nationality__c;
                
                ApplicantTriggerHandler.applicationTriggerProcess = true;
                try{
                    update acForUpdate;
                }
                catch(Exception e){
                    ApplicantTriggerHandler.insertErrorLog(
                        e.getMessage(),
                        e.getStackTraceString(),
                        'Account',
                        'SiteVisitcontroller',
                        'save update acForUpdate'
                    );
                }
               ////// Added by Neha Ends Here on 03/01/19    
               
               system.debug('sv.Alternate_Mobile_Number__c :'+sv.Alternate_Mobile_Number__c);
                if(sv.Channel_Partner__c != null)
               {
                 optyObjToupdate.Walk_In_CP__c=sv.Channel_Partner__c;
               }
                if(sv.Sobha_Connect__c != null)
               {
                 optyObjToupdate.Walk_In_SC__c = sv.Sobha_Connect__c;
               }
                 optyObjToupdate.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c; 
                 system.debug('optyObjToupdate.Date_Of_Site_Visit__c'+optyObjToupdate.Date_Of_Site_Visit__c);
                 system.debug('sv.Date__c'+sv.Date__c);             
                update optyObjToupdate;                
                insert sv;                                
            }
        
            Pagereference objReference = new Pagereference('/' + sv.Opportunity__c); //objLead.Id
            objReference.setRedirect(true);
            return objReference;                       
        }
        catch(exception ex){
            Database.rollback(sp);
            string strTempError = '';
            System.debug('Exception occured::'+ex);
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }

            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();

            return null;       
        }       
    }
    
    public static void convertCIFLeads(List < Lead > ll) {
        for (lead myLead: ll) {
            // try {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(myLead.id);
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
            /*} catch (Exception ex) {
                System.debug('Exception occured::'+ex.getMessage());
            }*/
        }
    }
    
    public void dummymethod()
    {
        
    }
}