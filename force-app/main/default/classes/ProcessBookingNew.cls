public class ProcessBookingNew {
    public string BookingId{get;set;}
    Public String ProjectId{get;set;}
    public id CustomerId {get;set;}
    public Id subProjectId {get;set;} 
    //  public Id salesOperationsId {get;set;}
    public String TowerName{get;set;}
    public list<Booking__c> lstbooking;
    public boolean status {get; set;}
    public Id towerId {get;set;}
    //  public list <id> ListOthereUsersId  {get;set;}
    //  public list <User> OtherUsersBooking {get;set;}
    public Booking__c bookingProc;
    
    public ProcessBookingNew(){  
        status = false;
        list<Booking__c> lstBooking = new list<Booking__c>();
        BookingId = ApexPages.currentPage().getParameters().get('id');   
        //    ListOthereUsersId = new list <id> ();
        //   OtherUsersBooking = new List <User> ();
        if(BookingId != null){
            lstBooking = [select id,name,Booking_Date__c, Paid_Percentage__c, status__c, Unit__c, Unit__r.name, Unit__r.Unit_Status__c,Project__c,Project__r.name, Unit__r.tower__r.Id, 
                          Opportunity__c,Opportunity__r.name, Ownerid, Sales_Managers__c, Unit__r.Tower__r.Cluster__c, Stage_of_Booking__c, Verification_status__c, Booking_Approver_Audit__c
                          FROM Booking__c WHERE id = :BookingId];                  
        }
        
        if(lstBooking != null && lstBooking.size() > 0){
            bookingProc = lstBooking[0];
            ProjectId = lstBooking[0].Project__c;
            towerId = lstBooking[0].Unit__r.tower__r.Id;         
            CustomerId = lstBooking[0].Opportunity__c;
            subProjectId = lstBooking[0].Unit__r.Tower__r.Cluster__c;
            //  salesOperationsId = UserInfo.getUserId(); 
        } 
    }
    
    Public PageReference Process(){
       if(bookingProc.Status__c == 'UnProcessed'){ 
            //if(bookingProc.Paid_Percentage__c >= 2){ 
               // if(bookingProc.Stage_of_Booking__c != null && bookingProc.Stage_of_Booking__c != 'EOI'){ //&& bookingProc.Unit__r.Unit_Status__c != null && bookingProc.Unit__r.Unit_Status__c != 'EOI'){
                    if(bookingProc.Booking_Approver_Audit__c != null && bookingProc.Booking_Approver_Audit__c != 'Accepted'){ 
                        if(bookingProc.Verification_status__c != null && bookingProc.Verification_status__c != 'Accepted'){
                            
                            //// CRM Team to be defined on Sub Project level  
                            /*   list<Team_Members__c> lstTeamMembers = [select id, User__c, User_Active__c, Counter__c, Team__c, Last_Assignment__c from Team_Members__c 
where Team__r.Team_Type__c= 'CRM Team' AND User_Active__c = true AND Team__r.Sub_Project__c = :subProjectId 
AND IsActive__c = true AND Team__r.Project__c =: ProjectId]; 
list<Team_Members__c> lstTeamMembersToUpdate = new List<Team_Members__c >();

system.debug('-------lstTeamMembers------'+lstTeamMembers); 
///// Assigning booking to CRM on Round Robin basis     
if(lstTeamMembers != null && lstTeamMembers.size() >= 1){
datetime lsttime = system.now();
bookingProc.Sales_Operations__c = salesOperationsId;
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
lstTeamMembersToUpdate.add(objTM);
}
}
///// Updating owner of Applicant Detail, Relationship Manager on Opportunity                       
bookingProc.ownerId = ownerId;
List<Applicant_Details__c> listApplicants= [Select Id, Name from Applicant_Details__c where booking__c =: bookingProc.Id];
if (listApplicants.size() > 0) {
for(Applicant_Details__c a : listApplicants) {
a.ownerId = ownerId;
}
update listApplicants;
}
List<Opportunity> oList = [Select Id, Relationship_Manager__c, Physical_document_received__c from Opportunity where Id =: bookingProc.Opportunity__c];
if(oList != null && oList.size() > 0) {
for(Opportunity op : oList) {
op.Relationship_Manager__c = ownerId;
op.Physical_document_received__c = false;
}
update oList;
}                                   
} else {
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'There is no member in selecting Team.'));
}

if(lstTeamMembersToUpdate != null && lstTeamMembersToUpdate.size() > 0)
update lstTeamMembersToUpdate;    */        
                            
                            ///// Send notification to CRM
                            /*  if(bookingProc.ownerId != null){           
list<User>LstUsersRm = [select id, name, email from user where id =:bookingProc.ownerId];      

if(LstUsersRm !=  null && LstUsersRm.size() > 0){
String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();                
String PageLink = '/apex/S_ProcessDocumentVerification';

String subjectMail = bookingProc.opportunity__r.name +
', Flat - ' + bookingProc.Unit__r.name + ': Booking Form Processed';

String strBookingHtmlBody = 'Dear ' +  LstUsersRm[0].Name + ',<br/><br/>' +
'Booking documents for ' + bookingProc.Opportunity__r.name +
', Flat - ' + bookingProc.Unit__r.name + ' in ' + bookingProc.Project__r.name + ' has been processed on ' + bookingProc.Booking_Date__c.format()+'.' +
' <br/>Please click the following link to accept and process the physical documents verification.<br/><br/>' +
baseUrl + PageLink  + ' <br></br><br/>' +
'Thanks and Regards,<br/>'+
'Salesforce Team';

Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
mail.setHtmlBody(strBookingHtmlBody);
list<string> lststringtoaddress = new list<string>();
//  lststringtoaddress.add('neha.pandey@stetig.in');
//lststringtoaddress.add('priya.patre@stetig.in');
lststringtoaddress.add(LstUsersRm[0].Email);
mail.setToAddresses(lststringtoaddress);
mail.setSubject(subjectMail);
Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Booking process has been initiated. A mail has been sent to CRM Team for further processing.'));               
System.debug('Email Sent to CRM::: ' + lststringtoaddress);
}                
}  */    
                            
                            ///// Send notification to Sales Operations i.e.owner of booking                 
                            if(bookingProc.ownerId != null) {             
                                list<User> LstUsersBooking = [select id, name, email from user where id = :bookingProc.ownerId];
                                
                                if(LstUsersBooking.size() > 0) {                   
                                    System.debug('inside LstUsersBooking ');
                                    String baseUrlNew = System.URL.getSalesforceBaseUrl().toExternalForm();
                                    string subjectMail = bookingProc.Name + ': Booking Form Processed';
                                    
                                    string strBookingHtmlBodyNew =  'Kind Attention !!<br></br><br></br>'+
                                        
                                        'Booking processed to Audit team for ' +' '+ bookingProc.Opportunity__r.name  + ', Flat - ' + bookingProc.Unit__r.name + ' in ' + bookingProc.project__r.name + '.<br/><br/>' +
                                        /*    ' Please submit physical booking form to CRM Team for further processing. <br/><br/>'+ */
                                        'Thanks,<br/>'+
                                        'Salesforce Team';
                                    
                                    Messaging.Singleemailmessage mailNew = new Messaging.Singleemailmessage();
                                    mailNew.setHtmlBody(strBookingHtmlBodyNew);
                                    list<string> lststringtoaddressNew = new list<string>();
                                    lststringtoaddressNew.add(LstUsersBooking[0].Email);
                                    //lststringtoaddressNew.add('neha.pandey@stetig.in');   
                                    //lststringtoaddressNew.add('priya.patre@stetig.in');                                             
                                    mailNew.setToAddresses(lststringtoaddressNew);
                                    mailNew.setSubject(subjectMail);
                                    Messaging.sendEmail(new Messaging.Singleemailmessage[] {mailNew});
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Booking has been processed. A mail has been sent to Sales Operations for further processing.'));                   
                                    System.debug('Email sent to Sales Operations::: ' + lststringtoaddressNew);
                                    status = true;
                                }  
                                ////// Updating booking   
                                if(bookingProc != null) {
                                    List<Opportunity> oList = [Select Relationship_Manager__c, Physical_document_received__c from Opportunity where Id = :bookingProc.Opportunity__c];
                                    try{  
                                        bookingProc.Booking_Approver_Audit__c = 'Not Started';
                                        bookingProc.Select_All_Audit__c = false;
                                        bookingProc.Audit_Approval_Date__c = null;
                                        //bookingProc.Comment_Audit__c = null;
                                        bookingProc.Verification_status__c = 'Not Started';
                                        bookingProc.Document_Checklist_Header__c = null;
                                        bookingProc.status__c = 'Booking In Process';  
                                        bookingProc.Current_Status__c = 'Submitted to Audit';                                                           
                                        update bookingProc;
                                        
                                        if(oList != null && oList.size() > 0) {
                                            for(Opportunity op : oList) {
                                                op.Relationship_Manager__c = bookingProc.ownerId;
                                                op.Physical_document_received__c = false;
                                            }
                                            update oList; 
                                        }
                                    } catch(Exception e){
                                        System.debug('Error occurred while updating booking status:: ' + e);
                                    }
                                }
                            }       
                        } else {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Document verification is done for this booking, So you cannot process this booking'));
                            status = true;
                        } 
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'This booking is approved by Audit, So you cannot process this booking'));  
                        status = true;
                    }                  
                } 
            
            /*else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'This booking or unit is in "EOI" stage, So you cannot process this booking'));
                    status = true;
                } 
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Purchase price paid percentage is less than 2%, So you cannot process this booking'));
                status = true;
            } */

        else {
            if(bookingProc.Status__c == 'Processed'){ 
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'This booking is already Submitted For Approval'));
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'This booking is '+bookingProc.Status__c));
            }
            
            status = true;
        }             
        return null;
    }
    
    public PageReference incrementCounter() {       
        if(BookingId != ''){
            pageReference P = new pageReference('/lightning/r/Booking__c/'+ BookingId+'/view');
            return P;
        }
        return null;
    }
}