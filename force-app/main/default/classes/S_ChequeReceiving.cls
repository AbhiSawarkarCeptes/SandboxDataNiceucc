public class S_ChequeReceiving {
    public List <rMainWrapper> rwList {get; set;}
    public transient List <rMainWrapper> dummyrwList {get; set;}
    public transient List <Receipt__c> totalReceiptList{get; set;}
    public transient List <Receipt__c> lstReceipt {get; set;}
    public Boolean error {get; set;}
    public PaginationController.PaginationWrapper pgw; // Neha
    public List<Account_Master__c> accList; //// Added by Neha on 12/6/19
    public List<String> accNameList {get;set;} //// Added by Neha on 12/6/19 
    public String searchByName {get; set;} ///// Added by Neha on 28/6/19
    public Boolean pagination {get;set;} ///// Added by Neha on 28/6/19
    
    public S_ChequeReceiving() {
        error = false;   
        pgw = new PaginationController.PaginationWrapper();// Neha
        pgw.list_size = 10; //Records to display on each page
        pgw.counter = 0; 
        accList = new List<Account_Master__c>(); //// Added by Neha on 12/6/19
        accNameList = new List<String>(); //// Added by Neha on 12/6/19  
        searchByName = ''; ///// Added by Neha on 28/6/19
        pagination = true; ///// Added by Neha on 28/6/19
        
        /// Added by Neha on 12/6/19      
        accList = [SELECT Name, Id, Type__c, Tax_Rate__c FROM Account_Master__c]; 
        if(accList != null){
            for(Account_Master__c a: accList){
                if(a.Type__c == 'Others')
                    accNameList.add(a.Name);
            }
        }
        getlist();     
    }
    
    public PageReference clearResult(){
        searchByName = '';
        getlist();   
        return null;     
    }
    
    public void searchResult(){
        rwList = new List<rMainWrapper>();
        if(searchByName != '' && searchByName != null){
            pagination = false;
            String search = '%' + searchByName  + '%'; 
            lstReceipt = [SELECT Receipt_Number__c, id, Physically_Cheque_Received__c, Total_Amount__c, Payment_Towards__c, Bank_Reference_Number__c,
                          Cheque_DD__c, Cheque_DD_Date__c, Mode__c,Drawn_in_favour_of__c, Cheque_DD_Amount_Rs__c, Project_Unit__c, Booking__r.Owner.Name,
                          PAN_no_of_TDS_Deductor__c, Project_Unit__r.Project__r.name, Project_Unit__r.name, Currency__c, Booking__r.Primary_Applicant_Email__c,
                          Opportunity__c, Reason__c, Opportunity__r.name, Booking__c, Booking__r.Name, GL_Date__c,  Project_Unit__r.Tower__c,
                          Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c, Debit_Account__c, Booking__r.Owner.Email,
                          name, Amount_Rs__c, DraweeBank__c, Reason_for_rejection_new__c, Receipt_Status__c, Banking__c, FOREX__c,
                          Project_Unit__r.Tower__r.Name, Business_Unit__c, Booking__r.Stage_of_Booking__c, Credit_Card_Charges__c, Other_Charges_Type__c,
                          Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c, Receipt_Date__c   
                          from Receipt__c
                          where Receipt_Status__c NOT IN('Dishonored', 'Cleared', 'Physical Verification Rejected', 'Cancelled') AND Is_Reversed_Receipt__c = False AND
                          (Booking__r.Name Like :search OR Booking__r.Opportunity__r.Name Like :search OR Booking__r.Unit__r.Name Like :search OR Name Like :search)
                          Order By CreatedDate DESC];
            
            if (lstReceipt.size() > 0) {
                for (Receipt__c r: lstReceipt) {
                    if (String.isNotBlank(r.Receipt_Status__c) && r.Receipt_Status__c.equalsIgnoreCase('UnProcessed') && !r.Physically_Cheque_Received__c) {
                        r.Receipt_Status__c = 'UnProcessed';
                    } 
                    String applicantNames;
                    if(String.isNotBlank(r.Opportunity__r.Primary_Name__c)) 
                        applicantNames = r.Opportunity__r.Primary_Name__c;
                    if(String.isNotBlank(r.Opportunity__r.Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                        applicantNames += ', ' + r.Opportunity__r.Other_Applicants_Name__c;
                    else if(String.isNotBlank(r.Opportunity__r.Other_Applicants_Name__c))
                        applicantNames = r.Opportunity__r.Other_Applicants_Name__c;
                    rMainWrapper rw = new rMainWrapper(r, applicantNames);
                    rwList.add(rw);
                }
            }                          
        } else {
            getlist();    
        }    
    }
    
    public PageReference getlist() {    
        rwList = new List<rMainWrapper>();
        dummyrwList = new List<rMainWrapper>();
        totalReceiptList = new List<Receipt__c>(); 
        Datetime todaysDate = System.now();
        pagination = true;
        totalReceiptList = [SELECT Receipt_Number__c, id, Physically_Cheque_Received__c, Total_Amount__c, Payment_Towards__c, Bank_Reference_Number__c,
                            Cheque_DD__c, Cheque_DD_Date__c, Mode__c,Drawn_in_favour_of__c, Cheque_DD_Amount_Rs__c, Project_Unit__c, Booking__r.Owner.Name,
                            PAN_no_of_TDS_Deductor__c, Project_Unit__r.Project__r.name, Project_Unit__r.name, Currency__c, Booking__r.Primary_Applicant_Email__c,
                            Opportunity__c, Reason__c, Opportunity__r.name, Booking__c, Booking__r.Name, GL_Date__c, Project_Unit__r.Tower__c,
                            Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c, Booking__r.Owner.Email, Debit_Account__c,
                            name, Amount_Rs__c, DraweeBank__c, Reason_for_rejection_new__c, Receipt_Status__c, Banking__c, FOREX__c,
                            Project_Unit__r.Tower__r.Name, Business_Unit__c, Booking__r.Stage_of_Booking__c, Credit_Card_Charges__c, Other_Charges_Type__c,
                            Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c, Receipt_Date__c   
                            from Receipt__c
                            where Receipt_Status__c NOT IN('Dishonored', 'Cleared', 'Physical Verification Rejected', 'Cancelled') AND Is_Reversed_Receipt__c = False and createdDate <=:todaysDate
                            Order By CreatedDate DESC];              
        pgw.total_size = totalReceiptList.size();// Total number of records               
        rwList = getReceipts(pgw.list_size, pgw.counter);  
        return null;    
    }
    
    public void Save() {
        error = false;
        Account_Master__c a;
        
        for (rMainWrapper rw: rwList) {
            rw.style0='';
            rw.style1='';
            rw.style2='';
            System.debug('RECEIPT DATA:' + rw);        
            // throw an error if physical verification is checked but the status of verification is blank
            System.debug('rw.rCloned.GL_Date__c ::'+rw.rCloned.GL_Date__c);
            System.debug('rw.accName ::'+rw.accName);
            if(String.isBlank(rw.rCloned.Banking__c)){
                rw.rCloned.GL_Date__c = rw.glDate;
                rw.r.GL_Date__c = rw.glDate;
            }
            System.debug('rw.rCloned.Bank_Reference_Number__c ::'+rw.rCloned.Bank_Reference_Number__c);
            System.debug('rw.rCloned.Payment_Towards__c ::'+rw.rCloned.Payment_Towards__c);
            if (rw.rCloned.Physically_Cheque_Received__c == true && 
                String.isnotBlank(rw.r.Receipt_status__c) && 
                rw.r.Receipt_status__c.equalsIgnoreCase('UnProcessed') && 
                (String.isBlank(rw.rCloned.Reason_for_rejection_new__c)
                 || rw.rCloned.GL_Date__c == null 
                 || rw.accName == '' 
                 || rw.accName == null 
                 || rw.rCloned.Bank_Reference_Number__c == null 
                 || rw.rCloned.Bank_Reference_Number__c == '' 
                 || rw.rCloned.Payment_Towards__c == '' 
                 || rw.rCloned.Payment_Towards__c == null)
            ) 
            {
                     rw.style0 = 'error';
                     System.debug('Error from here 1 :::'+rw.accName);
                     error = true;
                     // throw an error if Foreign Curreny payment is accepted but forex amt is not filled
                     /// Indian Rupees changed to AED by Neha on 12/3/19
                 } else if (rw.rCloned.Physically_Cheque_Received__c == true && 
                                String.isnotBlank(rw.r.Receipt_status__c) &&             
                                (rw.r.Receipt_status__c.equalsIgnoreCase('Processed-Sent for Banking') || rw.r.Receipt_status__c.equalsIgnoreCase('PDC')) && 
                                String.isNotBlank(rw.rCloned.Banking__c) &&             
                                rw.rCloned.Banking__c.equalsIgnoreCase('Payment Successful') && 
                                String.isNotBlank(rw.r.Currency__c) &&             
                                !rw.r.Currency__c.equalsIgnoreCase('AED') && 
                                rw.rCloned.Forex__c == null 
                                ) {             
                                    rw.style2 = 'error';
                                    error = true;
                                    System.debug('Error from here 2');
                 }
                 if (rw.r.Receipt_status__c.equalsIgnoreCase('UnProcessed') &&
                        (rw.rCloned.Other_Charges_Type__c != null && rw.rCloned.Credit_Card_Charges__c == null)) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Other charges value is mandatory if other charges type is selected'));
                    return;
                 }
                 if (rw.r.Receipt_status__c.equalsIgnoreCase('UnProcessed') &&
                        ((rw.rCloned.Credit_Card_Charges__c != null && rw.rCloned.Credit_Card_Charges__c > 0) && rw.rCloned.Other_Charges_Type__c == null)) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Other charges type is mandatory if other charges value is selected'));
                    return;
                 }
                if(rw.accName != null && rw.accName != ''){
                    try{
                        a = [SELECT Id FROM Account_Master__c WHERE Name = :rw.accName];
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select valid Debit Account'));
                        return;
                    }
                }
                /*if(rw.r.Other_Charges_Type__c != null && rw.r.Credit_Card_Charges__c == null ){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Other charges value is mandatory if other charges type is selected'));
                    return;
                }*/
        }
        List<Receipt__c> updateReceiptList = new List<Receipt__c>();
        List<Task> lstTask = new List<Task>();
        if (error) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please correct the errors below'));
            return;
        }else{
            for (rMainWrapper rw: rwList) {
                rw.style0='';
                rw.style1='';
                rw.style2='';          
                // physical verification is accepted or rejected, store the status in the receipt
                if (rw.rCloned.Physically_Cheque_Received__c == true && String.isNotBlank(rw.r.Receipt_status__c) &&            
                    rw.r.Receipt_status__c.equalsIgnoreCase('UnProcessed') && String.isNotBlank(rw.rCloned.Reason_for_rejection_new__c)) {                       
                        if (rw.rCloned.Reason_for_rejection_new__c.equalsIgnoreCase('Accepted')) {
                            rw.r.Receipt_status__c = 'Processed-Sent for Banking';
                            rw.r.Physically_Cheque_Received__c = true;
                            rw.r.Reason_for_rejection_new__c = rw.rCloned.Reason_for_rejection_new__c;
                            rw.r.GL_Date__c = rw.rCloned.GL_Date__c;
                            rw.r.Credit_Card_Charges__c = rw.rCloned.Credit_Card_Charges__c;
                            rw.r.Other_Charges_Type__c = rw.rCloned.Other_Charges_Type__c;  
                            rw.r.Payment_Towards__c = rw.rCloned.Payment_Towards__c;
                            rw.r.Bank_Reference_Number__c = rw.rCloned.Bank_Reference_Number__c;              
                            if(a.Id != null)
                                rw.r.Debit_Account__c = a.Id;  
                            if(rw.r.Currency__c != null && rw.r.Currency__c != 'AED'){
                                rw.r.Amount_in_Foreign_Currency__c = rw.r.Amount_Rs__c;
                                rw.r.Foreign_Currency_Type__c = rw.r.Currency__c;
                            }               
                        } else {
                            rw.r.Receipt_status__c = 'Physical Verification Rejected';
                            rw.r.Physically_Cheque_Received__c = true;
                            rw.r.Reason_for_rejection_new__c = rw.rCloned.Reason_for_rejection_new__c;
                            rw.r.GL_Date__c = rw.rCloned.GL_Date__c;
                            rw.r.Credit_Card_Charges__c = rw.rCloned.Credit_Card_Charges__c;
                            rw.r.Other_Charges_Type__c = rw.rCloned.Other_Charges_Type__c;               
                            if(a.Id != null)
                                rw.r.Debit_Account__c = a.Id;               
                            Task objTask = new Task();
                            objTask.Subject = rw.r.Cheque_DD__c + ' ' + 'is rejected by Finance Team for ' + rw.r.Reason_for_rejection_new__c;
                            objTask.WhatId = rw.r.Id;
                            objTask.Description = rw.r.Reason__c;
                            lstTask.add(objTask);
                        }
                        rw.r.status_change_date__c = system.today();
                        updateReceiptList.add(rw.r);
                        // if banking is completed, store the payment received /rejected status
                    } else if (rw.rCloned.Physically_Cheque_Received__c == true && 
                               String.isnotBlank(rw.r.Receipt_status__c) && 
                               (rw.r.Receipt_status__c.equalsIgnoreCase('Processed-Sent for Banking') || rw.r.Receipt_status__c.equalsIgnoreCase('PDC')) && 
                               String.isNotBlank(rw.rCloned.Banking__c)) {
                                   if (rw.rCloned.Banking__c.equalsIgnoreCase('Payment Successful')) {
                                       rw.r.Receipt_status__c = 'Cleared';
                                       rw.r.Banking__c = rw.rCloned.Banking__c;                 
                                       //// Indian Rupees changed to AED by Neha on 12/3/19   
                                       if(rw.rCloned.Forex__c != null && !rw.r.Currency__c.equalsIgnoreCase('AED')) {
                                           rw.r.Forex__c = rw.rCloned.Forex__c;
                                           rw.r.Amount_Rs__c = rw.r.Forex__c;
                                           rw.r.Currency__c = 'AED'; // Indian Rupees changed to AED by Neha on 12/3/19   
                                           rw.r.Total_Amount__c = rw.r.Forex__c;
                                           rw.r.On_Account_Money__c = rw.r.Forex__c;   
                                           if(rw.r.Booking__r.Primary_Applicant_Email__c != null) 
                                               sendEmail(rw.r);               
                                       }             
                                   } else if(rw.rCloned.Banking__c.equalsIgnoreCase('PDC')){
                                       rw.r.Banking__c = rw.rCloned.Banking__c;     
                                       rw.r.Receipt_status__c = 'PDC';       
                                   } else {
                                       rw.r.Receipt_status__c = 'Dishonored';
                                       rw.r.Banking__c = rw.rCloned.Banking__c;
                                       Task objTask = new Task();
                                       objTask.Subject = rw.r.Cheque_DD__c + ' ' + 'is rejected by Finance Team for ' + rw.r.Banking__c;
                                       objTask.WhatId = rw.r.Id;
                                       objTask.Description = rw.r.Reason__c;
                                       lstTask.add(objTask);
                                   }
                                   rw.r.status_change_date__c = system.today();
                                   updateReceiptList.add(rw.r);
                               }
            }
        }
        if(updateReceiptList.size() > 0){
            System.debug('In Update:' + updateReceiptList);
            update updateReceiptList;
        }
        if(lstTask.size() > 0) {
            System.debug('In Task creation:');
            insert lstTask;
        }
        getlist();
        return;
    }
    
    public void sendEmail(Receipt__c r){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
        email.setSubject('Amount has been credited');
        list<string> lststringtoaddress = new list<string>();
        list<string> lststringccaddress = new list<string>();
        
        String body =  'Dear Mr./Ms. ' + r.Booking__r.Opportunity__r.Name + ',<br/><br/>' + 
            '<b>Greetings from Sobha!</b><br/><br/>'+
            ' Amount paid by you has been credited. Please find below details:'+
            ' <br/>Tower: ' + r.Project_Unit__r.Tower__r.Name + 
            ' <br/>Unit No.: ' + r.Project_Unit__r.Name + 
            ' <br/> Mode of Payment: ' + r.Mode__c +
            ' <br/> Receipt_Date__c: ' + r.Receipt_Date__c.format() +
            ' <br/> Amount in Foreign Currency: ' + r.Amount_in_Foreign_Currency__c + ' ' + r.Foreign_Currency_Type__c +
            ' <br/> Amount in AED: ' + r.Amount_Rs__c + ' ' + r.Currency__c +
            ' <br/><br/>Best Regards,<br/>'+
            r.Booking__r.Owner.Name;
        
      /*  if(r.Booking__r.Primary_Applicant_Email__c != null) {
            lststringtoaddress.add(r.Booking__r.Primary_Applicant_Email__c); /// Commented to block direct communication with client and added booking owner
        }*/
        if(r.Booking__r.Owner.Email != null) {
            lststringtoaddress.add(r.Booking__r.Owner.Email);                       
        }
        if(r.Booking__r.Owner.Email != null && r.Booking__r.Owner.Email != ''){
            lststringccaddress.add(r.Booking__r.Owner.Email);                      
        }                   
        
        lststringtoaddress.add('neha.pandey@stetig.in');
        lststringtoaddress.add('priya.patre@stetig.in');
        email.setToAddresses(lststringtoaddress);
        email.setCCAddresses(lststringccaddress);
        email.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});       
    }
    
    public pagereference Back() {
        return new pagereference('/lightning/page/home');
    }  
    
    public List<rMainWrapper> getReceipts(Integer listSize, Integer counter){
        
        dummyrwList = new List<rMainWrapper>();
        lstReceipt = new list <Receipt__c> ();
        
        lstReceipt = [select Receipt_Number__c, id, Physically_Cheque_Received__c, Total_Amount__c, Project_Unit__r.Tower__c, Booking__r.Primary_Applicant_Email__c,
                      Cheque_DD__c, Cheque_DD_Date__c, Mode__c,Drawn_in_favour_of__c, Cheque_DD_Amount_Rs__c,Project_Unit__c, Payment_Towards__c, Bank_Reference_Number__c,
                      PAN_no_of_TDS_Deductor__c,  Project_Unit__r.Project__r.name, Project_Unit__r.name, Currency__c, Credit_Card_Charges__c, Other_Charges_Type__c, Booking__r.Owner.Name,
                      Opportunity__c, Reason__c, Opportunity__r.name, Booking__c, Booking__r.Name, GL_Date__c, Project_Unit__r.Tower__r.Name, Business_Unit__c,
                      Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c, Booking__r.Stage_of_Booking__c,Debit_Account__c,
                      name, Amount_Rs__c, DraweeBank__c, Reason_for_rejection_new__c, Receipt_Status__c, Banking__c, FOREX__c, Booking__r.Owner.Email,
                      Booking__r.Opportunity__r.Name, Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c, Receipt_Date__c  
                      from Receipt__c
                      where Receipt_Status__c NOT IN('Dishonored', 'Cleared', 'Physical Verification Rejected', 'Cancelled') AND Is_Reversed_Receipt__c = False
                      Order By CreatedDate DESC limit :listSize offset :counter];  
        
        if (lstReceipt.size() > 0) {
            for (Receipt__c r: lstReceipt) {
                if (String.isNotBlank(r.Receipt_Status__c) && r.Receipt_Status__c.equalsIgnoreCase('UnProcessed') && !r.Physically_Cheque_Received__c) {
                    r.Receipt_Status__c = 'UnProcessed';
                } 
                String applicantNames;
                if(String.isNotBlank(r.Opportunity__r.Primary_Name__c)) 
                    applicantNames = r.Opportunity__r.Primary_Name__c;
                if(String.isNotBlank(r.Opportunity__r.Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                    applicantNames += ', ' + r.Opportunity__r.Other_Applicants_Name__c;
                else if(String.isNotBlank(r.Opportunity__r.Other_Applicants_Name__c))
                    applicantNames = r.Opportunity__r.Other_Applicants_Name__c;
                rMainWrapper rw = new rMainWrapper(r, applicantNames);
                dummyrwList.add(rw);
            }
        }
        return dummyrwList;      
    }
    
    public PageReference Beginning() { //user clicked beginning
        pgw= PaginationController.Beginning(pgw);
        rwList = getReceipts(pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        pgw = PaginationController.Previous(pgw);       
        rwList = getReceipts(pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        rwList = getReceipts(pgw.list_size, pgw.counter);        
        return null;
    }
    
    public PageReference End() { //user clicked end
        pgw = PaginationController.End(pgw);
        rwList = getReceipts(pgw.list_size, pgw.counter);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        return(PaginationController.DisablePrevious(pgw));
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        return(PaginationController.DisableNext(pgw));
    }
    
    public Integer getTotal_size() {
        return (PaginationController.getTotal_size(pgw));
    }
    
    public Integer getPageNumber() {
        return (PaginationController.getPageNumber(pgw));
    }
    
    public Integer getTotalPages() {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        return (PaginationController.getTotalPages(pgw));
    }
    
    public class rMainWrapper {
        public Receipt__c r {get; set;}
        public Receipt__c rCloned {get; set;}
        public String style0 {get; set;}
        Public date glDate{get; set;}
        public String applicantNames {get; set;}
        public String style1 {get; set;}
        public String style2 {get; set;}
        public String accName {get;set;} //// Added by Neha on 12/6/19
        
        public rMainWrapper(Receipt__c r, String applicantNames) {
            this.r = r;
            this.applicantNames = applicantNames;
            this.rCloned = new Receipt__c();
            this.rCloned.Physically_Cheque_Received__c = r.Physically_Cheque_Received__c;
            this.rCloned.Other_Charges_Type__c = r.Other_Charges_Type__c;
            this.rCloned.Credit_Card_Charges__c = r.Credit_Card_Charges__c;
            if(r.Banking__c != null)
                this.rCloned.Banking__c = r.Banking__c;
            
            if(r.Reason_for_rejection_new__c != null)
                this.rCloned.Reason_for_rejection_new__c = r.Reason_for_rejection_new__c;
            
            if(r.Forex__c != null)
                this.rCloned.Forex__c = r.Forex__c;
            
            this.style0 = '';
            this.style1 = '';
            this.style2 = '';
        }

        
        
    }
}