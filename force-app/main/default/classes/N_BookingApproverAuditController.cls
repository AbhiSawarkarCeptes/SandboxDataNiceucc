public class N_BookingApproverAuditController{
    public List <rMainWrapper> rwList {get; set;}
    public List <Booking__c> lstBooking {get; set;}
    public List <Unit__c> lstUnit {get; set;}
    public List <Opportunity> lstOpty {get; set;}
    
    public N_BookingApproverAuditController(){
        getBookingList();
    }
    
    public void getBookingList(){
        
        rwList = new List<rMainWrapper>();
        lstBooking = [SELECT Id, Name, Primary_Applicant_Name__c, Booking_Approver_Audit__c, Comment_Audit__c, Select_All_Audit__c, Flat_No__c,
                      Tower__c, Sales_Managers__r.Name, Flat_Typology__c, CreatedDate, Agreement_Value__c, Audit_Approval_Date__c, Unit__c,
                      Status__c, Verification_status__c, Sales_Operations__r.Name, Cluster__c, Opportunity__r.StageName, Unit__r.Unit_Status__c, 
                      Current_Status__c FROM Booking__c 
                      WHERE Booking_Approver_Audit__c = 'Not Started'  
                      AND Verification_status__c = 'Accepted' AND Status__c = 'Booking In Process' 
                      Order By CreatedDate DESC limit 50];       
        
        if(lstBooking.size() > 0){
            for(Booking__c b: lstBooking){ 
                rMainWrapper rw = new rMainWrapper(b);
                rwList.add(rw);             
            }
        }  
    }
    
    public void Save() {        
        
        List <Booking__c> updateBookingList = new List <Booking__c>();
        boolean isError = true;  
        for (rMainWrapper rw: rwList) {
            if(rw.b.Select_All_Audit__c == true) {
                isError = false;
            }
        }    
        if(!isError){
            for (rMainWrapper rw: rwList) {
                rw.style0='';
                rw.style1='';
                rw.style2=''; 
                System.debug('List of booking for processing ' + rw);
                if(rw.b.Select_All_Audit__c == true){                                                 
                    if(rw.selectedVal == 'None'){                                       
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Booking Approval Status to proceed'));
                        return;  
                    } else {
                        rw.b.Booking_Approver_Audit__c = rw.selectedVal; 
                    }
                    if(rw.b.Booking_Approver_Audit__c == 'Rejected' && String.ISBLANK(rw.comment)){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Comments'));
                        return;                      
                    } 
                    if(rw.b.Booking_Approver_Audit__c == 'Accepted') {
                        rw.b.Current_Status__c = 'Audit Accepted';
                    }                    
                    if(rw.b.Booking_Approver_Audit__c == 'Rejected') {
                        String userName = UserInfo.getName();
                        String commentValue = '\r\n'+'Rejected On : '+System.now()+' by '+userName+' with the comment : '+rw.comment;
                        rw.b.Status__c = 'Unprocessed';
                        rw.b.Current_Status__c = 'Audit Rejected';
                        rw.b.Verification_status__c = 'Rejected';
                         rw.b.Comment_Audit__c = rw.b.Comment_Audit__c == null ? commentValue :rw.b.Comment_Audit__c+' , '+ commentValue;
                    }  
                    rw.b.Audit_Approval_Date__c = System.Today();                                                           
                    updateBookingList.add(rw.b);                                                           
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Booking to proceed'));
            return;    
        }
        
        if (updateBookingList.size() > 0){
            update updateBookingList;
        }
        getBookingList();
        return;
    }
    
    public pagereference Back() {
        return new pagereference('/lightning/page/home');
    }                        
    
    public class rMainWrapper {
        public Booking__c b {get; set;}
        public String bookingDate {get; set;}
        public String applicantNames {get; set;}
        public String style0 {get; set;}         
        public String style1 {get; set;}
        public String style2 {get; set;}        
        public List<SelectOption> options {get; set;}
         public string selectedVal {get; set;}
        public string comment {get; set;}
        
        public rMainWrapper(Booking__c b) {
            this.b = b;
            this.applicantNames = b.Primary_Applicant_Name__c;
            this.bookingDate = b.CreatedDate.format('dd/MM/yyyy');
                        
            options = new List<SelectOption>();
           // options.add(new SelectOption('None','None'));
            options.add(new SelectOption('Accepted','Accepted'));
            options.add(new SelectOption('Rejected','Rejected'));
            options.add(new SelectOption('None','None'));
           
            this.style0 = '';
            this.style1 = '';
            this.style2 = '';
            
           
            
        }
    }
}