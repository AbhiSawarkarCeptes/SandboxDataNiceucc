public class QuotationOnOfferController {
    public String msges {get;set;}
    public String frameSrc {get;set;}
    public String offerId {get;set;}
    public Bank_GL__c bankDetails {get;set;}
    public PropStrength__Offer__c offer {get;set;}
    public String projectLogoId {get;set;}
    public List<ppdWrapper> ppdList {get;set;}
    private Set<Id> unitPlanId;
    private Set<Id> floorPlanId;
    public Decimal purchasePrice {get;set;}
    public Decimal registrationPrice {get;set;}
    public List<String> imageUnitPlan {get;set;}
    public List<String> imageFloorPlan {get;set;}

    public QuotationOnOfferController() {
        imageUnitPlan = new List<String>();
        imageFloorPlan = new List<String>();
        offerId = ApexPages.currentPage().getParameters().get('id'); 
        if(offerId != null && offerId != '') {
            offer = [SELECT Id, PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Primary_Contact__r.Name, PropStrength__Property__r.PropStrength__Category__c, PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Floor__c, PropStrength__Property__r.PropStrength__Floor__r.PropStrength__Floor_Number__c, PropStrength__Property__r.PropStrength__Rate_per_unit_area__c,PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c, PropStrength__Project__r.Name,PropStrength__Offer_Close_Date__c, PropStrength__Property__r.PropStrength__Floor_Number__c, PropStrength__Property__r.PropStrength__Unit_Type__c, PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Property__r.PropStrength__Super_Area__c,
            PropStrength__Property__r.PropStrength__Property_Type_Name__c,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,PropStrength__Total_Sales_Consideration__c, PropStrength__Primary_Contact__c, PropStrength__Payment_Plan__c, PropStrength__Primary_Contact__r.Email, PropStrength__Project__c FROM PropStrength__Offer__c WHERE Id = :offerId];
            System.debug('offer.PropStrength__Project__c*---'+offer.PropStrength__Project__c);
            if(offer.PropStrength__Project__c != null) {
                List<Attachment> attList = [SELECT Id, Name FROM Attachment WHERE ParentId = :offer.PropStrength__Project__c AND (Name LIKE '%Logo%' OR Name LIKE 'Logo%' OR Name LIKE '%Logo')];
                if(!attList.isEmpty()) {
                    projectLogoId = attList[0].Id;
                }
            }


            PropStrength__Property__c prop = [SELECT Id, (SELECT Id,PropStrength__Rate_per_unit_Area__c, PropStrength__Fixed_Charge__c, PropStrength__Type__c FROM PropStrength__Property_Charges__r) FROM PropStrength__Property__c WHERE Id =:offer.PropStrength__Property__c];

            Decimal dldPercent = QuotationOnOfferController.getDlDCharge(offer.PropStrength__Property__r.PropStrength__Project_Name__c);
            
            Decimal amount = offer.PropStrength__Total_Sales_Consideration__c;
            
            for(PropStrength__Property_Charges__c ppCharge : prop.PropStrength__Property_Charges__r) {
                if(ppCharge.PropStrength__Type__c == 'Fixed') {
                    amount = amount + ppCharge.PropStrength__Fixed_Charge__c;
                }
                if(ppCharge.PropStrength__Type__c == 'Flexible') {
                    amount = amount + ppCharge.PropStrength__Rate_per_unit_Area__c * offer.PropStrength__Property__r.PropStrength__Super_Area__c;
                }
            }
            Decimal regFees = amount * dldPercent / 100;
            System.debug('====>'+ regFees);
            registrationPrice = regFees;
            purchasePrice = amount;

            bankDetails = getBankDetails(offer.PropStrength__Project__c);

            unitPlanId = new Set<Id>();
            floorPlanId = new Set<Id>();

            Decimal floorNumber = offer.PropStrength__Property__r.PropStrength__Floor__c != null ? offer.PropStrength__Property__r.PropStrength__Floor__r.PropStrength__Floor_Number__c : 0;

            unitPlanId = getUnitPlan(offer.PropStrength__Property__r.PropStrength__Tower__c, offer.PropStrength__Property__r.PropStrength__Unit_Type__c);
            floorPlanId = getFloorPlan(offer.PropStrength__Property__r.PropStrength__Tower__c, floorNumber, offer.PropStrength__Property__r.PropStrength__Unit_Type__c);
            System.debug('=======Test 1'+ unitPlanId);
            System.debug('=======Test 2'+ floorPlanId);

            if(!unitPlanId.isEmpty() || !floorPlanId.isEmpty()) {
                Map<String, String> mapOFFileandLink = new Map<String,String>();
                List<ContentDocumentLink> fileContentDocumentList = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                                    FROM ContentDocumentLink WHERE  (LinkedEntityId In :unitPlanId OR LinkedEntityId IN : floorPlanId)];
                for(ContentDocumentLink contentLink : fileContentDocumentList){
                    mapOFFileandLink.put(contentLink.ContentDocumentId , contentLink.LinkedEntityId);
                }
                System.debug(unitPlanId+'--mapOFFileandLink**-'+floorPlanId);
                System.debug('mapOFFileandLink**-'+mapOFFileandLink);

                List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId from ContentVersion where ContentDocumentId IN: mapOFFileandLink.keySet()];
                for(ContentVersion contRec : contentVersionList){
                    String headerUrl = '';
                    if(unitPlanId.contains(mapOFFileandLink.get(contRec.ContentDocumentId)) ){
                        headerUrl ='/sfc/servlet.shepherd/version/download/';
                        headerUrl += contRec.id;
                        imageUnitPlan.add(headerUrl);
                        
                    }
                    if(floorPlanId.contains(mapOFFileandLink.get(contRec.ContentDocumentId) )) {
                        headerUrl = '/sfc/servlet.shepherd/version/download/';
                        headerUrl += contRec.id;
                        imageFloorPlan.add(headerUrl);
                    }
                }
                SYstem.debug(imageFloorPlan+'--headerUrl**'+imageUnitPlan);
            }
            frameSrc = '/apex/QuotationPageHTML?id=' + offerId;
			System.debug('test---');
            if(offer.PropStrength__Payment_Plan__c != null) {
                ppdList = new List<ppdWrapper>();
                PropStrength__Payment_Plan__c pp = [SELECT Id, (SELECT Id, PropStrength__Order__c, PropStrength__Amount_Percent__c, PropStrength__Actual_Completed_Date__c, PropStrength__Milestone__r.PropStrength__Milestone_Name__c,PropStrength__Amount__c,PropStrength__Due_After_Days__c 
                                                                FROM PropStrength__Payment_Plan_Line_Items1__r ORDER BY PropStrength__Order__c) 
                                                    FROM PropStrength__Payment_Plan__c WHERE Id = :offer.PropStrength__Payment_Plan__c];
                if(!pp.PropStrength__Payment_Plan_Line_Items1__r.isEmpty()) {
                    Integer st = 0;
                    for(PropStrength__Payment_Plan_Line_Items__c pli : pp.PropStrength__Payment_Plan_Line_Items1__r) {
                        String ins = '';
                        String pd = '';
                        Decimal am = 0;
                        if(pli.PropStrength__Order__c == 1) {
                            //ins = pli.PropStrength__Order__c + 'st Installment';
                            ins = 'Booking Amount';
                            pd = 'On Booking';
                        } else if(pp.PropStrength__Payment_Plan_Line_Items1__r.size()-1 == st){
                            ins = 'Final Installment';
                        } else if(pli.PropStrength__Order__c > 1 && pli.PropStrength__Order__c < pp.PropStrength__Payment_Plan_Line_Items1__r.size()) {
                            ins = callPrintNumber(Integer.valueOf(pli.PropStrength__Order__c)-1) + ' Installment';
                        }
						System.debug('tets**---2');
                        if(offer.PropStrength__Offer_Close_Date__c != null) {
                            pd = offer.PropStrength__Offer_Close_Date__c.format();
                            if(pli.PropStrength__Due_After_Days__c != null)
                                pd = offer.PropStrength__Offer_Close_Date__c.addDays(Integer.valueof(pli.PropStrength__Due_After_Days__c)).format();
                        } else{
                            pd = '-';
                        }
						System.debug('*----'+pli.Id);
                        if(pli.PropStrength__Amount_Percent__c != null && offer.PropStrength__Total_Sales_Consideration__c != null)
                        	am = (offer.PropStrength__Total_Sales_Consideration__c * pli.PropStrength__Amount_Percent__c) / 100;
                        if(pli.PropStrength__Amount_Percent__c == null){
                            am = pli.PropStrength__Amount__c;
                        }
                        if(st == 0) {
                            ppdList.add(new ppdWrapper(ins, pli.PropStrength__Amount_Percent__c, am, 'On Booking', pli.PropStrength__Milestone__r.PropStrength__Milestone_Name__c));
                        } else {
                            ppdList.add(new ppdWrapper(ins, pli.PropStrength__Amount_Percent__c, am, '-', pli.PropStrength__Milestone__r.PropStrength__Milestone_Name__c));
                        }
                        // ppdList.add(new ppdWrapper(ins, pli.PropStrength__Amount_Percent__c, am, pd, pli.PropStrength__Milestone__r.PropStrength__Milestone_Name__c));
                        st++;
                    }
                }
            }
        }
    }

    private static Decimal getDlDCharge(Id proj) {
        List<PropStrength__Income_Charges__c> incomeCharge = InventoryCostServicesMultiUnitClone.getIncomeChargeList(proj);
        for(PropStrength__Income_Charges__c ic : incomeCharge) {
            if(ic.PropStrength__Category__c.contains('DLD Fees')) {
                return ic.Charge__c;
            }
        }
        return 0;
    }

    private Set<Id> getUnitPlan(Id towerId, String unitType) {
        Set<Id> unitPlanId = new Set<Id>();
        for(CS_Unit_plan__c u : [SELECT Id, Tower__c , Unit_Type__c  FROM CS_Unit_plan__c WHERE Tower__c=:towerId AND Unit_Type__c =:unitType]) {
            unitPlanId.add(u.Id);
        }
        return unitPlanId;
    }
    private Set<Id> getFloorPlan(Id towerId, Decimal floorNumber, String unitType) {
        Set<Id> floorPlanId = new Set<Id>();
        for(CS_Floor_Plan__c fp : [SELECT Id, Tower__c, Plan_Floor_From__c, Plan_Floor_To__c, Unit_Type__c FROM CS_Floor_Plan__c WHERE Tower__c =: towerId AND Plan_Floor_From__c <= :floorNumber AND Plan_Floor_To__c >= :floorNumber AND Unit_Type__c =:unitType ]) {
            floorPlanId.add(fp.Id);
        }
        return floorPlanId;
    }
    
    public String callPrintNumber(Integer num) {
        String[] units = new String[]{'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};
        String[] tens = new String[]{'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
        String[] specialOrdinals = new String[]{'First', 'Second', 'Third'};

        if (num <= 19) {
            return num < 4 ? specialOrdinals[num - 1] : units[num] + 'th';
        }

        Integer unitPart = num - ((num / 10) * 10);
        Integer tenPart = num / 10;

        String result = '';

        if (tenPart < 2) {
            result = units[num];
        } else {
            result = tens[tenPart - 2];
            if (unitPart > 0) {
                result += ' ' + numberToWord(unitPart, true);
            }
        }

        return result;
    }

    private Bank_GL__c getBankDetails(Id projId) {
        List<Bank_GL__c> bglList = [SELECT Id,Bank_Account_Type__c, Account_Number__c, Beneficiary__c, IBAN__c, Swift_Code__c, Bank_Name__c, Branch__c, Project__c FROM Bank_GL__c 
                                    WHERE Project__c =:projId 
                                    AND Bank_Account_Type__c = 'Escrow Account'];
        if(bglList.isEmpty()) {
            return null;
        }
        else {
            return bglList[0];
        }
    }
    
    private static String numberToWord(Integer num, Boolean isOrdinal) {
        String[] units = new String[]{'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'};
        String[] ordinals = new String[]{'Zeroth', 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Ninth'};

        return isOrdinal ? ordinals[num] : units[num];
    }

    public pageReference saveInAttachment(){
        if(offerId != null && offerId != ''){
            String frmSrc = '/apex/QuotationPdf?id=' + offerId;
            String aName = 'Quotation';
            String nameSubstring = aName +'.pdf';
            List<Attachment> aList = new List<Attachment>();
            List<Attachment> attachList = [select id,name,body from Attachment where parentId=:offerId and (name LIKE :nameSubstring) limit 1];

            if(attachList !=Null && attachList.size() == 1) {
                for(Attachment attach : attachList) {
                    Attachment a1;
                    if((String.valueOf(attach.name)).containsIgnorecase('pdf'))
                        a1 = new Attachment(id=attach.id,name=attach.name);
                    PageReference p1 = new PageReference(frmSrc); 
                    if(!Test.isRunningTest()){
                        a1.body = p1.getContentAsPDF();
                    }else{
                        a1.body = Blob.valueof('Test');
                    }  
                    aList.add(a1); 
                }
                upsert aList; 
            } 

            if(attachList !=Null && attachList.size() == 0) {
                PageReference p1 = new PageReference(frmSrc);
                Attachment a1 = new Attachment();
                a1.parentId = offerId; 
                a1.name = aName +'.pdf';
                if(!Test.isRunningTest()){
                    a1.body = p1.getContentAsPDF();
                } else
                    a1.body = Blob.valueof('Test');
                aList.add(a1);        
                upsert aList; 
            }

            if(offerId != null && offerId != ''){
                return new pageReference('/'+offerId);
            }
        }    
        return null;
    } 
    
    public PageReference backToRecPage() {
        if(offerId != null && offerId != '') {
            return new pageReference('/'+offerId);
        } else {
            return null;            
        }   
    }

    public void sendEmailAndSaveAtt(){
        if(offerId != null) {
            set<String> emailAddress = new set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<Attachment> att = new List<Attachment>();
            List<EmailTemplate> templatelist ;
            Id TempId;
            if(offerId != null) {
                emailAddress.add(offer.PropStrength__Primary_Contact__r.Email);
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                    
                templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Quotation Template' limit 1];
                
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                String frmsrc = '/apex/QuotationPdf?id='+offerId;
                PageReference p1 = new PageReference(frmsrc);
                String aName;
                String b;
                blob content;

                aName ='Quotation';

                if (Test.IsRunningTest()) {
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    content = p1.getContentAsPDF();
                } 

                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(aName+'.pdf');
                efa.setBody(content);
                emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                emails.setWhatId(offerId);
                
                if(offer.PropStrength__Primary_Contact__c != null) {
                    emails.setToAddresses(new String[]{offer.PropStrength__Primary_Contact__r.Email}); 
                }
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emails.setTemplateId(TempId);
                emails.setccAddresses(new String[] {UserInfo.getUserEmail()});
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(offer.PropStrength__Primary_Contact__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        msges = 'Mail sent successfully...';
                        Messaging.sendEmail(emaillist);
                        saveInAttachment();
                    }
                } catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }  
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }

    public class ppdWrapper{
        public String installment {get; set;}
        public Decimal percOfPP {get; set;}
        public Decimal amount {get; set;}
        public String paymentDates {get; set;}
        public String milestone {get; set;}

        public ppdWrapper(String inst, Decimal pp, Decimal amt, String payDate, String ms) {
            installment = inst;
            percOfPP = pp;
            amount = amt;
            paymentDates = payDate;
            milestone = ms;
        }
    }
}