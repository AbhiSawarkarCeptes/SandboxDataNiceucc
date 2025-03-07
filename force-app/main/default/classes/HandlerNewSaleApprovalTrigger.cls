public class  HandlerNewSaleApprovalTrigger {
    public static Boolean isFirstTime = true;
    
    public static void beforeUpdate(
        List<unit_hold_request__c> newList,
        Map<Id, unit_hold_request__c> oldMap
    ) {
        set<Id> ssmUserIds = new Set<Id>();
        set<Id> nsaIds = new Set<Id>();
        for (unit_hold_request__c nsa : newList) {
            if (
                nsa.Secondary_Sales_Manager__c != null &&
                nsa.Secondary_Sales_Manager__c !=
                oldMap.get(nsa.Id).Secondary_Sales_Manager__c
            ) {
                ssmUserIds.add(nsa.Secondary_Sales_Manager__c);
                nsaIds.add(nsa.Id);
            }
        }
        if (!ssmUserIds.isEmpty()) {
            Map<Id, User> userIdToUser = new Map<Id, User>();
            List<User> userList = [
                SELECT
                Id,
                ManagerId,
                Manager.ManagerId,
                Manager.Manager.ManagerId,
                Manager.Manager.Manager.ManagerId
                FROM User
                WHERE Id IN :ssmUserIds
            ];
            for (User u : userList) {
                userIdToUser.put(u.Id, u);
            }
            for (unit_hold_request__c nsa : newList) {
                if (nsaIds.contains(nsa.Id)) {
                    User u = userIdToUser.get(nsa.Secondary_Sales_Manager__c);
                    nsa.Secondary_Sales_Head__c = u?.ManagerId;
                    nsa.Secondary_Sales_Head_VP__c = u?.Manager?.ManagerId;
                    nsa.Secondary_Sales_Head_SVP__c = u?.Manager?.Manager?.ManagerId;
                    nsa.Secondary_CSO__c = u?.Manager?.Manager?.Manager?.ManagerId;
                }
            }
        }
    }
    
    public static void afterUpdate(List<unit_hold_request__c> newList, Map<Id, unit_hold_request__c> oldMap) {
        updateCreateSBTR(newList, oldMap);
        set<Id> nsaIdsToUpdateDeclaredDateOnSBTR = new set<Id>();
        for(unit_hold_request__c nsa : newList){
            if(
                nsa.Declared_Date__c != null &&
                nsa.Declared_Date__c != oldMap.get(nsa.Id).Declared_Date__c &&
                oldMap.get(nsa.Id).Declared_Date__c == null
            ){
                nsaIdsToUpdateDeclaredDateOnSBTR.add(nsa.Id);
            }
        }
        if(nsaIdsToUpdateDeclaredDateOnSBTR.size()>0){
            updateDeclaredDateOnSBTR(nsaIdsToUpdateDeclaredDateOnSBTR);
        }
    }
    
    public static void updateDeclaredDateOnSBTR(set<Id> nsaIdsToUpdateDeclaredDateOnSBTR){
        list<SBTR__c> sbtrToUpdate = new list<SBTR__c>();
        list<unit_hold_request__c> nsaList = [
            select Id,Declared_Date__c,
            (select Id,Declared_Date__c,Collection_10__c from SBTRs__r where Declared_Date__c = null) 
            from unit_hold_request__c    
            where Id IN : nsaIdsToUpdateDeclaredDateOnSBTR                      
        ];
        for(unit_hold_request__c nsa : nsaList){
            if(nsa.SBTRs__r != null){
                for(SBTR__c sbtr : nsa.SBTRs__r){
                    if(sbtr.Declared_Date__c == null){
                        sbtr.Declared_Date__c = nsa.Declared_Date__c;
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
                system.debug('SBTR UPDATE FAILED EXCEPTION MESSAGE: '+e.getMessage());
            }
        }
    }
    
    public static void updateCreateSBTR(List<unit_hold_request__c> newList, Map<Id, unit_hold_request__c> oldMap) {
        if(isFirstTime){
            List<SBTR__c> sbtrList = new List<SBTR__c>();
            Map<String, List<SBTR__c>> bookingIdBySBTRListMap = new Map<String, List<SBTR__c>>();
            Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap = new Map<String, List<Payment_Milestones__c>>();
            List<string> quottationIds = new List<string>();
            Boolean isInsert = oldMap == null;
            Boolean isUpdate = oldMap != null;
            Set<Id> bookingIdsToUpdate = new Set<Id>();
            
            for (unit_hold_request__c newApproval : [
                SELECT
                Id,
                Agent_Name__c,
                CP_ID__c,
                Approved_Date__c,
                Split_Deal__c,
                Sales_Value__c,
                Discounted_Sales_Value__c,
                Discount__c,
                Sales_Manager_Value__r.name,
                Applicant_Name1__c,
                Sales_Head__c,
                Opportunity__c,
                Payment_Request__r.Unit__r.Chargeable_Area__c,
                Payment_Request__r.Unit__c,
                Sales_Manager__c,
                Payment_Request__r.Unit__r.Tower__r.Date_of_Completion__c,
                Opportunity__r.LeadSource,
                Opportunity__r.Lead_Sub_Source__c,
                Booking__c,
                Booking__r.Name,
                Payment_Request__r.Lead_Source_Category__c,
                Blocking_Amount_Paid__c,
                Booked_Date__c,
                Declared_Date__c,
                Approval_Status__c,
                Sales_Head_Value__r.Name,
                Payment_Request__r.Lead_Source_Sub_Category__c,
                Payment_Request__r.Unit__r.Tower__r.Cluster__r.Name,
                Payment_Request__r.Unit__r.Tower__r.Name,
                Sales_Head_VP__c,
                Sales_Head_VP__r.Name,
                Payment_Request__r.Unit__r.Puchase_Price__c,
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
                Secondary_Sales_Manager__c,
                Secondary_Sales_Manager__r.Name,
                Booking__r.Secondary_Sales_Manager__c,
                Booking__r.Secondary_Sales_Manager__r.Name,
                Secondary_Sales_Head__c,
                Secondary_Sales_Head__r.Name,
                Secondary_Sales_Head_VP__c,
                Secondary_Sales_Head_VP__r.Name,
                Booking__r.Secondary_Sales_Head__c,
                Booking__r.Secondary_Sales_Head__r.Name,
                Booking__r.Secondary_Sales_Head_VP2__c,
                Booking__r.Secondary_Sales_Head_VP2__r.Name,
                Booking__r.Channel_Partner__c,
                Booking__r.Channel_Partner__r.Name,
                Booking__r.Channel_Partner__r.Contact_Person__c,
                Booking__r.Channel_Partner__r.Channel_Partner_Id__c,
                Booking__r.Channel_Partner__r.Category__c,
                Booking__r.Sobha_Connect__c,
                Booking__r.Sobha_Connect__r.Name,
                Booking__r.Sobha_Connect__r.Contact_Person__c,
                Booking__r.Sobha_Connect__r.Name__c,
                Booking__r.Sobha_Connect__r.Agent_Category__c
                FROM unit_hold_request__c
                WHERE
                Id IN :newList
                AND Approval_Status__c = 'Approved'
                AND Booked_Date__c != NULL
            ]) {
                if (
                    isUpdate && 
                    (oldMap.get(newApproval.Id).Approval_Status__c != newApproval.Approval_Status__c || 
                     oldMap.get(newApproval.Id).Booked_Date__c != newApproval.Booked_Date__c) && 
                    oldMap.get(newApproval.Id).Booked_Date__c == null
                ) 
                {
                    //bookingIdBySBTRListMap.put(newApproval.Booking__r.Name, new List<SBTR__c>());
                    //bookingIdBySBTRListMap.get(newApproval.Booking__r.Name).add(createSBTR(newApproval));
                    bookingIdBySBTRListMap.put(newApproval.Id + '1', new List<SBTR__c>());
                    bookingIdBySBTRListMap.get(newApproval.Id + '1').add(createSBTR(newApproval, 1));
                    if(
                        (newApproval.Split_Deal__c == true && newApproval.Secondary_Sales_Manager__c != null) || 
                        (newApproval.Booking__c != null && newApproval.Booking__r.Secondary_Sales_Manager__c != null)
                    )
                    {
                        bookingIdBySBTRListMap.put(newApproval.Id + '2', new List<SBTR__c>());
                        bookingIdBySBTRListMap.get(newApproval.Id + '2').add(createSBTR(newApproval, 2));
                    }
                    if(newApproval.Booking__c != null){
                        bookingIdsToUpdate.add(newApproval.Booking__c);
                    }
                }
                
            }
            for(String bookingName : bookingIdBySBTRListMap.keySet()) {
                sbtrList.addAll( bookingIdBySBTRListMap.get(bookingName));
                
            }
            if (!sbtrList.isEmpty()) {
                isFirstTime = false;
                insert sbtrList;
                try{
                    if(bookingIdsToUpdate.size()>0){
                        list<Booking__c> bookingList = [select Id from Booking__c where Id IN :bookingIdsToUpdate];
                        update bookingList;
                    }
                }
                catch(Exception e){
                    system.debug('BOOKING UPDATE FAILED EXCEPTION MESSAGE: '+e.getMessage());
                }
            }
        }
    }
    
    public static SBTR__c createSBTR(
        unit_hold_request__c newApproval,
        integer sbtrNumber
    ) {
        SBTR__c sbtr = new SBTR__c();
        if (newApproval.Booking__c != null)
            sbtr.Booking__c = newApproval.Booking__c;
        sbtr.Opportunity__c = newApproval.Opportunity__c;
        sbtr.Total_Booking_Amount_Received__c = newApproval.Blocking_Amount_Paid__c;
        sbtr.Unit__c = newApproval.Payment_Request__r.Unit__c;
        sbtr.New_Sale_Approval__c = newApproval.Id;
        sbtr.Sales_Manager__c = newApproval.Sales_Manager_Value__r.Name;
        sbtr.Secondary_Sales_Manager__c = newApproval
            ?.Secondary_Sales_Manager__r
            ?.Name;
        sbtr.Booked_Date__c = newApproval.Booked_Date__c;
        sbtr.Declared_Date__c = newApproval.Declared_Date__c;
        sbtr.Source_Classification_1__c = newApproval
            ?.Payment_Request__r
            ?.Lead_Source_Category__c;
        sbtr.Source_Classification_2__c = newApproval
            ?.Payment_Request__r
            ?.Lead_Source_Sub_Category__c;
        sbtr.Project_Sub_Type_New__c = newApproval
            ?.Payment_Request__r
            ?.Unit__r
            ?.Tower__r
            ?.Name;
        sbtr.Product_Group_1_New__c = newApproval
            ?.Payment_Request__r
            ?.Unit__r
            ?.Tower__r
            ?.Cluster__r
            ?.Name;
        sbtr.Product_Group_2_New__c = newApproval
            ?.Payment_Request__r
            ?.Unit__r
            ?.Tower__r
            ?.Name;
        if (sbtrNumber == 1){
            sbtr.Attended_by__c = newApproval?.Sales_Manager_Value__r?.Name;
            sbtr.Sales_Head__c = newApproval.Sales_Head_Value__r.Name;
            sbtr.Team_Head__c = newApproval.Sales_Head_VP__r?.Name;
            sbtr.Team_Head_2__c = newApproval?.Sales_Head_VP__r?.Name;
        }
        if (sbtrNumber == 2) {
            if (newApproval.Secondary_Sales_Manager__c != null) {
                sbtr.Attended_by__c = newApproval?.Secondary_Sales_Manager__r?.Name;
            } else if (
                newApproval.Booking__c != null &&
                newApproval.Booking__r.Secondary_Sales_Manager__c != null
            ) {
                sbtr.Attended_by__c = newApproval
                    ?.Booking__r
                    ?.Secondary_Sales_Manager__r
                    ?.Name;
            }
            if(newApproval.Secondary_Sales_Head__c != null){
                sbtr.Sales_Head__c = newApproval.Secondary_Sales_Head__r.Name;
            }
            else if(newApproval.Booking__c != null && newApproval.Booking__r.Secondary_Sales_Head__c != null){
                sbtr.Sales_Head__c = newApproval.Booking__r.Secondary_Sales_Head__r.Name;
            }
            if(newApproval.Secondary_Sales_Head_VP__c != null){
                sbtr.Team_Head__c = newApproval.Secondary_Sales_Head_VP__r.Name;
                sbtr.Team_Head_2__c = newApproval.Secondary_Sales_Head_VP__r.Name;
            }
            else if(newApproval.Booking__c != null && newApproval.Booking__r.Secondary_Sales_Head_VP2__c != null){
                sbtr.Team_Head__c = newApproval.Booking__r.Secondary_Sales_Head_VP2__r.Name;
                sbtr.Team_Head_2__c = newApproval.Booking__r.Secondary_Sales_Head_VP2__r.Name;
            }
        }
        sbtr.Chargeable_Area_sq_ft__c = newApproval
            ?.Payment_Request__r
            ?.Unit__r
            ?.Chargeable_Area__c;
        sbtr.Saleable_Area_sq_ft__c = newApproval
            ?.Payment_Request__r
            ?.Unit__r
            ?.Chargeable_Area__c;
        if (
            newApproval.Blocking_Amount_Paid__c != null &&
            newApproval.payment_Request__r.Unit__r.Puchase_Price__c != null
        ) {
            sbtr.POP_Percentage_New__c =
                (newApproval.Blocking_Amount_Paid__c /
                 newApproval.payment_Request__r.Unit__r.Puchase_Price__c) * 100;
        }

        if (
            newApproval?.Opportunity__r?.Channel_Partner__c == null &&
            newApproval?.Opportunity__r?.Sobha_Connect__c == null && 
            newApproval?.Opportunity__r?.Walk_In_CP__c == null && 
            newApproval?.Opportunity__r?.Walk_In_SC__c == null && 
            newApproval?.Booking__r?.Channel_Partner__c == null && 
            newApproval?.Booking__r?.Sobha_Connect__c == null
        ) {
            sbtr.Broker_Company_Name_New__c = 'NA';
            sbtr.Broker_Contact_Name_New__c = 'NA';
        }

        if (newApproval?.Opportunity__r?.Channel_Partner__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Opportunity__r.Channel_Partner__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = newApproval.Opportunity__r.Channel_Partner__r.Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Opportunity__r.Channel_Partner__r.Name;
            sbtr.Broker_Contact_Name_New__c = newApproval.Opportunity__r.Channel_Partner__r.Contact_Person__c;
        } 
        if (newApproval?.Opportunity__r?.Sobha_Connect__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Opportunity__r.Sobha_Connect__r.Name;
            sbtr.Category_Agent_New__c = newApproval.Opportunity__r.Sobha_Connect__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Opportunity__r.Sobha_Connect__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = newApproval.Opportunity__r.Sobha_Connect__r.Contact_Person__c;
        }

        if (newApproval?.Opportunity__r?.Walk_In_CP__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Opportunity__r.Walk_In_CP__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = newApproval.Opportunity__r.Walk_In_CP__r.Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Opportunity__r.Walk_In_CP__r.Name;
            sbtr.Broker_Contact_Name_New__c = newApproval.Opportunity__r.Walk_In_CP__r.Contact_Person__c;
        } 
        if (newApproval?.Opportunity__r?.Walk_In_SC__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Opportunity__r.Walk_In_SC__r.Name;
            sbtr.Category_Agent_New__c = newApproval.Opportunity__r.Walk_In_SC__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Opportunity__r.Walk_In_SC__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = newApproval.Opportunity__r.Walk_In_SC__r.Contact_Person__c;
        }

        if (newApproval?.Booking__r?.Channel_Partner__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Booking__r.Channel_Partner__r.Channel_Partner_Id__c;
            sbtr.Category_Agent_New__c = newApproval.Booking__r.Channel_Partner__r.Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Booking__r.Channel_Partner__r.Name;
            sbtr.Broker_Contact_Name_New__c = newApproval.Booking__r.Channel_Partner__r.Contact_Person__c;
        } 
        if (newApproval?.Booking__r?.Sobha_Connect__c != null) {
            sbtr.SFDC_CPID__c = newApproval.Booking__r.Sobha_Connect__r.Name;
            sbtr.Category_Agent_New__c = newApproval.Booking__r.Sobha_Connect__r.Agent_Category__c;
            sbtr.Broker_Company_Name_New__c = newApproval.Booking__r.Sobha_Connect__r.Name__c;
            sbtr.Broker_Contact_Name_New__c = newApproval.Booking__r.Sobha_Connect__r.Contact_Person__c;
        }
        
        if (
            newApproval?.Payment_Request__r?.Lead_Source_Category__c == 'Marketing' ||
            newApproval?.Payment_Request__r?.Lead_Source_Category__c == 'Direct'
        ) {
            sbtr.SFDC_CPID__c = newApproval.Payment_Request__r.Lead_Source_Sub_Category__c;
            sbtr.Broker_Company_Name_New__c = 'NA';
            sbtr.Broker_Contact_Name_New__c = 'NA';
        }
        
        if (
            newApproval.Agent_Name__c != null && 
            newApproval.Agent_Name__c != ''
        ) {
            sbtr.Broker_Contact_Name_New__c = newApproval.Agent_Name__c;
        }
        
        if (
            newApproval.CP_ID__c != null && 
            newApproval.CP_ID__c != ''
        ) {
            sbtr.SFDC_CPID__c = newApproval.CP_ID__c;
        }
        
        if (newApproval.Discount__c != null && newApproval.Discount__c > 0) {
            sbtr.Sale_Value_AED__c = newApproval.Discounted_Sales_Value__c;
        } else {
            sbtr.Sale_Value_AED__c = newApproval.Sales_Value__c;
        }
        
        sbtr.Initial_POP_Date__c = (newApproval.Approved_Date__c != null)
            ? newApproval.Approved_Date__c.date()
            : null;
        return sbtr;
    }
    
    @InvocableMethod(label = 'update SBTR')
    public static void  updateSBTR(List<String> SBTRApprovalId ){
        SBTR_Approval__c  approvalRec = [SELECT Id,Total_Booking_Amount_Received__c,SBTR__c,SBTR__r.booking__c,Sale_Value__c,Channel_Partner__c,Booked_Date__c,Deal_Type__c,Declared_Date__c,Source_Classification_1__c,Source_Classification_2__c,
                                         Sales_Manager__r.Name,Sales_Head__r.Name,Team_Head__r.Name,Team_Head_2__r.Name FROM SBTR_Approval__c where Id =: SBTRApprovalId[0]];
        
        List< SBTR__c>  SBTRRecList = [SELECT Id ,Sale_Value_AED__c,Total_Booking_Amount_Received__c,Booked_Date__c,Deal_Type__c,Sale_Value__c,Channel_Partner__c,Declared_Date__c,Source_Classification_1__c,Source_Classification_2__c,
                                       Sales_Manager__c,Sales_Head__c,Team_Head__c,Team_Head_2__c FROM
                                       SBTR__c where booking__c =: approvalRec.SBTR__r.booking__c];
        List< SBTR__c>  SBTRRecListtoupdate  = new  List< SBTR__c> ();
        for(SBTR__c SBTRRec : SBTRRecList) {
            SBTRRec.Booked_Date__c = (approvalRec.Booked_Date__c != Null ) ? approvalRec.Booked_Date__c : SBTRRec.Booked_Date__c;
            SBTRRec.Declared_Date__c = (approvalRec.Declared_Date__c != Null ) ? approvalRec.Declared_Date__c : SBTRRec.Declared_Date__c ;
            SBTRRec.Deal_Type__c = (approvalRec.Deal_Type__c != Null && approvalRec.Deal_Type__c != '' && approvalRec.Deal_Type__c != 'null') ? approvalRec.Deal_Type__c :SBTRRec.Deal_Type__c;
            SBTRRec.Source_Classification_1__c = (approvalRec.Source_Classification_1__c != Null && approvalRec.Source_Classification_1__c != ''  && approvalRec.Source_Classification_1__c != 'null') ? approvalRec.Source_Classification_1__c :  SBTRRec.Source_Classification_1__c;
            SBTRRec.Source_Classification_2__c = (approvalRec.Source_Classification_2__c != Null && approvalRec.Source_Classification_2__c != '') ? approvalRec.Source_Classification_2__c : SBTRRec.Source_Classification_2__c;
            SBTRRec.Sales_Manager__c = (approvalRec.Sales_Manager__c != Null ) ? approvalRec.Sales_Manager__r.Name :  SBTRRec.Sales_Manager__c;
            SBTRRec.Sales_Head__c = (approvalRec.Sales_Head__c != Null  ) ? approvalRec.Sales_Head__r.Name :  SBTRRec.Sales_Head__c;
            SBTRRec.Team_Head__c = (approvalRec.Team_Head__c != Null  ) ? approvalRec.Team_Head__r.Name :  SBTRRec.Team_Head__c;
            SBTRRec.Team_Head_2__c = (approvalRec.Team_Head_2__c != Null  ) ? approvalRec.Team_Head_2__r.Name :  SBTRRec.Team_Head_2__c;
            SBTRRec.Channel_Partner__c = (approvalRec.Channel_Partner__c != Null ) ? approvalRec.Channel_Partner__c : SBTRRec.Channel_Partner__c;
            SBTRRec.Sale_Value_AED__c = (approvalRec.Sale_Value__c != Null  ) ? approvalRec.Sale_Value__c :  SBTRRec.Sale_Value__c;
            SBTRRec.Total_Booking_Amount_Received__c = (approvalRec.Total_Booking_Amount_Received__c != Null ) ? approvalRec.Total_Booking_Amount_Received__c : SBTRRec.Total_Booking_Amount_Received__c;
            SBTRRecListtoupdate.add(SBTRRec);
        }
        update SBTRRecListtoupdate;
    }
}