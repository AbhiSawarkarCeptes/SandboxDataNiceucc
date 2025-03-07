public with sharing class DocumentChecklistPageDubaiController {
    
    public string test {get; set;}
    public String ArrayApplicant1String {get; set;}
    public String ArrayApplicant2String {get; set;}
    public String a {get; set;}
    public String b {get; set;}
    public String ArrayApplicant3String {get; set;}
    public String ArrayApplicant4String {get; set;}
    public String ArrayApplicant5String {get; set;}
    public boolean isError {get; set;}
    public boolean d1 {get; set;}
    public boolean d2 {get; set;}
    public boolean d3 {get; set;}
    public boolean d4 {get; set;}
    public boolean d5 {get; set;}
    public boolean d6 {get; set;}
    public boolean d7 {get; set;}
    public boolean d8 {get; set;}
    public boolean d9 {get; set;}
    public boolean d10 {get; set;}
    public boolean d11 {get; set;}
    public String drow1 {get; set;}
    public String drow2 {get; set;}
    public String drow3 { get; set;}
    public String drow4 {get; set;}
    public String drow5 {get; set;}
    public String drow6 {get; set;}
    public String drow7 {get; set;}
    public String drow8 {get; set;}
    public String drow9 {get; set;}
    public String drow10 {get; set;}
    public String drow11 {get; set;}
    public List <String> ArrayApplicant1 {get; set;}
    public List <String> ArrayApplicant2 {get; set;}
    public List <String> ArrayApplicant3 {get; set;}
    public List <String> ArrayApplicant4 {get; set;}
    public List <String> ArrayApplicant5 {get; set;}
    public List <Booking__c> lstBooking {get; set;}
    public Receipt__c lstReceiptTokenToShow {get; set;}
    public Receipt__c lstReceiptServiceTaxToShow {get; set;}
    public List <Receipt__c> lstReceiptToken {get; set;}
    public List < Receipt__c > lstReceiptServiceTax {get; set;}
    public Applicant_Details__c applicant {get; set;}
    public Applicant_Details__c applicant2 {get; set;}
    public Applicant_Details__c applicant3 {get; set;}
    public Applicant_Details__c applicant4 {get; set;}
    public Applicant_Details__c applicant5 {get; set;}
    public Document_Checklist_Header__c checklistHeader {get; set;}
    List < Document_Checklist__c > lstDocumentChecklist = new List < Document_Checklist__c > ();
    List < Document_Checklist__c > lstDocumentChecklistApplicant = new List < Document_Checklist__c > ();
    public Document_Checklist__c DocRow1 {get; set;}
    public Document_Checklist__c DocRow2 {get; set;}
    public Document_Checklist__c DocRow3 {get; set;}
    public Document_Checklist__c DocRow4 {get; set;}
    public Document_Checklist__c DocRow5 {get; set;}
    public Document_Checklist__c DocRow6 {get; set;}
    public Document_Checklist__c DocRow8 {get; set;}
    public Document_Checklist__c DocRow11 {get; set;}  
    List <Applicant_Details__c> listApplicant = new list <Applicant_Details__c> ();
    public Channel_Partner__c channelPartner; // Added by Neha on 1/6/19
    public List <Sobha_Connect__c> sc; // Added by Neha on 1/6/19
    public String bookingSourceCompany {get;set;}   // Added by Neha on 1/6/19
    String BookingId {get; set;}
    public String instrumentno {get; set;}
    public List <Applicant_Details__c> applicantList {get; set;}
    public Integer i {get; set;}
    public string err {get; set;}
    public string subsource {get; set;}
    public String error {get; set;}
    public Boolean isRejected {get; set;}
    public Boolean isAccepted {get; set;}
    public string infavourtoken1 {get; set;}
    public string infavourST1 {get; set;}
    public String alotment {get; set;}
    public String tokenamt {get; set;}
    public String STamt {get; set;}
    public String ApplicantNames {get; set;}
    public boolean NoST {get; set; }
    
    public DocumentChecklistPageDubaiController () {       
        
        isError = true;
        isRejected = false;
        isAccepted = false;
        ArrayApplicant1 = new List < String > ();
        ArrayApplicant2 = new List < String > ();
        ArrayApplicant3 = new List < String > ();
        ArrayApplicant4 = new List < String > ();
        ArrayApplicant5 = new List < String > ();
        
        applicant = new Applicant_Details__c();
        applicant2 = new Applicant_Details__c();
        applicant3 = new Applicant_Details__c();
        applicant4 = new Applicant_Details__c();
        applicant5 = new Applicant_Details__c();
        ApplicantNames = '';
        lstDocumentChecklist = new List <Document_Checklist__c> ();
        checklistHeader = new Document_Checklist_Header__c();
        lstReceiptTokenToShow = new Receipt__c();
        lstReceiptServiceTaxToShow = new Receipt__c();
        DocRow1 = new Document_Checklist__c();
        DocRow2 = new Document_Checklist__c();
        DocRow3 = new Document_Checklist__c();
        DocRow4 = new Document_Checklist__c();
        DocRow5 = new Document_Checklist__c();
        DocRow6 = new Document_Checklist__c();
        DocRow8 = new Document_Checklist__c();
        DocRow11 = new Document_Checklist__c();
        
        DocRow1.Description__c = 'Client Signatures';
        DocRow1.Verified__c = True;
        DocRow3.Description__c = 'Overwriting';
         DocRow3.Verified__c = True;
        DocRow4.Description__c = 'Future Correspondence';
         DocRow4.Verified__c = True;
        DocRow5.Description__c = 'Booking Details';
         DocRow5.Verified__c = True;
        DocRow6.Description__c = 'Receipt Details';
         DocRow6.Verified__c = True;
        DocRow8.Description__c = 'Source of Booking Details';
         DocRow8.Verified__c = True;     
        DocRow11.Description__c = 'Deal Approval Details: Quotation';
         DocRow11.Verified__c = True;
        subsource = '';
        
        //Get the booking id from URL
        if (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') 
            BookingId = ApexPages.currentPage().getParameters().get('id');
        
        if (BookingId != null && BookingId != '') {
            
            lstBooking = [Select Id, Sales_Managers__c, Ownerid, LastModifiedDate, Name, Status__c, Sales_Manager__c, Project__c, Opportunity__c, Opportunity__r.Physical_document_received__c, Unit__c, 
                          Unit__r.Unit_Status__c, Future_Correspondence_Contact__c, Future_Correspondence_Contact_Relation__c, Sales_Operations__c, Verification_status__c, Channel_Partner__c, Sobha_Connect__c,
                          Agreement_Value__c, Quotation__r.Owner.Name, No_of_Earmarked_Parking__c,No_of_Additional_Parking__c, Stage_of_Booking__c, 
                          Future_Correspondence_Contact_Email__c, Future_Correspondence_Contact_Phone__c, Future_Correspondence_Contact_Name__c, Cluster__c, Tower__c,
                          Source_of_Booking__c, Sub_Source__c, Booking_Date__c, Opportunity__r.name,
                          Opportunity__r.Account.Salutation, Unit__r.Name, Unit__r.Chargeable_Area__c,                
                          Unit__r.Configuration__c, Unit__r.Floor_No_to_print__c, Unit__r.Unit_No__c 
                          from Booking__c Where Id = :BookingId];
            // Added by Neha on 1/6/19 Starts Here
            // Fetching Channel Partner details 
            if(lstBooking[0].Channel_Partner__c != null){
                channelPartner = [SELECT Name FROM Channel_Partner__c WHERE Id = :lstBooking[0].Channel_Partner__c];
            }
            // Fetching Sobha Connect details
            if(lstBooking[0].Sobha_Connect__c != null) {
                sc = [SELECT Name__c, Contact_Person__c FROM Sobha_Connect__c WHERE Id = :lstBooking[0].Sobha_Connect__c];
            }
            
            ///// Added by Neha on 22/2/19
            if(lstBooking[0].Source_of_Booking__c == 'Channel Partner' || lstBooking[0].Source_of_Booking__c == 'Sobha Connect'){
                if(lstBooking[0].Source_of_Booking__c == 'Channel Partner' && channelPartner != null){        
                    bookingSourceCompany = channelPartner.Name;           
                } 
                if(lstBooking[0].Source_of_Booking__c == 'Sobha Connect' && sc != null && sc.size() > 0){      
                    bookingSourceCompany = sc[0].Name__c;         
                } 
            }
            // Added by Neha on 1/6/19 Ends Here
            if (lstBooking != null && lstBooking.size() > 0) {              
                alotment = INFormat(lstBooking[0].Agreement_Value__c);
            }
            if (lstBooking[0].Sub_Source__c != null) {
                subsource = ' - ' + lstBooking[0].Sub_Source__c;
            }
            
                if (lstBooking[0].Status__c == 'Cancelled') {
                    error = 'yes';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'This Booking Has Been Cancelled.'));    
                } else {    
                    if (lstBooking[0].Opportunity__r.Physical_document_received__c == False) {
                        error = 'yes';
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please Check Physical Document Received on Opportunity to Proceed'));
                    } else {
                       /* if (lstBooking[0].Unit__r.Unit_Status__c == 'EOI' || lstBooking[0].Verification_status__c != 'Not Started') {
                            error = 'yes';
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please ensure that the Unit Status is "Blocked" or "Booked" and Document Verification Status is "Not Started"'));    
                        } else {*/
                            //lstReceiptToken 
                            lstReceiptToken = [SELECT Cheque_DD__c, Cheque_DD_Date__c, Cheque_DD_Amount_Rs__c, Drawn_in_favour_of__c, DraweeBank__c, Branch__c, NEFT__c, RTGS__c, Challan_No__c, Pay_Order__c FROM Receipt__c Where Opportunity__c = :lstBooking[0].Opportunity__c and Token_Amount_Receipt__c = true]; //change from Token_Amount_Receipt__c = true to Token_Amount_ST__c = False
                            if (lstReceiptToken.size() > 0) {
                                lstReceiptTokenToShow = lstReceiptToken[0];
                                // getting substring of (in favour of) field from receipt  added on 29/12/15
                                string infavourtoken = lstReceiptToken[0].Drawn_in_favour_of__c;
                                if (infavourtoken != null) {
                                    integer l = infavourtoken.IndexOf('|');
                                    infavourtoken1 = infavourtoken.Substring(0, l);
                                }
                                if (lstReceiptToken[0].Cheque_DD_Amount_Rs__c != null)
                                    tokenamt = INFormat(lstReceiptToken[0].Cheque_DD_Amount_Rs__c);
                            }    
                            //lstReceiptServiceTax
                            lstReceiptServiceTax = [SELECT Cheque_DD__c, Cheque_DD_Date__c, Cheque_DD_Amount_Rs__c, DraweeBank__c, Branch__c, NEFT__c, RTGS__c, Drawn_in_favour_of__c, Challan_No__c, Pay_Order__c FROM Receipt__c Where Opportunity__c = :lstBooking[0].opportunity__c and Token_Amount_ST__c = true];
                            if (lstReceiptServiceTax.size() > 0) {
                                lstReceiptServiceTaxToShow = lstReceiptServiceTax[0];
                                // getting substring of (in favour of) field from receipt added on 29/12/15
                                string infavourST = lstReceiptServiceTax[0].Drawn_in_favour_of__c;
                                if (infavourST != null) {
                                    integer l = infavourST.IndexOf('|');
                                    infavourST1 = infavourST.Substring(0, l);
                                }
                                if (lstReceiptServiceTax[0].Cheque_DD_Amount_Rs__c != null)
                                    STamt = INFormat(lstReceiptServiceTax[0].Cheque_DD_Amount_Rs__c);
                            } else {
                                NoST = true;
                            }
                        
                    }
                } 
            
            //Fetch the list of applications for the bookingid provided in the URL
            applicantList = [Select Id, Mailing_Address_same_as_PermanentAddress__c, OwnerId, IsDeleted, Name, Salutation__c, Type_Of_Applicant__c, 
                             Permanent_Address__c, Mailing_Address__c, Mailing_Country__c, Country__c, Email_Address__c, Mobile_Number__c, Subtype_Of_Applicant__c,
                             Booking__c, Applicant_Number__c, Nationality__c,
                             Passport_Copy__c, Passport_Copy_Details__c, Valid_Until_Passport__c, Power_of_Attorney__c, Power_of_Attorney_Details__c,
                             Emirates_ID__c, Emirates_ID_Details__c, National_ID__c, National_ID_Details__c, Valid_Upto_National_ID__c, Visa_Copy_Valid_Upto__c, 
                             Non_residency_Letter__c, Non_residency_Letter_Details__c, Non_residency_Letter_Valid_Upto__c, Visa_Copy__c, Visa_Copy_Details__c,
                             Memoradum_Articles_of_Association__c, Memoradum_Articles_of_Association_Deta__c,  
                             Registration_License__c, Registration_License_Details__c, Certificate_of_Incorporation__c,
                             Certificate_of_Incorporation_Details__c, Certificate_of_Good_Standing_and_Certifi__c, Certificate_of_Standing_Incumbe_Detail__c,
                             Passport_Copy_of_Authorized_Signatory__c, Passport_Copy_of_Authorized_Signatory_De__c, Others__c, Others_Details__c, Others_Valid_Upto__c
                             FROM Applicant_Details__c 
                             WHERE Booking__c = :bookingId];
            
            if (applicantList.size() > 0) {
                applicant = applicantList[0];
                
                applicant.Permanent_Address__c = applicantList[0].Permanent_Address__c.replace(',', ' ');
                
                ApplicantNames = applicantList[0].Salutation__c + ' ' + applicantList[0].Name;
                if (applicant.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicant.Mailing_Address__c = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[0].Mailing_Address__c != null) {
                        applicant.Mailing_Address__c = applicantList[0].Mailing_Address__c.replace(',', ' ');
                    }
                    applicant.Mailing_Address__c = applicant.Mailing_Address__c + ' Country:' + applicant.Mailing_Country__c;
                    
                  }        
            }
            
            if (applicantList.size() > 1) {
                applicant2 = applicantList[1];
                ApplicantNames = ApplicantNames + ', ' + applicantList[1].Salutation__c + ' ' + applicantList[1].Name;
                applicant2.Permanent_Address__c = applicantList[1].Permanent_Address__c.replace(',', ' ');
                if (applicant2.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicant2.Mailing_Address__c = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[1].Mailing_Address__c != null) {
                        applicant2.Mailing_Address__c = applicantList[1].Mailing_Address__c.replace(',', ' ');
                    }
                    applicant2.Mailing_Address__c = applicant2.Mailing_Address__c + ' Country:' + applicant2.Mailing_Country__c;
                    
                }
            }        
            
            if (applicantList.size() > 2) {
                applicant3 = applicantList[2];
                ApplicantNames = ApplicantNames + ', ' + applicantList[2].Salutation__c + ' ' + applicantList[2].Name;
                applicant3.Permanent_Address__c = applicantList[2].Permanent_Address__c.replace(',', ' ');
                if (applicant3.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicant3.Mailing_Address__c = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[2].Mailing_Address__c != null) {
                        applicant3.Mailing_Address__c = applicantList[2].Mailing_Address__c.replace(',', ' ');
                    }
                    applicant3.Mailing_Address__c = applicant3.Mailing_Address__c + ' Country:' + applicant3.Mailing_Country__c;
                }
            }       
            
            if (applicantList.size() > 3) {
                applicant4 = applicantList[3];
                ApplicantNames = ApplicantNames + ', ' + applicantList[3].Salutation__c + ' ' + applicantList[3].Name;
                applicant4.Permanent_Address__c = applicantList[3].Permanent_Address__c.replace(',', ' ');
                if (applicant4.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicant4.Mailing_Address__c = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[3].Mailing_Address__c != null) {
                        applicant4.Mailing_Address__c = applicantList[3].Mailing_Address__c.replace(',', ' ');
                    }
                    applicant4.Mailing_Address__c = applicant4.Mailing_Address__c + ' Country:' + applicant4.Mailing_Country__c;
                }   
            }
            
            if (applicantList.size() > 4) {
                applicant5 = applicantList[4]; 
                ApplicantNames = ApplicantNames + ', ' +  ' ' + applicantList[4].Name;
                applicant5.Permanent_Address__c = applicantList[4].Permanent_Address__c.replace(',', ' ');
                if (applicant5.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicant5.Mailing_Address__c = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[4].Mailing_Address__c != null) {
                        applicant5.Mailing_Address__c = applicantList[4].Mailing_Address__c.replace(',', ' ');
                    }
                    applicant5.Mailing_Address__c = applicant5.Mailing_Address__c + ' Country:' + applicant5.Mailing_Country__c;
                }
            }
        }
    }
    
    public PageReference saveArray() {
        err = '';
        checklistHeader.Name = 'ChecklistHeader';
        checklistHeader.Booking__c = BookingId;
        insert(checklistHeader);
        
        ////////////Converting Applicant's DocumentArray into List//////////////////
        if (String.isNotBlank(ArrayApplicant1String)) {
            for (String eachStr: ArrayApplicant1String.split(',')) {
                ArrayApplicant1.add(eachStr);
            }
        }
        if (String.isNotBlank(ArrayApplicant2String)) {
            for (String eachStr: ArrayApplicant2String.split(',')) {
                ArrayApplicant2.add(eachStr);
            }
        }
        if (String.isNotBlank(ArrayApplicant3String)) {
            for (String eachStr: ArrayApplicant3String.split(',')) {
                ArrayApplicant3.add(eachStr);
            }
        }
        if (String.isNotBlank(ArrayApplicant4String)) {
            for (String eachStr: ArrayApplicant4String.split(',')) {
                ArrayApplicant4.add(eachStr);
            }
        }
        if (String.isNotBlank(ArrayApplicant5String)) {
            for (String eachStr: ArrayApplicant5String.split(',')) {
                ArrayApplicant5.add(eachStr);
            }
        }
        ////////////Adding Applicant1's Document to list if not Approved//////////////////
        if (ArrayApplicant1.size() > 0) {         
            for (i = 0; i < ArrayApplicant1.size(); i = i + 6) {
                if (ArrayApplicant1[i + 4] == 'false') {
                    Document_Checklist__c DocApp1 = new Document_Checklist__c();                     
                    DocApp1.Document_Checklist_Header__c = checklistHeader.id;
                    DocApp1.Name = 'Applicant 1';
                    DocApp1.Description__c = ArrayApplicant1[i + 1];
                    DocApp1.Verified__c = true;                    
                    DocApp1.Rejection_Remarks__c = ArrayApplicant1[i + 5];
                    lstDocumentChecklistApplicant.add(DocApp1);
                }       
            }           
        }
        ////////////Adding Applicant2's Document to list if not Approved//////////////////
        if (ArrayApplicant2.size() > 0) {
            for (i = 0; i < ArrayApplicant2.size(); i = i + 6) {
                if (ArrayApplicant2[i + 4] == 'false') {
                    Document_Checklist__c DocApp2 = new Document_Checklist__c();
                    DocApp2.Document_Checklist_Header__c = checklistHeader.id;
                    DocApp2.Name = 'Applicant 2';
                    DocApp2.Description__c = ArrayApplicant2[i + 1];
                    DocApp2.Verified__c = False;
                    DocApp2.Rejection_Remarks__c = ArrayApplicant2[i + 5];                                                                
                    lstDocumentChecklistApplicant.add(DocApp2);
                }
            }
        }
        ////////////Adding Applicant3's Document to list if not Approved//////////////////
        if (ArrayApplicant3.size() > 0) {
            for (i = 0; i < ArrayApplicant3.size(); i = i + 6) {
                if (ArrayApplicant3[i + 4] == 'false') {     
                    Document_Checklist__c DocApp3 = new Document_Checklist__c();
                    DocApp3.Document_Checklist_Header__c = checklistHeader.id;
                    DocApp3.Name = 'Applicant 3';
                    DocApp3.Description__c = ArrayApplicant3[i + 1];
                    DocApp3.Verified__c = False;
                    DocApp3.Rejection_Remarks__c = ArrayApplicant3[i + 5];                              
                    lstDocumentChecklistApplicant.add(DocApp3);
                }    
            }
        }
        ////////////Adding Applicant4's Document to list if not Approved//////////////////
        if (ArrayApplicant4.size() > 0) {
            for (i = 0; i < ArrayApplicant4.size(); i = i + 6) {
                if (ArrayApplicant4[i + 4] == 'false') {
                    Document_Checklist__c DocApp4 = new Document_Checklist__c();
                    DocApp4.Document_Checklist_Header__c = checklistHeader.id;
                    DocApp4.Name = 'Applicant 4';
                    DocApp4.Description__c = ArrayApplicant4[i + 1];
                    DocApp4.Verified__c = False;
                    DocApp4.Rejection_Remarks__c = ArrayApplicant4[i + 5];
                    lstDocumentChecklistApplicant.add(DocApp4);
                }
            }
        }
        ////////////Adding Applicant5's Document to list if not Approved//////////////////
        if (ArrayApplicant5.size() > 0) {
            for (i = 0; i < ArrayApplicant5.size(); i = i + 6) {
                if (ArrayApplicant5[i + 4] == 'false') {    
                    Document_Checklist__c DocApp5 = new Document_Checklist__c();
                    DocApp5.Document_Checklist_Header__c = checklistHeader.id;
                    DocApp5.Name = 'Applicant 5';
                    DocApp5.Description__c = ArrayApplicant5[i + 1];
                    DocApp5.Verified__c = False;
                    DocApp5.Rejection_Remarks__c = ArrayApplicant5[i + 5];                                                            
                    lstDocumentChecklistApplicant.add(DocApp5);
                }
            }
        }       
        btnReject();
        return new pagereference('/lightning/n/Docs_Verification');
    }
    
    //Copied method from the existing code 
    public void btnReject() {
        
        ////Send mail to sales operations when doc ver rejection //////////   
        if(lstBooking[0].Ownerid != null) {
            //  list <User> LstUsers = [select id, name, email from user where id = :lstBooking[0].Sales_Operations__c];
            list <User> LstUsers = [select id, name, email from user where id = :lstBooking[0].Ownerid];
            
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            string PageLink = '/'+lstBooking[0].Id;
            
            string subjectMail = lstBooking[0].Name + ': Document verification rejected by CRM';
            
            string strBookingHtmlBody = 'Kind Attention !!<br></br><br></br>' +
                'Physical document verification step is rejected. <br></br>' +
                ' <br/>Please click the below booking link:<br/>' +
                baseUrl + PageLink + '<br></br> <br></br>' +
                
                'Thanks, <br></br>' +
                'Salesforce Team';
            
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setHtmlBody(strBookingHtmlBody);
            list <string> lststringtoaddress = new list <string> ();
            lststringtoaddress.add('neha.pandey@stetig.in');
            lststringtoaddress.add('priya.patre@stetig.in');
            if (LstUsers.size() > 0) {
                lststringtoaddress.add(LstUsers[0].Email);
            }
            /*  if (LstUsersRm.size() > 0) {
lststringtoaddress.add(LstUsersRm[0].Email);
}*/
            
            System.debug('lststringtoaddress' + lststringtoaddress);
            mail.setToAddresses(lststringtoaddress);
            mail.setSubject(subjectMail);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
        }
        //mail sending ends here  ///
        
        // Update the Booking Status and opty
        if (ApexPages.currentPage().getParameters().get('bookingid') != null && ApexPages.currentPage().getParameters().get('bookingid') != '')
            BookingId = ApexPages.currentPage().getParameters().get('bookingid');
        if (BookingId != null && BookingId != '') {
            Booking__c updateBooking = new Booking__c();
            updateBooking.id = Id.ValueOf(BookingId);
            updateBooking.Document_Checklist_Header__c = checklistHeader.id;
            updateBooking.Verification_status__c = 'Rejected';
           // updateBooking.Booking_Approver_Audit__c = 'Rejected';
           // updateBooking.Audit_Approval_Date__c = System.today();
            //updateBooking.Comment_Audit__c = 'Rejected by CRM';
            updateBooking.Status__c = 'UnProcessed';
            updateBooking.Current_Status__c = 'Document Verification Rejected';                   
            updateBooking.Flat_Applicants__c = ApplicantNames;            
            if (updateBooking != null) {
                update updateBooking;               
            }            
            
            if (lstBooking != null && lstBooking.size() > 0) {
                if (d1 == False) {
                    DocRow1.Name = 'N/A';
                    DocRow1.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow1.Rejection_Remarks__c = drow1;
                    lstDocumentChecklistApplicant.add(DocRow1);
                }
                if (d3 == False) {
                    DocRow3.Name = 'N/A';
                    DocRow3.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow3.Rejection_Remarks__c = drow3;
                    lstDocumentChecklistApplicant.add(DocRow3);
                }
                if (d4 == False) {
                    DocRow4.Name = 'N/A';
                    DocRow4.Details__c = 'Contact: ' + lstBooking[0].Future_Correspondence_Contact__c + ', Relation: ' + lstBooking[0].Future_Correspondence_Contact_Relation__c + ', Name: ' + lstBooking[0].Future_Correspondence_Contact_Name__c + ', Contact Mobile: ' + lstBooking[0].Future_Correspondence_Contact_Phone__c + ', Contact Email: ' + lstBooking[0].Future_Correspondence_Contact_Email__c;
                    DocRow4.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow4.Rejection_Remarks__c = drow4;
                    lstDocumentChecklistApplicant.add(DocRow4);
                }
                if (d5 == False) {
                    DocRow5.Name = 'N/A';
                    DocRow5.Details__c = 'Tower: ' + lstBooking[0].Tower__c + ', Sub Project: ' + lstBooking[0].Cluster__c + ', Flat Typology: ' + lstBooking[0].Unit__r.Configuration__c + ', Floor: ' + lstBooking[0].Unit__r.Floor_No_to_print__c + ', Unit No: ' + lstBooking[0].Unit__r.Unit_No__c + ', Saleable Area: ' + lstBooking[0].Unit__r.Chargeable_Area__c + ', Alloted Parking: ' + lstBooking[0].No_of_Earmarked_Parking__c + ', Purchase price: ' + alotment;
                    DocRow5.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow5.Rejection_Remarks__c = drow5;
                    lstDocumentChecklistApplicant.add(DocRow5);
                }
                if (d6 == False) {
                    DocRow6.Name = 'N/A';
                    if (lstReceiptToken != null && lstReceiptToken.size() > 0) {
                        if (lstReceiptToken[0].Cheque_DD__c != '' && lstReceiptToken[0].Cheque_DD__c != null) {
                            instrumentno = lstReceiptToken[0].Cheque_DD__c;
                        }                        
                        DocRow6.Details__c = 'Amount: ' + lstReceiptToken[0].Cheque_DD_Amount_Rs__c + ', Cheque No.: ' + instrumentno + ', Cheque Date: ' + lstReceiptToken[0].Cheque_DD_Date__c.format() + ', Bank Name: ' + lstReceiptToken[0].DraweeBank__c;  ///// In Favour Of: ' + infavourtoken1
                    }
                    DocRow6.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow6.Rejection_Remarks__c = drow6;
                    lstDocumentChecklistApplicant.add(DocRow6);
                }
                
                if (d8 == False) {
                    DocRow8.Name = 'N/A';
                    DocRow8.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow8.Rejection_Remarks__c = drow8;
                    DocRow8.Details__c = 'Source Of Booking: ' + lstBooking[0].Source_of_Booking__c + ', Sub Source of Booking: ' + subsource;  //, Comapany: ' + bookingSourceCompany               
                    lstDocumentChecklistApplicant.add(DocRow8);
                }                
                if (d11 == False) {
                    DocRow11.Name = 'N/A';
                    DocRow11.Details__c = '';                      
                    DocRow11.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow11.Rejection_Remarks__c = drow11;
                    lstDocumentChecklistApplicant.add(DocRow11);
                }
                
                if (lstDocumentChecklistApplicant.size() > 0) {
                    insert(lstDocumentChecklistApplicant);
                }
            }
        }
        isRejected = true;
    }
    
    public pagereference Accept() {
        
        if (ApexPages.currentPage().getParameters().get('bookingid') != null && ApexPages.currentPage().getParameters().get('bookingid') != '') 
            BookingId = ApexPages.currentPage().getParameters().get('bookingid');
        if (BookingId != null && BookingId != '') {
            
            List < Booking__c > lstBooking = [Select Id, Name, Sales_Manager__c, Sales_Managers__c,/*Project__r.Project_Site_Head__c,*/ Opportunity__r.Account.Salutation, 
                                              Ownerid, Unit__r.Name, Project__r.Name, Opportunity__r.Name, LastModifiedDate, Opportunity__c, Opportunity__r.unit__c, Unit__c,
                                              Sales_Operations__c, Verification_status__c from Booking__c Where Id = :BookingId];
            if (lstBooking != null && lstBooking.size() > 0) {
                Booking__c updateAcceptBooking = new Booking__c();
                updateAcceptBooking.id = lstBooking[0].Id;
                updateAcceptBooking.Verification_status__c = 'Accepted';
                updateAcceptBooking.Current_Status__c = 'Document Verification Accepted';
                updateAcceptBooking.Document_Checklist_Header__c = null;
                updateAcceptBooking.Flat_Applicants__c = ApplicantNames;
                
                if(updateAcceptBooking != null)
                    update updateAcceptBooking;
            }
        }
        isAccepted = true;
        return new pagereference('/lightning/n/Docs_Verification');
    }
    
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);       
            if(i== 2 || i==5 || i==8 || i==11 || i==14) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(!negative)
            mf = 'AED ' + mf + '/-';
        else
            mf = '- AED ' + mf + '/-';
        return mf;
    }
}