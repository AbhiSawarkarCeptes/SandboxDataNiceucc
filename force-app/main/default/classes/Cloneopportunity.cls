Public class Cloneopportunity{
@AuraEnabled

 
       public static String createOpp(string recordId){
       Opportunity opp = New Opportunity();
      
       system.debug('recordId :: '+recordId);
       List<Opportunity> Opplist =[Select id, Name, StageName, Unit__c, Booking__c, Unique_SVF_Number__c,
                                   AccountId, Account_Mobile_Number__c, Account_Email__c, Lead_Id__c,
                                   CloseDate, Description__c, Manual_Upload__c, Sales_Manager_lookup__c,
                                   LeadSource, Lead_Sub_Source__c, Channel_Partner__c, Sobha_Connect__c,
                                   Name_of_Person__c, Employee_Id__c, PS_Next_Action_Date__c, 
                                   Project_Type__c, Project__c, Configuration__c, Reason_For_Purchase__c,
                                   S_Budget__c, Purchase_Timeframe__c, First_Call_Attempt_Date__c,
                                   First_Call_Attempted_by__c, First_Call_Description__c, Last_Call_Attempt_Date__c,
                                   Last_call_attempted_by__c, Last_call_description__c, First_Call_Attempt_Status__c,
                                   First_Next_Action_Date__c, First_Call_Proposed_DateOfVisit__c, Last_call_attempt_status__c,
                                   Next_Action_Date__c, call_proposed_date_of_visit__c, Sales_First_Call_Attempt_Date__c,
                                   Sales_First_Call_Attempted_By__c, Sales_First_Call_Description__c, Sales_Call_Attempt_Date__c,
                                   Sales_Call_Attempted_By__c, Sales_Call_Description__c, First_Sales_Next_Call_Attempt__c,
                                   First_Sales_Next_Action_Date__c,First_Sal_Next_Call_Proposed_DateOfVisit__c,
                                   Sales_Call_Attempt_Status__c, Sales_Next_Action_Date__c, Sales_Call_Proposed_Date_Of_Visit__c,
                                   Date_Of_Site_Visit__c, First_Site_Visit_Rating__c, Site_Visit_Count__c, Residential_Status__c,
                                   Walk_in_Source__c, Walk_in_Sub_Source__c, Walk_In_CP__c, Channel_Partner_Contact_Person__c,
                                   Walk_In_SC__c, Walk_In_Referred_By__c, Walk_in_Name_of_Person__c, Walk_in_Employee_Id__c,
                                   Is_Revisit_Done__c, Revisit_Unique_SVF_Number__c, Revisit_Date_Time__c, Descriptive_Remarks_Feedback__c,
                                   Site_Visit_Rating__c, Visit_Next_Action__c, SM_Next_Action_Date__c, Web_Source__c, Goal__c,
                                   Channel_Cluster__c, Keyword__c, Ad_position__c, Network__c, UTM_Source__c, UTM_Campaign__c,
                                   Last_Mile_Conversion__c, OS__c,Resolution__c,Website_Language__c,Landing_Page_URL__c,
                                   Adgroup__c,Lead_Source_WAYBEO__c,Digital_Source__c,Banner_Size__c,Placement__c,Match_Type__c,
                                   Bid_Type__c,UTM_Medium__c,UTM_Content__c,Device__c,Browser__c,GCLID__c,IP_Address__c,
                                   Time_Spent_before_Form_Submit__c, Presales_Agent__c,Promoter_Name__c, OwnerId                                  
                                  from Opportunity where id= :recordId];
       
       opp = Opplist[0].clone(false);
             
       Opp.StageName = 'Qualification';
       Opp.Unit__c= NULL; 
       Opp.Booking__c=NULL;
       Opp.Unique_SVF_Number__c= '';
       if(Opplist[0].Sales_Manager_lookup__c != Null){
       Opp.OwnerId = Opplist[0].Sales_Manager_lookup__c;
       }else{
       Opp.OwnerId = Opplist[0].OwnerId;
       }
      
       system.debug('Opp :: '+Opp);
        try{
        insert Opp;
       }catch(Exception e){
        system.debug('Exception '+e);
       }
       return Opp.id;
       }    
           
}