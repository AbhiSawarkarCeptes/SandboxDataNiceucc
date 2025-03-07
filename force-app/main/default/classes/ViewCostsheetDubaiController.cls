public class ViewCostsheetDubaiController{
    
    public String createDateTime {get; set;}
    
    public String qId {get; set;}
    public List<Quotation__c> qList {get; set;}
    public List<Rate_List__c> rList {get; set;}
    public Date qDate {get; set;}
    public String floorNo {get;set;}
    public String bankAddress {get;set;}
    Map<String, Integer> projChargeSeq = new Map<String,Integer>();
    public String basicChargesString {get;set;}
    public String floorRiseChargesString {get;set;}
    public String floorRiseAmount{get;set;}
    public String PLCAmount {get;set;}
    public String PLCChargesString {get;set;}
    public String stampDutyString {get;set;}
    public String totalKnowledgefeesString {get;set;}
    public String totalDLDfeesString {get;set;}
    public String totalDLDAdminfeesString {get;set;}
    public String registrationString{get;set;}
    public String totalRegStampString{get;set;}
    public string amtGTString{get;set;}
    public String grandTotalString{get;set;}
    public List<PMWrapper> pmwList {get;set;}
    public List<Payment_Milestones__c> pmList {get;set;}
    public Decimal stampDutyPerce{get;set;}
    public List<Quotation__c> qListImage {get; set;} 
    public String PimageURL {get; set;}
    public String PimageURL1 {get; set;}
    public List<String> unitImageUrlList {get; set;}
    public String floorPlan {get;set;}
    public String attachmentId {get; set;}
    public List<ContentDocumentLink> PattchList {get;set;} 
    public List<ContentDocumentLink> FloorPlanList {get;set;} 
    public List<Unit__c> uList {get;set;} 
    public String chgName{get;set;}
    public String KnowledgefeesString {get;set;}
    public String DLDfeesString {get;set;}
    public String DLDAdminfeesString {get;set;}
    public Decimal totalKnowledgefees{get;set;}
    public Decimal totalDLDfees{get;set;}
    public Decimal totalDLDAdminfees{get;set;}
    public String custEmailId{get;set;}
    public String custName{get;set;}
    public String custMob{get;set;}
    public String addresses{get;set;}
    public String varDescription1{get;set;}
    public String varDescription2{get;set;}
    //public string quoteCreatedBy{get;set;}
    public String twoMonthLaterDate {get;set;}
     
    public ViewCostsheetDubaiController(){
        rList = new List<Rate_List__c>();
        Map<String,String> mapCharges = new Map<String,String>();
        pmwList = new List<PMWrapper>();
        pmList  = new List<Payment_Milestones__c>();
        stampDutyPerce = 0;
        floorRiseChargesString = '0.00/-';
        PLCChargesString = '0.00/-';
        stampDutyString = '0.00/-';
        registrationString = '0.00/-';
        chgName = '';
        KnowledgefeesString ='';
        DLDfeesString='';
        totalKnowledgefees = 0;
        totalDLDfees = 0;
        totalDLDAdminfees =0;
        
        qId = ApexPages.currentPage().getParameters().get('qId'); 
        
        String queryString = '';
        for(Integer i = 1; i<=25; i++) {
            queryString += 'Charge' + i + 'Name__c'   + ',';
            queryString += 'Charge' + i + 'Value__c'  + ',';
            queryString += 'Charge' + i + 'Bucket__c' + ',';                               
        }
        
        queryString += 'Name,Customer_Name__c,Customer_Email__c,From_Broker_Portal__c,Is_Discount_Quote__c, Unit__r.Id, Unit__r.Project__r.Name, Unit__r.Typology__c, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name, Unit__r.Tower_No__c,'+
            'Unit__r.Floor__c, Unit__r.Unit_No__c, Unit__r.Unit_Status__c, Unit__r.No_of_Bedroom__c, Total_Other_Charges_Bucket__c,Unit__r.Store_Unit__c,Unit__r.Store_Area__c,'+ 
            'Unit__r.Super_Builtup_Area_Sq_Ft__c, Total_Agreement_Value_Bucket__c, Premium1_Original_PSF__c, Total_SD_Registration_Bucket__c,' +
            'Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.Favouring__c, Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c, Unit__r.Unit_Type__c,' +
            'Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c, Unit__r.Tower__r.Building_Number__c, Unit__r.Tower__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c, Unit__r.Floor_No_to_print__c,' +                                                                    
            'Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c, Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c, Payment_Plan__r.Disclaimer__c, Unit__r.Configuration__c, Unit__r.Chargeable_Area__c,' +
            'Unit__r.Tower__r.RDS_Company_Code__r.Developer_ID__c,  Unit__r.Name,Unit__r.RERA_Suite_Area_Sq_Ft__c,Unit__r.Balcony_Area_Sq_Ft__c,Unit__r.Tower__r.RDS_Company_Code__r.Project_Name_ID__c, Floor_Rise_Original_PSF__c, Opportunity__r.AccountId, CreatedDate,CreatedBy.Name,CreatedBy.Email,CreatedBy.CreatedDate ';                              
        
        if (qId != null) {
            queryString = 'Select ' + queryString  +' FROM Quotation__c WHERE Id = \'' + qId + '\'' ;
            qList = Database.Query(queryString);
        }
        /* For showing different name than vfp name while downloading pdf */
        // Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+qList[0].Unit__r.Unit_No__c + '-Quotation.pdf'); 
        
        System.debug('Unit Id::: ' +qList[0].Unit__r.Id);
        createDateTime = qList[0].CreatedDate.format('MMM d,yyyy hh:mm a', UserInfo.getTimeZone().getID());
        
        integer count;
        
        Date createdDate = qList[0].CreatedDate.date();
        createdDate = createdDate.addMonths(2);
        twoMonthLaterDate = createdDate.format();
        
        Account ac = new Account();
        if(qList[0].Opportunity__c != null){
            ac = [select id,name,FirstName,LastName,PersonEmail,PersonMobilePhone from Account where id =: qList[0].Opportunity__r.AccountId];
            if(ac != null){
                custName = ac.name;
                custMob = ac.PersonMobilePhone;
                custEmailId = ac.PersonEmail;
            }
        }
        
        
        DateTime dT = qList[0].CreatedDate;
        count = 123;
        qDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        /*     if(qList[0].Unit__r.Floor__c != null & qList[0].Unit__r.Floor__c == 0){
floorNo = 'G';
} else {
floorNo =  String.valueOf(qList[0].Unit__r.Floor__c);
}*/
        
        if(qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != null || qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != ''){
            bankAddress = qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c;
            if(qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c != null || qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c != ''){
                bankAddress += ', ' + qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c;
            }
        }             
        
        // For Payment Plan Milestone
        projChargeSeq = InventoryCostServices.getProjectChargesSequence(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        system.debug('projChargeSeq '+projChargeSeq );
        if(!projChargeSeq.isEmpty() && projChargeSeq.size() > 0) {
            
            integer basicSeq = projChargeSeq.get('Basic');
            basicChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + basicSeq + 'Value__c'));
            
            integer floorRiseSeq = projChargeSeq.get('Floor Rise');
            if(floorRiseSeq != null)
            {
                floorRiseChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + floorRiseSeq + 'Value__c'));
            }                 
            floorRiseAmount = InventoryCostServices.InFormat(qList[0].Floor_Rise_Original_PSF__c);
            
            PLCAmount = InventoryCostServices.InFormat(qList[0].Premium1_Original_PSF__c);
            
            integer PLCSeq = projChargeSeq.get('PLC');
            system.debug('PLCSeq ::'+PLCSeq );
            if(PLCSeq != null)
            {
                PLCChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + PLCSeq + 'Value__c'));
            }
            
            
            //-------------------------------------------------------------------------------------------------------------------- ------------------------------------//
            integer knowledgefeesseq = projChargeSeq.get('Knowledge Fees'); 
            system.debug('knowledgefeesseq ::'+knowledgefeesseq );               
            if(!String.isBlank(String.valueOf(knowledgefeesseq ))) {
                if(qList[0].get('Charge' + knowledgefeesseq + 'Value__c') != Null){
                    KnowledgefeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c'));                        
                    totalKnowledgefees += (Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c');
                    totalKnowledgefees = totalKnowledgefees.setScale(0);
                    system.debug('totalKnowledgefees ::'+totalKnowledgefees );}
            }
            //totalKnowledgefeesString = InventoryCostServices.InFormat(totalKnowledgefees );
            
            integer DLDfeesseq = projChargeSeq.get('DLD'); 
            system.debug('DLDfeesseq ::'+DLDfeesseq );                                  
            if(!String.isBlank(String.valueOf(DLDfeesseq ))) {
                if(qList[0].get('Charge' + DLDfeesseq + 'Value__c') != Null){
                    DLDfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c'));
                    totalDLDfees += (Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c');
                    totalDLDfees = totalDLDfees.setScale(0);
                    system.debug('totalDLDfees ::'+totalDLDfees );}
            }
            //totalDLDfeesString =  InventoryCostServices.InFormat(totalDLDfees );  
            
            integer DLDAdminfeesseq = projChargeSeq.get('DLD Admin Fees'); 
            system.debug('DLDAdminfeesseq ::'+DLDAdminfeesseq );                                  
            if(!String.isBlank(String.valueOf(DLDAdminfeesseq ))) {
                if(qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c') != Null){
                    DLDAdminfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c'));
                    totalDLDAdminfees += (Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c');
                    totalDLDAdminfees = totalDLDAdminfees.setScale(0);
                    system.debug('totalDLDAdminfees ::'+totalDLDAdminfees );}
            }
            //totalDLDAdminfeesString =  InventoryCostServices.InFormat(totalDLDAdminfees ).setScale(0);     
        }                      
        //------------------------------------------------------------------------------------------------------------------------------------------------//
        
        
        integer basicSeq = projChargeSeq.get('Basic');
        Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        Map<String,Integer> AVChargesSeqMap = new Map<String, Integer>();
        
        Integer Seq = 1;
        String chgName = '';
        system.debug(projChargesMap);
        
        if(!projChargesMap.isEmpty() && projChargesMap.containsKey('Stamp Duty') && projChargesMap.get('Stamp Duty') != null)
            stampDutyPerce = projChargesMap.get('Stamp Duty').Agreement_Value_Percentage__c;
        
        //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
        for(String chargeName : projChargesMap.keySet()) {
            system.debug('chargeName::'+chgName);
            chgName = projChargesMap.get(chargeName).ChargeBucket__c;
            
            if(chgName.equalsIgnoreCase('Agreement Value')) {
                AVChargesSeqMap.put(chargeName, Seq);
                
            }                              
            Seq++;
        }
        System.debug(Seq);
        AVChargesSeqMap.put('Interest On Common Area Charges',Seq);
        system.debug(AVChargesSeqMap);
        
        String queryString1 = '';
        
        for(Integer i = 1; i<=25; i++) {
            queryString1 += 'Charge' + i + 'Name__c'   + ',';
            queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
            queryString1 += 'C' + i + '_Amount__c' + ',';                    
            queryString1 += 'C' + i + '_CGST__c'   + ','; 
            queryString1 += 'C' + i + '_SGST__c'   + ','; 
        }
        
        if (qId != null) 
        {
            queryString1 = 'SELECT ' + queryString1  + ' Id, Name, Milestone_Name__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c  FROM Payment_Milestones__c WHERE Quotation__c = \'' + qId + '\' order by Name ASC' ;                                                                     
            pmList = Database.Query(queryString1);
        }
        
        Decimal amtGT = 0;
        Decimal taxGT = 0;
        Decimal sizeOfPM = pmList.size();
        Decimal srno = 0;
        System.debug('Size pf pm::: ' + pmList.size());    
        for(Payment_Milestones__c pm : pmList) {
            // check all the values in Agreement value bucket and sum total its amount and taxes
            Decimal totalAmt = 0;
            Decimal totalTax = 0;
            srno ++;
            for(Integer i : AVChargesSeqMap.values()) {
                totalAmt += (Decimal)pm.get('C' +i + '_Amount__c' );
                totalTax += (Decimal)pm.get('C' + i + '_CGST__c' ) + (Decimal)pm.get('C' + i + '_SGST__c' );
            }
            amtGT += totalAmt;
            system.debug('Amount::'+totalAmt);
            if(pm.get('Charge' + basicSeq + 'Percentage__c') != null) {
                pmWrapper pmw = new pmWrapper(srno, pm.Milestone_Due_Date__c,  pm.Milestone_Name__c, pm.get('Charge' + basicSeq + 'Percentage__c') + '%', totalAmt, pm.Milestone_Complete_At_Booking__c, pm.Milestone_Type_edit__c, sizeOfPM);
                pmwList.add(pmw);
            }
        }
        system.debug(pmwList);
        amtGTString = InventoryCostServices.InFormat(amtGT);                  
        decimal tempgrandTotal = (qList[0].Total_Agreement_Value_Bucket__c + qList[0].Total_Other_Charges_Bucket__c).setscale(0,RoundingMode.HALF_UP);
        grandTotalString = InventoryCostServices.InFormat(tempgrandTotal);
        
        ////////// For Images  
        PattchList = new List<ContentDocumentLink>();
        FloorPlanList = new List<ContentDocumentLink>();
        PimageURL = '';
        PimageURL1 = '';
        Id parentRecordId;
        Id parentFloorPlanRecordId;
        
        if(qId != null){ 
            qListImage = [SELECT Unit__c, Opportunity__c,unit__r.Unit_Type__c, Unit__r.Tower__c, Unit__r.Typology__c, Unit__r.View_Type__c, Unit__r.Direction__c, Unit__r.Unit_Type_Variant__c, unit__r.Floor__c  
                          FROM Quotation__c WHERE Id = :qId];
            System.debug('Quotation Tower Id::: ' + qListImage[0].Unit__r.Tower__c);
            System.debug('Unit Typology:::' + qListImage[0].Unit__r.Typology__c );
            /*List<Variant_Description__mdt> VDList= new List<Variant_Description__mdt>();
VDList=Variant_Description__mdt.getAll().values();
String varDescription;
for(Variant_Description__mdt vdRec:VDList)
{
if(qListImage[0].Unit__r.Unit_Type_Variant__c==vdRec.Variant__c)
varDescription=vdRec.Description__c;
}*/
            List<VarDescription__c> VDList= [SELECT Id,Variant__c,Description1__c,Description2__c FROM VarDescription__c];
            //VDList=Variant_Description__mdt.getAll().values();
           
            for(VarDescription__c vdRec:VDList)
            {
                if(qListImage[0].Unit__r.Unit_Type_Variant__c==vdRec.Variant__c)
                {
                    varDescription1=vdRec.Description1__c;
                    varDescription2=vdRec.Description2__c;
                }
            }
            system.debug('varDescription1'+varDescription1);
            
        }
        
        //Shoba_Default_Settings__mdt orgDefaults = Shoba_Default_Settings__mdt.getInstance('Org Defaults');
        List<Shoba_Default_Settings__mdt> orgDefaults = [SELECT Id,MasterLabel,Default_Layout_Object__c from Shoba_Default_Settings__mdt];
        
        String defaultLayoutObject = 'Unit';
        if (orgDefaults.size() > 0) {
            defaultLayoutObject = orgDefaults[0].Default_Layout_Object__c;
        }
        
        if (defaultLayoutObject == 'Unit') {
            if(qListImage.size() > 0 && qListImage != null){
                uList = [SELECT Id FROM Unit__c 
                         WHERE id = :qListImage[0].Unit__c];
                //System.debug('Unit Layout Id::: ' + uList[0].Id);
                parentRecordId = uList[0].id;
                list<Unit_Plan__c> twList= new list<Unit_Plan__c> ();
                twList = [Select id from Unit_Plan__c where tower__c = :qListImage[0].Unit__r.Tower__c and Unit_Type__c = :qListImage[0].Unit__r.Unit_Type_Variant__c AND (Floor_number__c <=:qListImage[0].Unit__r.Floor__c AND To_Floor_Number__c >=:qListImage[0].Unit__r.Floor__c) ];
                system.debug('Line no. 304'+twList);
                If(twList == null || twList.size()==0){
                twList = [Select id from Unit_Plan__c where tower__c = :qListImage[0].Unit__r.Tower__c and Unit_Type__c = :qListImage[0].Unit__r.Unit_Type_Variant__c and Floor_number__c = null AND To_Floor_Number__c = null];
                system.debug('Line no. 307'+twList);
                }
                If(twList != null && twList.size()>0){
                    parentRecordId = twList[0].Id;
                }
                
                // get the floor plan record to get the floor plan image
                List<Floor_Plan__c> lstfloorPlanRec = [SELECT Id FROM Floor_Plan__c 
                                                       WHERE tower__c = :qListImage[0].Unit__r.Tower__c 
                                                       AND (Plan_Floor_from__c  <= :qListImage[0].Unit__r.Floor__c 
                                                            AND Plan_Floor_to__c   >= :qListImage[0].Unit__r.Floor__c)];
                If(lstfloorPlanRec.size() > 0){
                    parentFloorPlanRecordId = lstfloorPlanRec[0].Id;
                }
                
                
            } 
        } else {
            if(qListImage.size() > 0 && qListImage != null){
                parentRecordId = [SELECT Id, Typology__c FROM Unit_Layout__c 
                                  WHERE Tower__c = :qListImage[0].Unit__r.Tower__c AND Typology__c = :qListImage[0].Unit__r.Typology__c][0].id;
                //System.debug('Unit Layout Id::: ' + uList[0].Id);
            }
        }
        
        if(parentRecordId != null){ 
            PattchList = [SELECT ContentDocumentId, 
                          ContentDocument.Title,
                          ContentDocument.LatestPublishedVersionId
                          FROM ContentDocumentLink 
                          WHERE LinkedEntityId = :parentRecordId
                          order by ContentDocument.Title asc];
            System.debug('AttacmentList::'+PattchList);  
        }  
        
        String userProfileName = [SELECT Name FROM PROFILE WHERE 
                                  ID =: USERINFO.getProfileId()].Name;
								  
		//List<String> unitImageUrlList= new List<String>();						  
								 
       //  if(!PattchList.isEmpty() && 
      //     (userProfileName == 'System Administrator' || userProfileName == 'Sales Operation With Area Update Access' || userProfileName == 'Sales Operation')
	//	   || ((userProfileName == System.Label.QuotationProfile || userProfileName == System.Label.QuotationProfile2 || userProfileName == System.Label.QuotationProfile3 || userProfileName == System.Label.QuotationProfile4 ) && (qList[0].Unit__r.Tower__r.Name == '310 Riverside Crescent'|| qList[0].Unit__r.Tower__r.Name == '320 Riverside Crescent' || qList[0].Unit__r.Tower__r.Name == '330 Riverside Crescent')) )  {      
        unitImageUrlList= new List<string>();
        if(!PattchList.isEmpty()){
               for(ContentDocumentLink a : PattchList) {
                   if(defaultLayoutObject == 'Unit') {
                       //PimageURL = '/servlet/servlet.FileDownload?file=' + a.ContentDocumentId;
                       PimageURL = '/sfc/servlet.shepherd/version/download/'+ a.ContentDocument.LatestPublishedVersionId;
                       PimageURL1 = PimageURL;
                       unitImageUrlList.add(PimageURL1);
                       System.debug('PimageURL::: ' + PimageURL);
                       //floorPlan = '/sfc/servlet.shepherd/version/download/'+ a.ContentDocument.LatestPublishedVersionId;
                   }else {
                       if(a.ContentDocument.Title.ContainsIgnoreCase('3')) {
                           PimageURL = '/servlet/servlet.FileDownload?file=' + a.Id;
                           System.debug('PimageURL::: ' + PimageURL);
                       }
                       if(a.ContentDocument.Title.ContainsIgnoreCase('3')) {
                           PimageURL1 = '/servlet/servlet.FileDownload?file=' + a.Id;
                           System.debug('PimageURL1::: ' + PimageURL1);
                       }
                   }
                   
               }
           }
        
        
        //populating images for floor plan
        if(parentFloorPlanRecordId != null){ 
            FloorPlanList = [SELECT ContentDocumentId, 
                             ContentDocument.Title,
                             ContentDocument.LatestPublishedVersionId
                             FROM ContentDocumentLink 
                             WHERE LinkedEntityId = :parentFloorPlanRecordId
                             order by ContentDocument.Title asc];
            System.debug('AttacmentList::'+FloorPlanList);  
        }  
        
       //  if(!PattchList.isEmpty() && 
       //    (userProfileName == 'System Administrator' || userProfileName == 'Sales Operation With Area Update Access' || userProfileName == 'Sales Operation')
		//   || ((userProfileName == System.Label.QuotationProfile || userProfileName == System.Label.QuotationProfile2 || userProfileName == System.Label.QuotationProfile3 || userProfileName == System.Label.QuotationProfile4 ) && (qList[0].Unit__r.Tower__r.Name == '310 Riverside Crescent'|| qList[0].Unit__r.Tower__r.Name == '320 Riverside Crescent' || qList[0].Unit__r.Tower__r.Name == '330 Riverside Crescent')) )  { 
        if(!PattchList.isEmpty()){
               for(ContentDocumentLink a : FloorPlanList) {
                   if(defaultLayoutObject == 'Unit') {
                       floorPlan = '/sfc/servlet.shepherd/version/download/'+ a.ContentDocument.LatestPublishedVersionId;
                   }
               }
           }
        // end of floor plan images population
        
    }
    public pageReference sendQuote(){ 
        
        system.debug('inside sendquoteMethod::');  
        Blob pdf;
        PageReference pageRef = new PageReference('/apex/ViewCostsheetDubaiPDF?qId='+qId);
        pageRef.getParameters().put('qId',qId);
        try {
            pdf = pageRef.getContentAsPdf();
        } catch (VisualforceException e) {
            pdf = Blob.valueOf('Some Text');
        }
        
        string strBookingHtmlBody ;
        string strImageBlob;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        strBookingHtmlBody = 'Dear '+custName+',<br/><br/> Thank you for your interest in '+qList[0].Unit__r.Project__r.Name+'. As requested, the cost sheet of Unit: '+qList[0].Unit__r.name+' in Tower: '+
            qList[0].Unit__r.Tower__r.Name +' of Project '+ qList[0].Unit__r.Project__r.Name +' is attached.' + 
            '<br></br>Please find Attached.<br></br> <br></br> Thanks, <br/> Sobha.';
        
        list<string> lststringtoaddress = new list<string>();
        if( string.isNotBlank(custEmailId))
            lststringtoaddress.add(custEmailId);
        
        if(string.isNotBlank(addresses)){
            for (String eachStr: addresses.split(',')) {
                lststringtoaddress.add(eachStr);
            }
            
        }
        string subject;
        subject = 'Please Find the attached Quotation for project - '+qList[0].Unit__r.Project__r.name+' Unit - '+qList[0].Unit__r.name;
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Quotation.pdf');
        efa.body = pdf;
        
        email.setSubject(subject);
        email.setToAddresses(lststringtoaddress);
        email.setHtmlBody(strBookingHtmlBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        mails.add(email);
        if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Quotation has been send successfully'));
        
        return null;
        
    }
    public class PMWrapper {
        public Decimal count {get;set;}
        public String dueDate {get;set;} 
        public String installment {get;set;}
        public String milestoneName {get;set;}
        public String amount        {get;set;}
        public String pct           {get;set;}      
        public String amtPayable    {get;set;}
        public String rowStyle      {get;set;}  
        public Decimal sizeOfPM;
        
        public PMWrapper(Decimal srno, Date milestoneDueDate, String msName, String pct, Decimal amt, Boolean milestoneAchieved, String milestoneType, Decimal size) {
            this.count = srno;
            this.installment = '';
            this.milestoneName = msName;
            this.sizeOfPM = size;
            if(milestoneDueDate != null && String.IsNotBlank(milestoneType) && milestoneType == 'Date Linked' && msName == 'On Booking Date'){
                this.dueDate = 'On Booking';
            } else {
                this.dueDate = '-'; 
            }                
            this.pct = pct;
            this.amount = InventoryCostServices.InFormat(amt);
            
            if(msName == 'Total') {
                this.rowStyle  = 'font-weight:bold';
            }
            if(milestoneAchieved) {
                this.rowStyle  = 'background-color:#D7BF5E';
            }
            
            if(this.milestoneName == 'On Booking Date'){
                this.installment = 'Booking Amount';              
            }
            if(this.count == 2){
                this.installment = 'First Installment';              
            }
            if(this.count == 3){
                this.installment = 'Second Installment';              
            }
            if(this.count == 4){
                this.installment = 'Third Installment';              
            }
            if(this.count == 5){
                this.installment = 'Fourth Installment';              
            }
            if(this.count == 6){
                this.installment = 'Fifth Installment';              
            }
            if(this.count == 7){
                this.installment = 'Sixth Installment';              
            }
            if(this.count == 8){
                this.installment = 'Seventh Installment';              
            }
            if(this.count == 9){
                this.installment = 'Eighth Installment';              
            }
            if(this.count == 10){
                this.installment = 'Ninth Installment';              
            }
            if(this.count == 11){
                this.installment = 'Tenth Installment';              
            }
            if(this.count == 12){
                this.installment = 'Eleventh Installment';              
            }
            if(this.count == 13){
                this.installment = 'Twelfth Installment';              
            }
            if(this.count == 14){
                this.installment = 'Thirteenth Installment';              
            }
            if(this.count == 15){
                this.installment = 'Fourteenth Installment';              
            }
            if(this.count == 16){
                this.installment = 'Fifteenth Installment';              
            }
            if(this.count == 17){
                this.installment = 'Sixteenth Installment';              
            }
            if(this.count == 18){
                this.installment = 'Seventeenth Installment';              
            }
            if(this.count == 19){
                this.installment = 'Eighteenth Installment';              
            }
            if(this.count == 20){
                this.installment = 'Nineteenth Installment';              
            }
            if(this.count == 21){
                this.installment = 'Twentieth Installment';              
            }
            if(this.count == 22){
                this.installment = 'Twenty-First Installment';              
            }
            if(this.count == 23){
                this.installment = 'Twenty-Second Installment';              
            }
            if(this.count == 24){
                this.installment = 'Twenty-Third Installment';              
            }
            if(this.count == 25){
                this.installment = 'Twenty-Fourth Installment';              
            }
            if(this.count == 26){
                this.installment = 'Twenty-Fifth Installment';              
            }
            if(this.count == 27){
                this.installment = 'Twenty-Sixth Installment';              
            }
            if(this.count == 28){
                this.installment = 'Twenty-Seventh Installment';              
            }
            if(this.count == 29){
                this.installment = 'Twenty-Eighth Installment';              
            }
            if(this.count == 30){
                this.installment = 'Twenty-Ninth Installment';              
            }
            if(this.count == 31){
                this.installment = 'Thirtieth Installment';              
            }
            if(this.count == 32){
                this.installment = 'Thirty-First Installment';              
            }
            if(this.count == 33){
                this.installment = 'Thirty-Second Installment';              
            }
            if(this.count == 34){
                this.installment = 'Thirty-Third Installment';              
            }
            if(this.count == 35){
                this.installment = 'Thirty-Fourth Installment';              
            }
            if(this.count == 36){
                this.installment = 'Thirty-Fifth Installment';              
            }
            if(this.count == 37){
                this.installment = 'Thirty-Sixth Installment';              
            }
            if(this.count == 38){
                this.installment = 'Thirty-Seventh Installment';              
            }
            if(this.count == 39){
                this.installment = 'Thirty-Eighth Installment';              
            }
            if(this.count == 40){
                this.installment = 'Thirty-Ninth Installment';              
            }
            if(this.count == 41){
                this.installment = 'Fortieth Installment';              
            }
            if(this.count == 42){
                this.installment = 'Forty-First Installment';              
            }
            if(this.count == 43){
                this.installment = 'Forty-Second Installment';              
            }
            if(this.count == 44){
                this.installment = 'Forty-Third Installment';              
            }
            if(this.count == 45){
                this.installment = 'Forty-Fourth Installment';              
            }
            if(this.count == 46){
                this.installment = 'Forty-Fifth Installment';              
            }
            if(this.count == 47){
                this.installment = 'Forty-Sixth Installment';              
            }
            if(this.count == 48){
                this.installment = 'Forty-Seventh Installment';              
            }
            if(this.count == 49){
                this.installment = 'Forty-Eighth Installment';              
            }
            if(this.count == 50){
                this.installment = 'Forty-Ninth Installment';              
            }
            if(this.count == 51){
                this.installment = 'Fiftieth Installment';              
            }
            if(this.count == 52){
                this.installment = 'Fift-One Installment';              
            }
            if(this.count == 53){
                this.installment = 'Fift-Second Installment';              
            }
            if(this.count == 54){
                this.installment = 'Fift-Third Installment';              
            }
            if(this.count == 55){
                this.installment = 'Fift-Fourth Installment';              
            }
            if(this.count == 56){
                this.installment = 'Fift-Fifth Installment';              
            }
            if(this.count == 57){
                this.installment = 'Fift-Sixth Installment';              
            }
            if(this.count == 58){
                this.installment = 'Fift-Seventh Installment';              
            }
            if(this.count == 59){
                this.installment = 'Fift-Eighth Installment';              
            }
            if(this.count == 60){
                this.installment = 'Fift-Ninth Installment';              
            }   
            if(this.count == this.sizeOfPM && this.milestoneName != 'On Booking Date'){
                this.installment = 'Final Installment';  
            }
        }
    }
}