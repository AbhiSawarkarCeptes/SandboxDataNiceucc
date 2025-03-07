public class S_ProcessDocumentVerification {
    public list <booking__c> lstBooking {get; set;}
    public string ProcessRowNo {get; set;}
    public string ReleaseRowNo {get; set;}
    public string AssignRowNo {get; set;}
    public string ProfileName {get; set;}
    public string UserName {get; set;}
    
    public S_ProcessDocumentVerification() {
        Id profileId = userinfo.getProfileId();
        ProfileName = [Select Id, Name from Profile where Id = :profileId].Name;
        UserName = userinfo.getname();
        GetListOfBooking();       
    }
    
        public Pagereference Process() {
        return (new PageReference('/apex/DocumentChecklistPageDubai?Id=' + lstBooking[integer.valueof(ProcessRowNo)].id));
        
    } 
    
    
    public Pagereference Assign() {
        Opportunity objOpp = new Opportunity();
        objOpp.id = lstBooking[integer.valueof(AssignRowNo)].Opportunity__c;
        objOpp.Physical_document_received__c = true;
        update objOpp;
        GetListOfBooking();
        return null;
    }
    
    public void GetListOfBooking() {
        lstBooking = New list < booking__c > ([select id, Owner.Name, Verification_status__c, View_Rejected_Documents__c, Opportunity__c, Opportunity__r.Name,
                                               Opportunity__r.Physical_document_received__c, Name, Last_Call_Date__c, Welcome_Call_Done_By__c, Call_Disposition__c, Status__c,
                                               Call_Back_Date__c, Call_Centre_Rep__c, Unit__c, Unit__r.Name, Project__r.name, Unit__r.Unit_Status__c, Booking_Date__c, Stage_of_Booking__c,
                                               Paid_Percentage__c,Total_On_Account_Money_With_Registration__c,Submitted_to_Audit__c	
                                               FROM booking__c
                                               WHERE /*Unit__r.Unit_Status__c != 'EOI' AND Stage_of_Booking__c != 'EOI' AND*/
                                               //Aayushi commented EOI part for SOB-157
                                                Verification_status__c = 'Not Started'  
                                               /*AND Booking_Approver_Audit__c = 'Accepted'*/
                                               AND Status__c = 'Booking In Process' AND Opportunity__c != null ORDER BY Booking_Date__c limit 999]);   
        System.debug('List Booking::: ' + lstBooking);
    }
}