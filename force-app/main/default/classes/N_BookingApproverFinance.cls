public class N_BookingApproverFinance{
public List < rMainWrapper > rwList {
    get;
    set;
   }
public List <Booking__c> lstBooking {
    get;
    set;
   }

    public N_BookingApproverFinance(){
     getBookingList();
    }
 
    public void getBookingList(){
    
    rwList = new List<rMainWrapper>();
    lstBooking = [SELECT Id, Name, Primary_Applicant_Name__c, Booking_Approver_Finance__c, Comment_Finance__c, Select_All_Finance__c, Flat_No__c,
                  Tower__c, Sales_Managers__r.Name, Flat_Typology__c, CreatedDate, Agreement_Value__c, Finance_Approval_Date__c FROM Booking__c 
                  WHERE Booking_Approver_Finance__c = 'Submitted' OR Booking_Approver_Finance__c = 'Re-Submitted'
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
                   if(rw.b.Select_All_Finance__c == true) {
                       isError = false;
                   }
               }
               if(!isError){
                   for (rMainWrapper rw: rwList) {
                       rw.style0='';
                       rw.style1='';
                       rw.style2=''; 
                       System.debug('List of booking for processing ' + rw);
                          if(rw.b.Select_All_Finance__c == true){                                                 
                               if(rw.selectedVal == 'None'){                                       
                                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Booking Approval Status to proceed'));
                                  return;  
                               } else {
                                   rw.b.Booking_Approver_Finance__c = rw.selectedVal; 
                               }
                               if(rw.b.Booking_Approver_Finance__c == 'Rejected' && String.ISBLANK(rw.b.Comment_Finance__c)){
                                   ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Comments'));
                                   return;                      
                               }                  
                               rw.b.Finance_Approval_Date__c = System.Today();
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
     return new pagereference('/home/home.jsp');
     }                        

    public class rMainWrapper {
         public Booking__c b {
          get;
          set;
         }
          public String bookingDate {
          get;
          set;
         }
          public String applicantNames {
          get;
          set;
         }
         public String style0 {
          get;
          set;
         }         
         public String style1 {
          get;
          set;
         }
         public String style2 {
          get;
          set;
         }
        
         public List<SelectOption> options {
          get;
          set;
         }
         public string selectedVal {
          get;
          set;
         }
         
         public rMainWrapper(Booking__c b) {
          this.b = b;
          this.applicantNames = b.Primary_Applicant_Name__c;
          this.bookingDate = b.CreatedDate.format('dd/MM/yyyy');
          
          options = new List<SelectOption>();
          options.add(new SelectOption('None','None'));
          options.add(new SelectOption('Approved','Approved'));
          options.add(new SelectOption('Rejected','Rejected'));

          this.style0 = '';
          this.style1 = '';
          this.style2 = '';
         }
      }
 }