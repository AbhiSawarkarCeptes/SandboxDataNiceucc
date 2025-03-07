public without sharing class BookingTriggerHandlerCtr {
    Public static Boolean firstcall=false;
    Public static Map<String, SBTR__c> cancelledSBTrtoUpdate = new Map<String, SBTR__c>();
    Public static  Map<String, List<SBTR__c>> cancelledSBTrMap = new Map<String, List<SBTR__c>>();
    public static void afterInsert(List<Booking__c> newList) {
        updateCreateSBTR(newList, null);  
    }
    
    public static void afterUpdate(List<Booking__c> newList, Map<Id, Booking__c> oldMap) {
        set<Id> bookingIdsToUpdateDeclaredDateOnSBTR = new set<Id>();
        map<Id,Decimal> bookingIdsToSaleValue = new map<Id,Decimal>();
        updateCreateSBTR(newList, oldMap);
        for(Booking__c b : newList){
            if(
                b.SBTR_Declared__c != null &&
                b.SBTR_Declared__c != oldMap.get(b.Id).SBTR_Declared__c &&
                oldMap.get(b.Id).SBTR_Declared__c == null
            ){
                bookingIdsToUpdateDeclaredDateOnSBTR.add(b.Id);
            }
            if(
                b.Agreement_Value__c != null && b.Agreement_Value__c > 0 && 
                b.Agreement_Value__c != oldMap.get(b.Id).Agreement_Value__c
            ){
                bookingIdsToSaleValue.put(b.Id,b.Agreement_Value__c);
            }
        }
        if(bookingIdsToUpdateDeclaredDateOnSBTR.size()>0){ updateDeclaredDateOnSBTR(bookingIdsToUpdateDeclaredDateOnSBTR); }
        if(bookingIdsToSaleValue.size()>0){ updateSaleValueOnSBTR(bookingIdsToSaleValue); }
    }
    
     public static void updateSaleValueOnSBTR(map<Id,Decimal> bookingIdsToSaleValue){
        list<SBTR__c> sbtrToUpdate = new list<SBTR__c>();
        for(SBTR__c sbtr : [select Id,Booking__c from SBTR__c where Booking__c IN :bookingIdsToSaleValue.keySet()]){
            sbtr.Sale_Value_AED__c = bookingIdsToSaleValue.get(sbtr.Booking__c);
            sbtrToUpdate.add(sbtr);
        }
        if(sbtrToUpdate.size() > 0){
            try{
                update sbtrToUpdate;
            }
            catch(Exception e){
                system.debug('BOOKING SBTR SALE VALUE UPDATE FAILED EXCEPTION MESSAGE: '+e.getMessage());
            }
        }
    }
    
    public static void updateDeclaredDateOnSBTR(set<Id> bookingIdsToUpdateDeclaredDateOnSBTR){
        list<SBTR__c> sbtrToUpdate = new list<SBTR__c>();
        list<Booking__c> bookingList = [
            select Id,SBTR_Declared__c,
            (select Id,Declared_Date__c,Collection_10__c from SBTRs__r where Declared_Date__c = null),
            (select Id from Payment_Requests__r) 
            from Booking__c    
            where Id IN : bookingIdsToUpdateDeclaredDateOnSBTR                      
        ];
        for(Booking__c bk : bookingList){
            if(bk.SBTRs__r != null && bk.Payment_Requests__r == null){
                for(SBTR__c sbtr : bk.SBTRs__r){
                    if(sbtr.Declared_Date__c == null){
                        sbtr.Declared_Date__c = bk.SBTR_Declared__c;
                        if(sbtr.Collection_10__c == 'No' || sbtr.Collection_10__c == '' || sbtr.Collection_10__c == null){
                            sbtr.Collection_10__c = 'Yes';
                        }
                        sbtrToUpdate.add(sbtr);
                    }
                }
            }
        }
        if(sbtrToUpdate.size() > 0){
            try{
                update sbtrToUpdate;
            }
            catch(Exception e){
                system.debug('BOOKING SBTR UPDATE FAILED EXCEPTION MESSAGE: '+e.getMessage());
            }
        }
    }
    
    public static void updateCreateSBTR(List<Booking__c> newList, Map<Id, Booking__c> oldMap) {
        SBTRTriggerHandler.hasFiredParentTrigger = true;
        firstcall = true;
        List<SBTR__c> sbtrList = new List<SBTR__c>();
        
        Map<String, List<SBTR__c>> bookingIdBySBTRListMap = new Map<String, List<SBTR__c>>();
        Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap = new Map<String, List<Payment_Milestones__c>>();
        Map<String, Collection_Report__c> bookingNameByCollReportMap = new Map<String, Collection_Report__c>();
        List<string> quottationIds = new List<string>();
        Boolean isInsert = oldMap == null;
        Boolean isUpdate = oldMap != null;
        List<String> oppList = new List<String>();
        List<String> NSAList = new List<String>();
        Map<String, List<Booking__c>> bookingListMap = new Map<String, List<Booking__c>>();
        List<date> bookingDate = new List<date>();
        List<string> applicantList = new List<string>();
        List<Booking__c> bookingList = new List<Booking__c>();
        
        
        for (Booking__c booking : [
            SELECT
            Id,
            Paid_Amount_For_Process__c,
            Booked_Date__c,
            Unit__r.Name,
            Primary_Applicant_Email__c,
            TypeOfApplicant__c,
            Initiate_SBTR__c,
            Sales_Head__c,
            SBTR_Booking_Amount_Received_AED__c,
            SBTR_Category__c,
            SBTR_Declared__c,
            SBTR_Swap_Details__c,
            Booking_to_SBTR_Appro__c,
            Secondary_Sales_Manager_VP__c,
            Secondary_Sales_Manager_VP__r.Name,
            Secondary_Sales_Head_VP2__c,
            Secondary_Sales_Head_VP2__r.Name,
            Name,
            Booking_Date__c,
            Secondary_Sales_Head__r.Name,
            Secondary_Sales_Manager__c,
            Secondary_Sales_Manager__r.Name,
            Opportunity__c,
            Applicant_Details__c,
            Unit__r.Chargeable_Area__c,
            Channel_Partner__r.Channel_Partner_Id__c,
            Unit__r.Puchase_Price__c,
            Channel_Partner__c,
            Channel_Partner__r.Category__c,
            Channel_Partner__r.Name,
            Channel_Partner__r.Contact_Person__c,
            Sobha_Connect__c,
            Sobha_Connect__r.Name,
            Sobha_Connect__r.Agent_Category__c,
            Sobha_Connect__r.Name__c,
            Sobha_Connect__r.Contact_Person__c,
            Unit__c,
            Sales_Head__r.Name,
            Sales_Managers__c,
            Sales_Managers__r.Name,
            Secondary_Sales_Head__c,
            Saleable_Area__c,
            Agreement_Value__c,
            Unit__r.Tower__r.Date_of_Completion__c,
            Unit__r.Tower__r.Cluster__r.Name,
            Unit__r.Tower__r.Name,
            Opportunity__r.Channel_Partner__c,
            Opportunity__r.Channel_Partner__r.Name,
            Opportunity__r.Channel_Partner__r.Contact_Person__c,
            Opportunity__r.Channel_Partner__r.Channel_Partner_Id__c,
            Opportunity__r.Channel_Partner__r.Category__c,
            Opportunity__r.Walk_In_CP__c,
            Opportunity__r.Walk_In_CP__r.Name,
            Opportunity__r.Walk_In_CP__r.Contact_Person__c,
            Opportunity__r.Walk_In_CP__r.Channel_Partner_Id__c,
            Opportunity__r.Walk_In_CP__r.Category__c,
            Opportunity__r.Sobha_Connect__c,
            Opportunity__r.Sobha_Connect__r.Name,
            Opportunity__r.Sobha_Connect__r.Contact_Person__c,
            Opportunity__r.Sobha_Connect__r.Name__c,
            Opportunity__r.Sobha_Connect__r.Agent_Category__c,
            Opportunity__r.Walk_In_SC__c,
            Opportunity__r.Walk_In_SC__r.Name,
            Opportunity__r.Walk_In_SC__r.Contact_Person__c,
            Opportunity__r.Walk_In_SC__r.Name__c,
            Opportunity__r.Walk_In_SC__r.Agent_Category__c,
            Opportunity__r.LeadSource,
            Opportunity__r.Lead_Sub_Source__c,
            Quotation__c,
            Opportunity__r.Walk_in_Source__c,
            (
                SELECT Id, Booking__c, Offer__c, Offer__r.Name, Remarks__c
                FROM Booking_Offers__r
            ),
            (
                SELECT
                Id,
                Name,
                Nationality__c,
                Applicant_Number__c,
                Salutation__c,
                POA_Nationality__c,
                POA_2_Nationality__c,
                Type_Of_Applicant__c
                FROM ApplicantDetails__r
                ORDER BY createddate ASC
            ),
            (
                SELECT
                Id,
                Secondary_Sales_Manager__c,
                Secondary_Sales_Manager__r.Name,
                Sales_Manager_Value__c,
                Sales_Manager_Value__r.Name,
                Blocking_Amount_Paid__c,
                Booked_Date__c,
                Declared_Date__c,
                Approval_Status__c,
                Payment_Request__r.Lead_Source_Category__c,
                Payment_Request__r.Lead_Source_Sub_Category__c,
                Payment_Request__c,
                Sales_Value__c,
                Discounted_Sales_Value__c,
                Discount__c,
                Agent_Name__c,
                CP_ID__c
                FROM New_Sale_Approvals__r
                WHERE Approval_Status__c = 'Approved'
            )
            FROM Booking__c
            WHERE Id IN :newList AND SMT__c != TRUE
        ]) {
            bookingList.add(booking);
            quottationIds.add(booking.Quotation__c);
            oppList.add(booking.Opportunity__c);
            if(!booking.New_Sale_Approvals__r.isempty())
                NSAList.add(booking.New_Sale_Approvals__r[0].Id);
            DateTime dT = booking.Booking_Date__c;
            Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
            applicantList.add(booking.Primary_Applicant_Email__c);
            
        }
        Map<id,SBTR__c> sbtrListofPrevious = new Map<id,SBTR__c>();
        
        for(Booking__c bk : [
            SELECT Id, Name, Booking_Date__c, Applicant_Details__c,Primary_Applicant_Email__c,
            (SELECT Id FROM SBTRs__r ) FROM Booking__c WHERE Primary_Applicant_Email__c IN:applicantList
        ]){
            
            if(bk.Primary_Applicant_Email__c != null){
                DateTime dT = bk.Booking_Date__c;
                Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
                if(bookingListMap.containsKey(d+'-'+bk.Primary_Applicant_Email__c)){ bookingListMap.get(d+'-'+bk.Primary_Applicant_Email__c).add(bk); } 
                else {
                    bookingListMap.put(d+'-'+bk.Primary_Applicant_Email__c, new List<Booking__c>{bk});
                }
            }
        }
        
        for(Quotation__c quotation : [
            SELECT Id,(SELECT Id, Milestone_Due_Date__c,Total_Installment__c,Charge1Percentage__c FROM Payment_Milestones__r order by Milestone_Due_Date__c Desc )
            FROM Quotation__c WHERE Id IN:quottationIds
        ]) {
            quotationIdBypaymentmilstoneListMap.put(quotation.Id,quotation.Payment_Milestones__r);
        }
        list<string> oldBookingId = new list<string>();
        Map<String, List<Cancelled_Unit_Detail__c>> NSAUnitListMap = new Map<String, List<Cancelled_Unit_Detail__c>>();
        for(unit_hold_request__c NSA : [SELECT Id,(select id,Old_Unit__r.name,Old_Booking_Date__c,Old_Booking__c from Exit_Unit_Details__r) FROM unit_hold_request__c WHERE Id In: NSAList
                                       ]) {
                                           NSAUnitListMap.put(NSA.Id,NSA.Exit_Unit_Details__r);
                                           for(Cancelled_Unit_Detail__c cancelledUnit : NSA.Exit_Unit_Details__r) { oldBookingId.add(cancelledUnit.Old_Booking__c); }
                                           
                                       }
        map<string,string> oldbbokingtoTo = new map<string,string>();
        for(Cancelled_Unit_Detail__c cancelled : [SELECT Id,old_Booking__c,New_Sale_Approval__c,New_Sale_Approval__r.Booking__r.Booking_Date__c,New_Sale_Approval__r.Unit__c,
                                                  New_Sale_Approval__r.Booking__c FROM Cancelled_Unit_Detail__c WHERE old_Booking__c In: oldBookingId AND New_Sale_Approval__r.Booking__c != null
                                                 ]) {
                                                     if(oldbbokingtoTo.containsKey(cancelled.old_Booking__c)){
                                                         if(cancelled.New_Sale_Approval__c != null && cancelled.New_Sale_Approval__r.Booking__c != null){
                                                             string tosting = oldbbokingtoTo.get(cancelled.old_Booking__c)+';'+cancelled.New_Sale_Approval__r.Unit__c+'--'+cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.day()+'-'+cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.format('MMM')+'-'+ cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.year()+'';
                                                             oldbbokingtoTo.put(cancelled.old_Booking__c,tosting);   
                                                         }
                                                         
                                                     } else {
                                                         oldbbokingtoTo.put(cancelled.old_Booking__c,'To: '+cancelled.New_Sale_Approval__r.Unit__c+'--'+cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.day()+'-'+cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.format('MMM')+'-'+ cancelled.New_Sale_Approval__r.Booking__r.Booking_Date__c.year()+'');
                                                     }
                                                     
                                                 }
        for(Booking__c booking : [SELECT Id,unit__r.Name,Booking_Date__c,(SELECT Id,Swap_Details__c FROM SBTRs__r order by createddate ASC) FROM Booking__c WHERE Id IN:oldBookingId
                                 ]) {
                                     cancelledSBTrMap.put(booking.Id,booking.SBTRs__r);
                                 }
        Map<String, List<SBTR__c>> existingSBTRMap = new Map<String, List<SBTR__c>>();
        
        for(opportunity opp : [SELECT Id,(SELECT Id,New_Sale_Approval__c,Total_Booking_Amount_Received__c,Booked_Date__c,Declared_Date__c FROM SBTRs__r order by createddate ASC) FROM opportunity WHERE Id IN:oppList
                              ]) {
                                  existingSBTRMap.put(opp.Id,opp.SBTRs__r);
                              }
        
        for(Booking__c booking : bookingList) {
            //if ( (isUpdate || isInsert ) && (!booking.New_Sale_Approvals__r.isEmpty() && booking.New_Sale_Approvals__r[0].Approval_Status__c == 'Approved') || (booking.New_Sale_Approvals__r.isEmpty() && booking.Initiate_SBTR__c ==  true && booking.Booking_to_SBTR_Appro__c == 'SBTR Approved' )) 
            if ( 
                (isUpdate || isInsert) && 
                ((!booking.New_Sale_Approvals__r.isEmpty() && booking.New_Sale_Approvals__r[0].Approval_Status__c == 'Approved') || 
                 (booking.New_Sale_Approvals__r.isEmpty() && 
                  booking.Initiate_SBTR__c ==  true && 
                  booking.Booking_to_SBTR_Appro__c == 'SBTR Approved'))
            )
            {
                boolean checkbulkbooking = false;
                DateTime dT = booking.Booking_Date__c;
                Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
                list<Booking__c> previousBookings =bookingListMap.get(d+'-'+booking.Primary_Applicant_Email__c);
                
                if(bookingListMap.get(d+'-'+booking.Primary_Applicant_Email__c)!= null && previousBookings.size() >= 3){
                    checkbulkbooking = true;
                    for(Booking__c prevbook : previousBookings){
                        if(!prevbook.SBTRs__r.isempty()){
                            list<SBTR__c> SBTRRecList = updateSBTRBulk(prevbook.SBTRs__r);
                            for(SBTR__c s : SBTRRecList){
                                sbtrListofPrevious.put(s.Id,s);   
                            }
                        }
                        
                    }  
                }
                List<SBTR__c> existing = new List<SBTR__c>();
                
                if (booking.Opportunity__c != null && existingSBTRMap.get(booking.Opportunity__c) != null && !existingSBTRMap.get(booking.Opportunity__c).isEmpty()) {
                    existing =existingSBTRMap.get(booking.Opportunity__c);
                    
                    if(!existing.isempty()){
                        
                        bookingIdBySBTRListMap.put(booking.Name, new List<SBTR__c>());
                        integer checkSBTRNumber =1;
                        for(SBTR__c sbtrRecordExt : existing){
                            
                            
                            SBTR__c SBTRRec = updateSBTR(booking,quotationIdBypaymentmilstoneListMap,sbtrRecordExt,checkbulkbooking,NSAUnitListMap,checkSBTRNumber,oldbbokingtoTo);
                            
                            bookingIdBySBTRListMap.get(booking.Name).add(SBTRRec);  
                            
                            checkSBTRNumber=checkSBTRNumber+1;
                            
                        }     
                        if(existing.size()<2 && (booking.Secondary_Sales_Manager__c != null)){
                            SBTR__c SBTRRec =createSBTR(booking,quotationIdBypaymentmilstoneListMap,checkbulkbooking,NSAUnitListMap,2,oldbbokingtoTo);
                            SBTRRec.New_Sale_Approval__c =existing[0].New_Sale_Approval__c;
                            SBTRRec.Total_Booking_Amount_Received__c = existing[0].Total_Booking_Amount_Received__c;
                            SBTRRec.Booked_Date__c = existing[0].Booked_Date__c;
                            SBTRRec.Declared_Date__c = existing[0].Declared_Date__c;
                            
                            
                            bookingIdBySBTRListMap.get(booking.Name).add(SBTRRec);        
                            
                        }
                    }
                    
                }
                else if(booking.Booked_Date__c != null && booking.New_Sale_Approvals__r.isEmpty()){
                    bookingIdBySBTRListMap.put(booking.Name, new List<SBTR__c>());
                    bookingIdBySBTRListMap.get(booking.Name).add(createSBTR(booking,quotationIdBypaymentmilstoneListMap,checkbulkbooking,NSAUnitListMap,1,oldbbokingtoTo));
                    if (booking.Secondary_Sales_Manager__c != null) {
                        bookingIdBySBTRListMap.get(booking.Name).add(createSBTR(booking,quotationIdBypaymentmilstoneListMap,checkbulkbooking,NSAUnitListMap,2, oldbbokingtoTo));
                    }
                    
                }
                
            }
            
            if (bookingIdBySBTRListMap.get(booking.Name) != null) {
                for (SBTR__c sbtrRec : bookingIdBySBTRListMap.get(booking.Name)) {
                    sbtrRec.Manual_BookingAmount_Received__c = booking.SBTR_Booking_Amount_Received_AED__c;
                    sbtrRec.Category__c = booking.SBTR_Category__c;
                    if(sbtrRec.Declared_Date__c == null && booking.SBTR_Declared__c != null) sbtrRec.Declared_Date__c = booking.SBTR_Declared__c;
                }
            }
            
            
            
        }
        
        for(Collection_Report__c collReport : [
            SELECT Id, Booking__c FROM Collection_Report__c WHERE Booking__c IN :bookingIdBySBTRListMap.keySet()
        ]){ bookingNameByCollReportMap.put(collReport.Booking__c, collReport); }
        
        for(String bookingName : bookingIdBySBTRListMap.keySet()) {
            
            if (bookingNameByCollReportMap.containsKey(bookingName)) {
                
                for(SBTR__c sbtr : bookingIdBySBTRListMap.get(bookingName)) {
                    sbtr.Collection_Report__c  = bookingNameByCollReportMap.get(bookingName).Id;
                    sbtrList.add(sbtr);
                }
            }
            else{
                sbtrList.addAll( bookingIdBySBTRListMap.get(bookingName));
            }
        }
        
        if (!sbtrListofPrevious.isEmpty())  Upsert sbtrListofPrevious.values();
        if (!sbtrList.isEmpty()) {
            
            Upsert sbtrList;
        }
        if (!cancelledSBTrtoUpdate.values().isEmpty()) Upsert cancelledSBTrtoUpdate.values();
        
        
    }
    
    public static SBTR__c createSBTR(Booking__c booking,Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap,boolean checkbulkbooking,  Map<String, List<Cancelled_Unit_Detail__c>> NSAUnitListMap,integer checkSBTRNumber,map<string,string> oldbbokingtoTo) {
        
        SBTR__c sbtr = new SBTR__c();
        sbtr.Booking__c = booking.Id;
        sbtr.Opportunity__c = booking.Opportunity__c;
        
        
        integer checkApplicant = 1;
        string applicantName;
        
        for(Applicant_Details__c applicanDetails : booking.ApplicantDetails__r) {
            IF(applicanDetails.Applicant_Number__c =='Primary Applicant'){
                sbtr.Applicant_Details__c =applicanDetails.Id;  
                if(applicanDetails.Type_Of_Applicant__c=='Individual Purchaser')
                    sbtr.Customer_Nationality__c=applicanDetails.Nationality__c ;
                
                if(applicanDetails.Type_Of_Applicant__c=='Corporate Purchaser'){
                    sbtr.Primary_Customer_Nationality__c=applicanDetails.POA_Nationality__c;  
                    sbtr.Secondary_Customer_Nationality__c=applicanDetails.POA_2_Nationality__c;                               
                }
            }
            ELSE{
                if( sbtr.Joint_Applicant_Names__c == null)
                    sbtr.Joint_Applicant_Names__c =applicanDetails.Name;
                else
                    sbtr.Joint_Applicant_Names__c =  sbtr.Joint_Applicant_Names__c+','+applicanDetails.Name;  
            }
            
            
            checkApplicant = checkApplicant+1;
            if(applicantName == null)
                applicantName = applicanDetails.Name;
            else
                applicantName = applicantName+' & '+applicanDetails.Name; 
        }
        if(applicantName != null)
            sbtr.Name_of_Party__c =applicantName.removeEnd('&');  
        sbtr.Unit__c = booking.Unit__c;
        sbtr.Channel_Partner__c = booking.Channel_Partner__c;
        
        if(booking.Sales_Managers__c != null) sbtr.Sales_Manager__c = booking.Sales_Managers__r.name;
        if(booking.Secondary_Sales_Manager__c != null)
            sbtr.Secondary_Sales_Manager__c = booking.Secondary_Sales_Manager__r.Name;
        
        system.debug('checkSBTRNumber'+checkSBTRNumber);
        
        if (checkSBTRNumber == 1) {
            if(booking.Sales_Managers__c != null){ sbtr.Attended_by__c = booking.Sales_Managers__r.name; }
            if(booking.Secondary_Sales_Manager_VP__c != null){ sbtr.Team_Head__c = booking.Secondary_Sales_Manager_VP__r.name; sbtr.Team_Head_2__c = booking.Secondary_Sales_Manager_VP__r.Name; }
            if(booking.Sales_Head__c != null){ sbtr.Sales_Head__c = booking.Sales_Head__r.Name; }
        } else if (checkSBTRNumber != null) {
            if(booking.Secondary_Sales_Manager__c != null){
                sbtr.Attended_by__c = booking.Secondary_Sales_Manager__r.Name;
            }
            if(booking.Secondary_Sales_Head_VP2__c != null){ sbtr.Team_Head__c = booking.Secondary_Sales_Head_VP2__r.Name; sbtr.Team_Head_2__c = booking.Secondary_Sales_Head_VP2__r.Name; }
            if(booking.Secondary_Sales_Head__c != null){ sbtr.Sales_Head__c = booking.Secondary_Sales_Head__r.Name; }
        }
        
        sbtr.Project_Sub_Type_New__c = booking?.Unit__r?.Tower__r?.Name;
        sbtr.Product_Group_1_New__c = booking?.Unit__r?.Tower__r?.Cluster__r?.Name;
        sbtr.Product_Group_2_New__c = booking?.Unit__r?.Tower__r?.Name;
        
        //sbtr.Saleable_Area_sq_ft__c = booking.Saleable_Area__c;
        sbtr.Saleable_Area_sq_ft__c = booking.Unit__r.Chargeable_Area__c;
        if(booking.Opportunity__r.Channel_Partner__c == null && 
            booking.Opportunity__r.Sobha_Connect__c == null && 
            booking.Opportunity__r.Walk_In_CP__c == null && 
            booking.Opportunity__r.Walk_In_SC__c == null && 
            booking.Channel_Partner__c == null && 
            booking.Sobha_Connect__c == null
        ){
            sbtr.Broker_Company_Name_New__c = 'NA';
            sbtr.Broker_Contact_Name_New__c = 'NA';
        }
        if(booking.Opportunity__r.Channel_Partner__c != null){
            sbtr.SFDC_CPID__c = booking.Opportunity__r.Channel_Partner__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = booking.Opportunity__r.Channel_Partner__r.Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Opportunity__r.Channel_Partner__r.Name;
            sbtr.Broker_Contact_Name_New__c = booking.Opportunity__r.Channel_Partner__r.Contact_Person__c;
        }
        if(booking.Opportunity__r.Sobha_Connect__c != null){
            sbtr.SFDC_CPID__c = booking.Opportunity__r.Sobha_Connect__r.Name;
            sbtr.Category_Agent_New__c = booking.Opportunity__r.Sobha_Connect__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Opportunity__r.Sobha_Connect__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = booking.Opportunity__r.Sobha_Connect__r.Contact_Person__c;
        }

        if (booking.Opportunity__r.Walk_In_CP__c != null) {
            sbtr.SFDC_CPID__c = booking.Opportunity__r.Walk_In_CP__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = booking.Opportunity__r.Walk_In_CP__r.Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Opportunity__r.Walk_In_CP__r.Name;
            sbtr.Broker_Contact_Name_New__c = booking.Opportunity__r.Walk_In_CP__r.Contact_Person__c;
        } 
        if (booking.Opportunity__r.Walk_In_SC__c != null) {
            sbtr.SFDC_CPID__c = booking.Opportunity__r.Walk_In_SC__r.Name;
            sbtr.Category_Agent_New__c = booking.Opportunity__r.Walk_In_SC__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Opportunity__r.Walk_In_SC__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = booking.Opportunity__r.Walk_In_SC__r.Contact_Person__c;
        }

        if (booking.Channel_Partner__c != null) {
            sbtr.SFDC_CPID__c = booking.Channel_Partner__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = booking.Channel_Partner__r.Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Channel_Partner__r.Name;
            sbtr.Broker_Contact_Name_New__c = booking.Channel_Partner__r.Contact_Person__c;
        }
        if (booking.Sobha_Connect__c != null) {
            sbtr.SFDC_CPID__c = booking.Sobha_Connect__r.Name;
            sbtr.Category_Agent_New__c = booking.Sobha_Connect__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = booking.Sobha_Connect__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = booking.Sobha_Connect__r.Contact_Person__c;
        }
        
        sbtr.Booked_Date__c = booking.Booked_Date__c;
        
        sbtr.Sale_Value_AED__c = booking.Agreement_Value__c;
        if(booking.Paid_Amount_For_Process__c!=null && booking?.Unit__r?.Puchase_Price__c != null)
            sbtr.POP_Percentage_New__c = (booking.Paid_Amount_For_Process__c / booking.Unit__r.Puchase_Price__c)*100;
        sbtr.Chargeable_Area_sq_ft__c = booking.Unit__r.Chargeable_Area__c;
        sbtr.Bulk_Deal__c= checkbulkbooking;
        if(checkbulkbooking) sbtr.Bulk_Booking_Date__c= date.valueof(booking.Booking_Date__c);
        
        //sbtr.SFDC_CPID__c = booking.Channel_Partner__r.Channel_Partner_Id__c;
        
        if(!quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c).isEmpty()){
            if(quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Milestone_Due_Date__c > booking.Unit__r.Tower__r.Date_of_Completion__c){
                if(quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Total_Installment__c != 0 && quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Charge1Percentage__c != 0)
                    sbtr.Post_Completion_Payment_Plan__c = (quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Charge1Percentage__c *  100)/quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Total_Installment__c;
                Integer numberDaysDue = booking.Unit__r.Tower__r.Date_of_Completion__c.daysBetween(  quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c)[0].Milestone_Due_Date__c);
                
                sbtr.Post_Completion_Payment_Plan_Years__c = numberDaysDue/365;    
            }
            else{
                sbtr.Normal_Payment_Plan_on_Completion__c = (quotationIdBypaymentmilstoneListMap.get(booking.Quotation__c))[0].Charge1Percentage__c;
            }
            
        }
        if (!booking.New_Sale_Approvals__r.isEmpty()) {
            sbtr.Total_Booking_Amount_Received__c = booking.New_Sale_Approvals__r[0].Blocking_Amount_Paid__c;
            if(booking?.New_Sale_Approvals__r[0]?.Payment_Request__r?.Lead_Source_Category__c=='Marketing' || booking?.New_Sale_Approvals__r[0]?.Payment_Request__r?.Lead_Source_Category__c=='Direct'){
                sbtr.SFDC_CPID__c = booking.New_Sale_Approvals__r[0].Payment_Request__r.Lead_Source_Sub_Category__c;
                sbtr.Broker_Company_Name_New__c = 'NA';
                sbtr.Broker_Contact_Name_New__c = 'NA';
            }
            if (
                booking?.New_Sale_Approvals__r[0]?.Agent_Name__c != null && 
                booking?.New_Sale_Approvals__r[0]?.Agent_Name__c != ''
            ) {
                sbtr.Broker_Contact_Name_New__c = booking?.New_Sale_Approvals__r[0]?.Agent_Name__c;
            }
            
            if (
                booking?.New_Sale_Approvals__r[0]?.CP_ID__c != null && 
                booking?.New_Sale_Approvals__r[0]?.CP_ID__c != ''
            ) {
                sbtr.SFDC_CPID__c = booking?.New_Sale_Approvals__r[0]?.CP_ID__c;
            }
            if(booking.New_Sale_Approvals__r[0].Blocking_Amount_Paid__c != null && booking.Unit__r.Puchase_Price__c != null){
                sbtr.POP_Percentage_New__c = (booking.New_Sale_Approvals__r[0].Blocking_Amount_Paid__c / booking.Unit__r.Puchase_Price__c)*100;
            }
            if(booking.New_Sale_Approvals__r[0].Discount__c != null && booking.New_Sale_Approvals__r[0].Discount__c > 0){
                sbtr.Sale_Value_AED__c = booking.New_Sale_Approvals__r[0].Discounted_Sales_Value__c;
            }
            else{
                sbtr.Sale_Value_AED__c = booking.New_Sale_Approvals__r[0].Sales_Value__c;
            }
            if(booking.New_Sale_Approvals__r[0].Sales_Manager_Value__c != null){
                sbtr.Sales_Manager__c = booking.New_Sale_Approvals__r[0].Sales_Manager_Value__r.Name;
            }
            if(booking.New_Sale_Approvals__r[0].Secondary_Sales_Manager__c != null){
                sbtr.Secondary_Sales_Manager__c = booking.New_Sale_Approvals__r[0].Secondary_Sales_Manager__r.Name;
            }
            if(checkSBTRNumber == 1 && booking.New_Sale_Approvals__r[0].Sales_Manager_Value__c != null){
                sbtr.Attended_by__c = booking.New_Sale_Approvals__r[0].Sales_Manager_Value__r.Name;  
            }
            else if(checkSBTRNumber != null && booking.New_Sale_Approvals__r[0].Secondary_Sales_Manager__c != null){
                sbtr.Attended_by__c = booking.New_Sale_Approvals__r[0].Secondary_Sales_Manager__r.Name;
            }
            if(booking.New_Sale_Approvals__r[0].Approval_Status__c =='Approved'){
                sbtr.Booked_Date__c = booking.New_Sale_Approvals__r[0].Booked_Date__c;
                if(booking.New_Sale_Approvals__r[0].Declared_Date__c != null){
                    sbtr.Declared_Date__c = booking.New_Sale_Approvals__r[0].Declared_Date__c;
                }
                sbtr.New_Sale_Approval__c = booking.New_Sale_Approvals__r[0].Id;
                if(booking.New_Sale_Approvals__r[0].Payment_Request__c != null){
                    sbtr.Source_Classification_1__c = booking.New_Sale_Approvals__r[0].Payment_Request__r.Lead_Source_Category__c;
                    sbtr.Source_Classification_2__c = booking.New_Sale_Approvals__r[0].Payment_Request__r.Lead_Source_Sub_Category__c;   
                }
                
                string swapdetails = '';
                if (!NSAUnitListMap.get(booking.New_Sale_Approvals__r[0].Id).isEmpty()) {
                    list<Cancelled_Unit_Detail__c> listOfUnits = NSAUnitListMap.get(booking.New_Sale_Approvals__r[0].Id);
                    for(Cancelled_Unit_Detail__c canUnit :  NSAUnitListMap.get(booking.New_Sale_Approvals__r[0].Id)) {
                        
                        Integer d = canUnit.Old_Booking_Date__c.day();
                        Integer mo = canUnit.Old_Booking_Date__c.month();
                        Integer yr = canUnit.Old_Booking_Date__c.year();
                        
                        DateTime DT = DateTime.newInstance(yr, mo, d);
                        if(swapdetails == null || swapdetails == ''){
                            
                            swapdetails = 'From '+canUnit.Old_Unit__r.name+'--'+canUnit.Old_Booking_Date__c.day()+'-'+DT.format('MMM')+'-'+ canUnit.Old_Booking_Date__c.year()+';';
                        }
                        else {
                            
                            swapdetails = swapdetails+canUnit.Old_Unit__r.name+'--'+ canUnit.Old_Booking_Date__c.day()+'-'+DT.format('MMM')+'-'+ canUnit.Old_Booking_Date__c.year()+';';
                            
                        }  
                        for(SBTR__c cancelSBTr : cancelledSBTrMap.get(canUnit.Old_Booking__c) ) {      
                            cancelSBTr.Swap_Details__c = oldbbokingtoTo.get(canUnit.Old_Booking__c);//'To: '+booking.Unit__r.Name+'--'+booking.Booking_Date__c.day()+'-'+booking.Booking_Date__c.format('MMM')+'-'+ booking.Booking_Date__c.year()+'';
                            cancelledSBTrtoUpdate.put(cancelSBTr.Id,cancelSBTr);
                        }
                        
                    }
                }
                if(swapdetails != null){
                    swapdetails=swapdetails;//+'To: '+booking.Unit__r.Name+'<'+date.valueof(booking.Booking_Date__c)+'>';
                    sbtr.Swap_Details__c = swapdetails;
                }
            }
        }
        if (!booking.Booking_Offers__r.isEmpty()) {
            for(Booking_Offers__c bookingOffer : booking.Booking_Offers__r) {
                if(bookingOffer.Offer__r.Name != NULL){
                    if(bookingOffer?.Offer__r?.Name?.contains('DLD')!=NULL){
                        sbtr.DLD_Waiver__c = bookingOffer.Offer__r.Name.substringafter(' ');
                        
                    }
                    else if(bookingOffer?.Offer__r?.Name?.contains('Service Charge')!=NULL){
                        sbtr.Service_Charge_Waiver__c = bookingOffer.Offer__r.Name.substringafter(' ');  
                    }
                    if(sbtr.Booking_Offers__c == null)
                        sbtr.Booking_Offers__c =bookingOffer.Offer__r.Name;
                    else
                        sbtr.Booking_Offers__c = sbtr.Booking_Offers__c+','+bookingOffer.Offer__r.Name;
                }
                
            }
        }
        return sbtr;
    }
    public static SBTR__c updateSBTR(Booking__c booking,Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap,SBTR__c sbtrRec,boolean checkbulkbooking, Map<String, List<Cancelled_Unit_Detail__c>> NSAUnitListMap,integer checkSBTRNumber,map<string,string> oldbbokingtoTo) {
        
        SBTR__c SBTR = createSBTR(booking,quotationIdBypaymentmilstoneListMap, checkbulkbooking,NSAUnitListMap,checkSBTRNumber,  oldbbokingtoTo) ;
        SBTR.Id= sbtrRec.Id;
        return SBTR;
    }
    public static List<SBTR__c> updateSBTRBulk(List<SBTR__c> sbtrList) {
        
        for(SBTR__c sbtr : sbtrList) {
            SBTR.Bulk_Deal__c= true;
        }
        return sbtrList;
    }
    public static void sendEmailOnBookingCancellation(List<Booking__c> newList){
        
        String noReplyEmail = '';
        OrgWideEmailAddress[] noReplyAddress = [select Id from OrgWideEmailAddress where Address = 'noreply@sobharealty.com'];
        if ( noReplyAddress.size() > 0 ) {
            noReplyEmail = noReplyAddress.get(0).Id;
        }
        List<Booking__c> bookingToSendEmail = new List<Booking__c>();
        List<String> validReasons = new List<String>{'15 days - 0%', '30 days - unit not qualified'};
            for(Booking__c booking1 : newList){
                if(booking1.status__c == 'Cancelled' &&
                   validReasons.contains(booking1.Reason_For_Cancellation_D__c)){
                       bookingToSendEmail.add(booking1);
                   }
            }       
        if(bookingToSendEmail.isEmpty()){ return; }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
        List<Booking__c> bookingToProcess = [SELECT Id, 
                                             Sales_Managers__r.managerid, 
                                             Unit__c,
                                             Unit__r.Name,
                                             Tower__c,
                                             Opportunity__c, 
                                             Project__r.Name,
                                             Primary_Applicant_Name__c,
                                             Primary_Applicant_Email__c,
                                             Paid_Percentage__c,
                                             Agreement_Value__c ,
                                             Sales_Head__r.ManagerId,
                                             Sales_Head__r.Manager.Email,
                                             Secondary_Sales_Head__r.ManagerId,
                                             Secondary_Sales_Head__r.Manager.Email,
                                             Secondary_Sales_Manager_VP__r.email,
                                             Sales_Head__r.email,
                                             Sales_Managers__r.email,
                                             Secondary_Sales_Manager__r.email,
                                             Secondary_Sales_Manager_VP__r.ManagerId,
                                             Secondary_Sales_Head_VP2__r.ManagerId,  
                                             Secondary_Sales_Manager_VP__r.Manager.Email,
                                             Secondary_Sales_Head_VP2__r.Manager.Email,  
                                             unit__r.Customers__c,
                                             Booking_Date__c,
                                             Secondary_Sales_Head__r.email,
                                             unit__r.Tower__r.name,
                                             ownerID,
                                             
                                             (SELECT Name, Email_Address__c FROM ApplicantDetails__r WHERE Applicant_Number__c != 'Primary Applicant') 
                                             FROM Booking__c 
                                             WHERE ID IN :bookingToSendEmail];
        for(Booking__c booking: bookingToProcess)
        {
            for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                if(!mapOfBookingToAddress.containsKey(booking.id)){
                    mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                }else{
                    mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                }
            }
        }
        Map<Id, Messaging.SingleEmailMessage> bookingIdtoEmailMap = new Map<Id, Messaging.SingleEmailMessage>();
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where developername = 'Booking_Cancellation_Email_V1'];
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        List<String> invalidEmails = new List<String>();
        user u = [select id,lastname,email,Manager.email,Manager.Manager.email from User where Id =: bookingToProcess[0].OwnerId];
        Contact dummyContact = new Contact(LastName = u.lastName, Email = u.Email);
        insert dummyContact;
        
        for(Booking__c booking1 : bookingToProcess){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            if(noReplyEmail != '') {
                email.setOrgWideEmailAddressId(noReplyEmail);
            }
            List <String> lststringtoaddress = new List<String>();
            List <String> lstStringccaddress = new List <String>();
            List <String> lstStringbccaddress = new List <String>();
            
            
            String emailAddressFromBooking = mapOfBookingToAddress.get(booking1.id);
            if(!string.isBlank(emailAddressFromBooking)){ lststringtoaddress.addAll(emailAddressFromBooking.split(',')); }
            if(booking1.Primary_Applicant_Email__c != null && booking1.Primary_Applicant_Email__c != ''){
                lstStringtoaddress.add(booking1.Primary_Applicant_Email__c);
            }
            SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
            if(booking1.Sales_Head__c != null){
                lstStringccaddress.add(booking1.Sales_Head__r.email);
                if(booking1.Sales_Head__r.ManagerId != null)
                    lstStringccaddress.add(booking1.Sales_Head__r.Manager.Email);
                SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
            }
            if(booking1.Secondary_Sales_Head__c!=null && booking1.Secondary_Sales_Head__r.ManagerId != null){
                lstStringccaddress.add(booking1.Secondary_Sales_Head__r.Manager.Email);
            }
            //code added by Roshan
            if(booking1.Secondary_Sales_Manager_VP__c!=null && booking1.Secondary_Sales_Manager_VP__r.ManagerId != null){ lstStringccaddress.add(booking1.Secondary_Sales_Manager_VP__r.Manager.Email); }
            if(booking1.Secondary_Sales_Head_VP2__c!=null && booking1.Secondary_Sales_Head_VP2__r.ManagerId != null){ lstStringccaddress.add(booking1.Secondary_Sales_Head_VP2__r.Manager.Email); }
            //-----
            if(booking1.Sales_Managers__c!=null){
                
                lstStringccaddress.add(booking1.Sales_Managers__r.email);
            }
            if(booking1.Secondary_Sales_Manager__c!=null){
                lstStringccaddress.add(booking1.Secondary_Sales_Manager__r.email);
            }
            if(booking1.Secondary_Sales_Head__c!=null){
                lstStringccaddress.add(booking1.Secondary_Sales_Head__r.email);
            }
            
            lstStringccaddress.add(System.label.SobhaSalesOp);
            lstStringccaddress.add(System.label.SobhaHelpdesk);
            lstStringccaddress.add(System.label.SF_Notifications);
            List<String> toAddressEmails = new List<String>();
            for(String toEmail : lststringtoaddress){
                Matcher MyMatcher = MyPattern.matcher(toEmail);
                if(!MyMatcher.matches()){ invalidEmails.add(toEmail);}
                else{
                    toAddressEmails.add(toEmail);
                }
            }
            List<String> ccAddressEmails = new List<String>();
            for(String ccEmail : lstStringccaddress){
                Matcher MyMatcher = MyPattern.matcher(ccEmail);
                if(!MyMatcher.matches()){
                    invalidEmails.add(ccEmail);
                }else{
                    ccAddressEmails.add(ccEmail);
                }
            }
            
            email.setToAddresses(toAddressEmails);
            email.setccAddresses(ccAddressEmails);
            email.setTemplateID(emailTemplate.Id); 
            email.setWhatId(booking1.Id);
            email.setTargetObjectId(dummyContact.Id);
            email.setTreatTargetObjectAsRecipient(false);
            
            email.setsaveAsActivity(false);
            bookingIdtoEmailMap.put(booking1.Id, email);
            system.debug('i am afteremail'+email);
            
        }
        
        Messaging.sendEmail(bookingIdtoEmailMap.values());
        delete dummyContact;
 
    }
}