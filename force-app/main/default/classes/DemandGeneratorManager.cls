public without sharing class DemandGeneratorManager {

    public static List<Demand__c> createMultipleDemand(Set<String> Payment_MilestonesMap){
        System.debug('Payment_MilestonesMap -> '+Payment_MilestonesMap);
        Set<String> unitIdSet = new Set<String>();
        Set<String> towerId = new Set<String>();
        Map<String, Id> accMasterMapForTaxRate = new Map<String, Id>(); 
        Map<String, Id> accMasterMap = new Map<String, Id>();
        Map<String, Tax_Slab__c> taxslabsMap = new Map<String, Tax_Slab__c>();
        Map<String, ProjectCharges__c> projChargeMap = new Map<String,ProjectCharges__c>();
        Map<String, Tax_Slab__c> chargeTaxRate = new Map<String, Tax_Slab__c>();
        List<Demand__c> DemandListTobeInsert = new List<Demand__c>();

        String tempQuery = '';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge' + i + 'Name__c' + ',';
            tempQuery += 'Charge' + i + 'Percentage__c' + ',';
            tempQuery += 'C' + i + '_Amount__c' + ',';
            tempQuery += 'C' + i + '_SGST__c' + ',';
            tempQuery += 'C' + i + '_CGST__c' + ',';
            tempQuery += 'Charge_' + i + '_Lookup__c' + ',';
        }
        String tempQuery1 = '';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery1 += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
        }
        if (tempQuery1.length() > 0 && tempQuery1.substring(tempQuery1.length() - 1).equals(',')){
            tempQuery1 = tempQuery1.substring(0, tempQuery1.length() - 1);
        }
        String query = 'SELECT Id, Name,Invoice_Due_Date__c,Unit_No__c,Invoice_Date__c,Tower__c, Milestone_Due_Date__c, Milestone_Name__c, Milestone_Type_Text__c, Milestone_Type_edit__c,Number_Of_Days__c,Milestone_Complete_At_Booking__c,Total_Installment_USD__c, ' + 
        'Quotation__r.Opportunity__r.Primary_Email__c, Installment__c, Quotation__r.Opportunity__r.Primary_Name__c, Quotation__r.Unit__c, Quotation__r.Unit__r.Project__c,  ' +
        'Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c,' +
        'Quotation__r.Unit__r.Tower__R.Name,' +
        'Quotation__r.Booking__c, Quotation__r.Booking__r.Unit__r.Tower__r.RDS_Company_Code__c,' +
        'Quotation__r.Booking__r.Booking_Date__c,' +
        'Quotation__R.Opportunity__r.Name,' +
        'Quotation__r.Booking__r.unit__r.Tower__c,' +
        'Quotation__r.Unit__r.Customers__r.Name,' +
        'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
        'Quotation__R.Unit__r.Name, Project_Construction_Stages__c,' + tempQuery + tempQuery1 +
        ' FROM Payment_Milestones__c WHERE Id IN : Payment_MilestonesMap ';
        
        System.debug('Query -> '+query);

        List<Payment_Milestones__c> pmList  = Database.Query(query + ' ORDER BY Name ASC');         

        System.debug('createMultipleDemand  pmList -> '+pmList);
        
        for (Payment_Milestones__c pmilestone : pmList) {
            System.debug('createMultipleDemand -> '+pmilestone);
            unitIdSet.add(pmilestone.Unit_No__c);
            towerId.add(pmilestone.Quotation__r.Booking__r.unit__r.Tower__c);
        }

        System.debug('createMultipleDemand  unitIdSet -> '+unitIdSet);
        System.debug('createMultipleDemand  towerId -> '+towerId);
        
        List<Account_Master__c> am = [SELECT Id, Name, Tax_Rate__c, Type__c FROM Account_Master__c]; 
        System.debug('createMultipleDemand  Account_Master__c -> '+am);
        for(Account_Master__c a: am){
            if(a.Type__c == 'Others'){
                accMasterMap.put(a.Name, a.Id);
            }
            else if(a.Type__c == 'VAT'){
                accMasterMapForTaxRate.put(a.Tax_Rate__c, a.Id);             
            }
        }
        // Get Tax Slab;
        List<Tax_Slab__c>  tsList = [SELECT Id, Name, Tax_Name__c, Tax1_Name__c, Tax1_Percentage_on_100__c, Tax1_Percentage__c, Taxable1_Percentage__c,
                                            Tax2_Name__c, Tax2_Percentage_on_100__c, Tax2_Percentage__c, Taxable2_Percentage__c,
                                            To_Date__c, Tax_Rate__c FROM Tax_Slab__c 
                                            WHERE From_Date__c <= TODAY and (To_Date__c >= TODAY OR To_Date__c = null)];
        System.debug('createMultipleDemand  Tax_Slab__c -> '+tsList);
        if(!tsList.isEmpty()) {
            for(Tax_Slab__c ts: tsList) {
                taxslabsMap.put(ts.Tax_Rate__c, ts);
                System.debug('createMultipleDemand  ts.Tax_Rate__c -> '+ts.Tax_Rate__c);
            }
        } 
        System.debug('createMultipleDemand  taxslabsMap -> '+taxslabsMap);
        // Get unitDetails
        List<Unit__c> unitList = [SELECT Id, Name,Project__r.Name,Project__r.Id, Tower__r.Name, Tower__r.Id,Tower__r.Cluster__r.id,Tower__r.Level_1_Approver__c,  
                                    Tax_Rate_Basic__c, OC_Received__c,
                                    Tower__r.Business_Unit__c, Tower__r.Business_Unit_Code__c,
                                    Tower__r.Level_2_Approver__c, Floor__c,Carpet_Area__c, Chargeable_Area__c , Carpet_Area_in_Sq_Mts__c,
                                    Enclosed_Balcony_in_Sq_Mtrs__c, Cupboard_Area_in_Sq_Mtrs__c, Configuration__c
                                    FROM Unit__c WHERE Name IN : unitIdSet ];

        System.debug('createMultipleDemand  unitList -> '+unitList);
        List<ProjectCharges__c> projCharges = [SELECT Id, Name, Active__c,Calculatedas__c,ChargeBucket__c,Taxable__c,SGST__c,CGST__c,IGST__c,
                                                Tax_Rate__c,Agreement_Value_Percentage__c,editable__c
                                                FROM ProjectCharges__c WHERE Tower__c IN: towerId AND active__c = true ORDER BY Code_Formula__c ASC];

        System.debug('createMultipleDemand  projCharges -> '+projCharges);                                                
        for(ProjectCharges__c pc: projCharges){
            projChargeMap.put(pc.Name, pc);
        }                 
        System.debug('createMultipleDemand  projChargeMap -> '+projChargeMap);
        for(String s: projChargeMap.keySet()) {
            System.debug('createMultipleDemand  s -> '+s);
            if(taxslabsMap.containsKey(projChargeMap.get(s).tax_rate__c)) {
                chargeTaxRate.put(s, taxslabsMap.get( projChargeMap.get(s).tax_rate__c) );
            }
            System.debug('createMultipleDemand  chargeTaxRate -> '+chargeTaxRate);
            for (Unit__c unit : unitList) {
                System.debug('createMultipleDemand  unit -> '+unit);
                if(unit.OC_Received__c) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value'){
                        chargeTaxRate.put(s, taxSlabsMap.get('GST 0%'));
                    }
                } else if (unit.Tax_Rate_Basic__c != null) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value'){
                        chargeTaxRate.put(s, taxslabsMap.get(unit.Tax_Rate_Basic__c));
                    }
                }
            }
        }
        System.debug('createMultipleDemand  chargeTaxRate -> '+chargeTaxRate);
        Map<String, Tax_Slab__c> taxSlabMap = chargeTaxRate;

        for (Payment_Milestones__c pmile_Stone : pmList) {
            System.debug('createMultipleDemand  pmile_Stone -> '+pmile_Stone);
            Demand__c di = new Demand__c();
            di.Payment_Milestones__c = pmile_Stone.Id;
            di.Quotation__c = pmile_Stone.Quotation__c;
            di.Booking__c = pmile_Stone.Quotation__r.Booking__c;            
            di.Invoice_Date__c = pmile_Stone.Invoice_Date__c; 
            di.Due_Date__c = pmile_Stone.Milestone_Due_Date__c; 
            di.Milestone_Name__c = pmile_Stone.Milestone_Name__c; 
            di.Descriptions__c = pmile_Stone.Milestone_Name__c; 
            di.Unit__c = pmile_Stone.Quotation__r.Unit__c; 
            di.Project__c = pmile_Stone.Quotation__r.Unit__r.Project__c; 

            for (Integer i = 1; i <= 15; i++) {
                Decimal amountForTaxation = 0;
                Decimal sgst = 0;
                Decimal cgst = 0;
                if (pmile_Stone.getSObject('Charge_' + i + '_Lookup__r') != null && (String) pmile_Stone.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null && String.isNotBlank((String) pmile_Stone.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) && (String) pmile_Stone.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value') {

                    if ((String) pmile_Stone.get('Charge' + i + 'Name__c') != null && String.isNotBlank((String) pmile_Stone.get('Charge' + i + 'Name__c'))) {

                        di.put('Charge_' + i + '_Name__c', pmile_Stone.get('Charge' + i + 'Name__c'));

                        if (pmile_Stone.get('C' + i + '_Amount__c') != null) {
                            di.put('Charge_' + i + '_Demanded__c', math.abs(((Decimal) pmile_Stone.get('C' + i + '_Amount__c')).setscale(0,RoundingMode.HALF_UP)));
                            amountForTaxation = math.abs(((Decimal) pmile_Stone.get('C' + i + '_Amount__c')).setscale(0,RoundingMode.HALF_UP));
                        } 
                        
                        di.put('Charge_' + i + '_Lookup__c', pmile_Stone.get('Charge_' + i + '_Lookup__c'));

                        String chargeName = (String) pmile_Stone.get('Charge' + i + 'Name__c');

                        if(chargeName == 'Parking Charges'){
                            chargeName = 'Basic';
                        }
                        
                        System.debug('chargeName -> '+chargeName);
                        System.debug('taxSlabMap.get(chargeName).Taxable2_Percentage__c -> '+taxSlabMap.get(chargeName));
                        if(taxSlabMap.containsKey(chargeName) && (taxSlabMap.get(chargeName) != null)) {
                            sgst = math.abs(((amountForTaxation * taxSlabMap.get(chargeName).Taxable2_Percentage__c * taxSlabMap.get(chargeName).Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                            cgst = math.abs(((amountForTaxation * taxSlabMap.get(chargeName).Taxable1_Percentage__c * taxSlabMap.get(chargeName).Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                        }
                        di.put('Charge_' + i + '_SGST__c', sgst);
                        di.put('Charge_' + i + '_CGST__c', cgst);
                    }
                }
                    
                if(!accMasterMap.isEmpty()){            
                    for(String s: accMasterMap.keySet()){
                        if(s.equalsIgnoreCase('Trade Receivable'))
                            di.Total_Amount_with_Tax_Account__c = accMasterMap.get(s);
                        if(s.equalsIgnoreCase('Unearned Revenue'))  
                            di.Total_Amount_Account__c = accMasterMap.get(s);
                    }
                }              
                if(taxSlabMap != null){
                    if(taxSlabMap.containsKey('Basic')){
                        if(!accMasterMapForTaxRate.isEmpty()){
                            for(String s: accMasterMapForTaxRate.keySet()){
                                if(taxSlabMap.get('Basic') != null && (s.equalsIgnoreCase(taxSlabMap.get('Basic').Tax_Rate__c))){
                                    di.Total_Tax_Account__c = accMasterMapForTaxRate.get(taxSlabMap.get('Basic').Tax_Rate__c);                                    
                                }
                            } 
                        }               
                    }
                    if (taxSlabMap.get('Basic') != null) {
                        di.Tax_Rate__c = taxSlabMap.get('Basic').Tax_Rate__c;
                    }
                } 
                for (Unit__c unit : unitList) {
                    if(unit.Tower__c != null && unit.Id == pmile_Stone.Quotation__r.Unit__c){
                        di.Business_Unit__c = unit.Tower__r.Business_Unit__c;
                        di.Business_Unit_Code__c = unit.Tower__r.Business_Unit_Code__c;
                    }
                }
                di.GL_Date__c = System.Today(); // date demand is raised
                di.Payment_Towards__c = 'ESCROW Account';

            }
            DemandListTobeInsert.add(di);
        }
        insert DemandListTobeInsert;
        return DemandListTobeInsert;
    }

    public static String sendDemandToCustomer(Set<String> dId){
        try {
            
            Set<String> BookingIds = new Set<String>();
            List <Demand__c> diList = [SELECT Id, Name, Invoice_Date__c,Unit__r.Name, Due_Date__c, Invoice_Number__c, 
                Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__c,Payment_Milestones__c,Booking__r.Project__r.Name,
                Booking__r.Opportunity__r.Name,  Booking__r.Opportunity__r.Unit__r.Name, 
                Booking__r.Primary_Applicant_Email__c, Total_Amount_Demanded__c,
                Booking__r.Opportunity__r.Unit__r.Tower__r.Name, Booking__r.Unit__r.Tower__r.Stop_Automatic_Email__c,
                Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name, AttachmentId__c 
                FROM Demand__c WHERE Id IN: dId AND Booking__r.Unit__r.Tower__r.Stop_Automatic_Email__c = false ];

            Blob body;
            Blob htmlBody;

            if(diList.size() > 0){
                List<ContentVersion> listContentVersion = new List<ContentVersion>();
                for (Demand__c demand : diList) {
                    BookingIds.add(demand.Booking__c);
                    System.debug(' demand - '+demand);
                    System.debug(' demand - '+demand.Due_Date__c);
                    String invoiceNumber = '';
                    Date invoiceDueDate = system.today().addDays(-10000);
                    invoiceNumber = demand.Invoice_Number__c;
                    invoiceDueDate = demand.Due_Date__c;

                    
                    PageReference pageRef = new PageReference('/apex/AutoDemandView'); 
                    System.debug('DONE --->'+pageRef);
                    pageRef.getParameters().put('mode', 'raise');
                    pageRef.getParameters().put('letterHead', '1');
                    pageRef.getParameters().put('previewId', demand.Unit__r.Id);
                    pageRef.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef.getParameters().put('invoiceNumber', invoiceNumber);
                    pageRef.getParameters().put('forMilestone', demand.Payment_Milestones__c);
                    
                    PageReference pageRef2 = new PageReference('/apex/SendDemandMail');
                    pageRef2.getParameters().put('unitId', demand.Unit__r.Id);
                    pageRef2.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef2.getParameters().put('invoiceNumber', invoiceNumber);
                    
                    if(!test.isRunningTest()) {
                        body = pageRef.getContentAsPDF();
                        String content = pageRef.getContent().toString();
                        if (content.contains('Error in PDF Demand Not')) {
                            return 'Error in PDF Demand Not Sent To Customer. Please check demand Manually render as pdf : Time : '+System.Now();
                        }
                        htmlBody = pageRef2.getContent();
                    }else {
                        htmlBody = Blob.valueof('Dummy Content for Test Methods');
                        body = Blob.valueOf('Some Text');
                    }
                    Set<String> contId = new Set<String>();
                    

                    ContentVersion cont = new ContentVersion();
                    cont.Title = demand.Invoice_Number__c + '-' + demand.Booking__r.Opportunity__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Name + system.now();
                    cont.VersionData = body;
                    cont.ExternalDocumentInfo1 = demand.Id;
                    cont.PathOnClient = demand.Invoice_Number__c +'.pdf';
                    cont.ContentLocation = 'S';
                    cont.Description = 'Demand for :' + demand.Booking__r.Opportunity__r.Name;
                    cont.TagCSV = 'Demand for :' + demand.Booking__r.Opportunity__r.Name;
                    listContentVersion.add(cont);
                    System.debug(' listContentVersion '+listContentVersion);
                }

                insert listContentVersion;
                System.debug(' listContentVersion '+listContentVersion);
                Set<String> contId = new Set<String>();
                for (ContentVersion cv : listContentVersion) {
                    contId.add(cv.Id);
                }
                System.debug(' contId '+contId);            
                List<ContentDocumentLink> cDeList = new List<ContentDocumentLink>();
                for (ContentVersion CV : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contId ]) {
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = CV.ContentDocumentId;
                    cDe.LinkedEntityId = '0582o0000002N5c'; 
                    cDe.ShareType = 'I';
                    cDe.Visibility  = 'AllUsers';
                    cDeList.add(cDe);
                } 
                System.debug(' cDeList '+cDeList); 
                try {
                    insert cDeList; 
                } catch (Exception e) {}
                
                List<FeedItem> flList = new List<FeedItem>();
                for(Demand__c d: diList) {
                    for (ContentVersion CV : listContentVersion) {
                        if(CV.ExternalDocumentInfo1 == d.Id){
                            FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = d.Id, RelatedRecordId = CV.Id, Type = 'ContentPost');
                            flList.add(elm);
                        }
                    }
                }
                System.debug(' diList '+diList); 
                insert flList;
                
                List<Demand__c> dmandListForUpdate = new List<Demand__c>();
                for(Demand__c d : diList){
                    for (ContentVersion CV : listContentVersion) {
                        if(CV.ExternalDocumentInfo1 == d.Id){
                            d.AttachmentId__c = CV.id;
                            dmandListForUpdate.add(d); 
                        }
                    }
                }
                System.debug(' dmandListForUpdate '+dmandListForUpdate); 
                update dmandListForUpdate; 

                Map<String,String> bookingwithEmail = new Map<String,String>();
                for (Applicant_Details__c app : [SELECT Name,Booking__c, Email_Address__c FROM Applicant_Details__c WHERE Booking__c IN: BookingIds ORDER BY Booking__c]) {
                    if(bookingwithEmail.get(app.Booking__c) != null){
                        bookingwithEmail.put(app.Booking__c,bookingwithEmail.get(app.Booking__c)+','+app.Email_Address__c);
                    }else{
                        bookingwithEmail.put(app.Booking__c,app.Email_Address__c);
                    }
                }
                System.debug(' bookingwithEmail '+bookingwithEmail); 
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                
                System.debug(' fileAttachments '+fileAttachments); 
                Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
                System.debug(' owaMap '+owaMap); 
                for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
                    owaMap.put(owa.Address,owa);
                }
                System.debug(' owaMap '+owaMap); 
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

                for(Demand__c d: diList) {
                    System.debug(' d '+d); 
                    for (ContentVersion CV : listContentVersion) {
                        List<String> toAddresses = new List<String>();
                        List<String> ccAddress = new List<String>();
                        if(CV.ExternalDocumentInfo1 == d.Id){
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(CV.Title+'.pdf');
                            efa.setBody(CV.VersionData);
                            fileAttachments.add(efa);
                            System.debug(' fileAttachments '+fileAttachments); 
                            string fromMailId;
                            if( d.Booking__c != null &&  d.Booking__r.Owner != null){
                                fromMailId = d.Booking__r.Owner.Email;
                            }
                            
                            for(String s : bookingwithEmail.get(d.Booking__c).split(',')){
                                if(!s.containsIgnoreCase('null')){
                                    toAddresses.add(s);
                                }
                            }
                            System.debug(' toAddresses '+toAddresses); 
                            if(d.Booking__r.Primary_Applicant_Email__c != null && d.Booking__r.Primary_Applicant_Email__c != ''){
                                toAddresses.add(d.Booking__r.Primary_Applicant_Email__c);
                            }
                            ccAddress.add(System.label.CollectionTeamEmail); 
                            ccAddress.add('sfnotifications@sobharealty.com'); 
                            System.debug(' ccAddress '+ccAddress); 
                            
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                            email.setSubject('Installment Notice for ' + d.Unit__r.Name);
                            email.setToAddresses(toAddresses);
                            email.setCCAddresses(ccAddress);
                            email.setHtmlBody(htmlBody.toString());
                            System.debug(' fromMailId '+fromMailId); 
                            System.debug(' owaMap '+owaMap); 
                            email.setFileAttachments(fileAttachments);
                            email.setWhatId(d.Booking__c);
                            if(d.Booking__r.Project__r.Name.contains('Siniya')){
                                email.setOrgWideEmailAddressId(owaMap.get(System.Label.Collection_Siniya_Email).id);
                            }else{
                                email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
                            }
                            System.debug(' emails '+emails); 
                            if(d.Total_Amount_Demanded__c > 10000){
                                emails.add(email);
                            }
                        }
                    }
                }
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,false);
                System.debug(' r '+r); 
                return 'Success';
            }else{
                return 'Demand Generated Email Not Sent Time : '+System.Now()+' Either Unit Status is not correct or Current Status is not correct';
            }
        }catch (VisualforceException e) { 
            System.debug('EXCEPTION '+e);
            return 'Demand Generated Email Not Sent : Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + ' Stack Trace :' +e.getStackTraceString();
        }catch (System.NullPointerException e) {
            System.debug('EXCEPTION '+e);
            return 'Demand Generated Email Not Sent : Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + ' Stack Trace :' +e.getStackTraceString();
        }catch (Exception e) {
            System.debug('EXCEPTION '+e);
            return 'Demand Generated Email Not Sent : Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + ' Stack Trace :' +e.getStackTraceString();
        }
    }

    @InvocableMethod(label='Send Invoice Notification' description='Demand Id To be send')
    public static void resendNotification(List<Demand__c> demandList){
        DemandGeneratorManager.sendDemandToCustomer(new Set<String>{demandList[0].Id});
    }
}