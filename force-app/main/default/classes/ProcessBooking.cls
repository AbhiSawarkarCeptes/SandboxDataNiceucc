public class ProcessBooking {

  public string BookingId {get;set;}
  public string outputmessage {get;set;}
  Public String ProjectId {get;set;}
  public id CustomerId {get;set;}
  public Id subProjectId {get;set;} // Added by Neha on 6/3/19
  Public String TowerName {get;set;}
  public list<Booking__c> lstbooking;
  public boolean status {get ; set ;}
  public Id towerId {get;set;}
  public list <id>  ListOthereUsersId  {get;set;}
  public list <User> OtherUsersBooking {get;set;}
  public Booking__c bookingProc;
  
    public ProcessBooking(){      
        list<Booking__c> lstBooking = new list<Booking__c>();
        BookingId = ApexPages.currentPage().getParameters().get('id');   
        ListOthereUsersId = New list <id> ();
        OtherUsersBooking  =  new List <User> ();
        if(BookingId != null){
            //////////////////Ankur : Commenting out this line and added the next one to fetch an extra field on 18.11.2015 19:36 hrs//////////////////////////////////
              lstBooking = [select id,name,Booking_Date__c, status__c,Unit__c, Unit__r.name, Unit__r.Unit_Status__c,UnitChange__c,Project__c,Project__r.name,/*Unit__r.Param2__c,*/Unit__r.tower__r.Id, 
                              Opportunity__c,Opportunity__r.name,Opportunity__r.Passport_No__c,Opportunity__r.POI_Card_No__c,Opportunity__r.PAN_Card_No__c, Quotation__c, Quotation__r.Quote_Status__c, Ownerid,  
                              Project__r.Sales_Site_Head__c,Project__r.Sales_MIS__c,Project__r.Project_CRM_Lead__c,Sales_Managers__c, Unit__r.Reason_For_CRM_returns_to_sales__c,Opportunity__r.Account.Salutation,
                              Unit__r.Tower__r.Cluster__c, Stage_of_Booking__c, Verification_status__c, Booking_Approver_Audit__c, Call_Disposition__c
                              from Booking__c where id = :BookingId];                    
        }

        if(lstBooking != null && lstBooking.size() > 0){
            bookingProc = lstBooking[0];
            ProjectId = lstBooking[0].Project__c;
            towerId = lstBooking[0].Unit__r.tower__r.Id;         
            CustomerId = lstBooking[0].Opportunity__c;
            subProjectId = lstBooking[0].Unit__r.Tower__r.Cluster__c; // Added by Neha on 6/3/19
        } 
    }
    
    Public PageReference Process(){
       //////////////////Ankur : Commenting out this code as on 18.11.2015 19:36 hrs//////////////////////////////////
    if(bookingProc != null && bookingProc.Quotation__r.Quote_Status__c != 'Valid') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Booking cannot be processed as the Quotation used for this booking is not in "Valid" status')); // Commented by Neha on 6/3/19
        return null;
    }        
    if (bookingProc.Stage_of_Booking__c != null && bookingProc.Stage_of_Booking__c == 'Booked' && bookingProc.Unit__r.Unit_Status__c != null && bookingProc.Unit__r.Unit_Status__c == 'Booked'){
     if(bookingProc.Verification_status__c != null && bookingProc.Verification_status__c != 'Accepted'){
      if(bookingProc.Booking_Approver_Audit__c != null && bookingProc.Booking_Approver_Audit__c != 'Approved'){
        if(bookingProc.Call_Disposition__c != null && bookingProc.Call_Disposition__c != 'Accept'){
        
        //// CRM Team to be defined on Sub Project level  
            list<Team_Members__c> lstTeamMembers = [select id, User__c, User_Active__c, Counter__c, Team__c, Last_Assignment__c from Team_Members__c where Team__r.Team_Type__c= 'CRM Team' AND User_Active__c = true AND Team__r.Sub_Project__c = :subProjectId AND IsActive__c = true AND Team__r.Project__c =: ProjectId];  //Team__r.Towerlookup__c =: towerId// 
            list<Team_Members__c> lstTeamMembersToUpdate = new List<Team_Members__c >();
            system.debug('-------lstTeamMembers------'+lstTeamMembers); 
            if(lstTeamMembers != null && lstTeamMembers.size() >= 1){
                datetime lsttime = system.now();
                Id ownerId = bookingProc.ownerId;      
                for(Team_Members__c objTM : lstTeamMembers){
                    if(lsttime!= null && objTM.Last_Assignment__c < lsttime){
                        lsttime = objTM.Last_Assignment__c;
                        ownerId = objTM.user__c;
                    }
                }    
                    
                for(Team_Members__c objTM : lstTeamMembers){
                    if(objTM.user__c == ownerId){
                            objTM.Last_Assignment__c = system.now();
                            if(objTM.Counter__c != null)
                            objTM.Counter__c = objTM.Counter__c+1;
                            objTM.Ownerid = ownerId;
                            objTM.Last_Assignment__c = system.now();
                            lstTeamMembersToUpdate.add(objTM);
                    }
                }
                
                  if(bookingProc.UnitChange__c != true) {
                     if(bookingProc.Unit__r.Reason_For_CRM_returns_to_sales__c == null) {
                          bookingProc.Sales_Managers__c = bookingProc.ownerId;
                     }
                     bookingProc.ownerId = ownerId;
                     List<Applicant_Details__c> listApplicants= [Select Id, Name from Applicant_Details__c where booking__c =: bookingProc.Id];
                     if (listApplicants.size() > 0) {
                        for(Applicant_Details__c a : listApplicants) {
                            a.ownerId = ownerId;
                        }
                        update listApplicants;
                     }
                     List<Opportunity> oList = [Select Id, Relationship_Manager__c from Opportunity where Id =: bookingProc.Opportunity__c];
                     if(oList != null && oList.size() > 0) {
                        for(Opportunity op : oList) {
                            op.Relationship_Manager__c = ownerId;
                        }
                        update oList;
                     }                                                      
                  }
                  else {
                  }
                  bookingProc.status__c = 'Booking In Process';
                  update bookingProc;
            }            
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'There is no member in selecting Team.'));
            }
            
            if(lstTeamMembersToUpdate != null && lstTeamMembersToUpdate.size() > 0)
                update lstTeamMembersToUpdate;
            
            if(bookingProc != null && bookingProc.Unit__c != null) {
                list<Unit__c> lstProjunit = [select id, Project__c, Reason_For_CRM_returns_to_sales__c, Unit_Status__c from Unit__c where Id =: bookingProc.Unit__c ];
                if(lstProjunit != null && lstProjunit.size() > 0) {
                    //////Ankur : Adding on 16.02.2016 
                    if(lstProjunit[0].Unit_Status__c =='CRM Returned To Sales') {
                        if(lstProjunit[0].Reason_For_CRM_returns_to_sales__c == 'Physical Document Rejected') {
                            lstProjunit[0].Unit_Status__c = 'BIP - Sales';
                            update lstProjunit;
                            
                            opportunity objCustomer = new opportunity();
                            objCustomer.id = CustomerId;
                            objCustomer.Physical_document_received__c = false;
                            update objCustomer ;
                        }                  
                    }
                    else{                      
                            opportunity objCustomer = new opportunity();
                            objCustomer.id = CustomerId;        
                            objCustomer.Physical_document_received__c = false;                        
                            update objCustomer ;
                    }
                }    
            }
 ///// Send mail to CRM           
            list<User>LstUsersRm = [select id, name, email, Salutation__c from user where id =:bookingProc.ownerId];
            if(LstUsersRm !=  null && LstUsersRm.size() > 0){
                String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();               
                string PageLink = '/apex/S_ProcessDocumentVerification';
                string subjectMail = bookingProc.opportunity__r.name +
                                     ', Flat - ' + bookingProc.Unit__r.name + ': Booking Form Processed';
                
                string strBookingHtmlBody = 'Dear ' + LstUsersRm[0].Name + ',<br/><br/>' +
                'Booking Documents for ' + bookingProc.Opportunity__r.Account.Salutation + ' ' + bookingProc.Opportunity__r.name +
                ', Flat - ' + bookingProc.Unit__r.name + ' in ' + bookingProc.Project__r.name + ' has  been processed on ' + bookingProc.Booking_Date__c.format() +
                ' <br/>please click the following link to accept and process the physical documents verification.<br/><br/>' +
                 baseUrl + PageLink  + ' <br></br><br/>' +
                 'Thanks and Regards<br/>'+
                 'Salesforce Team';
                
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                mail.setHtmlBody(strBookingHtmlBody);
                list<string> lststringtoaddress = new list<string>();
                lststringtoaddress.add('neha.pandey@stetig.in');
                lststringtoaddress.add(LstUsersRm[0].Email);
                mail.setToAddresses(lststringtoaddress);
                mail.setSubject(subjectMail);
                Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Booking Process Has Been Initiated. A mail has been sent to CRM Team for further processing.'));              
           }    
                /////To SM, Sales Site Head, Sales MIS, Project CRM Lead, RM ///               
                
                if(ListOthereUsersId.size() > 0){
                    OtherUsersBooking = [select id, name, email from user where id In : ListOthereUsersId];                    
                }
            if(bookingProc.Sales_Managers__c != null) {
          ///// Send mail to Sales Operations i.e. owner of booking     
                list<User> LstUsersBooking = [select id, name, email, Salutation__c from user where id = :bookingProc.OwnerId];
                
               if( LstUsersBooking.size() > 0) {
                    
                         String baseUrlNew = System.URL.getSalesforceBaseUrl().toExternalForm();
                         string subjectMail =  bookingProc.opportunity__r.name +
                                     ', Flat - ' + bookingProc.Unit__r.name + ': Booking Form Processed';
                         
                         string strBookingHtmlBodyNew =  'Dear ' +' ' +' '+ LstUsersBooking[0].Name + ',<br></br><br></br>'+
        
                        'Booking processed for ' +' '+ bookingProc.Opportunity__r.name  + ' , Flat - ' + bookingProc.Unit__r.name + '  in ' + bookingProc.project__r.name + '.' +
                        'Please submit physical booking form to CRM Team for further processing.';
        
                        Messaging.Singleemailmessage mailNew = new Messaging.Singleemailmessage();
                        mailNew.setHtmlBody(strBookingHtmlBodyNew);
                        list<string> lststringtoaddressNew = new list<string>();
                        lststringtoaddressNew.add(LstUsersBooking[0].Email);
                        lststringtoaddressNew.add('neha.pandey@stetig.in');
                        if(OtherUsersBooking.size() > 0){
                            for(integer  i = 0 ; i < OtherUsersBooking.size() ; i++) {
                                System.debug('lststringtoaddressNew' +lststringtoaddressNew );
                                 lststringtoaddressNew.add(OtherUsersBooking[i].Email);
                            }                            
                        }
                        if(LstUsersRm.size() > 0){ 
                            lststringtoaddressNew.add(LstUsersRm[0].Email);
                        }
                        System.debug('lststringtoaddressNew' +lststringtoaddressNew );
                        mailNew.setToAddresses(lststringtoaddressNew);
                        mailNew.setSubject(subjectMail);
                        Messaging.sendEmail(new Messaging.Singleemailmessage[] {mailNew});
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Booking  Has Been Processed . A mail has been sent to Sales Ope for further processing.'));                   
                }  
            } 
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Welcome call is done for this booking, So you cannot process this booking'));
        }
      } else {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'This booking is approved by Audit, So you cannot process this booking'));  
      }   
     } else {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Document verification is done for this booking, So you cannot process this booking'));
     }         
    } else {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Either booking or unit is not in "Booked" stage, So you cannot process this booking'));
      }        
        return null;
    }
        
    public PageReference incrementCounter() {       
        if(BookingId!= ''){
            pageReference P = new pageReference('/'+ BookingId);
            return P;
        }
        return null;
    }
}