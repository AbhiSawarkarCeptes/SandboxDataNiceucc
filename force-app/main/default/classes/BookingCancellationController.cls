public with sharing class BookingCancellationController{
    
    Public string bookId{get;set;}
    Public List<Booking__c> bookList{get;set;}
    Public List<File_Note__c> fnList;
    Public List<File_Note__c> cancellationfnList;
    public boolean isError{get;set;}
    Public string demandedAmount{get;set;}
    Public string paidAmount{get;set;}
    Public string outstandingAmount{get;set;}
    Public List<Opportunity> oppList{get;set;}
    Public string applicantNames{get;set;}
    public decimal amountOnAccount{get;set;}
    Public string amountOnAccountSTR{get;set;}
    Public List<Receipt__c> recList{get;set;}
    Public string refundAmountStr{get;set;}
    Public boolean isSave{get;set;}
    
    public BookingCancellationController(){
        
        bookList = new List<Booking__c>();
        fnList = new List<File_Note__c>();
        cancellationfnList = new List<File_Note__c>();
        isError = false;
        demandedAmount = '';
        paidAmount = '';
        outstandingAmount = '';
        oppList = new List<opportunity>();
        applicantNames = '';
        amountOnAccount = 0;
        recList = new List<Receipt__c>();
        refundAmountStr = '';
        isSave = false;
        
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != ''){
            bookId = ApexPages.currentPage().getParameters().get('Id');
        }
        
        if(string.isNotBlank(bookId)){
            bookList = [select id, name, Reason_For_Cancellation__c,Date_of_Cancellation__c,Reason_For_Cancellation_D__c,Refund_Amount__c,Project__c, Booking_Previous_Status__c,
                        Unit__c,Opportunity__c,Opportunity__r.stageName,Booking_Date__c,Application_No__c,TotalAmountDemanded__c,TotalAmountPaid__c,TotalAmountBalance__c,
                        Status__c,Cancellation_In_Progress__c,Unit__r.Tower__c,Cancellation_Approver_1__c,Cancellation_Approver_2__c,Amount_On_Account__c,Total_Receipts_Amount__c,
                        Reverse_Demand__c, Application_Number__c, Other_Charge__c, Interest_Charges__c, Agent_Fees__c, Incentive_paid__c, Admin_Charges__c,
                        CRM_Head_Approved_Rejected_Date__c, Unit__r.Tower__r.Cluster__c
                        from booking__c where id =:bookId];
            
            if(!bookList.isEmpty()){
                if(string.isNotBlank(bookList[0].Status__c)){
                    if(bookList[0].Status__c != 'Cancelled' && bookList[0].Status__c != 'Cancellation In Progress'){                       
                        fnList = [SELECT Category__c, Is_Approved__c, Final_Status__c FROM File_Note__c WHERE Booking__c = :bookId and Unit__c = :bookList[0].Unit__c and Category__c LIKE 'Cancellation%'];
                        system.debug('file note list::: ' + fnList.size());
                        if(!fnList.isEmpty()){
                            for(File_Note__c f : fnList){                              
                                if(f.Category__c.contains('Cancellation')){
                                    cancellationfnList.add(f);                                                      
                                }
                            } 
                            if(cancellationfnList.size() == 1){
                                if((cancellationfnList[0].Final_Status__c == 'Submitted' && !cancellationfnList[0].Is_Approved__c) || (cancellationfnList[0].Final_Status__c == 'Approved')){
                                    if(cancellationfnList[0].Is_Approved__c){
                                        if(bookList[0].Opportunity__c != null){
                                            oppList = [select id,name,Primary_Name__c,Other_Applicants_Name__c from opportunity where id = :bookList[0].Opportunity__c];
                                            if(!oppList.isEmpty()){
                                                applicantNames = oppList[0].Primary_Name__c;
                                                if(string.isNotBlank(oppList[0].Other_Applicants_Name__c))    
                                                    applicantNames += ', ' +  oppList[0].Other_Applicants_Name__c;
                                                amountOnAccount = PaymentManagementServices.getOnAccountMoney(oppList[0].id);
                                            }
                                        }
                                        amountOnAccountSTR = InventoryCostServices.INFormatR(amountOnAccount);
                                        if(bookList[0].TotalAmountDemanded__c != null)
                                            demandedAmount = InventoryCostServices.INFormatR(bookList[0].TotalAmountDemanded__c);
                                        if(bookList[0].TotalAmountPaid__c != null)    
                                            paidAmount = InventoryCostServices.INFormatR(bookList[0].TotalAmountPaid__c);
                                        if(bookList[0].TotalAmountBalance__c != null)
                                            outstandingAmount = InventoryCostServices.INFormatR(bookList[0].TotalAmountBalance__c);   
                                    } else {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. File note for cancellation is not approved.'));
                                        isError = true;
                                    }
                                } else {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. File note for cancellation is not submitted for approval.'));
                                    isError = true;                                        
                                }                                  
                            } else if (cancellationfnList.size() > 1){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking has multiple file note for cancellation.'));
                                isError = true;    
                            } else {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking has no file note for cancellation.'));
                                isError = true; 
                            }                            
                        } else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. There is no cancellation file note for selected booking.'));
                            isError = true;
                        }                  
                    } else {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking is already cancelled or cancellation is in process.'));
                        isError = true;
                    }
                } else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking is not processed.'));
                    isError = true;
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking is not available.'));
                isError = true;
            }           
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking is not available.'));
            isError = true;
        }
    }
    
    public void submit(){
        Boolean isErrorNew = false;
        system.debug('Reason for cancellation:: '+ bookList[0].Reason_For_Cancellation_D__c);
        system.debug('amount:: ' + bookList[0].Interest_Charges__c);       
        if(string.isBlank(bookList[0].Reason_For_Cancellation_D__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select Reason for Cancellation.'));
            isErrorNew = true;
        }
        if(bookList[0].Interest_Charges__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Interest Charges.'));
            isErrorNew = true;
        }
        if(bookList[0].Agent_Fees__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Agent Fees.'));
            isErrorNew = true;
        }
        if(bookList[0].Incentive_paid__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Incentive Paid.'));
            isErrorNew = true;
        }        
        if(bookList[0].Admin_Charges__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Admin Charges.'));
            isErrorNew = true;
        }
        if(bookList[0].Other_Charge__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Other Charges.'));
            isErrorNew = true;
        }
         if(string.isBlank(bookList[0].Reason_For_Cancellation__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Remarks.'));
            isErrorNew = true;
        }
        
        if(!isErrorNew){
            try{
                decimal totalReceipts = 0;
                Decimal refundAmount = 0;
                
                List<Team_Members__c> approverTeam = new List<Team_Members__c>();
                approverTeam = [select id,name,Team__c,User__c,Approver_Type__c from Team_Members__c 
                                where Team__r.Team_Type__c = 'Cancellation Approval Team' and Team__r.Sub_Project__c = :bookList[0].Unit__r.Tower__r.Cluster__c
                                and Team__r.TowerLookup__c = :bookList[0].Unit__r.Tower__c and User_Active__c = true];
                if(!approverTeam.isEmpty()){
                    for(Team_Members__c tm : approverTeam){
                        if(string.isNotBlank(tm.Approver_Type__c ) && tm.Approver_Type__c == 'First Level'){
                            bookList[0].Cancellation_Approver_1__c = tm.User__c;
                        }
                        if(string.isNotBlank(tm.Approver_Type__c ) && tm.Approver_Type__c == 'Second Level'){
                            bookList[0].Cancellation_Approver_2__c = tm.User__c;
                        }
                    }
                    
                    if(!opplist.isEmpty())
                        totalReceipts = PaymentManagementServices.getRefundAmount(oppList[0].id);
                   
                    system.debug('amountOnAccount:::: ' + amountOnAccount);
                    bookList[0].Total_Receipts_Amount__c = totalReceipts;
                    bookList[0].Amount_On_Account__c = amountOnAccount;   
                    refundAmount = totalReceipts - bookList[0].Interest_Charges__c - bookList[0].Agent_Fees__c - bookList[0].Incentive_paid__c - bookList[0].Admin_Charges__c - bookList[0].Other_Charge__c ;                     
                    refundAmountStr = InventoryCostServices.INFOrmat(refundAmount);
                    system.debug('total receipt amount:::: ' + totalReceipts);
                    system.debug('amountOnAccount:::: ' + refundAmountStr);
                    bookList[0].Booking_Previous_Status__c = bookList[0].Status__c;
                    bookList[0].Cancellation_In_Progress__c = true;
                    bookList[0].Status__c = 'Cancellation In Progress';
                    bookList[0].CRM_Head_Approved_Rejected_Date__c = null;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no team member added in the cancellation team.'));
                    isErrorNew = true;
                }
                update bookList;
                isSave = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Booking cancellation process successfully submitted and notification send to respective team.'));
            }catch(Exception e){
                system.debug('Exception:: '+e.getMessage());
                ApexPages.addMessages(e);
            } 
        }
    }
    
    public PageReference goBackMethod(){
        PageReference pageRef;
        if(!bookList.isEmpty())
            pageRef = new PageReference('/' + bookList[0].id); 
        else
            pageRef = new PageReference('/home/home.jsp');    
        pageRef.setRedirect(true);
        return pageRef;
    }
}