public class S_ProcessDocumentVerification_PS {
    public list <PropStrength__Application_Booking__c> lstBooking {get; set;}
    public string ProcessRowNo {get; set;}
    public string ReleaseRowNo {get; set;}
    public string AssignRowNo {get; set;}
    public string ProfileName {get; set;}
    public string UserName {get; set;}
    
    public S_ProcessDocumentVerification_PS() {
        Id profileId = userinfo.getProfileId();
        ProfileName = [Select Id, Name from Profile where Id = :profileId].Name;
        UserName = userinfo.getname();
        GetListOfBooking();       
    }
    
    public Pagereference Process() {
        return (new PageReference('/apex/DocumentChecklistPageDubai_PS?Id=' + lstBooking[integer.valueof(ProcessRowNo)].id));
    } 
    
    
    public Pagereference Assign() {
        PropStrength__Offer__c objOffer = new PropStrength__Offer__c();
        objOffer.id = lstBooking[integer.valueof(AssignRowNo)].PropStrength__Offer__c;
        objOffer.Physical_document_received__c = true;
        update objOffer;
        GetListOfBooking();
        return null;
    }
    
    public void GetListOfBooking() {
        lstBooking = New list < PropStrength__Application_Booking__c > ([SELECT id, CreatedById, CreatedBy.Name, Verification_status__c, PropStrength__Offer__c, PropStrength__Offer__r.Name,PropStrength__Offer__r.Physical_document_received__c,
                                                                        Name, Call_Disposition__c, PropStrength__Status__c,PropStrength__Primary_Customer__c, PropStrength__Primary_Applicant_Name__c,
                                                                        PropStrength__Property__c, PropStrength__Property__r.Name, Project_Name__c, PropStrength__Property__r.PropStrength__Unit_Status__c, PropStrength__Booking_Date__c,
                                                                        PropStrength__Total_Paid_Percent__c,Submitted_to_Audit__c, PropStrength__Total_Payment_Received__c 
                                                                        FROM PropStrength__Application_Booking__c
                                                                        WHERE Verification_status__c = 'Not Started'  
                                                                        AND (NOT(PropStrength__Status__c LIKE :'%Cancelled%')) AND PropStrength__Offer__c != null ORDER BY PropStrength__Booking_Date__c LIMIT 999]);   
        System.debug('List Booking::: ' + lstBooking);
    }
}