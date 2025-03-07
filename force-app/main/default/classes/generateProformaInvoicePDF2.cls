public class generateProformaInvoicePDF2
{

    public Proforma_Invoice__c currentRecord{get; set;}
    public String unitNames{get; set;}
    public Decimal areaTotal{get; set;}
    public Bank_GL__c legalEntity{get; set;}
    public Boolean show {get;set;}
    public Boolean showEuro {get;set;}
    public Boolean showGbp {get;set;}
    public Boolean showAed {get;set;}
    public Boolean showUsd {get;set;}
    
    public generateProformaInvoicePDF2(ApexPages.StandardController controller){
        // Proforma_Invoice__c pv = (Proforma_Invoice__c)controller.getRecord();  
        currentRecord = [SELECT Id, Name, Enquiry__r.PropStrength__Selected_Property_Ids__c, Generate_invoice_in_AED__c, 
                        Generate_invoice_in_Euro__c, Generate_invoice_in_GBP__c, Generate_invoice_in_USD__c, Status__c,
                        Enquiry__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c 
                        FROM Proforma_Invoice__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        show = false;
        showEuro = false;
        showGbp = false;
        showAed = false;
        showUsd = false;

        if(!currentRecord.Generate_invoice_in_USD__c && !currentRecord.Generate_invoice_in_AED__c && !currentRecord.Generate_invoice_in_GBP__c && !currentRecord.Generate_invoice_in_Euro__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select the checkbox to generate the invoice either with AED or GBP or USD or Euro '));
        } else {
            if(currentRecord.Generate_invoice_in_USD__c) {
                showUsd = true;
            } else if(currentRecord.Generate_invoice_in_AED__c) {
                showAed = true;
            } else if(currentRecord.Generate_invoice_in_GBP__c) {
                showGbp = true;
            } else if(currentRecord.Generate_invoice_in_Euro__c) {
                showEuro = true;
            }

            if(currentRecord.Enquiry__r.PropStrength__Selected_Property_Ids__c != null) {
                if(!currentRecord.Enquiry__r.PropStrength__Selected_Property_Ids__c.contains(',')) {
                    show = true;
                    List<Id> propId = new List<Id>();
                    unitNames = '';
                    areaTotal = 0;
                    legalEntity = new Bank_GL__c();
                    if(!currentRecord.Enquiry__r.PropStrength__Selected_Property_Ids__c.contains(',')) {
                        propId.add(currentRecord.Enquiry__r.PropStrength__Selected_Property_Ids__c);
                    } else {
                        propId.addAll(currentRecord.Enquiry__r.PropStrength__Selected_Property_Ids__c.split(','));
                    }

                    if(!propId.isEmpty()) {
                        List<PropStrength__Property__c> propList = [SELECT Id, PropStrength__House_Unit_No__c, PropStrength__Super_Area__c, PropStrength__Project_Name__c FROM PropStrength__Property__c WHERE Id IN :propId];
                        List<PropStrength__Projects__c> projList = [SELECT Id, (SELECT Id, Favouring__c, IBAN__c, Bank_Name__c, RDS_Address1__c, Account_Number__c, Swift_Code__c FROM Bank_GL__r WHERE Bank_Account_Type__c = 'Escrow Account') FROM PropStrength__Projects__c WHERE Id = :propList[0].PropStrength__Project_Name__c];
                        if(!projList[0].Bank_GL__r.isEmpty()) {
                            legalEntity = projList[0].Bank_GL__r[0];
                        }
                        for(PropStrength__Property__c prop : propList) {
                            unitNames += prop.PropStrength__House_Unit_No__c + ',';
                            areaTotal += prop.PropStrength__Super_Area__c;
                        }

                        unitNames = unitNames.substring(0,unitNames.length()-1);
                    }
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select single property on enquiry'));
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select a property on enquiry'));
            }
        }
        
        System.debug('Proforma Invoice'+currentRecord.id);
    }
          
    public void savePdf(){ 
        if(ApexPages.currentPage().getParameters().containsKey('generatepdf')) {
            return;
        }
       if(ApexPages.currentPage().getParameters().containsKey('createAttachment')) {
            String InvoiceId = currentRecord.id;
            PageReference pdf = ApexPages.currentPage();
            pdf.getParameters().put('generatepdf','true');
            Blob body;   
            try {        
                body = pdf.getContent();            
            } 
            catch (VisualforceException e) {
                body = Blob.valueOf('Some Error ');
            }   
            Attachment attachmentProformaInvoice = new Attachment();
            attachmentProformaInvoice.Body = body;
            attachmentProformaInvoice.Name = 'ProformaInvoice'+System.now()+'.pdf';
            attachmentProformaInvoice.IsPrivate = false;
            attachmentProformaInvoice.ParentId = currentRecord.id;
            attachmentProformaInvoice.ContentType='application/pdf';
            
            Insert attachmentProformaInvoice ; 
      }
    }              
}