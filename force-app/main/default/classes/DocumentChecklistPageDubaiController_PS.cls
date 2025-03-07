public with sharing class DocumentChecklistPageDubaiController_PS {
    
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
    public List <PropStrength__Application_Booking__c> lstBooking {get; set;}
    public Receipt__c lstReceiptTokenToShow {get; set;}
    public Receipt__c lstReceiptServiceTaxToShow {get; set;}
    public List <Receipt__c> lstReceiptToken {get; set;}
    public List < Receipt__c > lstReceiptServiceTax {get; set;}
    public PropStrength__Applicant_Detail__c applicant {get; set;}
    public PropStrength__Applicant_Detail__c applicant2 {get; set;}
    public PropStrength__Applicant_Detail__c applicant3 {get; set;}
    public PropStrength__Applicant_Detail__c applicant4 {get; set;}
    public PropStrength__Applicant_Detail__c applicant5 {get; set;}
    public String applicantAdd {get; set;}
    public String applicantAdd2 {get; set;}
    public String applicantAdd3 {get; set;}
    public String applicantAdd4 {get; set;}
    public String applicantAdd5 {get; set;}
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
    List <PropStrength__Applicant_Detail__c> listApplicant = new list <PropStrength__Applicant_Detail__c> ();
    public Channel_Partner__c channelPartner; // Added by Neha on 1/6/19
    public List <Sobha_Connect__c> sc; // Added by Neha on 1/6/19
    public String bookingSourceCompany {get;set;}   // Added by Neha on 1/6/19
    String BookingId {get; set;}
    public String instrumentno {get; set;}
    public List <PropStrength__Applicant_Detail__c> applicantList {get; set;}
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
    
    public DocumentChecklistPageDubaiController_PS () {       
        
        isError = true;
        isRejected = false;
        isAccepted = false;
        ArrayApplicant1 = new List < String > ();
        ArrayApplicant2 = new List < String > ();
        ArrayApplicant3 = new List < String > ();
        ArrayApplicant4 = new List < String > ();
        ArrayApplicant5 = new List < String > ();
        
        applicant = new PropStrength__Applicant_Detail__c();
        applicant2 = new PropStrength__Applicant_Detail__c();
        applicant3 = new PropStrength__Applicant_Detail__c();
        applicant4 = new PropStrength__Applicant_Detail__c();
        applicant5 = new PropStrength__Applicant_Detail__c();
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
            
            lstBooking = [SELECT Id, Sales_Manager__c, CreatedById, LastModifiedDate, Name, PropStrength__Status__c, PropStrength__Project__c, PropStrength__Project__r.Name, PropStrength__Offer__c, PropStrength__Offer__r.Physical_document_received__c, PropStrength__Property__c, 
                        PropStrength__Property__r.PropStrength__Unit_Status__c, Verification_status__c, PropStrength__Broker_Account__c,
                        PropStrength__Total_Agreement_Amount__c, No_of_Earmarked_Parking__c,No_of_Additional_Parking__c, 
                        PropStrength__Property__r.PropStrength__Tower__c,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                        Sub_Source__c, PropStrength__Booking_Date__c, PropStrength__Offer__r.name,PropStrength__Property__r.PropStrength__Unit_Type__c,
                        PropStrength__Offer__r.PropStrength__Broker_Account__r.Salutation, PropStrength__Property__r.Name, PropStrength__Property__r.PropStrength__Chargeable_Area__c,                
                        PropStrength__Property__r.PropStrength__Floor_Number__c, PropStrength__Property__r.PropStrength__House_Unit_No__c 
                        FROM PropStrength__Application_Booking__c Where Id = :BookingId];
            
            // if(lstBooking[0].Channel_Partner__c != null){
            //     channelPartner = [SELECT Name FROM Channel_Partner__c WHERE Id = :lstBooking[0].Channel_Partner__c];
            // }
            
            // if(lstBooking[0].Sobha_Connect__c != null) {
            //     sc = [SELECT Name__c, Contact_Person__c FROM Sobha_Connect__c WHERE Id = :lstBooking[0].Sobha_Connect__c];
            // }

            // if(lstBooking[0].Source_of_Booking__c == 'Channel Partner' || lstBooking[0].Source_of_Booking__c == 'Sobha Connect'){
            //     if(lstBooking[0].Source_of_Booking__c == 'Channel Partner' && channelPartner != null){        
            //         bookingSourceCompany = channelPartner.Name;           
            //     } 
            //     if(lstBooking[0].Source_of_Booking__c == 'Sobha Connect' && sc != null && sc.size() > 0){      
            //         bookingSourceCompany = sc[0].Name__c;         
            //     } 
            // }
            
            if (lstBooking != null && lstBooking.size() > 0) {              
                alotment = INFormat(lstBooking[0].PropStrength__Total_Agreement_Amount__c);
            }
            if (lstBooking[0].Sub_Source__c != null) {
                subsource = ' - ' + lstBooking[0].Sub_Source__c;
            }
            
                if (lstBooking[0].PropStrength__Status__c.containsIgnoreCase('Cancelled')) {
                    error = 'yes';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'This Booking Has Been Cancelled.'));    
                } else {    
                    if (lstBooking[0].PropStrength__Offer__r.Physical_document_received__c == False) {
                        error = 'yes';
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please Check Physical Document Received on Offer to Proceed'));
                    } else {
                        /*lstReceiptToken = [SELECT Cheque_DD__c, Cheque_DD_Date__c, Cheque_DD_Amount_Rs__c, Drawn_in_favour_of__c, DraweeBank__c, Branch__c, NEFT__c, RTGS__c, Challan_No__c, Pay_Order__c FROM Receipt__c Where Opportunity__c = :lstBooking[0].Opportunity__c and Token_Amount_Receipt__c = true]; 
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
                        }*/
                    }
                } 
            
            applicantList = [Select Id, PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c, CreatedById, IsDeleted, Name, PropStrength__Applicant_Acc__r.Salutation, PropStrength__Type__c, 
                            PropStrength__Applicant_Acc__r.Permanent_Address__c, PropStrength__Applicant_Address__c, PropStrength__Applicant_Acc__r.MailingCountry, PropStrength__Applicant_Acc__r.Country__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Mobile__c,
                            PropStrength__Application__c, PropStrength__Applicant_Acc__r.PropStrength__Nationality__c,
                            PropStrength__Applicant_Acc__r.Passport_Copy__c, PropStrength__Applicant_Acc__r.Passport_Copy_Details_Arabic__c, PropStrength__Applicant_Acc__r.Passport_Expiry_Date__c,
                            PropStrength__Applicant_Acc__r.Emirates_ID__c, PropStrength__Applicant_Acc__r.Emirates_ID_Details__c, PropStrength__Applicant_Acc__r.National_ID__c, PropStrength__Applicant_Acc__r.National_ID_Details__c, PropStrength__Applicant_Acc__r.Valid_Upto_National_ID__c, PropStrength__Applicant_Acc__r.Visa_Copy_Valid_Upto__c, 
                            PropStrength__Applicant_Acc__r.Non_residency_Letter__c, PropStrength__Applicant_Acc__r.Non_residency_Letter_Details__c, PropStrength__Applicant_Acc__r.Non_residency_Letter_Valid_Upto__c, PropStrength__Applicant_Acc__r.Visa_Copy__c, PropStrength__Applicant_Acc__r.Visa_Copy_Details__c,
                            PropStrength__Applicant_Acc__r.Memoradum_Articles_of_Association__c, PropStrength__Applicant_Acc__r.Power_of_Attorney__c, PropStrength__Applicant_Acc__r.Power_of_Attorney_Details__c, 
                            PropStrength__Applicant_Acc__r.Registration_License__c, PropStrength__Applicant_Acc__r.Registration_License_Details__c, PropStrength__Applicant_Acc__r.Certificate_of_Incorporation__c,
                            PropStrength__Applicant_Acc__r.Certificate_of_Incorporation_Details__c,PropStrength__Applicant_Acc__r.Name,
                            PropStrength__Applicant_Acc__r.Passport_Copy_of_Authorized_Signatory__c, PropStrength__Applicant_Acc__r.Passport_Copy_of_Authorized_Signatory_De__c, PropStrength__Applicant_Acc__r.Others__c, PropStrength__Applicant_Acc__r.Others_Details__c, PropStrength__Applicant_Acc__r.Others_Valid_Upto__c
                            FROM PropStrength__Applicant_Detail__c 
                            WHERE PropStrength__Application__c = :bookingId];
            
            if (applicantList.size() > 0) {
                applicant = applicantList[0];
                
                applicant.PropStrength__Applicant_Acc__r.Permanent_Address__c = applicantList[0].PropStrength__Applicant_Acc__r.Permanent_Address__c != null ? applicantList[0].PropStrength__Applicant_Acc__r.Permanent_Address__c.replace(',', ' ') : '';
                
                ApplicantNames = applicantList[0].PropStrength__Applicant_Acc__r.Salutation + ' ' + applicantList[0].PropStrength__Applicant_Acc__r.Name;
                if (applicant.PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicantAdd = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[0].PropStrength__Applicant_Address__c != null) {
                        applicantAdd = applicantList[0].PropStrength__Applicant_Address__c+' Country:' + applicantList[0].PropStrength__Applicant_Acc__r.MailingCountry;
                    }
                    
                }        
            }
            
            if (applicantList.size() > 1) {
                applicant2 = applicantList[1];
                ApplicantNames = ApplicantNames + ', ' + applicantList[1].PropStrength__Applicant_Acc__r.Salutation + ' ' + applicantList[1].PropStrength__Applicant_Acc__r.Name;
                applicant2.PropStrength__Applicant_Acc__r.Permanent_Address__c = applicantList[1].PropStrength__Applicant_Acc__r.Permanent_Address__c != null ? applicantList[1].PropStrength__Applicant_Acc__r.Permanent_Address__c.replace(',', ' ') : '';
                if (applicant2.PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicantAdd2 = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[1].PropStrength__Applicant_Address__c != null) {
                        applicantAdd2 = applicantList[1].PropStrength__Applicant_Address__c +' Country:' + applicantList[1].PropStrength__Applicant_Acc__r.MailingCountry;
                    }
                }
            }        
            
            if (applicantList.size() > 2) {
                applicant3 = applicantList[2];
                ApplicantNames = ApplicantNames + ', ' + applicantList[2].PropStrength__Applicant_Acc__r.Salutation + ' ' + applicantList[2].PropStrength__Applicant_Acc__r.Name;
                applicant3.PropStrength__Applicant_Acc__r.Permanent_Address__c = applicantList[2].PropStrength__Applicant_Acc__r.Permanent_Address__c != null ? applicantList[2].PropStrength__Applicant_Acc__r.Permanent_Address__c.replace(',', ' ') : '';
                if (applicant3.PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicantAdd3 = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[2].PropStrength__Applicant_Address__c != null) {
                        applicantAdd3 = applicantList[2].PropStrength__Applicant_Address__c+' Country:' + applicantList[2].PropStrength__Applicant_Acc__r.MailingCountry;
                    }
                }
            }       
            
            if (applicantList.size() > 3) {
                applicant4 = applicantList[3];
                ApplicantNames = ApplicantNames + ', ' + applicantList[3].PropStrength__Applicant_Acc__r.Salutation + ' ' + applicantList[3].PropStrength__Applicant_Acc__r.Name;
                applicant4.PropStrength__Applicant_Acc__r.Permanent_Address__c = applicantList[3].PropStrength__Applicant_Acc__r.Permanent_Address__c != null ? applicantList[3].PropStrength__Applicant_Acc__r.Permanent_Address__c.replace(',', ' ') : '';
                if (applicant4.PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicantAdd4 = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[3].PropStrength__Applicant_Address__c != null) {
                        applicantAdd4 = applicantList[3].PropStrength__Applicant_Address__c+' Country:' + applicantList[3].PropStrength__Applicant_Acc__r.MailingCountry;
                    }
                }   
            }
            
            if (applicantList.size() > 4) {
                applicant5 = applicantList[4]; 
                ApplicantNames = ApplicantNames + ', ' + applicantList[4].PropStrength__Applicant_Acc__r.Salutation + ' ' + applicantList[4].PropStrength__Applicant_Acc__r.Name;
                applicant5.PropStrength__Applicant_Acc__r.Permanent_Address__c = applicantList[4].PropStrength__Applicant_Acc__r.Permanent_Address__c != null ? applicantList[4].PropStrength__Applicant_Acc__r.Permanent_Address__c.replace(',', ' ') : '';
                if (applicant5.PropStrength__Applicant_Acc__r.Mailing_Address_same_as_PermanentAddress__c == true) {
                    applicantAdd5 = 'Correspondence address same as permanent address';
                } else {
                    if (applicantList[4].PropStrength__Applicant_Address__c != null) {
                        applicantAdd5 = applicantList[4].PropStrength__Applicant_Address__c+' Country:' + applicantList[4].PropStrength__Applicant_Acc__r.MailingCountry;
                    }
                }
            }
        }
    }
    
    public PageReference saveArray() {
        err = '';
        checklistHeader.Name = 'ChecklistHeader';
        checklistHeader.Application_Booking__c = BookingId;
        insert checklistHeader;
        
        System.debug('ArrayApplicant1String****');
        System.debug(ArrayApplicant1String);
        System.debug(ArrayApplicant2String);
        System.debug(ArrayApplicant3String);
        System.debug(ArrayApplicant4String);
        System.debug(ArrayApplicant5String);
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

        System.debug('ArrayApplicant1****');
        System.debug(ArrayApplicant1);
        System.debug(ArrayApplicant2);
        System.debug(ArrayApplicant3);
        System.debug(ArrayApplicant4);
        System.debug(ArrayApplicant5);
        
        if (ArrayApplicant1.size() > 0) {     
            System.debug('ArrayApplicant1 size****');
            System.debug(ArrayApplicant1.size());    
            for (i = 0; i < ArrayApplicant1.size(); i = i + 6) {
                if ((i + 4) < ArrayApplicant1.size() && ArrayApplicant1[i + 4] == 'false') {
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
        
        if (ArrayApplicant2.size() > 0) {
            for (i = 0; i < ArrayApplicant2.size(); i = i + 6) {
                if ((i + 4) < ArrayApplicant2.size() && ArrayApplicant2[i + 4] == 'false') {
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
        
        if (ArrayApplicant3.size() > 0) {
            for (i = 0; i < ArrayApplicant3.size(); i = i + 6) {
                if ((i + 4) < ArrayApplicant3.size() && ArrayApplicant3[i + 4] == 'false') {     
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
        
        if (ArrayApplicant4.size() > 0) {
            for (i = 0; i < ArrayApplicant4.size(); i = i + 6) {
                if ((i + 4) < ArrayApplicant4.size() && ArrayApplicant4[i + 4] == 'false') {
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
        
        if (ArrayApplicant5.size() > 0) {
            for (i = 0; i < ArrayApplicant5.size(); i = i + 6) {
                if ((i + 4) < ArrayApplicant5.size() && ArrayApplicant5[i + 4] == 'false') {    
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
        return new pagereference('/lightning/n/Docs_Verification_PS');
    }
    
    public void btnReject() {
        if(lstBooking[0].CreatedById != null) {
            list <User> LstUsers = [select id, name, email from user where id = :lstBooking[0].CreatedById];
            
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
            
            System.debug('lststringtoaddress' + lststringtoaddress);
            mail.setToAddresses(lststringtoaddress);
            mail.setSubject(subjectMail);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
        }
        
        if (ApexPages.currentPage().getParameters().get('bookingid') != null && ApexPages.currentPage().getParameters().get('bookingid') != '')
            BookingId = ApexPages.currentPage().getParameters().get('bookingid');
        if (BookingId != null && BookingId != '') {
            PropStrength__Application_Booking__c updateBooking = new PropStrength__Application_Booking__c();
            updateBooking.id = Id.ValueOf(BookingId);
            updateBooking.Document_Checklist_Header__c = checklistHeader.id;
            updateBooking.Verification_status__c = 'Rejected';
            updateBooking.PropStrength__Status__c = 'UnProcessed';
            updateBooking.Document_Verification_Remarks__c = 'Document Verification Rejected';                   
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
                    //DocRow4.Details__c = 'Contact: ' + lstBooking[0].Future_Correspondence_Contact__c + ', Relation: ' + lstBooking[0].Future_Correspondence_Contact_Relation__c + ', Name: ' + lstBooking[0].Future_Correspondence_Contact_Name__c + ', Contact Mobile: ' + lstBooking[0].Future_Correspondence_Contact_Phone__c + ', Contact Email: ' + lstBooking[0].Future_Correspondence_Contact_Email__c;
                    DocRow4.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow4.Rejection_Remarks__c = drow4;
                    lstDocumentChecklistApplicant.add(DocRow4);
                }
                if (d5 == False) {
                    DocRow5.Name = 'N/A';
                    DocRow5.Details__c = 'Tower: ' + lstBooking[0].PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c + ', Sub Project: ' + lstBooking[0].PropStrength__Project__r.Name + ', Flat Typology: ' + lstBooking[0].PropStrength__Property__r.PropStrength__Unit_Type__c + ', Floor: ' + lstBooking[0].PropStrength__Property__r.PropStrength__Floor_Number__c + ', Unit No: ' + lstBooking[0].PropStrength__Property__r.PropStrength__House_Unit_No__c + ', Saleable Area: ' + lstBooking[0].PropStrength__Property__r.PropStrength__Chargeable_Area__c + ', Alloted Parking: ' + lstBooking[0].No_of_Earmarked_Parking__c + ', Purchase price: ' + alotment;
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
                        //DocRow6.Details__c = 'Amount: ' + lstReceiptToken[0].Cheque_DD_Amount_Rs__c + ', Cheque No.: ' + instrumentno + ', Cheque Date: ' + lstReceiptToken[0].Cheque_DD_Date__c.format() + ', Bank Name: ' + lstReceiptToken[0].DraweeBank__c; 
                    }
                    DocRow6.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow6.Rejection_Remarks__c = drow6;
                    lstDocumentChecklistApplicant.add(DocRow6);
                }
                
                if (d8 == False) {
                    DocRow8.Name = 'N/A';
                    DocRow8.Document_Checklist_Header__c = checklistHeader.id;
                    DocRow8.Rejection_Remarks__c = drow8;
                    //DocRow8.Details__c = 'Source Of Booking: ' + lstBooking[0].Source_of_Booking__c + ', Sub Source of Booking: ' + subsource;  
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
            List < PropStrength__Application_Booking__c > lstBooking = [Select Id, Name, Sales_Manager__c, PropStrength__Offer__r.PropStrength__Broker_Account__r.Salutation, 
                                                                        CreatedById, PropStrength__Property__r.Name, Project_Name__c, PropStrength__Offer__r.Name, LastModifiedDate, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Property__c, PropStrength__Property__c,
                                                                        Verification_status__c FROM PropStrength__Application_Booking__c Where Id = :BookingId];
            if (lstBooking != null && lstBooking.size() > 0) {
                PropStrength__Application_Booking__c updateAcceptBooking = new PropStrength__Application_Booking__c();
                updateAcceptBooking.id = lstBooking[0].Id;
                updateAcceptBooking.Verification_status__c = 'Accepted';
                updateAcceptBooking.Document_Verification_Remarks__c = 'Document Verification Accepted';
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