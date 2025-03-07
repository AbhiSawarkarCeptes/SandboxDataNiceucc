public class SOAController {
    public PropStrength__Application_Booking__c bookingRecord {get;set;}
    public List<paymentWrapper> paymentAWrapperList {get;set;}
    public List<paymentWrapper> paymentBWrapperList {get;set;}
    public List<incomeChargeDueWrapper> incomeChargeDueWrapperList {get;set;}
    public List<paymentReceivedIncomeChargeReceiveWrapper> paymentReceivedIncomeChargeReceiveWrapperList {get;set;}
    public Decimal totalPercentageA {get;set;}
    public Decimal totalAmountA {get;set;}
    public Decimal totalVATA {get;set;}
    public Decimal totalAmountPlusVATA {get;set;}
    public Decimal totalPaidA {get;set;}
    public Decimal totalBalanceA {get;set;}
    public Decimal totalPercentageB {get;set;}
    public Decimal totalAmountB {get;set;}
    public Decimal totalVATB {get;set;}
    public Decimal totalAmountPlusVATB {get;set;}
    public Decimal totalPaidB {get;set;}
    public Decimal totalBalanceB {get;set;}
    public Decimal totalPercentage {get;set;}
    public Decimal totalAmount {get;set;}
    public Decimal totalVAT {get;set;}
    public Decimal totalAmountPlusVAT {get;set;}
    public Decimal totalPaid {get;set;}
    public Decimal totalBalance {get;set;}
    public Decimal totalChargeAmountWithVAT {get;set;}
    public Decimal installmentAdjustmentTowardsOtherCharges {get;set;}
    public Decimal totalWaivedAmount {get;set;}
    public Decimal totalPaidAmount {get;set;}
    public Decimal totalBalanceAmount {get;set;}
    public Decimal totalInstallmentAmount {get;set;}
    public Decimal totalAdditionalChargesAmount {get;set;}
    public Decimal totalIncRecPayRecAmount {get;set;}
    public Boolean showError {get;set;}
    public String bookId;

    public SOAController() {
        bookId = ApexPages.currentPage().getParameters().get('id');
        paymentAWrapperList = new List<paymentWrapper>();
        paymentBWrapperList = new List<paymentWrapper>();
        incomeChargeDueWrapperList = new List<incomeChargeDueWrapper>();
        paymentReceivedIncomeChargeReceiveWrapperList = new List<paymentReceivedIncomeChargeReceiveWrapper>();
        totalPercentage = 0.00;
        totalAmount = 0.00;
        totalVAT = 0.00;
        totalAmountPlusVAT = 0.00;
        totalPaid = 0.00;
        totalBalance = 0.00;
        totalPercentageA = 0.00;
        installmentAdjustmentTowardsOtherCharges = 0.00;
        totalAmountA = 0.00;
        totalVATA = 0.00;
        totalAmountPlusVATA = 0.00;
        totalPaidA = 0.00;
        totalBalanceA = 0.00;
        totalPercentageB = 0.00;
        totalAmountB = 0.00;
        totalVATB = 0.00;
        totalAmountPlusVATB = 0.00;
        totalPaidB = 0.00;
        totalBalanceB = 0.00;
        totalChargeAmountWithVAT = 0.00;
        totalWaivedAmount = 0.00;
        totalPaidAmount = 0.00;
        totalBalanceAmount = 0.00;
        totalInstallmentAmount = 0.00;
        totalAdditionalChargesAmount = 0.00;
        totalIncRecPayRecAmount = 0.00;
        if(bookId != null && bookId != '') {
            showError = false;
            bookingRecord = [SELECT Id, PropStrength__Property__r.PropStrength__Unit_Status__c, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.Name, Project_Name__c, PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Customer__r.Phone, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Primary_Customer__r.MailingState, PropStrength__Primary_Customer__r.MailingCountry, PropStrength__Primary_Customer__r.MailingPostalCode,
                            PropStrength__Tower__c, PropStrength__Property_Name__c, PropStrength__Property_Type_Code__c, PropStrength__Super_Area__c, PropStrength__Revised_Total_Sales_Consideration__c, 
                            (SELECT Id, PropStrength__Milestone__r.PropStrength__Milestone_Name__c, 
                             PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c, PropStrength__Milestone_Name__c, 
                             PropStrength__Amount_Percent__c, PropStrength__Payment_Due_Date__c, PropStrength__Is_Milestone_Completed__c, 
                             PropStrength__Approval_Status__c, PropStrength__Amount_Due__c, PropStrength__Total_Other_Charges_Dues__c, 
                             PropStrength__Service_Tax_Due_on_BSP__c, PropStrength__Service_Tax_on_Other_Charges__c, PropStrength__Amount_Paid__c, 
                             PropStrength__Balance__c FROM PropStrength__Payment_Plan_Details__r ORDER BY PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c), 
                            (SELECT Id, PropStrength__Receipt_Reversed__c, PropStrength__Description__c, PropStrength__Prorated_Payment_Received__c,
                             PropStrength__Waiver_Amount__c, Receipt_Number__c, RecordType.Name, PropStrength__Payment_Type__c, PropStrength__Amount_Due_Type__c,
                             PropStrength__Payment_Date__c, PropStrength__Amount__c, PropStrength__VAT_Amount__c, PropStrength__Balance__c 
                             FROM PropStrength__Payments_Cheques__r WHERE PropStrength__Amount_Due_Type__c != 'Adjustment' ORDER BY PropStrength__Payment_Date__c), 
                            (SELECT Id, PropStrength__Waiver_Components_Name_Wise__c, CreatedDate, PropStrength__Credit_Waiver_Amount__c 
                             FROM PropStrength__Transaction_Request__r WHERE RecordType.Name = 'Credit Waiver' AND 
                             PropStrength__Status__c = 'Request Completed') 
                            FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
            if(bookingRecord != null) {
                if(!bookingRecord.PropStrength__Payment_Plan_Details__r.isEmpty()) {
                    Integer count = 1;
                    for(PropStrength__Payment_Plan_Details__c ppd: bookingRecord.PropStrength__Payment_Plan_Details__r) {
                        Decimal tempPerc = ppd.PropStrength__Amount_Percent__c != null && ppd.PropStrength__Amount_Percent__c > 0 ? ppd.PropStrength__Amount_Percent__c : 0.00;
                        Decimal tempPaid = ppd.PropStrength__Amount_Paid__c != null && ppd.PropStrength__Amount_Paid__c > 0 ? ppd.PropStrength__Amount_Paid__c : 0.00;
                        Decimal tempBal = ppd.PropStrength__Balance__c != null && ppd.PropStrength__Balance__c > 0 ? ppd.PropStrength__Balance__c : 0.00;
                        Decimal tempAmt = 0.00;
                        if(ppd.PropStrength__Total_Other_Charges_Dues__c != null && ppd.PropStrength__Total_Other_Charges_Dues__c > 0 && ppd.PropStrength__Amount_Due__c != null && ppd.PropStrength__Amount_Due__c > 0) {
                            tempAmt = ppd.PropStrength__Amount_Due__c + ppd.PropStrength__Total_Other_Charges_Dues__c;
                        } else if((ppd.PropStrength__Total_Other_Charges_Dues__c == null || ppd.PropStrength__Total_Other_Charges_Dues__c <= 0) && ppd.PropStrength__Amount_Due__c != null && ppd.PropStrength__Amount_Due__c > 0) {
                            tempAmt = ppd.PropStrength__Amount_Due__c;
                        } else if(ppd.PropStrength__Total_Other_Charges_Dues__c != null && ppd.PropStrength__Total_Other_Charges_Dues__c > 0 && (ppd.PropStrength__Amount_Due__c == null || ppd.PropStrength__Amount_Due__c <= 0)) {
                            tempAmt = + ppd.PropStrength__Total_Other_Charges_Dues__c;
                        }

                        Decimal tempVat = 0.00;
                        if(ppd.PropStrength__Service_Tax_on_Other_Charges__c != null && ppd.PropStrength__Service_Tax_on_Other_Charges__c > 0 && ppd.PropStrength__Service_Tax_Due_on_BSP__c != null && ppd.PropStrength__Service_Tax_Due_on_BSP__c > 0) {
                            tempVat = ppd.PropStrength__Service_Tax_on_Other_Charges__c+ppd.PropStrength__Service_Tax_Due_on_BSP__c;
                        } else if(ppd.PropStrength__Service_Tax_Due_on_BSP__c != null && ppd.PropStrength__Service_Tax_Due_on_BSP__c > 0 && (ppd.PropStrength__Service_Tax_on_Other_Charges__c == null || ppd.PropStrength__Service_Tax_on_Other_Charges__c <= 0)) {
                            tempVat = ppd.PropStrength__Service_Tax_Due_on_BSP__c;
                        } else if((ppd.PropStrength__Service_Tax_Due_on_BSP__c == null || ppd.PropStrength__Service_Tax_Due_on_BSP__c <= 0) && ppd.PropStrength__Service_Tax_on_Other_Charges__c != null && ppd.PropStrength__Service_Tax_on_Other_Charges__c > 0) {
                            tempVat = ppd.PropStrength__Service_Tax_on_Other_Charges__c;
                        }
                        if(ppd.PropStrength__Payment_Due_Date__c <= System.today()) {
                        //if(ppd.PropStrength__Approval_Status__c == 'Approved' && ppd.PropStrength__Is_Milestone_Completed__c) {
                            //paymentAWrapperList.add(new paymentWrapper(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c, ppd.PropStrength__Milestone_Name__c, tempPerc, ppd.PropStrength__Payment_Due_Date__c, tempAmt, tempVat, tempAmt+tempVat, tempPaid, tempBal));
                            paymentAWrapperList.add(new paymentWrapper(count++, ppd.PropStrength__Milestone__r.PropStrength__Milestone_Name__c, tempPerc, ppd.PropStrength__Payment_Due_Date__c, tempAmt, tempVat, tempAmt+tempVat, tempPaid, tempBal));
                            totalPercentageA += tempPerc;
                            totalAmountA += tempAmt;
                            totalVATA += tempVat;
                            totalAmountPlusVATA = totalAmountPlusVATA + tempAmt + tempVat;
                            totalPaidA += tempPaid;
                            totalBalanceA += tempBal;
                        } else {
                            //paymentBWrapperList.add(new paymentWrapper(ppd.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c, ppd.PropStrength__Milestone_Name__c, tempPerc, ppd.PropStrength__Payment_Due_Date__c, tempAmt, tempVat, tempAmt+tempVat, tempPaid, tempBal));
                            paymentBWrapperList.add(new paymentWrapper(count++, ppd.PropStrength__Milestone__r.PropStrength__Milestone_Name__c, tempPerc, ppd.PropStrength__Payment_Due_Date__c, tempAmt, tempVat, tempAmt+tempVat, tempPaid, tempBal));
                            totalPercentageB += tempPerc;
                            totalAmountB += tempAmt;
                            totalVATB += tempVat;
                            totalAmountPlusVATB = totalAmountPlusVATB + tempAmt + tempVat;
                            totalPaidB += tempPaid;
                            totalBalanceB += tempBal;
                        }

                        totalPercentage = totalPercentageA + totalPercentageB;
                        totalAmount = totalAmountA + totalAmountB;
                        totalVAT = totalVATA + totalVATB;
                        totalAmountPlusVAT = totalAmountPlusVATA + totalAmountPlusVATB;
                        totalPaid = totalPaidA + totalPaidB;
                        totalBalance = totalBalanceA + totalBalanceB;
                    }
                }
                Map<String, paymentReceivedIncomeChargeReceiveWrapper> paymentReceivedIncomeChargeReceiveWrapperMap = new Map<String, paymentReceivedIncomeChargeReceiveWrapper>();
                if(!bookingRecord.PropStrength__Payments_Cheques__r.isEmpty()) {
                    for(PropStrength__Received_Payment__c incDue : bookingRecord.PropStrength__Payments_Cheques__r) {
                        if(incDue.RecordType.Name == 'Income Charge Due') {
                            String amtType = '';
                            if(incDue.PropStrength__Amount_Due_Type__c != null) {
                                amtType = incDue.PropStrength__Amount_Due_Type__c;
                            }

                            Decimal amt = 0.00;
                            if(incDue.PropStrength__Amount__c != null) {
                                amt = incDue.PropStrength__Amount__c;
                            }

                            Decimal bal=0.00;
                            if(incDue.PropStrength__Balance__c != null) {
                                bal = incDue.PropStrength__Balance__c;
                            }

                            Decimal paid=0.00;
                            if(incDue.PropStrength__Prorated_Payment_Received__c != null) {
                                paid = incDue.PropStrength__Prorated_Payment_Received__c;
                            }
                            Decimal waiver=0.00;
                            if(incDue.PropStrength__Waiver_Amount__c != null) {
                                waiver = (incDue.PropStrength__Waiver_Amount__c * -1);
                            }

                            incomeChargeDueWrapperList.add(new incomeChargeDueWrapper(amtType, incDue.PropStrength__Payment_Date__c, amt, paid,waiver, bal));
                            totalChargeAmountWithVAT += amt;
                            totalWaivedAmount += waiver;
                            totalPaidAmount += paid;
                            totalBalanceAmount += bal;
                            
                        } else if(incDue.RecordType.Name == 'Payment Received' && !incDue.PropStrength__Receipt_Reversed__c) {
                            String recNumber = '';
                            String amtType = '';
                            String payMode = '';
                            Decimal inst = 0.00;
                            Decimal ac = null;
                            Decimal totInc = 0.00;

                            if(incDue.Receipt_Number__c != null) {
                                recNumber = incDue.Receipt_Number__c;
                            }
                            if(incDue.PropStrength__Amount_Due_Type__c != null) {
                                amtType = incDue.PropStrength__Amount_Due_Type__c;
                            }
                            if(incDue.PropStrength__Payment_Type__c != null) {
                                payMode = incDue.PropStrength__Payment_Type__c;
                            } 
                            if(incDue.PropStrength__Amount__c != null) {
                                inst = incDue.PropStrength__Amount__c;
                                totInc = incDue.PropStrength__Amount__c;
                            }

                            if(!paymentReceivedIncomeChargeReceiveWrapperMap.containsKey(amtType)) {
                                paymentReceivedIncomeChargeReceiveWrapperMap.put(amtType, new paymentReceivedIncomeChargeReceiveWrapper(recNumber, amtType, payMode, incDue.PropStrength__Payment_Date__c, inst, ac, totInc));
                            } else {
                                Decimal intChrge = (paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).installment != null ? paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).installment : 0) + inst;
                                Decimal totalCharge = (paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).totalIncRecPayRec != null ? paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).totalIncRecPayRec : 0) + totInc;
                                paymentReceivedIncomeChargeReceiveWrapperMap.put(amtType, new paymentReceivedIncomeChargeReceiveWrapper(recNumber, amtType, payMode, incDue.PropStrength__Payment_Date__c, intChrge, ac, totalCharge));
                            }
                            totalInstallmentAmount += inst;
                            totalIncRecPayRecAmount += totInc;
                        } else if(incDue.RecordType.Name == 'Income Charge Received' && !incDue.PropStrength__Receipt_Reversed__c) {
                            String recNumber = '';
                            String amtType = '';
                            String payMode = '';
                            Decimal inst = null;
                            Decimal ac = 0.00;
                            Decimal totInc = 0.00;

                            if(incDue.Receipt_Number__c != null) {
                                recNumber = incDue.Receipt_Number__c;
                            }
                            if(incDue.PropStrength__Amount_Due_Type__c != null) {
                                amtType = incDue.PropStrength__Amount_Due_Type__c;
                            }
                            if(incDue.PropStrength__Payment_Type__c != null) {
                                payMode = incDue.PropStrength__Payment_Type__c;
                            } 
                            if(incDue.PropStrength__Amount__c != null) {
                                ac = incDue.PropStrength__Amount__c;
                                totInc = incDue.PropStrength__Amount__c;
                            }

                            if(!paymentReceivedIncomeChargeReceiveWrapperMap.containsKey(amtType)) {
                                paymentReceivedIncomeChargeReceiveWrapperMap.put(amtType, new paymentReceivedIncomeChargeReceiveWrapper(recNumber, amtType, payMode, incDue.PropStrength__Payment_Date__c, inst, ac, totInc));
                            } else {
                                Decimal addCharge = (paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).additionalCharges != null ? paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).additionalCharges : 0) + ac;
                                Decimal totalCharge = (paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).totalIncRecPayRec != null ? paymentReceivedIncomeChargeReceiveWrapperMap.get(amtType).totalIncRecPayRec : 0) + totInc;
                                paymentReceivedIncomeChargeReceiveWrapperMap.put(amtType, new paymentReceivedIncomeChargeReceiveWrapper(recNumber, amtType, payMode, incDue.PropStrength__Payment_Date__c, inst, addCharge, totalCharge));
                            }
                            
                            totalAdditionalChargesAmount += ac;
                            totalIncRecPayRecAmount += totInc;
                        }
                    }
                    if(totalBalanceAmount > 0 && totalInstallmentAmount > totalPaid){
                        installmentAdjustmentTowardsOtherCharges = totalInstallmentAmount - totalPaid;
                        totalBalanceAmount = totalBalanceAmount - installmentAdjustmentTowardsOtherCharges >= 0 ? (totalBalanceAmount - installmentAdjustmentTowardsOtherCharges) : 0;
                        incomeChargeDueWrapperList.add(new incomeChargeDueWrapper('Excess Installment', null, 0, installmentAdjustmentTowardsOtherCharges,0, totalBalanceAmount));
                    }
                }
                List<paymentReceivedIncomeChargeReceiveWrapper> tempList = new List<paymentReceivedIncomeChargeReceiveWrapper>();

                if(!bookingRecord.PropStrength__Transaction_Request__r.isEmpty()) {
                    for(PropStrength__Transaction_Requests__c trRec : bookingRecord.PropStrength__Transaction_Request__r) {
                        String recNumber = '';
                        String amtType = '';
                        String payMode = 'Credit Waiver';
                        Decimal inst = null;
                        Decimal ac = 0.00;
                        Decimal totInc = 0.00;

                        if(trRec.PropStrength__Waiver_Components_Name_Wise__c != null) {
                            amtType = trRec.PropStrength__Waiver_Components_Name_Wise__c;
                        }
                        if(trRec.PropStrength__Credit_Waiver_Amount__c != null) {
                            ac = trRec.PropStrength__Credit_Waiver_Amount__c;
                            totInc = trRec.PropStrength__Credit_Waiver_Amount__c;
                        }

                        paymentReceivedIncomeChargeReceiveWrapperList.add(new paymentReceivedIncomeChargeReceiveWrapper(recNumber, amtType, payMode, trRec.CreatedDate.Date(), inst, ac, totInc));
                                                
                        totalAdditionalChargesAmount += ac;
                        totalIncRecPayRecAmount += totInc;
                    }
                }
                
                if(!paymentReceivedIncomeChargeReceiveWrapperMap.isEmpty()) {
                    paymentReceivedIncomeChargeReceiveWrapperList.addAll(paymentReceivedIncomeChargeReceiveWrapperMap.values());

                    paymentReceivedIncomeChargeReceiveWrapperList.sort();
                }
            }
        }
    }

    public PageReference backToRecPage() {
        if(bookId != null && bookId != '') {
            return new pageReference('/'+bookId);
        } else {
            return null;            
        }   
    }

    public pageReference saveDocFile(){
        if(bookId != null && bookId != ''){
            SavePdfAndHtmlToAttachement.doSaveReceipt(bookId, 'SOALetter');
            return new pageReference('/'+bookId);
        }    
        return null;
    }
    
    public pageReference sendMail(){
        if(bookingRecord != null) {
            List<String> emailAddress = new List<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<Attachment> att = [SELECT Id FROM Attachment WHERE Name = 'SOALetter.pdf'];
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

            List<EmailTemplate> templatelist ;
            Id TempId;
            if(bookId != null) {
                emailAddress.add(bookingRecord.PropStrength__Primary_Customer__r.Email);
                    templatelist = [SELECT id,name FROM EmailTemplate where Name = 'SOA Letter' limit 1];
                    
                    if(!templatelist.isEmpty()) {
                        TempId = templatelist[0].id;
                    }                
                String frmsrc = '/apex/SOALetter?Id=' + bookId;
                PageReference p1 = new PageReference(frmsrc);
                String aName;
                String b;
                blob content;
                aName ='SOALetter';
                Attachment a1 = new Attachment();
                a1.parentid = bookId;
                a1.name = aName + '.pdf';
                System.debug('1');
                if (Test.IsRunningTest()) {
                    a1.body = Blob.valueOf('UNIT.TEST');
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    a1.body = p1.getContentAsPDF();
                    content = p1.getContentAsPDF();
                } 
                if(att.isEmpty()) {
                    insert a1;
                }
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(aName+'.pdf');
                efa.setBody(content);
                emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                emails.setWhatId(bookId);
                if(!emailAddress.isEmpty()) {
                    emails.setToAddresses(emailAddress); 
                }
                system.debug('===========emailAddress ============'+emailAddress);
                emails.setTemplateId(TempId);
                emails.setccAddresses(new String[] {UserInfo.getUserId()});
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(bookingRecord.PropStrength__Primary_Customer__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                    }
                } catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            } 
            return new pageReference('/'+bookId); 
        } 
        return null;
    }

    public class paymentWrapper {
        public Decimal instalmentNo {get;set;}
        public String milestoneNo {get;set;}
        public Decimal chargePercentage {get;set;}
        public Date dueDate {get;set;}
        public Decimal amount {get;set;}
        public Decimal vat {get;set;}
        public Decimal total {get;set;}
        public Decimal paid {get;set;}
        public Decimal balance {get;set;}

        public paymentWrapper(Decimal iNo, String mNo, Decimal chargePerc, Date dd, Decimal amt, Decimal v, Decimal t, Decimal p, Decimal b) {
            instalmentNo = iNo;
            milestoneNo = mNo;
            chargePercentage = chargePerc;
            dueDate = dd;
            amount = amt;
            vat = v;
            total = t;
            paid = p;
            balance = b;
        }
    }

    public class incomeChargeDueWrapper {
        public String description {get;set;}
        public Date demandDate {get;set;}
        public Decimal chargedAmtWithVAT {get;set;}
        public Decimal paid {get;set;}
        public Decimal waivedAmount {get;set;}
        public Decimal balance {get;set;}

        public incomeChargeDueWrapper(String descr, Date demDate, Decimal chargeAmt, Decimal p, Decimal waived, Decimal bal) {
            description = descr;
            demandDate = demDate;
            chargedAmtWithVAT = chargeAmt;
            paid = p;
            waivedAmount = waived;
            balance = bal;
        }
    }

    public class paymentReceivedIncomeChargeReceiveWrapper implements Comparable {
        public String receiptNo {get;set;}
        public String description {get;set;}
        public String paymentMethod {get;set;}
        public Date incRecPayRecDate {get;set;}
        public Decimal installment {get;set;}
        public Decimal additionalCharges {get;set;}
        public Decimal totalIncRecPayRec {get;set;}

        public paymentReceivedIncomeChargeReceiveWrapper(String recNo, String descr, String payMethod, Date incPayDate, Decimal inst, Decimal ac, Decimal totAmt) {
            receiptNo = recNo;
            description = descr;
            paymentMethod = payMethod;
            incRecPayRecDate = incPayDate;
            installment = inst;
            additionalCharges = ac;
            totalIncRecPayRec = totAmt;
        }

        public Integer compareTo(Object compareTo) {
            paymentReceivedIncomeChargeReceiveWrapper other = (paymentReceivedIncomeChargeReceiveWrapper) compareTo;
            if (this.incRecPayRecDate == other.incRecPayRecDate) {
                return 0;
            }
            return this.incRecPayRecDate > other.incRecPayRecDate ? 1 : -1;
        }
    }
}