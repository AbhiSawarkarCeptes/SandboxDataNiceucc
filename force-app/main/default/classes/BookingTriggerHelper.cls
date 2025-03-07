public class BookingTriggerHelper {
    public static Boolean isRun = true;
    public static Boolean isSecondRun = true;
    
    public static void updateSellerRepresentative(List<PropStrength__Application_Booking__c> newList) { 
        Set<Id> projId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.PropStrength__Project__c != null) {
                projId.add(book.PropStrength__Project__c);
            }
        }
        
        Map<Id, PropStrength__Projects__c> projMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, Master_Project__r.Siniya_Island_Project__c FROM PropStrength__Projects__c WHERE Id IN :projId]);
        
        String crmDoc = System.Label.CrmDocumentController;
        String sellerRepre = System.Label.SellerRepresentative;
        String sellerRepre2 = System.Label.Siniya_Island_Authorized_Signatory;
        
        List<User> userList = [SELECT Id, Email FROM User WHERE (Email LIKE :crmDoc OR Email LIKE :sellerRepre OR Email LIKE :sellerRepre2)];
        
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.Docusign_Sales_Ops_Email__c == null || book.Docusign_Sales_Ops_Email__c == '') {
                book.Docusign_Sales_Ops_Email__c = System.label.DocusignSalesOpsEmail;
            }
            if(book.Docusign_Audit_Email__c == null || book.Docusign_Audit_Email__c == '') {
                book.Docusign_Audit_Email__c = System.label.DocusignAuditEmail;
            }
            
            for(User u : userList) {    
                if(u.Email == System.Label.CrmDocumentController) {
                    if(book.CRM_Document_Controller__c == null) {
                        book.CRM_Document_Controller__c = u.Id;
                    }
                }
                if(book.PropStrength__Project__c != null && projMap.containsKey(book.PropStrength__Project__c) && projMap.get(book.PropStrength__Project__c).Master_Project__r.Siniya_Island_Project__c) {
                    if(u.Email == System.Label.Siniya_Island_Authorized_Signatory) {
                        if(book.Seller_Representative__c == null) {
                            book.Seller_Representative__c = u.Id;
                        }
                    }
                } else {
                    if(u.Email == System.Label.SellerRepresentative) {
                        if(book.Seller_Representative__c == null) {
                            book.Seller_Representative__c = u.Id;
                        }
                    }
                }
            }
        }
    }
    // Modified By Gourav Gour 26/09/2024 
    public static void updateBookedDateFromOffer(List<PropStrength__Application_Booking__c> newList) {      
        Set<Id> offerIds = new Set<Id>();
        for(PropStrength__Application_Booking__c book : newList) {            
            book.Create_SBTR__c = true;
            offerIds.add(book.PropStrength__Offer__c);
        } 
        Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT ID, Booked_Date__c, Status_for_Cancel_Swap__c
                                                                                        FROM PropStrength__Offer__c WHERE ID IN :offerIds]);
        for(PropStrength__Application_Booking__c book : newList) { 
            if(offerMap.containsKey(book.PropStrength__Offer__c)) {
                book.Booked_Date__c = offerMap.get(book.PropStrength__Offer__c).Booked_Date__c;
            }
            if(offerMap.containsKey(book.PropStrength__Offer__c) && offerMap.get(book.PropStrength__Offer__c).Status_for_Cancel_Swap__c != null) {
                book.Status_for_CancelSwap__c = offerMap.get(book.PropStrength__Offer__c).Status_for_Cancel_Swap__c;
            }
        } 
    }
    
    public static void updateBrokeragePayable(List<PropStrength__Application_Booking__c> newList ) {        
        for(PropStrength__Application_Booking__c book : newList) {
            Decimal adjustedAmount = 0;
            adjustedAmount = book.PropStrength__Total_Brokerage_Payable__c;
            if(book.PropStrength__Brokerage_Adjusted__c != null && book.PropStrength__Brokerage_Adjusted__c > 0){
                adjustedAmount = book.PropStrength__Total_Brokerage_Payable__c - book.PropStrength__Brokerage_Adjusted__c;
            }
            book.PropStrength__Brokerage_Payable__c = adjustedAmount;
        }        
    }
    
    public static void UpdateCreateSBTR(List<PropStrength__Application_Booking__c> newList ) { 
        Set<String> bookingId = new Set<String>();
        for(PropStrength__Application_Booking__c book : newList) {            
            bookingId.add(book.Id);
        } 
        updateBooking(bookingId);
    }
    @future
    Public static void updateBooking(Set<String> bookingId) {
        List<PropStrength__Application_Booking__c> newList = [SELECT Id, PropStrength__Offer__c, Qualification_Date__c,Signed_Status__c, Current_Status__c, PropStrength__Booking_Amount_Received__c,
                                                              (SELECT Id, PropStrength__Active__c, PropStrength__Type__c, PropStrength__Applicant_Acc__c, PropStrength__Applicant_Acc__r.Name, 
                                                               PropStrength__Applicant_Acc__r.PropStrength__Nationality__c
                                                               FROM PropStrength__Applicant_Details__r 
                                                               WHERE PropStrength__Active__c = true 
                                                               AND (PropStrength__Type__c = '1st Applicant' OR PropStrength__Type__c = '2nd Applicant')) 
                                                              FROM PropStrength__Application_Booking__c WHERE Id In: bookingId];
        
        Set<Id> offerIds = new Set<Id>();
        for(PropStrength__Application_Booking__c book : newList) {            
            book.Create_SBTR__c = true;
            offerIds.add(book.PropStrength__Offer__c);
        }  
        /*Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT ID, PropStrength__Status__c, 
                                                                                        (SELECT Id, Booking__c FROM SBTRs__r) FROM PropStrength__Offer__c WHERE ID IN :offerIds]);*/
        Map<Id, SBTR__c> sbtrToUpdate = new Map<Id, SBTR__c>();
        for(PropStrength__Application_Booking__c book : newList) {  
            Id primaryApplicantId = null;
            String jointApplicantName = '';
            String jointApplicantNationality = '';
            String customeNationality = '';
            for(PropStrength__Applicant_Detail__c ad : book.PropStrength__Applicant_Details__r) {
                if(ad.PropStrength__Type__c == '1st Applicant' ) {
                    primaryApplicantId = Id.valueOf(ad.Id);
                    customeNationality = ad.PropStrength__Applicant_Acc__c != null ? ad.PropStrength__Applicant_Acc__r.PropStrength__Nationality__c != null ? ad.PropStrength__Applicant_Acc__r.PropStrength__Nationality__c : '' : '';
                }
                if(ad.PropStrength__Type__c == '2nd Applicant') {
                    jointApplicantName =   ad.PropStrength__Applicant_Acc__c != null ? ad.PropStrength__Applicant_Acc__r.Name != null ? ad.PropStrength__Applicant_Acc__r.Name : '' : '';
                    jointApplicantNationality = ad.PropStrength__Applicant_Acc__c != null ? ad.PropStrength__Applicant_Acc__r.PropStrength__Nationality__c != null ? ad.PropStrength__Applicant_Acc__r.PropStrength__Nationality__c : '' : '';
                }
            }       
            /*if(offerMap.containsKey(book.PropStrength__Offer__c) && offerMap.get(book.PropStrength__Offer__c).SBTRs__r.size() > 0) {
                for(SBTR__c sb : offerMap.get(book.PropStrength__Offer__c).SBTRs__r) {
                    SBTR__c sbtr = new SBTR__c();
                    sbtr.Id  = sb.Id;
                    sbtr.Booking__c = book.Id;
                    sbtr.Total_Booking_Amount_Received__c = book.PropStrength__Booking_Amount_Received__c != null ? book.PropStrength__Booking_Amount_Received__c : null;
                    sbtr.Signed_Status_PS__c = book.Signed_Status__c != null ? book.Signed_Status__c : null;
                    sbtr.Current_Status_PS__c = book.Current_Status__c != null ? book.Current_Status__c : null;
                    sbtr.Qualified_Date_PS__c = book.Qualification_Date__c != null ? book.Qualification_Date__c : null;
                    sbtr.Customer_Nationality__c = customeNationality != '' ? customeNationality : null;
                    sbtr.Applicant_Details_PS__c = primaryApplicantId != null ? primaryApplicantId : null;
                    sbtr.Joint_Applicant_Names__c = jointApplicantName != '' ? jointApplicantName : null;
                    sbtr.Secondary_Customer_Nationality__c = jointApplicantNationality != '' ? jointApplicantNationality : null;
                    sbtrToUpdate.put(sbtr.Id, sbtr);
                }
            }*/
        } 
        /*if(!sbtrToUpdate.values().isEmpty() ) {
            update sbtrToUpdate.values();
        } */                                          
        if(newList.size() > 0){
            update newList;
        }
    }
    public static void checkSplit(List<PropStrength__Application_Booking__c> newList ) {
        system.debug(' list 5 '+newList);
        system.debug(' inside checksplit  ');
        Set<Id> offId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.PropStrength__Offer__c != null){
                offId.add(book.PropStrength__Offer__c);
            }
        }
        Map<Id, PropStrength__Offer__c> offMap = new Map<Id, PropStrength__Offer__c>([select Id, Split_Deals__c FROM PropStrength__Offer__c WHERE Id IN :offId]);
        for(PropStrength__Application_Booking__c booking : newList){
            if(booking.PropStrength__Offer__c != null){
                system.debug('line 9');
                if(booking.PropStrength__Offer__c != null && offMap.get(booking.PropStrength__Offer__c).Split_Deals__c){
                    system.debug('line 10');
                    booking.Split_Deals__c      = true;
                    system.debug(' list 12 '+newList);
                }
            }
        }
    }
    
    // Added by deepak on may 2024 to create BPM records
    /*public static void createBPMRec(List<PropStrength__Application_Booking__c> newList, map<Id,PropStrength__Application_Booking__c> oldMap ) {
Set<id> bookingIds = new Set<Id>();
Set<id> bookingIdsUncheck = new Set<Id>();
Map<String, Decimal> mapOfBookingAndCount = new Map<String, Decimal>();
Map<Id, PropStrength__Application_Booking__c> mapOfBookingRecId = new Map<Id, PropStrength__Application_Booking__c>();
for(PropStrength__Application_Booking__c bookRec : newList){
if(bookRec.Differentiate_Brokerage_on_Other_Charge__c != oldMap.get(bookRec.Id).Differentiate_Brokerage_on_Other_Charge__c || 
bookRec.Differentiate_Brokerage_on_BSP__c != oldMap.get(bookRec.Id).Differentiate_Brokerage_on_BSP__c) {
mapOfBookingAndCount.put( bookRec.Id , ( bookRec.Differentiate_Brokerage_on_Other_Charge__c != null ? bookRec.Differentiate_Brokerage_on_Other_Charge__c : 0 +
bookRec.Differentiate_Brokerage_on_BSP__c != null ? bookRec.Differentiate_Brokerage_on_BSP__c : 0 ) );
mapOfBookingRecId.put(bookRec.Id, bookRec);
}             
}
if(mapOfBookingRecId.size() > 0){
Map<Id,PropStrength__Application_Booking__c> listOfBookingRecAnd = new Map<Id,PropStrength__Application_Booking__c>([SELECT Id,(SELECT Id,PropStrength__Amount_Paid_By_Customer__c,PropStrength__Brokerage_Due__c from PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true ORDER BY Createddate DESC limit 1) from PropStrength__Application_Booking__c WHERE Id IN : mapOfBookingRecId.keySet() ]); 

System.debug(mapOfBookingAndCount.size()+'--**----**--'+mapOfBookingAndCount);
List<PropStrength__Broker_Payment_Milestone__c> listOfBPM = new List<PropStrength__Broker_Payment_Milestone__c>();
for(String bookIds : mapOfBookingAndCount.keyset() ){
PropStrength__Broker_Payment_Milestone__c BPMRec = new PropStrength__Broker_Payment_Milestone__c();
BPMRec.PropStrength__Booking_ID__c = bookIds;
BPMRec.PropStrength__Brokerage_Type__c = 'Standard';
BPMRec.PropStrength__Brokerage_Due_Rs__c = mapOfBookingAndCount.get(bookIds);
BPMRec.PropStrength__Active__c = true;
BPMRec.Differentiate_Brokerage__c = true;
if(listOfBookingRecAnd.get(bookIds).PropStrength__Broker_Payment_Milestones__r.size() > 0 ){
BPMRec.PropStrength__Amount_Paid_By_Customer__c = listOfBookingRecAnd.get(bookIds).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Amount_Paid_By_Customer__c;
BPMRec.PropStrength__Brokerage_Due__c = listOfBookingRecAnd.get(bookIds).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Brokerage_Due__c;
}
listOfBPM.add(BPMRec);
} 
if(listOfBPM.size() > 0){
insert listOfBPM;            
}
}
}*/
    
    
    /* public static void updateIncentiveOnBooking(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap ) {
Set<Id> bookingIds = new Set<Id>();
for(PropStrength__Application_Booking__c bookRec : newList){
if(bookRec.PropStrength__Super_Area__c != null && bookRec.PropStrength__Super_Area__c != oldMap.get(bookRec.Id).PropStrength__Super_Area__c){
bookingIds.add(bookRec.Id);
}
}

if(!bookingIds.isEmpty()) {
List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();

Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();

Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
[SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate,  
PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c,PropStrength__Discount_Type__c, 
Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Manager__c ,Marketing_CP_Commission_Eligible__c,
PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,PropStrength__Project__r.Master_Project__c,
PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,PropStrength__Property__r.Special_Incentive_Applicable__c,PropStrength__Property__r.PropStrength__Tower__r.Special_Incentive_Applicable__c,
CMO_Marketing_Incentive__c,Incentive_Update_Option__c, Sales_Commission_Eligible_1st_Half__c ,Sales_Commission_Eligible_2nd_Half__c,
DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, 
X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c ,
Marketing_Team_Incentive__c,Marketing_Head_Incentive__c, Promoter_Incentive__c, Mall_Team_Lead_Incentive__c,TeleSales_Agent_Incentive__c, TeleSales_Head_Incentive__c,Campaign_Manager_Influence_Incentive__c,Digital_Marketing_Head_Incentive__c, 
Loyalty_Sales_Executive_Incentive__c,Team_Lead_Incentive__c,GM_Marketing_Incentive__c, PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c,
Employee_Referral_Incentive__c,                 Sales_Manager_Incentive__c, Channel_Relation_Team_Incentive__c ,Brand_Evangelist_Incentive_Slab__c, 
CMO_Channel_Relation_Incentive__c, Sales_Director_Incentive__c,Channel__c,Booked_Date__c,
VP_Channel_Relation_Incentive__c,TL_Channel_Relation_Incentive__c,Marketing_Incentive_Slab__c,Sales_Incentive_Slab__c,
RM_Channel__c ,PropStrength__Property_Type__c, PropStrength__Property_Type__r.Loyalty_Discount__c           
FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
//Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
List<Incentive_Slab__c> interestSlabRec = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = false];

List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = true];

Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec1 = new Map<String, List<Incentive_Slab__c>>();
Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec2 = new Map<String, List<Incentive_Slab__c>>();

if(interestSlabRec.size() > 0){
for(Incentive_Slab__c IncentiveRec : interestSlabRec){
if(mapOfREcordTypeAndinterestSlabRec1.containskey(IncentiveRec.RecordType.Name)){
mapOfREcordTypeAndinterestSlabRec1.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
}
else{
mapOfREcordTypeAndinterestSlabRec1.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
}
}
}

if(interestSlabRecWithSiniyaProject.size() > 0){
for(Incentive_Slab__c IncentiveRec : interestSlabRecWithSiniyaProject){
if(mapOfREcordTypeAndinterestSlabRec2.containskey(IncentiveRec.RecordType.Name)){
mapOfREcordTypeAndinterestSlabRec2.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
}
else{
mapOfREcordTypeAndinterestSlabRec2.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
}
}
}


Map<Id,Map<String, List<Incentive_Slab__c>>> bookingSlabMap = new Map<Id,Map<String, List<Incentive_Slab__c>>>();
for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && !bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec1 );
}
else if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec2 );
}

}
Set<Id> towerIds = new Set<Id>();
Map<Id, Id> bookingTowerId = new Map<Id, Id>();
for(PropStrength__Application_Booking__c booking : bookMap.values()) {
if(booking.PropStrength__Property__c != null && booking.PropStrength__Property__r.PropStrength__Tower__c != null) {
towerIds.add(booking.PropStrength__Property__r.PropStrength__Tower__c);
bookingTowerId.put(booking.Id, booking.PropStrength__Property__r.PropStrength__Tower__c);
}
}    

Map<Id, Integer> countBookingOnContactMap = new Map<Id, Integer>();
Set<Id> contactId = new Set<Id>();

Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap = new Map<Id, List<PropStrength__Application_Booking__c>>();
Set<Id> brokerIds = new Set<Id>(); 
for(PropStrength__Application_Booking__c book : bookMap.values()) {
if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Primary_Customer__c != null) {
contactId.add(book.PropStrength__Primary_Customer__c);
}
if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null) {
brokerIds.add(book.PropStrength__Broker_Account__c);
}
}

System.debug('contactId: '+contactId);

if(!contactId.isEmpty()) {
List<Contact> contList = [SELECT Id, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];

for(Contact cont : contList) {
if(!cont.PropStrength__Applications_Bookings__r.isEmpty()) {
if(!countBookingOnContactMap.containsKey(cont.Id)) {
countBookingOnContactMap.put(cont.Id, cont.PropStrength__Applications_Bookings__r.size());
}
}
}
}

System.debug('countBookingOnContactMap: '+countBookingOnContactMap);
System.debug('brokerIds: '+brokerIds);

if(!brokerIds.isEmpty()) {
List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c, Booked_date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];

for(Account brk : brokerAccList) {
if(!brk.PropStrength__Applications_Bookings__r.isEmpty()) {
if(!countBookingOnBrokerMap.containsKey(brk.Id)) {
countBookingOnBrokerMap.put(brk.Id, brk.PropStrength__Applications_Bookings__r);
}
}
}
}

System.debug('countBookingOnBrokerMap: '+countBookingOnBrokerMap);
System.debug('interestSlabRec: ' + interestSlabRec);
//System.debug('salesManagerIncentiveId: ' + salesManagerIncentiveId);
List<PropStrength__Application_Booking__c>  listOfBookingRec = new List<PropStrength__Application_Booking__c>();
for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
map<String,boolean> mapOfUserRoleAmountOnPayout = new map<String,boolean>();
map<String,boolean> mapOfUserRoleANDPayout = new map<String,boolean>();
if(bookRec.Incentive_Payouts__r.size() > 0){
for(Incentive_Payouts__c payoutRec : bookRec.Incentive_Payouts__r){
mapOfUserRoleANDPayout.put(payoutRec.User_Role__c , true);
if(payoutRec.Balance__c == null || payoutRec.Balance__c > 0){
mapOfUserRoleAmountOnPayout.put(payoutRec.User_Role__c , true);
}
}                    
}
PropStrength__Application_Booking__c updateBookRec = PaymentTriggerHandler.updatePercentageBooking1(bookRec, bookingSlabMap.get(bookRec.Id), countBookingOnContactMap, countBookingOnBrokerMap,'Super Area',mapOfUserRoleAmountOnPayout, mapOfUserRoleANDPayout);
listOfBookingRec.add(updateBookRec); 
}
System.debug('testttt----'+listOfBookingRec);
if(listOfBookingRec.size() > 0){
update listOfBookingRec;
}
}
}*/
    
   /* public static void createIncentivePayoutRecFromBooking(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap ) {
        Set<Id> bookingIds = new Set<Id>();
        
        for(PropStrength__Application_Booking__c bookRec : newList){
            if((bookRec.X9_5_Payment_Received_Date__c != null && bookRec.X9_5_Payment_Received_Date__c != oldMap.get(bookRec.Id).X9_5_Payment_Received_Date__c) ||
               (bookRec.Booking_Form_Verified__c != null && bookRec.Booking_Form_Verified__c != oldMap.get(bookRec.Id).Booking_Form_Verified__c) ||
               (bookRec.Oqood_Fees_Received__c != null && bookRec.Oqood_Fees_Received__c != oldMap.get(bookRec.Id).Oqood_Fees_Received__c) ||
               (bookRec.SPA_Executed__c != null && bookRec.SPA_Executed__c != oldMap.get(bookRec.Id).SPA_Executed__c) ||
               (bookRec.X20_Payment_Received_Date__c != null && bookRec.X20_Payment_Received_Date__c != oldMap.get(bookRec.Id).X20_Payment_Received_Date__c) ||
               (bookRec.DLD_Fees_Received__c != null && bookRec.DLD_Fees_Received__c != oldMap.get(bookRec.Id).DLD_Fees_Received__c) ||
               (bookRec.DLD_Fees_Due__c != null && bookRec.DLD_Fees_Due__c != oldMap.get(bookRec.Id).DLD_Fees_Due__c)){
                   bookingIds.add(bookRec.Id);
               }
        }
        // System.debug('bookingIds*--'+bookingIds);
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
            
            List<Incentive_Month__c> monthsListToUpsert = new List<Incentive_Month__c>();
            Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate,  
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
                 PropStrength__Property_Type__r.Loyalty_Discount__c, 
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c,
                 VP_Incentive__c, CSO_Incentive__c,Sales_Manager__c ,Incentive_Update_Option__c, Marketing_CP_Commission_Eligible__c,
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,
                 Sales_Commission_Eligible_1st_Half__c ,Sales_Commission_Eligible_2nd_Half__c , PropStrength__Discount_Type__c,
                 DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, PropStrength__Project__r.Master_Project__c,
                 PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,PropStrength__Property__r.Special_Incentive_Applicable__c,PropStrength__Property__r.PropStrength__Tower__r.Special_Incentive_Applicable__c,
                 X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c ,Marketing_Team_Incentive__c,Marketing_Head_Incentive__c, Promoter_Incentive__c, Mall_Team_Lead_Incentive__c,TeleSales_Agent_Incentive__c,CMO_Marketing_Incentive__c, TeleSales_Head_Incentive__c,Campaign_Manager_Influence_Incentive__c,Digital_Marketing_Head_Incentive__c, 
                 Loyalty_Sales_Executive_Incentive__c,Team_Lead_Incentive__c,GM_Marketing_Incentive__c ,
                 Sales_Manager_Incentive__c, Channel_Relation_Team_Incentive__c ,Brand_Evangelist_Incentive_Slab__c, 
                 Sales_Head_Incentive__c,CMO_Channel_Relation_Incentive__c, Sales_Director_Incentive__c,Channel__c,
                 VP_Channel_Relation_Incentive__c,TL_Channel_Relation_Incentive__c,Marketing_Incentive_Slab__c,
                 RM_Channel__c,Sales_Incentive_Slab__c,Employee_Referral_Incentive__c,PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c,
                 (SELECT id,User_Role__c, Amount__c, Balance__c, Application_Booking__c,All_Payment_Of_Sale_Inn__c from Incentive_Payouts__r)
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
            
            //Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                       CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                       Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                       Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                       LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
                                                       Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                       Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                       Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                       Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                       VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = false];
            
            List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                                        CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                                        Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                                        Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                                        LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
                                                                        Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                                        Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                                        Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                                        Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                                        VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = true];
            
            
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec1 = new Map<String, List<Incentive_Slab__c>>();
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec2 = new Map<String, List<Incentive_Slab__c>>();
            
            if(interestSlabRec != null && interestSlabRec.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRec){
                    if(mapOfREcordTypeAndinterestSlabRec1.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec1.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec1.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            if(interestSlabRecWithSiniyaProject != null && interestSlabRecWithSiniyaProject.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRecWithSiniyaProject){
                    if(mapOfREcordTypeAndinterestSlabRec2.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec2.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec2.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            
            Map<Id,Map<String, List<Incentive_Slab__c>>> bookingSlabMap = new Map<Id,Map<String, List<Incentive_Slab__c>>>();
            for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
                if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && !bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec1 );
                }
                else if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec2 );
                }
                
            }
            Set<Id> towerIds = new Set<Id>();
            Map<Id, Id> bookingTowerId = new Map<Id, Id>();
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Property__c != null && booking.PropStrength__Property__r.PropStrength__Tower__c != null) {
                    towerIds.add(booking.PropStrength__Property__r.PropStrength__Tower__c);
                    bookingTowerId.put(booking.Id, booking.PropStrength__Property__r.PropStrength__Tower__c);
                }
            }    
            Set<Id> projectIds = new Set<Id>();
            Map<Id, Id> bookingProjectId = new Map<Id, Id>();
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Project__c != null ) {
                    projectIds.add(booking.PropStrength__Project__c);
                    bookingProjectId.put(booking.Id, booking.PropStrength__Project__c);
                }
            }    
            Map<Id, Map<String, Id>> projectIdAndRoleUsermap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String, Id>> projectIdAndRoleTeamIdMap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String,Incentive_Month__c>> teamIdWithMonthMap = new Map<Id, Map<String, Incentive_Month__c>>();
            Map<String,Incentive_Month__c> projectIdTeamIdMonthIdAndMonth = new Map<String,Incentive_Month__c>();
            Map<String,Decimal> projectIdTeamIdMonthIdAndAmount = new Map<String, Decimal>();
            Map<Incentive_Month__c,Incentive_Month__c> upsertmonthsMap = new Map<Incentive_Month__c,Incentive_Month__c>();
            
            Set<Id> teamIds = new Set<Id>();
            if(projectIds.size() > 0){
                Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, (SELECT Id,Project__c,Incentive_User_Type__c,
                                                                                                                    User__c FROM Incentive_Team_Members__r) 
                                                                                                        FROM PropStrength__Projects__c 
                                                                                                        WHERE Id IN :projectIds]); 
                for( PropStrength__Projects__c  proj : projectMap.values()){
                    if(!projectIdAndRoleUsermap.containsKey(proj.id) && !projectIdAndRoleTeamIdMap.containsKey(proj.id)){
                        projectIdAndRoleUsermap.put(proj.id, new Map<String, Id>());
                        projectIdAndRoleTeamIdMap.put(proj.id, new Map<String, Id>());
                        for(Incentive_Team_Members__c  teamMember : proj.Incentive_Team_Members__r){
                            teamIds.add(teamMember.id);
                            if(teamMember.Incentive_User_Type__c != null && !projectIdAndRoleUsermap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c) && !projectIdAndRoleTeamIdMap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c)){
                                projectIdAndRoleUsermap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.User__c);
                                projectIdAndRoleTeamIdMap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.Id);
                                
                            }
                        }
                    }
                    
                }
                if(teamIds.size() > 0){
                    Map<Id, Incentive_Team_Members__c> teamMembersMap = new Map<Id, Incentive_Team_Members__c>([SELECT Id,Project__c, (SELECT Id,Target_Acheived__c,Name,Incentive_Team_Member__c
                                                                                                                                       FROM Incentive_Month__r) 
                                                                                                                FROM Incentive_Team_Members__c 
                                                                                                                WHERE Id IN :teamIds]); 
                    for( Incentive_Team_Members__c  team  : teamMembersMap.values()){
                        if(!teamIdWithMonthMap.containsKey(team.id)){
                            teamIdWithMonthMap.put(team.id, new Map<String, Incentive_Month__c>());
                            for(Incentive_Month__c  teamMonth : team.Incentive_Month__r){
                                if(!teamIdWithMonthMap.get(team.id).containsKey(teamMonth.Name)){
                                    teamIdWithMonthMap.get(team.id).put(teamMonth.Name, teamMonth);
                                    projectIdTeamIdMonthIdAndMonth.put(team.Project__c+' '+team.id+ ' '+teamMonth.name, teamMonth);
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
            Map<Id, Integer> countBookingOnContactMap = new Map<Id, Integer>();
            Set<Id> contactId = new Set<Id>();
            
            Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap = new Map<Id, List<PropStrength__Application_Booking__c>>();
            Set<Id> brokerIds = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookMap.values()) {
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Primary_Customer__c != null) {
                    contactId.add(book.PropStrength__Primary_Customer__c);
                }
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null) {
                    brokerIds.add(book.PropStrength__Broker_Account__c);
                }
            }
            
            System.debug('contactId: '+contactId);
            
            if(!contactId.isEmpty()) {
                List<Contact> contList = [SELECT Id, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];
                
                for(Contact cont : contList) {
                    if(!cont.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnContactMap.containsKey(cont.Id)) {
                            countBookingOnContactMap.put(cont.Id, cont.PropStrength__Applications_Bookings__r.size());
                        }
                    }
                }
            }
            
            System.debug('countBookingOnContactMap: '+countBookingOnContactMap);
            System.debug('brokerIds: '+brokerIds);
            
            if(!brokerIds.isEmpty()) {
                List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];
                
                for(Account brk : brokerAccList) {
                    if(!brk.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnBrokerMap.containsKey(brk.Id)) {
                            countBookingOnBrokerMap.put(brk.Id, brk.PropStrength__Applications_Bookings__r);
                        }
                    }
                }
            }
            Map<Id, PropStrength__Tower__c> towerMap = new Map<Id, PropStrength__Tower__c>();
            if(towerIds.size() > 0){
                towerMap = new Map<Id, PropStrength__Tower__c>([SELECT Id, (SELECT Id, Campaign_Manager_Influence__c, CMO_Channel_Relation__c, 
                                                                            CSO__c, Digital_Marketing_Head__c, Loyalty_Sales_Executive__c, 
                                                                            Mall_Team_Lead__c, Marketing_Head__c, Promoter__c, RM_Channel_Relation__c, Brand_Evangelist__c,
                                                                            Sales_Director__c, Team_Lead__c, TeleSales_Agent__c, TeleSales_Head__c, TL_Channel_Relation__c, 
                                                                            VP_Channel_Relation__c, VP_Sales__c, GM_Marketing__c, CMO_Marketing__c FROM Incentive_Teams__r) 
                                                                FROM PropStrength__Tower__c 
                                                                WHERE Id IN :towerIds]);
            }
            
            
            System.debug('countBookingOnBrokerMap: '+countBookingOnBrokerMap);
            System.debug('interestSlabRec: ' + interestSlabRec);
            //System.debug('salesManagerIncentiveId: ' + salesManagerIncentiveId);
            List<Incentive_Payouts__c>  listOfPayouts = new List<Incentive_Payouts__c>();   
            List<PropStrength__Application_Booking__c>  listOfbookingRec = new List<PropStrength__Application_Booking__c>();            
            for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
                Decimal calFromPercentage = bookRec.X20_Payment_Received_Date__c != null ? 1.0 : bookRec.X9_5_Payment_Received_Date__c != null ? 0.5 : 0.0;
                system.debug(' calFromPercentage here '+calFromPercentage+' '+' '+bookRec.X9_5_Payment_Received_Date__c+ ' '+bookRec.Booking_Form_Verified__c+ ' '+bookRec.Oqood_Fees_Received__c+' '+!bookRec.PropStrength__Project__r.RERA_Registered__c);
                if( ( calFromPercentage == 0.5 || calFromPercentage == 1.0 ) && bookRec.X9_5_Payment_Received_Date__c != null && bookRec.Booking_Form_Verified__c && bookRec.Oqood_Fees_Received__c 
                   && ((bookRec.PropStrength__Project__r.RERA_Registered__c && bookRec.DLD_Fees_Received__c != null && bookRec.DLD_Fees_Due__c != null && bookRec.DLD_Fees_Received__c >= bookRec.DLD_Fees_Due__c)
                       || !bookRec.PropStrength__Project__r.RERA_Registered__c)) {
                           BookingTriggerSupport.wrapper wrap =  AppBookingTriggerHandler.createIncetiveOnBooking(bookRec, bookingSlabMap.get(bookRec.Id), countBookingOnContactMap, countBookingOnBrokerMap, bookingTowerId,towerMap, projectIdAndRoleUsermap, projectIdAndRoleTeamIdMap, teamIdWithMonthMap,  projectIdTeamIdMonthIdAndMonth,  projectIdTeamIdMonthIdAndAmount );
                           
                           listOfPayouts.addAll(wrap.incentivePayout); 
                           listOfbookingRec.add(wrap.tempBooking);
                           monthsListToUpsert.addAll(wrap.incentiveMonth);
                       }
            }
            System.debug('testttt----'+listOfPayouts);
            System.debug('testttt----'+listOfbookingRec);
            if(listOfPayouts.size() > 0){
                upsert listOfPayouts;
            }
            if(listOfbookingRec.size() > 0){
                update listOfbookingRec;
            }
            if(monthsListToUpsert.size() > 0){
                upsert monthsListToUpsert;
            }
        }   
    }*/
    
   /* public static void createIncentivePayoutRec(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap ) {
        Set<Id> bookingIds = new Set<Id>();
        for(PropStrength__Application_Booking__c bookRec : newList){
            if((bookRec.Sales_Manager_Incentive__c != null && bookRec.Sales_Manager_Incentive__c != oldMap.get(bookRec.Id).Sales_Manager_Incentive__c) ||
               (bookRec.Sales_Head_Incentive__c != null && bookRec.Sales_Head_Incentive__c != oldMap.get(bookRec.Id).Sales_Head_Incentive__c) ||
               (bookRec.VP_Incentive__c != null && bookRec.VP_Incentive__c != oldMap.get(bookRec.Id).VP_Incentive__c) ||
               (bookRec.Sales_Director_Incentive__c != null && bookRec.Sales_Director_Incentive__c != oldMap.get(bookRec.Id).Sales_Director_Incentive__c) ||
               (bookRec.CSO_Incentive__c != null && bookRec.CSO_Incentive__c != oldMap.get(bookRec.Id).CSO_Incentive__c) ||
               (bookRec.Channel_Relation_Team_Incentive__c != null && bookRec.Channel_Relation_Team_Incentive__c != oldMap.get(bookRec.Id).Channel_Relation_Team_Incentive__c) ||
               (bookRec.CMO_Channel_Relation_Incentive__c != null && bookRec.CMO_Channel_Relation_Incentive__c != oldMap.get(bookRec.Id).CMO_Channel_Relation_Incentive__c) ||
               (bookRec.VP_Channel_Relation_Incentive__c != null && bookRec.VP_Channel_Relation_Incentive__c != oldMap.get(bookRec.Id).VP_Channel_Relation_Incentive__c) ||
               (bookRec.TL_Channel_Relation_Incentive__c != null && bookRec.TL_Channel_Relation_Incentive__c != oldMap.get(bookRec.Id).TL_Channel_Relation_Incentive__c) ||
               (bookRec.TL_Channel_Relation_Incentive__c != null && bookRec.TL_Channel_Relation_Incentive__c != oldMap.get(bookRec.Id).TL_Channel_Relation_Incentive__c) ||
               (bookRec.Brand_Evangelist_Incentive__c != null && bookRec.Brand_Evangelist_Incentive__c != oldMap.get(bookRec.Id).Brand_Evangelist_Incentive__c) ||
               (bookRec.Marketing_Team_Incentive__c != null && bookRec.Marketing_Team_Incentive__c != oldMap.get(bookRec.Id).Marketing_Team_Incentive__c) ||
               (bookRec.Marketing_Head_Incentive__c != null && bookRec.Marketing_Head_Incentive__c != oldMap.get(bookRec.Id).Marketing_Head_Incentive__c) ||
               (bookRec.Promoter_Incentive__c != null && bookRec.Promoter_Incentive__c != oldMap.get(bookRec.Id).Promoter_Incentive__c) ||
               (bookRec.Mall_Team_Lead_Incentive__c != null && bookRec.Mall_Team_Lead_Incentive__c != oldMap.get(bookRec.Id).Mall_Team_Lead_Incentive__c) ||
               (bookRec.TeleSales_Agent_Incentive__c != null && bookRec.TeleSales_Agent_Incentive__c != oldMap.get(bookRec.Id).TeleSales_Agent_Incentive__c) ||
               (bookRec.CMO_Marketing_Incentive__c != null && bookRec.CMO_Marketing_Incentive__c != oldMap.get(bookRec.Id).CMO_Marketing_Incentive__c) ||
               (bookRec.TeleSales_Head_Incentive__c != null && bookRec.TeleSales_Head_Incentive__c != oldMap.get(bookRec.Id).TeleSales_Head_Incentive__c) ||
               (bookRec.Campaign_Manager_Influence_Incentive__c != null && bookRec.Campaign_Manager_Influence_Incentive__c != oldMap.get(bookRec.Id).Campaign_Manager_Influence_Incentive__c) ||
               (bookRec.Digital_Marketing_Head_Incentive__c != null && bookRec.Digital_Marketing_Head_Incentive__c != oldMap.get(bookRec.Id).Digital_Marketing_Head_Incentive__c) ||
               (bookRec.Loyalty_Sales_Executive_Incentive__c != null && bookRec.Loyalty_Sales_Executive_Incentive__c != oldMap.get(bookRec.Id).Loyalty_Sales_Executive_Incentive__c) ||
               (bookRec.Team_Lead_Incentive__c != null && bookRec.Team_Lead_Incentive__c != oldMap.get(bookRec.Id).Team_Lead_Incentive__c) ||
               (bookRec.GM_Marketing_Incentive__c != null && bookRec.GM_Marketing_Incentive__c != oldMap.get(bookRec.Id).GM_Marketing_Incentive__c) ||
               (bookRec.Secondary_Sales_Manager_Incentive__c != null && bookRec.Secondary_Sales_Manager_Incentive__c != oldMap.get(bookRec.Id).Secondary_Sales_Manager_Incentive__c)||
               (bookRec.Secondary_Sales_Head_Incentive__c != null && bookRec.Secondary_Sales_Head_Incentive__c != oldMap.get(bookRec.Id).Secondary_Sales_Head_Incentive__c)||
               (bookRec.Secondary_VP_Incentive__c != null && bookRec.Secondary_VP_Incentive__c != oldMap.get(bookRec.Id).Secondary_VP_Incentive__c)||
               (bookRec.Secondary_SVP_Incentive__c != null && bookRec.Secondary_SVP_Incentive__c != oldMap.get(bookRec.Id).Secondary_SVP_Incentive__c)||
               (bookRec.Secondary_CSO_Incentive__c != null && bookRec.Secondary_CSO_Incentive__c != oldMap.get(bookRec.Id).Secondary_CSO_Incentive__c) ||
               (bookRec.Employee_Referral_Incentive__c != null && bookRec.Employee_Referral_Incentive__c != oldMap.get(bookRec.Id).Employee_Referral_Incentive__c) ){
                   bookingIds.add(bookRec.Id);
               }
        }
        // System.debug('bookingIds*--'+bookingIds);
        if(!bookingIds.isEmpty()) {
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate,  
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c,
                 VP_Incentive__c, CSO_Incentive__c,Sales_Manager__c ,Incentive_Update_Option__c, Marketing_CP_Commission_Eligible__c,
                 Secondary_Sales_Manager__c,Secondary_Sales_Manager_Incentive__c,Secondary_Sales_Head_Incentive__c,Secondary_VP_Incentive__c,
                 Secondary_SVP_Incentive__c,Secondary_CSO_Incentive__c,PropStrength__Project__r.Master_Project__c,
                 PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,Employee_Referral_Incentive__c,
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,
                 Sales_Commission_Eligible_1st_Half__c ,Sales_Commission_Eligible_2nd_Half__c , 
                 DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, 
                 X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c ,Marketing_Team_Incentive__c,Marketing_Head_Incentive__c, Promoter_Incentive__c, Mall_Team_Lead_Incentive__c,TeleSales_Agent_Incentive__c,CMO_Marketing_Incentive__c, TeleSales_Head_Incentive__c,Campaign_Manager_Influence_Incentive__c,Digital_Marketing_Head_Incentive__c, 
                 Loyalty_Sales_Executive_Incentive__c,Team_Lead_Incentive__c,GM_Marketing_Incentive__c,
                 Sales_Manager_Incentive__c, Channel_Relation_Team_Incentive__c ,Brand_Evangelist_Incentive_Slab__c, 
                 PropStrength__Property__r.Special_Incentive_Applicable__c ,
                 PropStrength__Property__r.PropStrength__Tower__r.Special_Incentive_Applicable__c,
                 Sales_Head_Incentive__c,CMO_Channel_Relation_Incentive__c, Sales_Director_Incentive__c,Channel__c,PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c,
                 VP_Channel_Relation_Incentive__c,TL_Channel_Relation_Incentive__c,Marketing_Incentive_Slab__c,
                 RM_Channel__c,Sales_Incentive_Slab__c,
                 (SELECT id,User_Role__c, Amount__c, Balance__c, Application_Booking__c,All_Payment_Of_Sale_Inn__c from Incentive_Payouts__r)
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
            //Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                       CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                       Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                       Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                       LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
                                                       Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                       Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                       Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                       Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                       VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = false];
            
            List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                                        CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                                        Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                                        Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                                        LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,Employee_Referal_Inc__c,
                                                                        Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                                        Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                                        Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                                        Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                                        VP_Split__c FROM Incentive_Slab__c where Siniya_Island_Project__c = true];
            
            
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec1 = new Map<String, List<Incentive_Slab__c>>();
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec2 = new Map<String, List<Incentive_Slab__c>>();
            
            if(interestSlabRec.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRec){
                    if(mapOfREcordTypeAndinterestSlabRec1.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec1.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec1.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            if(interestSlabRecWithSiniyaProject.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRecWithSiniyaProject){
                    if(mapOfREcordTypeAndinterestSlabRec2.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec2.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec2.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            
            Map<Id,Map<String, List<Incentive_Slab__c>>> bookingSlabMap = new Map<Id,Map<String, List<Incentive_Slab__c>>>();
            for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
                if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && !bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec1 );
                }
                else if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec2 );
                }
                
            }
            Set<Id> towerIds = new Set<Id>();
            Map<Id, Id> bookingTowerId = new Map<Id, Id>();
            Map<Id, PropStrength__Tower__c> towerMap = new Map<Id, PropStrength__Tower__c>();
            
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Property__c != null && booking.PropStrength__Property__r.PropStrength__Tower__c != null) {
                    towerIds.add(booking.PropStrength__Property__r.PropStrength__Tower__c);
                    bookingTowerId.put(booking.Id, booking.PropStrength__Property__r.PropStrength__Tower__c);
                }
            }
            
            Set<Id> projectIds = new Set<Id>();
            Map<Id, Id> bookingProjectId = new Map<Id, Id>();
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Project__c != null ) {
                    projectIds.add(booking.PropStrength__Project__c);
                    bookingProjectId.put(booking.Id, booking.PropStrength__Project__c);
                }
            }  
            
            Map<Id, Map<String, Id>> projectIdAndRoleUsermap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String, Id>> projectIdAndRoleTeamIdMap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String,Incentive_Month__c>> teamIdWithMonthMap = new Map<Id, Map<String, Incentive_Month__c>>();
            Map<String,Incentive_Month__c> projectIdTeamIdMonthIdAndMonth = new Map<String,Incentive_Month__c>();
            Map<String,Decimal> projectIdTeamIdMonthIdAndAmount = new Map<String, Decimal>();
            Set<Id> teamIds = new Set<Id>();
            
            if(projectIds.size() > 0){
                Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, (SELECT Id,Project__c,Incentive_User_Type__c,
                                                                                                                    User__c FROM Incentive_Team_Members__r) 
                                                                                                        FROM PropStrength__Projects__c 
                                                                                                        WHERE Id IN :projectIds]); 
                for( PropStrength__Projects__c  proj : projectMap.values()){
                    if(!projectIdAndRoleUsermap.containsKey(proj.id) && !projectIdAndRoleTeamIdMap.containsKey(proj.id)){
                        projectIdAndRoleUsermap.put(proj.id, new Map<String, Id>());
                        projectIdAndRoleTeamIdMap.put(proj.id, new Map<String, Id>());
                        for(Incentive_Team_Members__c  teamMember : proj.Incentive_Team_Members__r){
                            teamIds.add(teamMember.id);
                            if(teamMember.Incentive_User_Type__c != null && !projectIdAndRoleUsermap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c) && !projectIdAndRoleTeamIdMap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c)){
                                projectIdAndRoleUsermap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.User__c);
                                projectIdAndRoleTeamIdMap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.Id);
                                
                            }
                        }
                    }                    
                }
                
                if(teamIds.size() > 0) {
                    Map<Id, Incentive_Team_Members__c> teamMembersMap = new Map<Id, Incentive_Team_Members__c>([SELECT Id,Project__c, (SELECT Id,Target_Acheived__c,Name,Incentive_Team_Member__c
                                                                                                                                       FROM Incentive_Month__r) 
                                                                                                                FROM Incentive_Team_Members__c 
                                                                                                                WHERE Id IN :teamIds]); 
                    for( Incentive_Team_Members__c  team  : teamMembersMap.values()){
                        if(!teamIdWithMonthMap.containsKey(team.id)){
                            teamIdWithMonthMap.put(team.id, new Map<String, Incentive_Month__c>());
                            for(Incentive_Month__c  teamMonth : team.Incentive_Month__r){
                                if(!teamIdWithMonthMap.get(team.id).containsKey(teamMonth.Name)){
                                    teamIdWithMonthMap.get(team.id).put(teamMonth.Name, teamMonth);
                                    if( teamMonth.Target_Acheived__c == Null)
                                        teamMonth.Target_Acheived__c = 0;
                                    projectIdTeamIdMonthIdAndMonth.put(team.Project__c+' '+team.id+ ' '+teamMonth.name, teamMonth);
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
            
            
            Map<Id, Integer> countBookingOnContactMap = new Map<Id, Integer>();
            Set<Id> contactId = new Set<Id>();
            
            Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap = new Map<Id, List<PropStrength__Application_Booking__c>>();
            Set<Id> brokerIds = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookMap.values()) {
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Primary_Customer__c != null) {
                    contactId.add(book.PropStrength__Primary_Customer__c);
                }
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null) {
                    brokerIds.add(book.PropStrength__Broker_Account__c);
                }
            }
            
            System.debug('contactId: '+contactId);
            
            if(!contactId.isEmpty()) {
                List<Contact> contList = [SELECT Id, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];
                
                for(Contact cont : contList) {
                    if(!cont.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnContactMap.containsKey(cont.Id)) {
                            countBookingOnContactMap.put(cont.Id, cont.PropStrength__Applications_Bookings__r.size());
                        }
                    }
                }
            }
            
            System.debug('countBookingOnContactMap: '+countBookingOnContactMap);
            System.debug('brokerIds: '+brokerIds);
            
            if(!brokerIds.isEmpty()) {
                List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];                
                for(Account brk : brokerAccList) {
                    if(!brk.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnBrokerMap.containsKey(brk.Id)) {
                            countBookingOnBrokerMap.put(brk.Id, brk.PropStrength__Applications_Bookings__r);
                        }
                    }
                }
            }
            
            if(towerIds.size() > 0){
                towerMap = new Map<Id, PropStrength__Tower__c>([SELECT Id, (SELECT Id, Campaign_Manager_Influence__c, CMO_Channel_Relation__c, 
                                                                            CSO__c, Digital_Marketing_Head__c, Loyalty_Sales_Executive__c, 
                                                                            Mall_Team_Lead__c, Marketing_Head__c, Promoter__c, RM_Channel_Relation__c, Brand_Evangelist__c,
                                                                            Sales_Director__c, Team_Lead__c, TeleSales_Agent__c, TeleSales_Head__c, TL_Channel_Relation__c, 
                                                                            VP_Channel_Relation__c, VP_Sales__c, GM_Marketing__c, CMO_Marketing__c FROM Incentive_Teams__r) 
                                                                FROM PropStrength__Tower__c 
                                                                WHERE Id IN :towerIds]);
            }
            
            
            system.debug('mapOfREcordTypeAndinterestSlabRec2 heere'+mapOfREcordTypeAndinterestSlabRec2);
            system.debug('mapOfREcordTypeAndinterestSlabRec1 heere'+mapOfREcordTypeAndinterestSlabRec1);
            
            List<Incentive_Payouts__c>  listOfPayouts = new List<Incentive_Payouts__c>();   
            List<Incentive_Month__c> listOfMonths = new List<Incentive_Month__c>();
            
            for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
                map<String,boolean> mapOfUserRoleAmountOnPayout = new map<String,boolean>();
                // map<String,boolean> mapOfUserRoleAndPayout = new map<String,boolean>();
                if(bookRec.Incentive_Payouts__r.size() > 0){
                    for(Incentive_Payouts__c payoutRec : bookRec.Incentive_Payouts__r){
                        if(payoutRec.Balance__c == null || payoutRec.Balance__c > 0){
                            mapOfUserRoleAmountOnPayout.put(payoutRec.User_Role__c , true);
                        }
                    }                    
                }
                // else {
                //     map<String,boolean> mapOfUserRoleAndPayout = new map<String,boolean>();
                // }
                // System.debug('mapOfUserRoleAmountOnPayout----'+mapOfUserRoleAmountOnPayout);
                
                BookingTriggerSupport.WrapperOfPayoutAndMonths obj = AppBookingTriggerHandler.updateIncetiveOnBooking(bookRec, bookingSlabMap.get(bookRec.Id), countBookingOnContactMap, countBookingOnBrokerMap, bookingTowerId,towerMap,oldMap, mapOfUserRoleAmountOnPayout, projectIdAndRoleUsermap, projectIdAndRoleTeamIdMap,teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount );
                List<Incentive_Payouts__c> incentivePayout =  obj.incentivePayout;
                listOfPayouts.addAll(incentivePayout); 
                List<Incentive_Month__c> incentiveMonths = obj.incentiveMonths;
                listOfMonths.addAll(incentiveMonths);
            }
            // System.debug('testttt----'+listOfPayouts);
            if(listOfPayouts.size() > 0){
                insert listOfPayouts;
            }
            if(listOfMonths.size() > 0){
                upsert listOfMonths;
            }
            
            
        }   
    }*/
    public static void updateOnHold(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap ) {
        Set<id> bookingIds = new Set<Id>();
        Set<id> bookingIdsUncheck = new Set<Id>();
        for(Integer  i=0;i<newList.size();i++){
            if(newList[i].PropStrength__Status__c != oldMap.get(newList[i].id).PropStrength__Status__c || newList[i].Do_Not_Raise_Demand__c != oldMap.get(newList[i].id).Do_Not_Raise_Demand__c) {
                if( newList[i].PropStrength__Status__c == 'Submitted for Swap Process' ||  newList[i].Do_Not_Raise_Demand__c == true){ 
                    bookingIds.add(newList[i].id);
                }                
                if( ( oldMap.get(newList[i].id).PropStrength__Status__c == 'Submitted for Swap Process' && newList[i].PropStrength__Status__c != 'Submitted for Swap Process' ) || ( oldMap.get(newList[i].id).Do_Not_Raise_Demand__c == true && newList[i].Do_Not_Raise_Demand__c == false ) ){ 
                    bookingIdsUncheck.add(newList[i].id); 
                }
            }             
        }   
        // System.debug(bookingIds+'--**----**--'+bookingIdsUncheck);
        if(bookingIds.size() > 0){
            List<Incentive_Payouts__c> updatePayouts = new List<Incentive_Payouts__c>([select id,On_Hold__c , RecordType.Name  from Incentive_Payouts__c where RecordType.Name = 'Incentive Due' and    Application_Booking__c in :bookingIds]);        
            for(Incentive_Payouts__c payRec : updatePayouts){     
                payRec.On_Hold__c = true;                                                       
            }
            update updatePayouts;
        }
        if(bookingIdsUncheck.size() > 0){
            List<Incentive_Payouts__c> updatePayouts = new List<Incentive_Payouts__c>([select id,On_Hold__c , RecordType.Name  from Incentive_Payouts__c where RecordType.Name = 'Incentive Due' and    Application_Booking__c in :bookingIdsUncheck]);        
            for(Incentive_Payouts__c payRec : updatePayouts){     
                payRec.On_Hold__c = false;                                                       
            }
            update updatePayouts;
        }        
    }
    
    public static void userCaseAPI(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.User_trigger__c;
        if(trgFlg) {
            for(PropStrength__Application_Booking__c book : newList) {
                if(book.Applicant_Created__c == true && 
                   book.Applicant_Created__c != oldMap.get(book.Id).Applicant_Created__c) {
                       bookingIds.add(book.Id);
                   }
            }
            if(!bookingIds.isEmpty() && !System.isBatch() && !Test.IsRunningTest()) {
                CreateUserBatch u = new CreateUserBatch(bookingIds);
                Database.executeBatch(u,1);
            }
        }
    }
    // commented by nishank, uncomment
    public static void sendNotYetSchedule(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        set<Id> checkbookingIds = new set<Id>();
        for(PropStrength__Application_Booking__c bk : newList) {
            if(bk.Slot_Status__c != oldMap.get(bk.Id).Slot_Status__c &&
               bk.Slot_Status__c == 'Not yet scheduled') {
                   bookingIds.add(bk.Id);
               }
            if((bk.Handover_Completed__c != oldMap.get(bk.Id).Handover_Completed__c || bk.PropStrength__Total_Paid_Percent__c != oldMap.get(bk.Id).PropStrength__Total_Paid_Percent__c) &&
               bk.Handover_Completed__c) {
                   checkbookingIds.add(bk.Id);
               }
        }
        
        if(!checkbookingIds.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                       PropStrength__Total_Paid_Percent__c, Handover_Completed__c,
                                                                                                                       (SELECT Id, PropStrength__Balance__c FROM PropStrength__Payment_Plan_Details__r)
                                                                                                                       FROM PropStrength__Application_Booking__c
                                                                                                                       WHERE Id IN :checkbookingIds]);
            
            checkbookingIds = new Set<Id>();
            
            for(Id bookId : bookMap.keySet()) {
                if(bookMap.get(bookId).Handover_Completed__c) {
                    if(bookMap.get(bookId).PropStrength__Total_Paid_Percent__c >= 100) {
                        checkbookingIds.add(bookId);
                    } else if(!bookMap.get(bookId).PropStrength__Payment_Plan_Details__r.isEmpty()) {
                        Boolean flag = true;
                        for(PropStrength__Payment_Plan_Details__c ppd : bookMap.get(bookId).PropStrength__Payment_Plan_Details__r) {
                            if(ppd.PropStrength__Balance__c > 0) {
                                flag = false;
                                break;
                            }
                        }
                        
                        if(flag) {
                            checkbookingIds.add(bookId);
                        }
                    }
                }
            }
        }
        
        if(!bookingIds.isEmpty()) {
            BookingTriggerHelper.sendNotYetScheduleEmail(bookingIds);
        }
        
        if(!checkbookingIds.isEmpty()) {
            BookingTriggerHelper.sendTitleDeedFeesPaid(checkbookingIds);
        }
    }
    
    @future
    public static void sendTitleDeedFeesPaid(set<Id> bookingIds) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        String tempId = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        
        List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Primary_Customer__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds];
        if(!bookingIds.isEmpty()) {
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                               FROM PropStrength__Applicant_Detail__c 
                                                               WHERE PropStrength__Application__c IN: bookingIds 
                                                               AND PropStrength__Active__c =: true 
                                                               AND PropStrength__Applicant_Acc__c != null]) {
                                                                   if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                       List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                       newPLI.add(appLicant);
                                                                       applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                   } else {
                                                                       applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                   }
                                                               }
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Title_deed_fees_paid_Template'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            for(PropStrength__Application_Booking__c tran : bookList) {
                List<String> sendTo = new List<String>(); 
                List<String> ccList = new List<String>(); 
                ccList.add('helpdesk@sobharealty.com');
                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.Id)) {
                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                    }
                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                    }
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(!ccList.isEmpty()) {
                    email.setCcAddresses(ccList);
                    email.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                }
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(tran.Id);
                email.setTargetObjectId(tran.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    @future
    public static void sendNotYetScheduleEmail(set<Id> bookingIds) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        String tempId = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        
        List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Primary_Customer__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds];
        if(!bookingIds.isEmpty()) {
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                               FROM PropStrength__Applicant_Detail__c 
                                                               WHERE PropStrength__Application__c IN: bookingIds 
                                                               AND PropStrength__Active__c =: true 
                                                               AND PropStrength__Applicant_Acc__c != null]) {
                                                                   if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                       List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                       newPLI.add(appLicant);
                                                                       applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                   } else {
                                                                       applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                   }
                                                               }
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Not_yet_scheduled'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            for(PropStrength__Application_Booking__c tran : bookList) {
                List<String> sendTo = new List<String>(); 
                List<String> ccList = new List<String>(); 
                ccList.add('helpdesk@sobharealty.com');
                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.Id)) {
                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                    }
                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                    }
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(!ccList.isEmpty()) {
                    email.setCcAddresses(ccList);
                    email.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                }
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(tran.Id);
                email.setTargetObjectId(tran.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    public static void sendToMobile(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        set<Id> bookingNotificationIds = new set<Id>();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Booking_Trigger__c;
        String notificationStatus = '';
        Boolean sendAlert = false;
        if(trgFlg) {
            for(PropStrength__Application_Booking__c bk : newList) {
                if(bk.Name != oldMap.get(bk.Id).Name ||
                   bk.PropStrength__Status__c != oldMap.get(bk.Id).PropStrength__Status__c ||
                   bk.PropStrength__Primary_Applicant_Name__c != oldMap.get(bk.Id).PropStrength__Primary_Applicant_Name__c ||
                   bk.PropStrength__Applicant_Email__c != oldMap.get(bk.Id).PropStrength__Applicant_Email__c ||
                   bk.Handover_Date__c != oldMap.get(bk.Id).Handover_Date__c ||
                   bk.DLP_End_Date__c != oldMap.get(bk.Id).DLP_End_Date__c ||
                   bk.Unit_Handover_Date__c != oldMap.get(bk.Id).Unit_Handover_Date__c) {
                       bookingIds.add(bk.Id);      
                   }
                
                if(bk.Booking_Form_Sent_for_Digisign__c != oldMap.get(bk.Id).Booking_Form_Sent_for_Digisign__c && 
                   bk.Booking_Form_Sent_for_Digisign__c != null) {
                       notificationStatus = 'booking_form_readiness_for_the_customer_signature';
                       sendAlert = true;
                       bookingNotificationIds.add(bk.Id);
                   }
                else if(bk.PropStrength__Status__c != oldMap.get(bk.Id).PropStrength__Status__c && 
                        bk.PropStrength__Status__c == 'Audit Approved') {
                            notificationStatus = 'confirmation_message_upload_signed_booking_buyer';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.SPA_Status__c != oldMap.get(bk.Id).SPA_Status__c &&
                        bk.SPA_Status__c == 'SPA Sent through Docusign') {
                            sendAlert = true;
                            notificationStatus = 'SPA_readiness_customer_signature';
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.SPA_Executed__c &&
                        bk.SPA_Executed__c != oldMap.get(bk.Id).SPA_Executed__c) {
                            sendAlert = true;
                            notificationStatus = 'completion_SPA_approval';
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Pre_Registration_Status__c != oldMap.get(bk.Id).Pre_Registration_Status__c && 
                        bk.Pre_Registration_Status__c == 'Request Completed'){
                            notificationStatus = 'document_available_user_after_final_approval';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                /*else if(bk.PCC_Status__c != oldMap.get(bk.Id).PCC_Status__c && 
bk.PCC_Status__c == 'PCC Approved'){
notificationStatus = 'payment_completion_certificate_document';
sendAlert = true;
bookingNotificationIds.add(bk.Id);
}*/
                else if(bk.BCC_Notice_Sent__c != oldMap.get(bk.Id).BCC_Notice_Sent__c && 
                        bk.BCC_Notice_Sent__c) {
                            notificationStatus = 'building_completion_certificate_document';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Title_Deed_Status__c != oldMap.get(bk.Id).Title_Deed_Status__c && 
                        bk.Title_Deed_Status__c == 'Title Deed Uploaded') {
                            notificationStatus = 'readiness_title_deed';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                
                else if(bk.Home_Orientation_Slot_Status__c != oldMap.get(bk.Id).Home_Orientation_Slot_Status__c && 
                        bk.Home_Orientation_Slot_Status__c == 'Booking Allowed') {
                            notificationStatus = 'your_apartment_ready_for_the_home_orientation';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Home_Orientation_Slot_Status__c != oldMap.get(bk.Id).Home_Orientation_Slot_Status__c && 
                        bk.Home_Orientation_Slot_Status__c == 'Confirmed') {
                            notificationStatus = 'appointment_confirmation';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Home_Orientation_Slot_Status__c != oldMap.get(bk.Id).Home_Orientation_Slot_Status__c && 
                        bk.Home_Orientation_Slot_Status__c == 'Completed') {
                            notificationStatus = 'home_orientation_completion';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Slot_Status__c   != oldMap.get(bk.Id).Slot_Status__c  && 
                        bk.Slot_Status__c   == 'Booking Allowed') {
                            notificationStatus = 'your_apartment_is_ready';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
                else if(bk.Slot_Status__c   != oldMap.get(bk.Id).Slot_Status__c && 
                        bk.Slot_Status__c   == 'Completed') {
                            notificationStatus = 'hand_over_completion';
                            sendAlert = true;
                            bookingNotificationIds.add(bk.Id);
                        }
            }
            if(!bookingIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                BookingTriggerHelper.sendToMobileAPI(bookingIds);
            }
            
            if(!bookingNotificationIds.isEmpty() && sendAlert && !System.IsBatch() && !System.isFuture()) {
                ID jobID = System.enqueueJob(new MobileAppQueuableNotification(bookingNotificationIds,notificationStatus,'alert'));
            }
        }   
    }
    
    @future(callOut=true)
    public static void sendToMobileAPI(set<Id> bookingIds) {
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        List<Mobile_App_Log__c> logList = new List<Mobile_App_Log__c>();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endPointURL = mobile_appmdt.Booking_Endpoint_URL__c;
        string methodType = 'POST';
        List<PropStrength__Application_Booking__c> newList = [SELECT Id,PropStrength__Applicant_Email__c,Unit_Handover_Date__c,PropStrength__Property__c,Handover_Date__c,
                                                              PropStrength__Primary_Applicant_Name__c,Name,PropStrength__Status__c,
                                                              DLP_End_Date__c
                                                              FROM PropStrength__Application_Booking__c
                                                              WHERE Id IN: bookingIds];
        if(!newList.isEmpty()) {
            for(PropStrength__Application_Booking__c bk :newList) {
                requestBodyWrapper wrap = new requestBodyWrapper();
                wrap.sfUnitId = (bk.PropStrength__Property__c != null ? bk.PropStrength__Property__c : null);
                wrap.handoverDate = bk.Handover_Date__c != null ? bk.Handover_Date__c : null;
                wrap.dlpDate = bk.DLP_End_Date__c != null ? bk.DLP_End_Date__c : null;
                wrap.customerName = bk.PropStrength__Primary_Applicant_Name__c != null ? bk.PropStrength__Primary_Applicant_Name__c : '';
                wrap.customerEmail = bk.PropStrength__Applicant_Email__c != null ? bk.PropStrength__Applicant_Email__c : '';
                wrap.bookingName = bk.Name;
                wrap.bookingID = bk.Id;   
                wrap.actualHandoverDate = bk.Unit_Handover_Date__c != null ? bk.Unit_Handover_Date__c : null;
                wrap.bookingStatus = bk.PropStrength__Status__c != null ? bk.PropStrength__Status__c : '';
                wraplst.add(wrap);
            }
            if(wraplst != null){
                String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
                system.debug('response::'+response);
                try {
                    if(!String.isBlank(response)) {
                        for(PropStrength__Application_Booking__c bk :newList) {
                            Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                            appLog.Class_Name__c = 'BookingTriggerHelper';
                            appLog.Application_Booking__c = bk.Id;
                            if(response.contains('Success')){
                                appLog.Status__c = 'Success';
                            }else
                                appLog.Status__c = 'Error';
                            appLog.API_Name__c = endPointURL;
                            appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                            appLog.Response_Body__c = response;
                            logList.add(appLog);
                        }
                        if(!logList.isEmpty()) {
                            insert logList;
                        }
                    }
                } catch(Exception e) {
                    Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                    appLog.Class_Name__c = 'BookingTriggerHelper';
                    appLog.Status__c = '400';
                    appLog.API_Name__c = endPointURL;
                    appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                    appLog.Response_Body__c = e.getMessage();
                    insert appLog;
                }
            }
        }
    }
    
    public static void CreateTask(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        List<Task> taskList = new List<Task>();
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.Noqoodi_Wallet_Ref_No_Approved__c == true && 
               book.Noqoodi_Wallet_Ref_No_Approved__c != oldMap.get(book.Id).Noqoodi_Wallet_Ref_No_Approved__c) {
                   bookingIds.add(book.Id);
               }
        }
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,Name,PropStrength__Project__r.DLD_Executive__c FROM PropStrength__Application_Booking__c WHERE Id IN: bookingIds];
            for(PropStrength__Application_Booking__c booking : bookingList) {
                Task tsk = new Task();
                tsk.Subject = 'Please Execute the Pre-Registration Process';
                tsk.Status = 'Not Started';
                tsk.Priority = 'High';
                tsk.WhatId = booking.Id;
                tsk.OwnerId = booking.PropStrength__Project__r.DLD_Executive__c;
                tsk.ActivityDate = date.today();
                tsk.ReminderDateTime = system.now();
                tsk.IsReminderSet = true;
                taskList.add(tsk);
            }
            if(!taskList.isEmpty()) {
                List<Database.SaveResult> SaveResults = database.insert(taskList);
                // system.debug('SaveResults::'+SaveResults);
            }
        }
    }
    
    public static void sendEmailOqoodReceived(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> fromAddress = new set<String>();
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.Oqood_Fees_Received__c == true && book.SPA_Executed__c == true &&
               book.Oqood_Fees_Received__c != oldMap.get(book.Id).Oqood_Fees_Received__c) {
                   bookingIds.add(book.Id);
                   book.Date_of_Pre_Registration_Initiation__c = System.Today();
                   book.Pre_Registration_Status__c = 'Request to Initiate Pre-Registration';
               }
        }
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,PropStrength__Primary_Customer__c,PropStrength__Project__r.Accounts_Executive__c,
                                                                      PropStrength__Primary_Customer__r.PropStrength__Resident_Status__c,PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c,
                                                                      PropStrength__Primary_Customer__r.Passport_Expiry_Date__c,
                                                                      PropStrength__Project__r.Accounts_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c
                                                                      FROM PropStrength__Application_Booking__c
                                                                      WHERE Id IN: bookingIds];
            if(!bookingList.isEmpty()) {
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Transfer_Money_to_Noqoodi_Wallet_is_Send'];
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if(!fromAddress.isEmpty()) {
                    if(!test.isrunningtest())
                        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: fromAddress limit 1];
                }
                for(PropStrength__Application_Booking__c book : bookingList) {
                    Date today = Date.today();
                    Boolean flag = false;
                    if(book.PropStrength__Primary_Customer__r.PropStrength__Resident_Status__c == 'Resident Citizen'
                       && book.PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c != null 
                       && today.daysBetween(book.PropStrength__Primary_Customer__r.Emirates_ID_Expiry_Date__c) < 0) {
                           flag = true;
                       } else if(book.PropStrength__Primary_Customer__r.Passport_Expiry_Date__c != null && 
                                 today.daysBetween(book.PropStrength__Primary_Customer__r.Passport_Expiry_Date__c) < 0) {
                                     flag = true;
                                 }
                    if(flag){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(new List<String>{book.PropStrength__Project__r.Accounts_Executive__r.Email});
                        }
                        if(owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(book.id);
                        email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        mails.add(email); 
                    }
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
            }
        }
    }
    
    public static void sendPCC(List<PropStrength__Application_Booking__c> newList,map<Id,PropStrength__Application_Booking__c> oldMap) {
        set<Id> bookingIds = new set<Id>();
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.PCC_Status__c == 'PCC Approved' && book.PCC_Document_Approved__c == true &&
               book.PCC_Status__c != oldMap.get(book.Id).PCC_Status__c) {
                   bookingIds.add(book.Id);
               }
        }
        if(!bookingIds.isEmpty()) {
            BookingTriggerHelper.sendMailPCC(bookingIds);
        }
    }
    
    @Future(Callout=True)
    public static void sendMailPCC(Set<Id> bookingIds) {
        if(!bookingIds.isEmpty()) {
            Map<Id,Attachment> attachmentMap = new Map<Id,Attachment>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
            List<String> sendTo = new List<String>(); 
            List<String> ccList = new List<String>(); 
            set<String> fromAddress = new set<String>();
            
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,
                                                                      PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.DLD_Executive__c,
                                                                      PropStrength__Project__r.DLD_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c,
                                                                      PropStrength__Primary_Customer__r.Email,
                                                                      (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Type__c FROM PropStrength__Applicant_Details__r)
                                                                      FROM PropStrength__Application_Booking__c
                                                                      WHERE Id IN: bookingIds];
            List<Attachment> insertList = new List<Attachment>();
            for(PropStrength__Application_Booking__c book : bookingList) {
                PageReference pdf;
                pdf =  Page.PaymentCompletionCertificate;
                pdf.getParameters().put('id', book.Id);
                Blob b;
                if(Test.isRunningTest()) {
                    b = Blob.valueOf('test');
                } else {
                    b = pdf.getContent();
                }
                Attachment att = new Attachment();
                att.ParentId = book.Id;
                att.Name = 'Approved PCC document.pdf';
                att.Body = b;
                insertList.add(att);
            }
            if(!insertList.isEmpty()) {
                insert insertList;
            }
            for(Attachment oneAtt : [SELECT Id,Name,ParentId, Body FROM Attachment WHERE ParentId IN: bookingIds AND Name =: 'Approved PCC document.pdf' ORDER BY CreatedDate DESC LIMIT 1]) {
                attachmentMap.put(oneAtt.ParentId, oneAtt);
            }
            for(PropStrength__Application_Booking__c book : bookingList) {
                fromAddress.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c);
                if(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c != null) {
                    ccList.add(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email);
                }
                if(book.PropStrength__Project__r.DLD_Executive__c != null) {
                    //ccList.add(book.PropStrength__Project__r.DLD_Executive__r.Email);
                }
            }
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                for(PropStrength__Applicant_Detail__c applicant : book.PropStrength__Applicant_Details__r) {
                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                    }
                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                    }
                }
            }
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'PCC_Transaction_Completed' OR DeveloperName =: 'PCCSendToCustomerApproval'];
            
            String tempId = '';
            String custTempId = '';
            
            if(!emailTemplate.isEmpty()){
                for(EmailTemplate em : emailTemplate) {
                    if(em.DeveloperName == 'PCC_Transaction_Completed') {
                        tempId =  em.Id;
                    } else if(em.DeveloperName == 'PCCSendToCustomerApproval') {
                        custTempId = em.Id; 
                    }
                }
                
            }
            
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if(!fromAddress.isEmpty()) {
                if(!test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: fromAddress limit 1];
            }
            for(PropStrength__Application_Booking__c book : bookingList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(!ccList.isEmpty()) {
                    email.setCcAddresses(ccList);
                }
                if(owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                if(attachmentMap.containskey(book.Id)) {
                    if(attachmentMap.get(book.Id).Name == 'Approved PCC document.pdf') {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName('Approved PCC document.pdf');
                        efa.setBody(attachmentMap.get(book.Id).Body);
                        efalst.add(efa);
                    }
                    if(!efalst.isEmpty()) {
                        email.setFileAttachments(efalst);
                    }
                }
                mails.add(email); 
            }
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(new List<String>{book.PropStrength__Primary_Customer__r.Email});
                }
                if(owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(custTempId);
                if(attachmentMap.containskey(book.Id)) {
                    if(attachmentMap.get(book.Id).Name == 'Approved PCC document.pdf') {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName('Approved PCC document.pdf');
                        efa.setBody(attachmentMap.get(book.Id).Body);
                        efalst.add(efa);
                    }
                    if(!efalst.isEmpty()) {
                        email.setFileAttachments(efalst);
                    }
                }
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
    
    public static boolean runSecond(){
        if(isSecondRun) {
            isSecondRun=false;
            return true;
        }else{
            return isSecondRun;
        }
    }
    
    //Created By Deepak Sharma to add CRM Executive Field's value from Tower CRM Executive Field
    public static void updateCRMExecutiveField(List<PropStrength__Application_Booking__c> newList) {
        Set<Id> propIds = new Set<Id>();
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.PropStrength__Property__c != null) {
                propIds.add(book.PropStrength__Property__c);
            }
        }
        
        if(!propIds.isEmpty()) {
            Map<Id, PropStrength__Property__c> propRecs = new Map<Id, PropStrength__Property__c>([SELECT Id, PropStrength__Tower__r.CRM_Executive__c FROM PropStrength__Property__c WHERE Id IN :propIds]);
            if(!propRecs.isEmpty()) {
                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                for(PropStrength__Application_Booking__c book : newList) {
                    if(book.PropStrength__Property__c != null && propRecs.containsKey(book.PropStrength__Property__c)) {
                        updateBookList.add(new PropStrength__Application_Booking__c(Id = book.Id, CRM_Executive__c = propRecs.get(book.PropStrength__Property__c).PropStrength__Tower__r.CRM_Executive__c));
                    }
                }
                if(!updateBookList.isEmpty()) {
                    update updateBookList;
                }
            }
        }
    }
    
    //Created By Deepak Sharma to add Flip Validity Date Field's value on 04 Jul 2023
    public static void fillFlipValidityDate(List<PropStrength__Application_Booking__c> newList) {
        Set<Id> customerIds = new Set<Id>();
        Set<Id> propertyIds = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : newList) {
            if(book.PropStrength__Primary_Customer__c != null) {
                customerIds.add(book.PropStrength__Primary_Customer__c);
            }
            if(book.PropStrength__Property__c != null) {
                propertyIds.add(book.PropStrength__Property__c);
            }
        }
        
        if(!customerIds.isEmpty() && !propertyIds.isEmpty()) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, PropStrength__Account_Type__c FROM Contact WHERE Id IN :customerIds]);
            Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, Flip_Deal_Duration_In_days__c FROM PropStrength__Property__c WHERE Id IN :propertyIds]);
            if(!contactMap.isEmpty() && !propMap.isEmpty()) {
                for(PropStrength__Application_Booking__c book : newList) {
                    if(book.PropStrength__Property__c != null && book.PropStrength__Primary_Customer__c != null && contactMap.containsKey(book.PropStrength__Primary_Customer__c) && contactMap.get(book.PropStrength__Primary_Customer__c).PropStrength__Account_Type__c == 'Broker' && propMap.containsKey(book.PropStrength__Property__c)) {
                        book.Flip_Validity_Date__c = System.Today() + Integer.valueOf(propMap.get(book.PropStrength__Property__c).Flip_Deal_Duration_In_days__c != null ? propMap.get(book.PropStrength__Property__c).Flip_Deal_Duration_In_days__c : 0);
                    }
                }
            }
        }
    }
    
    /*//Created By Deepak Sharma to create broker payment milestone record on 01 Aug 2023
public static void createBrokerPaymentMS(List<PropStrength__Application_Booking__c> newList) {
Set<Id> bookId = new Set<Id>();
Set<Id> brokSchedId = new Set<Id>();
for(PropStrength__Application_Booking__c book : newList) {
if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null && book.PropStrength__Brokerage_Release_Schedule__c != null) {
bookId.add(book.Id);
brokSchedId.add(book.PropStrength__Brokerage_Release_Schedule__c);
}
}
if(!bookId.isEmpty() && !brokSchedId.isEmpty()) {
Map<Id, PropStrength__Application_Booking__c> bookingBrokerScheMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Broker_Account__c, PropStrength__Brokerage_Release_Schedule__c, PropStrength__Broker_Account__r.VAT_Registration_Status__c, PropStrength__Broker_Account__r.VAT_Applicable_From__c, PropStrength__Brokerage_Payable__c, PropStrength__Primary_Customer__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
Map<Id, PropStrength__Brokerage_Payment_Plan__c> brokScheBrokLineMap = new Map<Id, PropStrength__Brokerage_Payment_Plan__c>([SELECT Id, (SELECT Id, PropStrength__Brokerage_Due__c, PropStrength__Brokerage_Schedule_Type__c, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Schedule_Name__c,Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c, Order__c   FROM PropStrength__Brokerage_Release_Schedule_Line_Items__r ORDER BY Order__c) FROM PropStrength__Brokerage_Payment_Plan__c WHERE Id IN :brokSchedId]);
List<PropStrength__Broker_Payment_Milestone__c> brokPliCreate = new List<PropStrength__Broker_Payment_Milestone__c>();
if(!bookingBrokerScheMap.isEmpty() && !brokScheBrokLineMap.isEmpty()) {
for(PropStrength__Application_Booking__c book : newList) {
if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null && book.PropStrength__Brokerage_Release_Schedule__c != null) {
if(bookingBrokerScheMap.containsKey(book.Id) && bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c != null && brokScheBrokLineMap.containsKey(bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c)) {
List<PropStrength__Brokerage_Release_Schedule_Line_Item__c> brokRelLineItem = brokScheBrokLineMap.get(bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Release_Schedule__c).PropStrength__Brokerage_Release_Schedule_Line_Items__r;                            
if(!brokRelLineItem.isEmpty()) {
for(PropStrength__Brokerage_Release_Schedule_Line_Item__c bli : brokRelLineItem) {
if(bli.PropStrength__Brokerage_Schedule_Type__c == 'Standard' && bli.PropStrength__Brokerage_Due__c != null && bli.PropStrength__Amount_Paid_By_Customer__c != null) {
Decimal cgst = 0.00;
//Added by Deepak for VAT_Applicable_From__c check and Updated VAT Registration Status__c picklist value 'Register' to 'Yes' on 21-Aug-2024 as per Sushil's discussion
if(bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Registration_Status__c == 'Yes' && bookingBrokerScheMap.get(book.Id).PropStrength__Broker_Account__r.VAT_Applicable_From__c >= System.Today()) {
cgst = ((bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Payable__c * bli.PropStrength__Brokerage_Due__c)/100) * 0.05;
}
brokPliCreate.add(new PropStrength__Broker_Payment_Milestone__c(Booking_Form_Audit_Approved__c = bli.Booking_Form_Audit_Approved__c, DLD_Fee_Received__c = bli.DLD_Fee_Received__c, SPA_Executed__c = bli.SPA_Executed__c, Order__c = bli.Order__c, PropStrength__Applicant_Name__c=bookingBrokerScheMap.get(book.Id).PropStrength__Primary_Customer__c, PropStrength__Booking_ID__c=book.Id, PropStrength__Brokerage_Type__c = bli.PropStrength__Brokerage_Schedule_Type__c, PropStrength__Amount_Paid_By_Customer__c = bli.PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Due__c = bli.PropStrength__Brokerage_Due__c, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = (bookingBrokerScheMap.get(book.Id).PropStrength__Brokerage_Payable__c * bli.PropStrength__Brokerage_Due__c)/100, PropStrength__Broker_Service_Tax__c = cgst));
}
}
}
}
}
}
}
if(!brokPliCreate.isEmpty()) {
insert brokPliCreate;
}
}
}*/
    
    //Created By Deepak Sharma to create broker payment milestone ledger record on 02 Aug 2023
    /* public static void createBPMLedger(List<PropStrength__Application_Booking__c> newList, Map<Id,PropStrength__Application_Booking__c> oldMap) {
Set<Id> bookIds = new Set<Id>();
for(PropStrength__Application_Booking__c book : newList) {
if( (book.PropStrength__Total_Paid_Percent__c != oldMap.get(book.Id).PropStrength__Total_Paid_Percent__c || 
book.PropStrength__Status__c != oldMap.get(book.Id).PropStrength__Status__c || 
book.Oqood_Fees_Received__c != oldMap.get(book.Id).Oqood_Fees_Received__c ||
book.SPA_Execution_Date__c != oldMap.get(book.Id).SPA_Execution_Date__c || 
book.SPA_Executed__c != oldMap.get(book.Id).SPA_Executed__c) &&
book.PropStrength__Status__c == 'Audit Approved' && book.PropStrength__Total_Paid_Percent__c >= 10 && book.Oqood_Fees_Received__c) {
bookIds.add(book.Id);
}
}
System.debug('bookIds/****'+bookIds);
if(!bookIds.isEmpty()) {
Map<Id, PropStrength__Application_Booking__c> bookBPMMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Status__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c, SPA_Executed__c, SPA_Execution_Date__c, PropStrength__Broker_Account__c, (SELECT Id, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c, PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c FROM PropStrength__Broker_Payment_Milestones__r ORDER BY Name) FROM PropStrength__Application_Booking__c WHERE Id IN :bookIds]);
List<PropStrength__Broker_Ledger__c> bpmLedgerList = new List<PropStrength__Broker_Ledger__c>();
List<PropStrength__Broker_Payment_Milestone__c> updateBPMList = new List<PropStrength__Broker_Payment_Milestone__c>();
Id bpmLedgerDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
for(PropStrength__Application_Booking__c book : bookBPMMap.values()) {
System.debug('test*----'+book.PropStrength__Status__c);
System.debug(book.PropStrength__Total_Paid_Percent__c);
System.debug(book.Oqood_Fees_Received__c);
System.debug(bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r);
if((book.SPA_Execution_Date__c == oldMap.get(book.Id).SPA_Execution_Date__c && 
book.SPA_Executed__c == oldMap.get(book.Id).SPA_Executed__c) && bookBPMMap.containsKey(book.Id) && 
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r.size() > 0 &&
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Due_Date__c == null &&
!bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Is_Paid__c) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c=book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].Id, PropStrength__Active__c= TRUE, PropStrength__Brokerage_Due_Rs__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].PropStrength__Broker_Service_Tax__c, RecordTypeId=bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[0].Id, PropStrength__Due_Date__c=System.Today(), PropStrength__Is_Paid__c = TRUE));
}
if((book.SPA_Execution_Date__c != oldMap.get(book.Id).SPA_Execution_Date__c || 
book.SPA_Executed__c != oldMap.get(book.Id).SPA_Executed__c) && bookBPMMap.containsKey(book.Id) && 
book.SPA_Executed__c && book.SPA_Execution_Date__c != null &&
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r.size() > 1 &&
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].PropStrength__Due_Date__c == null &&
!bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].PropStrength__Is_Paid__c) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c=book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].Id, PropStrength__Active__c= TRUE, PropStrength__Brokerage_Due_Rs__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].PropStrength__Broker_Service_Tax__c, RecordTypeId=bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[1].Id, PropStrength__Due_Date__c=System.Today(), PropStrength__Is_Paid__c = TRUE));
}
if((book.PropStrength__Total_Paid_Percent__c != oldMap.get(book.Id).PropStrength__Total_Paid_Percent__c)
&& bookBPMMap.containsKey(book.Id) && 
book.SPA_Executed__c && book.SPA_Execution_Date__c != null && book.PropStrength__Total_Paid_Percent__c >= 10 &&
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r.size() > 2 &&
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].PropStrength__Due_Date__c == null &&
!bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].PropStrength__Is_Paid__c && 
bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].PropStrength__Brokerage_Type__c == 'Additional Brokerage') {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c=book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].Id, PropStrength__Active__c= TRUE, PropStrength__Brokerage_Due_Rs__c=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].PropStrength__Brokerage_Due_Rs__c, RecordTypeId=bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Additional', PropStrength__Service_Tax__c = bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].PropStrength__Broker_Service_Tax__c));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id=bookBPMMap.get(book.Id).PropStrength__Broker_Payment_Milestones__r[2].Id, PropStrength__Due_Date__c=System.Today(), PropStrength__Is_Paid__c = TRUE));
}
}
if(!bpmLedgerList.isEmpty()) {
insert bpmLedgerList;
}
if(!updateBPMList.isEmpty()) {
update updateBPMList;
}
}
}*/
    //  Added By Gourav Gour 07/05/2024 
    //Modified by Nishank Manwani on  12-07-2024
    public static void createBPMLedger(List<PropStrength__Application_Booking__c> newList, Map<Id,PropStrength__Application_Booking__c> oldMap) {
        /*  Set<Id> bookIds = new Set<Id>();
for(PropStrength__Application_Booking__c book : newList) {
if( (book.X10_Payment_Received_Date__c != oldMap.get(book.Id).X10_Payment_Received_Date__c || 
book.X20_Payment_Received_Date__c != oldMap.get(book.Id).X20_Payment_Received_Date__c || 
(book.DLD_Fees_Due__c != oldMap.get(book.Id).DLD_Fees_Due__c ||
book.DLD_Fees_Received__c != oldMap.get(book.Id).DLD_Fees_Received__c)|| 
book.SPA_Executed__c != oldMap.get(book.Id).SPA_Executed__c ||
book.Booking_Form_Executed__c != oldMap.get(book.Id).Booking_Form_Executed__c  ||
book.Total_Payment_Receive_Percent__c != oldMap.get(book.Id).Total_Payment_Receive_Percent__c 
) && (book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c || book.Booking_Form_Executed__c || book.X10_Payment_Received_Date__c != null)) {
bookIds.add(book.Id);
}
}

if(!bookIds.isEmpty()) {
Map<Id, PropStrength__Application_Booking__c> bookBPMMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Status__c, DLD_Fees_Due__c,X10_Payment_Received_Date__c,X20_Payment_Received_Date__c,  
DLD_Fees_Received__c, Booking_Form_Executed__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c, SPA_Executed__c, X9_5_Payment_Received_Date__c,
SPA_Execution_Date__c, PropStrength__Broker_Account__c, PropStrength__Project__r.RERA_Registered__c,Total_Payment_Receive_Percent__c,
(SELECT Id, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c, 
PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c, Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c,
Order__c, PropStrength__Active__c
FROM PropStrength__Broker_Payment_Milestones__r WHERE PropStrength__Active__c = true AND PropStrength__Is_Paid__c = FALSE AND PropStrength__Due_Date__c = null ORDER BY Order__c) 
FROM PropStrength__Application_Booking__c WHERE Id IN :bookIds]);
List<PropStrength__Broker_Ledger__c> bpmLedgerList = new List<PropStrength__Broker_Ledger__c>();
List<PropStrength__Broker_Payment_Milestone__c> updateBPMList = new List<PropStrength__Broker_Payment_Milestone__c>();
Id bpmLedgerDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
for(PropStrength__Application_Booking__c book : bookBPMMap.values()) {
for(PropStrength__Broker_Payment_Milestone__c bpm : book.PropStrength__Broker_Payment_Milestones__r) {*/
        /*if(book.X10_Payment_Received_Date__c != null && book.X20_Payment_Received_Date__c == null && book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c && book.Booking_Form_Executed__c && ((book.PropStrength__Project__r.RERA_Registered__c && book.SPA_Execution_Date__c == null) || !book.PropStrength__Project__r.RERA_Registered__c)) {
if(bpm.PropStrength__Amount_Paid_By_Customer__c == 10 &&  bpm.DLD_Fee_Received__c && bpm.Booking_Form_Audit_Approved__c && !bpm.SPA_Executed__c && !bpm.PropStrength__Is_Paid__c) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c= book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id = bpm.Id, PropStrength__Due_Date__c = System.Today(), PropStrength__Is_Paid__c = TRUE));
}
}
else if(book.X10_Payment_Received_Date__c != null  && book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c && book.Booking_Form_Executed__c && book.X20_Payment_Received_Date__c == null && ((book.PropStrength__Project__r.RERA_Registered__c && book.SPA_Execution_Date__c != null) || !book.PropStrength__Project__r.RERA_Registered__c)) {
if(bpm.PropStrength__Amount_Paid_By_Customer__c == 10 &&  bpm.DLD_Fee_Received__c && bpm.Booking_Form_Audit_Approved__c && bpm.SPA_Executed__c && !bpm.PropStrength__Is_Paid__c) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c= book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id = bpm.Id, PropStrength__Due_Date__c = System.Today(), PropStrength__Is_Paid__c = TRUE));
}
}
else if(book.X10_Payment_Received_Date__c != null && book.X20_Payment_Received_Date__c != null && book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c && book.Booking_Form_Executed__c  && ((book.PropStrength__Project__r.RERA_Registered__c && book.SPA_Execution_Date__c != null) || !book.PropStrength__Project__r.RERA_Registered__c)) {
if(bpm.PropStrength__Amount_Paid_By_Customer__c == 20 &&  bpm.DLD_Fee_Received__c && bpm.Booking_Form_Audit_Approved__c && bpm.SPA_Executed__c && !bpm.PropStrength__Is_Paid__c) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c = book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id = bpm.Id, PropStrength__Due_Date__c = System.Today(), PropStrength__Is_Paid__c = TRUE));
}
}*/
        /*   Map<String, String> checkMap = new Map<String, String>();*/
        
        /*if(bpm.PropStrength__Amount_Paid_By_Customer__c == 9.5) {
if(book.X9_5_Payment_Received_Date__c != null || (book.Total_Payment_Receive_Percent__c >= 9 && book.Total_Payment_Receive_Percent__c < 10)) {
checkMap.put('PropStrength__Amount_9_5_Paid_By_Customer__c', 'true');
} else {
checkMap.put('PropStrength__Amount_9_5_Paid_By_Customer__c', 'false');
}
} 
if(bpm.PropStrength__Amount_Paid_By_Customer__c == 10) {
if(book.X10_Payment_Received_Date__c != null || (book.Total_Payment_Receive_Percent__c >= 10 && book.Total_Payment_Receive_Percent__c < 20)) {
checkMap.put('PropStrength__Amount_10_Paid_By_Customer__c', 'true');
} else {
checkMap.put('PropStrength__Amount_10_Paid_By_Customer__c', 'false');
}
} 
if(bpm.PropStrength__Amount_Paid_By_Customer__c == 20) {
if(book.X20_Payment_Received_Date__c != null || (book.Total_Payment_Receive_Percent__c >= 20 && book.Total_Payment_Receive_Percent__c < 21)) {
checkMap.put('PropStrength__Amount_20_Paid_By_Customer__c', 'true');
} else {
checkMap.put('PropStrength__Amount_20_Paid_By_Customer__c', 'false');
}
} */
        /* if(bpm.PropStrength__Amount_Paid_By_Customer__c != null) {
if(book.Total_Payment_Receive_Percent__c >= bpm.PropStrength__Amount_Paid_By_Customer__c) {
checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'true');
} else {
checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'false');
}
}
if(bpm.DLD_Fee_Received__c) {
if(book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c) {
checkMap.put('DLD_Fee_Received__c', 'true');
} else {
checkMap.put('DLD_Fee_Received__c', 'false');
}
}
if(bpm.Booking_Form_Audit_Approved__c) {
if(book.Booking_Form_Executed__c) {
checkMap.put('Booking_Form_Audit_Approved__c', 'true');
} else {
checkMap.put('Booking_Form_Audit_Approved__c', 'false');
}
}
if(book.PropStrength__Project__r.RERA_Registered__c && bpm.SPA_Executed__c) {
if(book.SPA_Executed__c) {
checkMap.put('SPA_Executed__c', 'true');
} else {
checkMap.put('SPA_Executed__c', 'false');
}
}


if(!checkMap.isEmpty() && !checkMap.values().contains('false')) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c = book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
updateBPMList.add(new PropStrength__Broker_Payment_Milestone__c(Id = bpm.Id, PropStrength__Due_Date__c = System.Today(), PropStrength__Is_Paid__c = TRUE));
}
}
}
if(!bpmLedgerList.isEmpty()) {
insert bpmLedgerList;
}
if(!updateBPMList.isEmpty()) {
update updateBPMList;
}
}*/
    }
    
    
    //Added by Deepak sharma to send Booking Form in mail to customer on Aug'25 2023
    public static void sendMailBookingForm(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.Booking_Form_Signed_Date__c != null && oldBookMap.get(book.Id).Booking_Form_Signed_Date__c == null && book.Booking_Form_Signed_Date__c != oldBookMap.get(book.Id).Booking_Form_Signed_Date__c) {
                bookId.add(book.Id);
            }
        }
        
        if(!bookId.isEmpty()) {
            BookingTriggerHelper.sendBookingFormMail(bookId);
        }
    }
    
    //Added by Deepak sharma to send Booking Form in mail to customer on Aug'25 2023
    @Future(Callout=True)
    public static void sendBookingFormMail(Set<Id> bookId) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Primary_Customer__c, PropStrength__Project__r.Sales_Ops_Executive__r.Name, PropStrength__Project__r.Sales_Ops_Executive__c, PropStrength__Project__r.Sales_Ops_Executive__r.Email FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];
            if(!bookList.isEmpty()) {
                for(PropStrength__Application_Booking__c book : bookList) {
                    //PageReference pdf = Page.TransferChargeNotice;
                    
                    /* if (pdf != null) {
pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
}
Blob b = pdf.getContent();
Attachment att = new Attachment();
att.ParentId = pay.Id;
att.Name = 'TransferChargeNotice.pdf';
att.Body = b;
insertList.add(att);*/
                }
                if(!insertList.isEmpty()) {
                    //insert insertList;
                    /* for(Attachment oneAtt : insertList) {
if(attachmentMap.containskey(oneAtt.ParentId)) {
List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
newPLI.add(oneAtt);
attachmentMap.put(oneAtt.ParentId, newPLI);
} else {
attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
}
}*/
                }
                // if(!attachmentMap.isEmpty()) {
                // system.debug('attachmentMap::'+attachmentMap);
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Sales_ops_Executive_Booking_Form'];
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                for(PropStrength__Application_Booking__c book : bookList) {
                    if(book.PropStrength__Project__r.Sales_Ops_Executive__r.Email != null) {
                        sendTo.add(book.PropStrength__Project__r.Sales_Ops_Executive__r.Email);
                    }
                }
                for(PropStrength__Application_Booking__c book : bookList) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    email.setWhatId(book.id);
                    email.setTargetObjectId(book.PropStrength__Project__r.Sales_Ops_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    email.setTemplateId(tempId);
                    /* if(attachmentMap.containskey(ppd.Id)){
for(Attachment att : attachmentMap.get(ppd.Id)) {
if(att.Name == 'TransferChargeNotice.pdf') {
Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
efa.setFileName('TransferChargeNotice.pdf');
efa.setBody(att.Body);
efalst.add(efa);
}
if(!efalst.isEmpty()) {
email.setFileAttachments(efalst);
}
}
}*/
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
                
                
                //}
                
            }
        }
    }
    
    //Added by Deepak sharma to update Property Status when Booking status is Audit Approved on Oct'16 2023
    public static void updateStatusOnProperty(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Property__c> updatePropList = new List<PropStrength__Property__c>();
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.PropStrength__Property__c != null && book.PropStrength__Status__c == 'Audit Approved' && book.PropStrength__Status__c != oldBookMap.get(book.Id).PropStrength__Status__c) {
                updatePropList.add(new PropStrength__Property__c(Id = book.PropStrength__Property__c, PropStrength__Unit_Status__c = 'SOLD'));
            }
        }
        
        if(!updatePropList.isEmpty()) {
            update updatePropList;
        }
    }
    
    //Added by Deepak sharma to Calculate Channel Partner Incentive when Booking Through is Broker on Oct'17 2023
    public static void channelRelationIncentiveCalc(List<PropStrength__Application_Booking__c> bookingList) {
        Set<Id> brokerBookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.PropStrength__Booking_Through__c == 'Broker' && book.Channel_Relation_Team_Incentive__c == null) {
                brokerBookId.add(book.Id);
            }
        }
        
        if(!brokerBookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookRec = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Application_Booking__c> bookingRecords = [SELECT Id, PropStrength__Booking_Through__c, PropStrength__Broker_Account__c, PropStrength__Primary_Customer__c, 
                                                                         PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__r.Broker_Sub_Type__c,
                                                                         PropStrength__Revised_Total_Sales_Consideration__c 
                                                                         FROM PropStrength__Application_Booking__c WHERE Id IN :brokerBookId];
            
            Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Id, Intl_Broker_New_Customer_Inc__c, Intl_Broker_Old_Customer_Inc__c, Sobha_Connect_UAE_New_Inc__c, 
                                                       Sobha_Connect_UAE_Old_Inc__c, VP_Channel_Relations_Split__c, TL_Channel_Relation_Split__c, RM_Channel_Split__c 
                                                       FROM Incentive_Slab__c WHERE RecordTypeId = :channelPartnerIncentiveId ORDER BY CreatedDate DESC];
            
            Map<Id, Integer> countBookingOnContactMap = new Map<Id, Integer>();
            Set<Id> contactId = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookingRecords) {
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Primary_Customer__c != null) {
                    contactId.add(book.PropStrength__Primary_Customer__c);
                }
            }
            
            if(!contactId.isEmpty()) {
                List<Contact> contList = [SELECT Id, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];
                
                for(Contact cont : contList) {
                    if(!cont.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnContactMap.containsKey(cont.Id)) {
                            countBookingOnContactMap.put(cont.Id, cont.PropStrength__Applications_Bookings__r.size());
                        }
                    }
                }
            }
            
            Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap = new Map<Id, List<PropStrength__Application_Booking__c>>();
            Set<Id> brokerIds = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookingRecords) {
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null) {
                    brokerIds.add(book.PropStrength__Broker_Account__c);
                }
            }
            
            if(!brokerIds.isEmpty()) {
                List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];
                
                for(Account brk : brokerAccList) {
                    if(!brk.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnBrokerMap.containsKey(brk.Id)) {
                            countBookingOnBrokerMap.put(brk.Id, brk.PropStrength__Applications_Bookings__r);
                        }
                    }
                }
            }
            
            for(PropStrength__Application_Booking__c book : bookingRecords) {
                if(book.PropStrength__Booking_Through__c == 'Broker') {
                    if((book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Standard' && book.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker International') ||
                       (book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Sobha Connect' && book.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Sobha Connect International')) {
                           if(!countBookingOnContactMap.isEmpty() && countBookingOnContactMap.containsKey(book.PropStrength__Primary_Customer__c) && countBookingOnContactMap.get(book.PropStrength__Primary_Customer__c) == 1) {
                               if(!interestSlabRec.isEmpty() && book.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                   Decimal cusParInc = (book.PropStrength__Revised_Total_Sales_Consideration__c*interestSlabRec[0].Intl_Broker_New_Customer_Inc__c)/100;
                                   updateBookRec.add(new PropStrength__Application_Booking__c(Id=book.Id, Channel_Relation_Team_Incentive__c = cusParInc, VP_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].VP_Channel_Relations_Split__c)/100, TL_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].TL_Channel_Relation_Split__c)/100, RM_Channel__c = (cusParInc*interestSlabRec[0].RM_Channel_Split__c)/100));
                               }
                           } else if(!countBookingOnContactMap.isEmpty() && countBookingOnContactMap.containsKey(book.PropStrength__Primary_Customer__c) && countBookingOnContactMap.get(book.PropStrength__Primary_Customer__c) > 1) {
                               if(!interestSlabRec.isEmpty() && book.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                   Decimal cusParInc = (book.PropStrength__Revised_Total_Sales_Consideration__c*interestSlabRec[0].Intl_Broker_Old_Customer_Inc__c)/100;
                                   updateBookRec.add(new PropStrength__Application_Booking__c(Id=book.Id, Channel_Relation_Team_Incentive__c = cusParInc, VP_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].VP_Channel_Relations_Split__c)/100, TL_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].TL_Channel_Relation_Split__c)/100, RM_Channel__c = (cusParInc*interestSlabRec[0].RM_Channel_Split__c)/100));
                               }
                           }
                       } else if((book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Standard' && 
                                  ( book.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker UAE' || book.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker RERA' )) || (book.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Sobha Connect' && book.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Sobha Connect UAE')) {
                                      if(!countBookingOnBrokerMap.isEmpty() && countBookingOnBrokerMap.containsKey(book.PropStrength__Broker_Account__c) && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c).isEmpty() == FALSE && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c).size() == 1) {
                                          if(!interestSlabRec.isEmpty() && book.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                              Decimal cusParInc = (book.PropStrength__Revised_Total_Sales_Consideration__c*interestSlabRec[0].Sobha_Connect_UAE_New_Inc__c)/100;
                                              updateBookRec.add(new PropStrength__Application_Booking__c(Id=book.Id, Channel_Relation_Team_Incentive__c = cusParInc, VP_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].VP_Channel_Relations_Split__c)/100, TL_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].TL_Channel_Relation_Split__c)/100, RM_Channel__c = (cusParInc*interestSlabRec[0].RM_Channel_Split__c)/100));
                                          }
                                      } else if(!countBookingOnBrokerMap.isEmpty() && countBookingOnBrokerMap.containsKey(book.PropStrength__Broker_Account__c) && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c).isEmpty() == FALSE && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c).size() > 1) {
                                          if(countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c)[0].PropStrength__Booking_Date__c != null && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c)[1].PropStrength__Booking_Date__c != null && countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c)[1].PropStrength__Booking_Date__c.daysBetween(countBookingOnBrokerMap.get(book.PropStrength__Broker_Account__c)[0].PropStrength__Booking_Date__c) > 90) {
                                              if(!interestSlabRec.isEmpty() && book.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                                  Decimal cusParInc = (book.PropStrength__Revised_Total_Sales_Consideration__c*interestSlabRec[0].Sobha_Connect_UAE_New_Inc__c)/100;
                                                  updateBookRec.add(new PropStrength__Application_Booking__c(Id=book.Id, Channel_Relation_Team_Incentive__c = cusParInc, VP_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].VP_Channel_Relations_Split__c)/100, TL_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].TL_Channel_Relation_Split__c)/100, RM_Channel__c = (cusParInc*interestSlabRec[0].RM_Channel_Split__c)/100));
                                              }
                                          } else {
                                              if(!interestSlabRec.isEmpty() && book.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                                  Decimal cusParInc = (book.PropStrength__Revised_Total_Sales_Consideration__c*interestSlabRec[0].Sobha_Connect_UAE_Old_Inc__c)/100;
                                                  updateBookRec.add(new PropStrength__Application_Booking__c(Id=book.Id, Channel_Relation_Team_Incentive__c = cusParInc, VP_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].VP_Channel_Relations_Split__c)/100, TL_Channel_Relation_Incentive__c = (cusParInc*interestSlabRec[0].TL_Channel_Relation_Split__c)/100, RM_Channel__c = (cusParInc*interestSlabRec[0].RM_Channel_Split__c)/100));
                                              }
                                          }                            
                                      }
                                  }
                }
            }
            
            if(!updateBookRec.isEmpty()) {
                update updateBookRec;
            }
        }
    }
    
    //Added by Deepak sharma to Calculate Marketing Incentive when Enquiry Source is Loyalty Sales, Mall Stands/Kiosks Sales, Telesales, Digital Marketing Sales (Inc. Influencer) on Oct'18 2023
    public static void updateMarketingIncentive(List<PropStrength__Application_Booking__c> bookingList) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.PropStrength__Offer__c != null) {
                bookId.add(book.Id);
            }
        }
        
        if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Application_Booking__c> bookingsRecs = [SELECT Id, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c,
                                                                       PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c,
                                                                       PropStrength__Revised_Total_Sales_Consideration__c 
                                                                       FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];
            
            Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Id, Marketing_Category__c, Marketing_Incentive__c, Loyalty_Sales_Executive_Split__c,
                                                       Marketing_Head_Split__c, Promoter_Split__c, Mall_Team_Lead_Split__c, Telesales_Agent_Split__c, 
                                                       Campaign_Manager_Split__c, Digital_Marketing_Head_Split__c, Team_Lead_Split__c, TeleSales_Head_Split__c 
                                                       FROM Incentive_Slab__c WHERE RecordTypeId = :marketingIncentiveId ORDER BY CreatedDate DESC];
            
            
            for(PropStrength__Application_Booking__c book : bookingsRecs) {
                if(book.PropStrength__Offer__c != null) {
                    if(book.PropStrength__Offer__r.PropStrength__Request__c != null) {
                        if(book.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Loyalty') {
                            PropStrength__Application_Booking__c tempBook = new PropStrength__Application_Booking__c(Id=book.Id);
                            if(!interestSlabRec.isEmpty()) {
                                for(Incentive_Slab__c iss : interestSlabRec) {
                                    if(iss.Marketing_Category__c == 'Loyalty Sales') {
                                        if(iss.Marketing_Incentive__c != null) {
                                            tempBook.Marketing_Team_Incentive__c = (book.PropStrength__Revised_Total_Sales_Consideration__c*iss.Marketing_Incentive__c)/100;
                                            if(iss.Loyalty_Sales_Executive_Split__c != null) {
                                                tempBook.Loyalty_Sales_Executive_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Loyalty_Sales_Executive_Split__c)/100;
                                            }
                                            if(iss.Marketing_Head_Split__c != null) {
                                                tempBook.Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Promoter_Split__c != null) {
                                                tempBook.Promoter_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Promoter_Split__c)/100;
                                            }
                                            if(iss.Mall_Team_Lead_Split__c != null) {
                                                tempBook.Mall_Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Mall_Team_Lead_Split__c)/100;
                                            }
                                            if(iss.Telesales_Agent_Split__c != null) {
                                                tempBook.TeleSales_Agent_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Telesales_Agent_Split__c)/100;
                                            }
                                            if(iss.Campaign_Manager_Split__c != null) {
                                                tempBook.Campaign_Manager_Influence_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Campaign_Manager_Split__c)/100;
                                            }
                                            if(iss.Digital_Marketing_Head_Split__c != null) {
                                                tempBook.Digital_Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Digital_Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Team_Lead_Split__c != null) {
                                                tempBook.Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Team_Lead_Split__c)/100;
                                            }
                                            if(iss.TeleSales_Head_Split__c != null) {
                                                tempBook.TeleSales_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.TeleSales_Head_Split__c)/100;
                                            }
                                        }
                                    }
                                }
                            }
                            updateBookList.add(tempBook);
                        } else if(book.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Mall Stand') {
                            PropStrength__Application_Booking__c tempBook = new PropStrength__Application_Booking__c(Id=book.Id);
                            if(!interestSlabRec.isEmpty()) {
                                for(Incentive_Slab__c iss : interestSlabRec) {
                                    if(iss.Marketing_Category__c == 'Mall Stands/Kiosks Sales') {
                                        if(iss.Marketing_Incentive__c != null) {
                                            tempBook.Marketing_Team_Incentive__c = (book.PropStrength__Revised_Total_Sales_Consideration__c*iss.Marketing_Incentive__c)/100;
                                            if(iss.Loyalty_Sales_Executive_Split__c != null) {
                                                tempBook.Loyalty_Sales_Executive_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Loyalty_Sales_Executive_Split__c)/100;
                                            }
                                            if(iss.Marketing_Head_Split__c != null) {
                                                tempBook.Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Promoter_Split__c != null) {
                                                tempBook.Promoter_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Promoter_Split__c)/100;
                                            }
                                            if(iss.Mall_Team_Lead_Split__c != null) {
                                                tempBook.Mall_Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Mall_Team_Lead_Split__c)/100;
                                            }
                                            if(iss.Telesales_Agent_Split__c != null) {
                                                tempBook.TeleSales_Agent_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Telesales_Agent_Split__c)/100;
                                            }
                                            if(iss.Campaign_Manager_Split__c != null) {
                                                tempBook.Campaign_Manager_Influence_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Campaign_Manager_Split__c)/100;
                                            }
                                            if(iss.Digital_Marketing_Head_Split__c != null) {
                                                tempBook.Digital_Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Digital_Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Team_Lead_Split__c != null) {
                                                tempBook.Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Team_Lead_Split__c)/100;
                                            }
                                            if(iss.TeleSales_Head_Split__c != null) {
                                                tempBook.TeleSales_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.TeleSales_Head_Split__c)/100;
                                            }
                                        }
                                    }
                                }
                            }
                            updateBookList.add(tempBook);
                        } else if(book.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Telesales') {
                            PropStrength__Application_Booking__c tempBook = new PropStrength__Application_Booking__c(Id=book.Id);
                            if(!interestSlabRec.isEmpty()) {
                                for(Incentive_Slab__c iss : interestSlabRec) {
                                    if(iss.Marketing_Category__c == 'Telesales') {
                                        if(iss.Marketing_Incentive__c != null) {
                                            tempBook.Marketing_Team_Incentive__c = (book.PropStrength__Revised_Total_Sales_Consideration__c*iss.Marketing_Incentive__c)/100;
                                            if(iss.Loyalty_Sales_Executive_Split__c != null) {
                                                tempBook.Loyalty_Sales_Executive_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Loyalty_Sales_Executive_Split__c)/100;
                                            }
                                            if(iss.Marketing_Head_Split__c != null) {
                                                tempBook.Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Promoter_Split__c != null) {
                                                tempBook.Promoter_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Promoter_Split__c)/100;
                                            }
                                            if(iss.Mall_Team_Lead_Split__c != null) {
                                                tempBook.Mall_Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Mall_Team_Lead_Split__c)/100;
                                            }
                                            if(iss.Telesales_Agent_Split__c != null) {
                                                tempBook.TeleSales_Agent_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Telesales_Agent_Split__c)/100;
                                            }
                                            if(iss.Campaign_Manager_Split__c != null) {
                                                tempBook.Campaign_Manager_Influence_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Campaign_Manager_Split__c)/100;
                                            }
                                            if(iss.Digital_Marketing_Head_Split__c != null) {
                                                tempBook.Digital_Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Digital_Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Team_Lead_Split__c != null) {
                                                tempBook.Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Team_Lead_Split__c)/100;
                                            }
                                            if(iss.TeleSales_Head_Split__c != null) {
                                                tempBook.TeleSales_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.TeleSales_Head_Split__c)/100;
                                            }
                                        }
                                    }
                                }
                            }
                            updateBookList.add(tempBook);
                        } else if(book.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Digital Platform') {
                            PropStrength__Application_Booking__c tempBook = new PropStrength__Application_Booking__c(Id=book.Id);
                            if(!interestSlabRec.isEmpty()) {
                                for(Incentive_Slab__c iss : interestSlabRec) {
                                    if(iss.Marketing_Category__c == 'Digital Marketing Sales (Inc. Influencer)') {
                                        if(iss.Marketing_Incentive__c != null) {
                                            tempBook.Marketing_Team_Incentive__c = (book.PropStrength__Revised_Total_Sales_Consideration__c*iss.Marketing_Incentive__c)/100;
                                            if(iss.Loyalty_Sales_Executive_Split__c != null) {
                                                tempBook.Loyalty_Sales_Executive_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Loyalty_Sales_Executive_Split__c)/100;
                                            }
                                            if(iss.Marketing_Head_Split__c != null) {
                                                tempBook.Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Promoter_Split__c != null) {
                                                tempBook.Promoter_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Promoter_Split__c)/100;
                                            }
                                            if(iss.Mall_Team_Lead_Split__c != null) {
                                                tempBook.Mall_Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Mall_Team_Lead_Split__c)/100;
                                            }
                                            if(iss.Telesales_Agent_Split__c != null) {
                                                tempBook.TeleSales_Agent_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Telesales_Agent_Split__c)/100;
                                            }
                                            if(iss.Campaign_Manager_Split__c != null) {
                                                tempBook.Campaign_Manager_Influence_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Campaign_Manager_Split__c)/100;
                                            }
                                            if(iss.Digital_Marketing_Head_Split__c != null) {
                                                tempBook.Digital_Marketing_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Digital_Marketing_Head_Split__c)/100;
                                            }
                                            if(iss.Team_Lead_Split__c != null) {
                                                tempBook.Team_Lead_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.Team_Lead_Split__c)/100;
                                            }
                                            if(iss.TeleSales_Head_Split__c != null) {
                                                tempBook.TeleSales_Head_Incentive__c = (tempBook.Marketing_Team_Incentive__c*iss.TeleSales_Head_Split__c)/100;
                                            }
                                        }
                                    }
                                }
                            }
                            updateBookList.add(tempBook);
                        }
                    }
                }
            }
            
            if(!updateBookList.isEmpty()) {
                update updateBookList;
            }
        }
    }
    
    //Added by Deepak sharma to Create Payment Record of DLD Fee on Oct'19 2023
    public static void createDldFeePaymentRec(List<PropStrength__Application_Booking__c> bookingList) {
        Set<Id> projId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.PropStrength__Project__c != null) {
                projId.add(book.PropStrength__Project__c);
            }
        }
        
        if(!projId.isEmpty()) {
            Map<Id, PropStrength__Projects__c> projMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, Master_Project__r.Siniya_Island_Project__c FROM PropStrength__Projects__c WHERE Id IN :projId]);
            List<PropStrength__Received_Payment__c> createPayRec = new List<PropStrength__Received_Payment__c>();
            Id incChrgeDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                if(book.PropStrength__Project__c != null && projMap.containsKey(book.PropStrength__Project__c) && !projMap.get(book.PropStrength__Project__c).Master_Project__r.Siniya_Island_Project__c) {
                    createPayRec.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c=book.Id, PropStrength__Amount_Due_Type__c='DLD Fees', RecordTypeId=incChrgeDueId, PropStrength__Amount__c=(book.PropStrength__Revised_Total_Sales_Consideration__c*0.04)+1150, PropStrength__Payment_Date__c=System.Today(), PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generated__c=TRUE, PropStrength__Demand_Generated_By__c=UserInfo.getUserId(), PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c='Demand Generated'));
                }
            }
            
            
            if(!createPayRec.isEmpty()) {
                insert createPayRec;
                Set<id> idsPay = new Set<Id>();
                for(PropStrength__Received_Payment__c pay: createPayRec) {
                    idsPay.add(pay.id);
                }
                BookingTriggerHelper.sendEmailOfPayment(idsPay);
            }
        }
    }
    
    @Future(Callout=True)
    public static void sendEmailOfPayment(Set<Id> payIdset) {
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.PropStrength__Grace_Days__c, RecordType.Name
                                                                   FROM PropStrength__Received_Payment__c
                                                                   WHERE Id IN: payIdset AND 
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
                
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                                                                           if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                               List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                               newPLI.add(appLicant);
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                           } else {
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                           }
                                                                       }
                }
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Received_Payment__c pay : paymentList) {
                        PageReference pdf = Page.TransferChargeNotice;
                        
                        if (pdf != null) {
                            pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                        }
                        Blob b;
                        
                        if(!Test.isRunningTest()) {
                            b = pdf.getContent();
                        } else {
                            b = Blob.valueOf('Test');
                        }
                        Attachment att = new Attachment();
                        att.ParentId = pay.Id;
                        att.Name = 'DLD Fee.pdf';
                        att.Body = b;
                        insertList.add(att);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                        for(Attachment oneAtt : insertList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                    if(!attachmentMap.isEmpty()) {
                        // system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'DLD_Fee_Email_Template'];
                        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                        if( !test.isrunningtest())
                            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                        
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                }
                            }
                        }
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            email.saveAsActivity = true;
                            email.setTemplateId(tempId);
                            if(attachmentMap.containskey(ppd.Id)){
                                for(Attachment att : attachmentMap.get(ppd.Id)) {
                                    if(att.Name == 'DLD Fee.pdf') {
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName('DLD Fee.pdf');
                                        efa.setBody(att.Body);
                                        efalst.add(efa);
                                    }
                                    if(!efalst.isEmpty()) {
                                        email.setFileAttachments(efalst);
                                    }
                                }
                            }
                            mails.add(email); 
                        }
                        try {
                            if(!mails.isEmpty()){
                                Messaging.sendEmail(mails);
                            }
                        } catch(Exception e){
                            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        }
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send mail to Crm Executive SPA when total paid percent is greater than 9.5 on Oct'20 2023
    public static void sendEmailToCrmExecutiveSPA(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(!book.Notification_to_CRM_Executive_for_SPA__c && (book.SPA_Transaction_Exception__c && book.SPA_Transaction_Exception__c != oldBookMap.get(book.Id).SPA_Transaction_Exception__c) || (book.Qualification_Date__c != null && book.PropStrength__Active__c && (book.Qualification_Date__c != oldBookMap.get(book.Id).Qualification_Date__c))) {
                bookId.add(book.Id);
            }
        }
        
        // System.debug('bookId: '+bookId);
        
        if(!bookId.isEmpty() && !System.isBatch()) {
            BookingTriggerHelper.sendMailToSPAExecCRM(bookId);
        }
    }
    
    @Future(Callout=True)
    public static void sendMailToSPAExecCRM(Set<Id> bookId) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> emailAddress = new set<String>(); 
        String tempId = '';
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        
        List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,
                                                               PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,
                                                               PropStrength__Property__r.Floor_Plan_Uploaded__c,PropStrength__Property__r.Unit_Plan_Uploaded__c,
                                                               PropStrength__Property__r.Area_Confirmation_by_Sales_Ops_Date__c,PropStrength__Property__r.Material_Specification_Uploaded__c,
                                                               PropStrength__Property__r.District_Plan_Uploaded__c,
                                                               PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c 
                                                               FROM PropStrength__Application_Booking__c 
                                                               WHERE ((PropStrength__Property__r.Floor_Plan_Uploaded__c != null
                                                                       AND PropStrength__Property__r.Unit_Plan_Uploaded__c != null
                                                                       AND PropStrength__Property__r.RecordType.Name != 'Plots' 
                                                                       AND PropStrength__Property__r.Area_confirmation_Date_Time__c != null 
                                                                       AND PropStrength__Property__r.Area_Confirmation_by_Sales_Ops_Date__c != null
                                                                       AND PropStrength__Property__r.Material_Specification_Uploaded__c != null
                                                                       AND PropStrength__Property__r.District_Plan_Uploaded__c != null
                                                                       AND PropStrength__Project__r.RERA_Registered__c = true
                                                                       AND Qualification_Date__c != null) OR SPA_Transaction_Exception__c = TRUE )
                                                               AND Id IN :bookId];
        
        // System.debug('bookRecs: '+bookRecs);
        
        if(!bookRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Eligible_for_SPA'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Application_Booking__c book : bookRecs) {
                if(book.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    emailAddress.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c); 
                }
                if(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c != null) {
                    sendTo.add(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email);
                }
            }
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                //owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
            }
            
            for(PropStrength__Application_Booking__c book : bookRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                // system.debug('sendTo::'+sendTo);
                // system.debug('book.PropStrength__Primary_Customer__c::'+book.PropStrength__Primary_Customer__c);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                    List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
                    for(PropStrength__Application_Booking__c book : bookRecs) {
                        PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                        oneBook.Id = book.Id;
                        oneBook.Notification_to_CRM_Executive_for_SPA__c = true;
                        oneBook.Notification_Sent_Date_to_CRM_for_SPA__c = Date.today();
                        bookingList.add(oneBook);
                        trList.add(new PropStrength__Transaction_Requests__c(RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Status__c = 'To Be Issued'));
                    }
                    if(!bookingList.isEmpty()) {
                        update bookingList;
                        insert trList;
                    }
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    //Added by Deepak sharma to send mail to Crm Executive DSPA when MOU_Executed__c is TRUE on Oct'20 2023
    public static void sendEmailToCrmExecutiveDSPA(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(!book.Notification_to_CRM_Executive_for_DSPA__c && (book.DSPA_Transaction_Exception__c || (book.MOU_Executed__c && book.PropStrength__Active__c)) && (book.DSPA_Transaction_Exception__c != oldBookMap.get(book.Id).DSPA_Transaction_Exception__c || book.MOU_Executed__c != oldBookMap.get(book.Id).MOU_Executed__c)) {
                bookId.add(book.Id);
            }
        }
        
        // System.debug('bookId: '+bookId);
        
        if(!bookId.isEmpty() && !System.isBatch()) {
            BookingTriggerHelper.sendMailToDSPAExecCRM(bookId);
        }
    }
    
    @Future(Callout=True)
    public static void sendMailToDSPAExecCRM(Set<Id> bookId) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> emailAddress = new set<String>(); 
        String tempId = '';
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        
        List<PropStrength__Application_Booking__c> bookingRecs = [SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,
                                                                  PropStrength__Property__r.Annexure_Document_Uploaded__c,PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,
                                                                  PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c 
                                                                  FROM PropStrength__Application_Booking__c 
                                                                  WHERE (DSPA_Transaction_Exception__c = TRUE OR (PropStrength__Property__r.Annexure_Document_Uploaded__c!= null 
                                                                                                                  AND PropStrength__Property__r.Plot_Location_Plan_Uploaded__c != null))
                                                                  AND Id IN :bookId];
        
        if(!bookingRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Eligible_for_DSPA'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Application_Booking__c book : bookingRecs) {
                if(book.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    emailAddress.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c); 
                }
                if(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c != null) {
                    sendTo.add(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email);
                }
            }
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];
            
            for(PropStrength__Application_Booking__c book : bookingRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                // system.debug('sendTo::'+sendTo);
                // system.debug('book.PropStrength__Primary_Customer__c::'+book.PropStrength__Primary_Customer__c);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                    List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
                    for(PropStrength__Application_Booking__c book : bookingRecs) {
                        PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                        oneBook.Id = book.Id;
                        oneBook.Notification_to_CRM_Executive_for_DSPA__c = true;
                        oneBook.Notification_Sent_Date_to_CRM_for_DSPA__c = System.now();
                        bookingList.add(oneBook);
                        trList.add(new PropStrength__Transaction_Requests__c(RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
                    }
                    // System.debug('bookingList****'+bookingList);
                    if(!bookingList.isEmpty()) {
                        update bookingList;
                        insert trList;
                    }
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    //Added by Deepak sharma to add Attachment when SPA_Executed__c is true on Oct'20 2023
    public static void pccDocGenerate(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookingList) {
            Decimal totInt = book.Total_Interest_Due_Till_Date__c != null ? book.Total_Interest_Due_Till_Date__c : 0.0;
            if(!book.PCC_Document_Generated__c && book.SPA_Executed__c && book.Pre_Registration_Completed__c && (totInt-book.Total_Interest_Received_Till_Date__c) <= 0 && book.PropStrength__Active__c && (book.SPA_Executed__c != oldBookMap.get(book.Id).SPA_Executed__c || book.Pre_Registration_Completed__c != oldBookMap.get(book.Id).Pre_Registration_Completed__c)) {
                bookId.add(book.Id);
            }
        }
        
        // System.debug('bookId: '+bookId);
        
        if(!bookId.isEmpty() && !System.isBatch()) {
            BookingTriggerHelper.createPCCDocAtt(bookId);
        }
    }
    
    @Future(Callout=True)
    public static void createPCCDocAtt(Set<Id> bookId) {
        Id paymentDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        
        List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,
                                                               PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,
                                                               PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.DLD_Executive__c,
                                                               PropStrength__Project__r.DLD_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c ,
                                                               (SELECT Id, PropStrength__Approval_Status__c, PropStrength__Is_Milestone_Completed__c, PropStrength__Balance__c FROM PropStrength__Payment_Plan_Details__r), 
                                                               (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :paymentDueRT AND PropStrength__Amount_Due_Type__c = 'Installment') 
                                                               FROM PropStrength__Application_Booking__c 
                                                               WHERE Id IN :bookId];
        
        // System.debug('bookRecs: '+bookRecs);
        
        if(!bookRecs.isEmpty()) {
            List<Attachment> insertList = new List<Attachment>();
            List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
            for(PropStrength__Application_Booking__c book : bookRecs) {
                Boolean ppdEntry = TRUE;
                Boolean payEntry = TRUE;
                
                if(!book.PropStrength__Payment_Plan_Details__r.isEmpty()) {
                    // System.debug('book*---'+book.Id);
                    for(PropStrength__Payment_Plan_Details__c ppd : book.PropStrength__Payment_Plan_Details__r) {
                        if(!(ppd.PropStrength__Approval_Status__c == 'Approved' && ppd.PropStrength__Is_Milestone_Completed__c && ppd.PropStrength__Balance__c <= 100)) {
                            System.debug(ppd.Id+'--book*--Abc-'+book.Id);
                            ppdEntry = FALSE;
                            break;
                        }
                    }
                } else {
                    ppdEntry = FALSE;
                }
                System.debug(book.PropStrength__Payments_Cheques__r.isEmpty()+'---book*--42-'+book.Id);
                if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                    System.debug('---book*--43-'+book.Id);
                    for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                        if(!pay.PropStrength__Demand_Generated__c) {
                            System.debug(pay.Id+'---book*--44-'+book.Id);
                            payEntry = FALSE;
                            break;
                        }
                    }
                } else {
                    payEntry = FALSE;
                }
                
                System.debug('Entry:::::::'+ppdEntry);
                System.debug('Entry:::::::'+payEntry);
                
                if(ppdEntry && payEntry) {
                    // System.debug('book*--AAA-'+book.Id);
                    PageReference pdf;
                    pdf =  Page.PaymentCompletionCertificate;
                    pdf.getParameters().put('id', book.Id);
                    Blob b = pdf.getContent();
                    
                    Attachment att = new Attachment();
                    att.ParentId = book.Id;
                    att.Name = 'PCC Document.pdf';
                    att.Body = b;
                    insertList.add(att);
                    
                    PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                    oneBook.Id = book.id;
                    oneBook.PCC_Document_Generated__c = true;
                    oneBook.PCC_Document_Generated_Date__c = Date.today();
                    updateList.add(oneBook);
                    
                    if(!insertList.isEmpty()) {
                        insert insertList;
                        system.debug('insertList::'+insertList);
                    }
                    if(!updateList.isEmpty()){
                        update updateList;
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma to send mail to Crm Executive MOU when total paid percent is greater than 9.5 on Oct'20 2023
    public static void sendEmailToCRMExecutiveMOU(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(!book.Notification_to_CRM_Executive_for_MOU__c && (book.MOU_Transaction_Exception__c || (book.PropStrength__Status__c == 'Audit Approved' &&  book.Notification_Sent_Date_to_CRM_for_MOU__c == null && book.PropStrength__Total_Paid_Percent__c >= 9.5 && book.PropStrength__Active__c)) && (book.MOU_Transaction_Exception__c != oldBookMap.get(book.Id).MOU_Transaction_Exception__c || book.PropStrength__Total_Paid_Percent__c != oldBookMap.get(book.Id).PropStrength__Total_Paid_Percent__c || book.PropStrength__Status__c != oldBookMap.get(book.Id).PropStrength__Status__c)) {
                bookId.add(book.Id);
            }
        }
        
        // System.debug('bookId: '+bookId);
        
        if(!bookId.isEmpty() && !System.isBatch()) {
            BookingTriggerHelper.sendMailToMOUExecCRM(bookId);
        }
    }
    
    @Future(Callout=True)
    public static void sendMailToMOUExecCRM(Set<Id> bookId) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> emailAddress = new set<String>(); 
        String tempId = '';
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        
        List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,
                                                               PropStrength__Property__r.Annexure_Document_Uploaded__c,PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,
                                                               PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c
                                                               FROM PropStrength__Application_Booking__c
                                                               WHERE (MOU_Transaction_Exception__c = TRUE OR (PropStrength__Property__r.Annexure_Document_Uploaded__c != null AND 
                                                                                                              PropStrength__Property__r.RecordType.Name =: 'Plots')) AND Id IN :bookId];
        
        if(!bookRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Eligible_for_MOU'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Application_Booking__c book : bookRecs) {
                if(book.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    emailAddress.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c); 
                }
                if(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c != null) {
                    sendTo.add(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email);
                }
            }
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];
            
            for(PropStrength__Application_Booking__c book : bookRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                system.debug('sendTo::'+sendTo);
                // system.debug('book.PropStrength__Primary_Customer__c::'+book.PropStrength__Primary_Customer__c);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                    List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
                    for(PropStrength__Application_Booking__c book : bookRecs) {
                        PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                        oneBook.Id = book.Id;
                        oneBook.Notification_to_CRM_Executive_for_MOU__c = true;
                        oneBook.Notification_Sent_Date_to_CRM_for_MOU__c = System.now();
                        bookingList.add(oneBook);
                        trList.add(new PropStrength__Transaction_Requests__c(RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
                    }
                    if(!bookingList.isEmpty()) {
                        update bookingList;
                        insert trList;
                    }
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    //Added by Nishank Manwani to send mail to Crm Executive when Title Deed status is Title Deed Uploaded on Dec'22 2023
    public static void sendEmailToCRMExecutiveTitleDeed(List<PropStrength__Application_Booking__c> bookingList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookingList) {
            if(book.Title_Deed_Status__c == 'Title Deed Uploaded' && book.PropStrength__Active__c && (book.Title_Deed_Status__c != oldBookMap.get(book.Id).Title_Deed_Status__c)) {
                bookId.add(book.Id);
            }
        }
        
        // System.debug('bookId: '+bookId);
        
        if(!bookId.isEmpty() && !System.isBatch()) {
            BookingTriggerHelper.sendMailToExecCRMTitleDeed(bookId);
        }
    }
    
    //Added by Nishank Manwani to send mail to Crm Executive when Title Deed status is Title Deed Uploaded on Dec'22 2023
    @Future(Callout=True)
    public static void sendMailToExecCRMTitleDeed(Set<Id> bookId) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        String tempId = '';
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        
        List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, CRM_Executive_Email__c, CRM_Executive__c 
                                                               FROM PropStrength__Application_Booking__c
                                                               WHERE Id IN :bookId];
        
        if(!bookRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Title_Deed_Uploaded'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Application_Booking__c book : bookRecs) {
                if(book.CRM_Executive_Email__c != null) {
                    sendTo.add(book.CRM_Executive_Email__c); 
                }
            }
            
            for(PropStrength__Application_Booking__c book : bookRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                email.setWhatId(book.id);
                email.setTargetObjectId(book.CRM_Executive__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                system.debug('sendTo::'+sendTo);
                // system.debug('book.CRM_Executive_Email__c::'+book.CRM_Executive_Email__c);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    //Added by Deepak sharma on 07/11/23 to show error when pcc status is rejected by audit and reason is blank
    public static void showErrorOnPCCRejection(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book: bookList) {
            if((book.Audit_Rejected_PCC_to__c == null || book.Audit_Rejected_PCC_to__c == '') && (book.PCC_Status__c == 'PCC Rejected by Accounts' || book.PCC_Status__c == 'PCC Rejected by Audit')  && book.PCC_Status__c != oldBookMap.get(book.Id).PCC_Status__c) {
                book.addError('Please Enter Value in Audit Rejected PCC to Field');
            }
        }
    }
    
    //Added by Deepak sharma on 10/Nov/2023 to update Sales_Commission_Eligible_1st_Half__c, Marketing_CP_Commission_Eligible__c true when PropStrength__Total_Paid_Percent__c > = 10% , Booking_Form_Executed__c = TRUE , for 2nd PropStrength__Total_Paid_Percent__c > = 20% , Booking_Form_Executed__c = TRUE, SPA_Executed__c = TRUE (on insert)
    public static void markCBTrue1stN2ndHalf(List<PropStrength__Application_Booking__c> bookList) {
        List<PropStrength__Application_Booking__c> updateBookList1st = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> updateBookList2nd = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c book: bookList) {
            if(book.Booking_Form_Executed__c && book.PropStrength__Total_Paid_Percent__c >= 20 && book.SPA_Executed__c) {
                updateBookList2nd.add(new PropStrength__Application_Booking__c(Id=book.Id, Sales_Commission_Eligible_2nd_Half__c = TRUE));
            } 
            if(book.Booking_Form_Executed__c && book.PropStrength__Total_Paid_Percent__c >= 10) {
                updateBookList1st.add(new PropStrength__Application_Booking__c(Id=book.Id, Sales_Commission_Eligible_1st_Half__c = TRUE, Marketing_CP_Commission_Eligible__c = TRUE));
            }
        }
        
        if(!updateBookList1st.isEmpty()) {
            update updateBookList1st;
        }
        if(!updateBookList2nd.isEmpty()) {
            update updateBookList2nd;
        }
    }
    
    //Added by Deepak sharma on 10/Nov/2023 to update Sales_Commission_Eligible_1st_Half__c, Marketing_CP_Commission_Eligible__c true when PropStrength__Total_Paid_Percent__c > = 10% , Booking_Form_Executed__c = TRUE , for 2nd PropStrength__Total_Paid_Percent__c > = 20% , Booking_Form_Executed__c = TRUE, SPA_Executed__c = TRUE (on update)
    public static void markCBTrue1stN2ndHalfOnUpdate(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Application_Booking__c> updateBookList1st = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> updateBookList2nd = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c book: bookList) {
            // System.debug('book***'+book);
            System.debug('oldBookMap.get(book.Id)***'+oldBookMap.get(book.Id));
            if(!book.Sales_Commission_Eligible_2nd_Half__c && (oldBookMap.get(book.Id).Booking_Form_Executed__c != book.Booking_Form_Executed__c || oldBookMap.get(book.Id).PropStrength__Total_Paid_Percent__c != book.PropStrength__Total_Paid_Percent__c || oldBookMap.get(book.Id).SPA_Executed__c != book.SPA_Executed__c) && book.Booking_Form_Executed__c && book.PropStrength__Total_Paid_Percent__c >= 20 && book.SPA_Executed__c) {
                updateBookList2nd.add(new PropStrength__Application_Booking__c(Id=book.Id, Sales_Commission_Eligible_2nd_Half__c = TRUE));
            } 
            if(!book.Sales_Commission_Eligible_1st_Half__c && !book.Marketing_CP_Commission_Eligible__c && (oldBookMap.get(book.Id).Booking_Form_Executed__c != book.Booking_Form_Executed__c || oldBookMap.get(book.Id).PropStrength__Total_Paid_Percent__c != book.PropStrength__Total_Paid_Percent__c) && book.Booking_Form_Executed__c && book.PropStrength__Total_Paid_Percent__c >= 10) {
                updateBookList1st.add(new PropStrength__Application_Booking__c(Id=book.Id, Sales_Commission_Eligible_1st_Half__c = TRUE, Marketing_CP_Commission_Eligible__c = TRUE));
            }
        }
        
        System.debug('updateBookList1st***'+updateBookList1st);
        System.debug('updateBookList2nd***'+updateBookList2nd);
        
        if(!updateBookList1st.isEmpty()) {
            update updateBookList1st;
        }
        if(!updateBookList2nd.isEmpty()) {
            update updateBookList2nd;
        }
    }
    // Added By Deepak 4-1-2024
    public static void validateBooking(List<PropStrength__Application_Booking__c> bookingList, Map<Id,PropStrength__Application_Booking__c> oldBookingMap) {
        Set<Id> brokerAccountId = new Set<Id>();
        Set<Id> primaryContactId = new Set<Id>();
        Set<Id> propertyId = new Set<Id>();
        Set<String> blockIds = new Set<String>();
        List<PropStrength__Application_Booking__c> bookingsHaveToBeCheck = new List<PropStrength__Application_Booking__c>();
        if(oldBookingMap != null) {
            for(PropStrength__Application_Booking__c rec : bookingList) {
                if( rec.PropStrength__Broker_Account__c != oldBookingMap.get(rec.Id).PropStrength__Broker_Account__c 
                   || rec.PropStrength__Primary_Customer__c != oldBookingMap.get(rec.Id).PropStrength__Primary_Customer__c
                   || rec.PropStrength__Property__c != oldBookingMap.get(rec.Id).PropStrength__Property__c) {
                       bookingsHaveToBeCheck.add(rec);
                   }
            }
        }
        else {
            bookingsHaveToBeCheck.addAll(bookingList);
        }
        
        if(!bookingsHaveToBeCheck.isEmpty()) {
            for(PropStrength__Application_Booking__c bookingRec : bookingsHaveToBeCheck) {
                if(bookingRec.PropStrength__Broker_Account__c != null) {
                    brokerAccountId.add(bookingRec.PropStrength__Broker_Account__c);
                }
                if(bookingRec.PropStrength__Primary_Customer__c != null) {
                    primaryContactId.add(bookingRec.PropStrength__Primary_Customer__c);
                }
                if(bookingRec.PropStrength__Property__c != null) {
                    propertyId.add(bookingRec.PropStrength__Property__c);
                }
            }
            
            
            List<Blacklisted__c> blackList = [SELECT Id, Channel_Partner__c, Customer__c, Unit__c, From_Date__c, To_Date__c,  RecordType.name 
                                              FROM Blacklisted__c 
                                              WHERE Blacklisted__c = true AND ((From_Date__c = null OR From_Date__c <= TODAY) AND (To_Date__c >= TODAY OR To_Date__c = null)) AND (Channel_Partner__c IN :brokerAccountId OR Customer__c IN: primaryContactId)];
            for(Blacklisted__c rec : blackList) {
                if(rec.RecordType.name  == 'Broker') {
                    blockIds.add(rec.Channel_Partner__c+'');
                }
                if(rec.RecordType.name == 'Customer') {
                    if(rec.Unit__c != null) {
                        blockIds.add(rec.Customer__c + '_' + rec.Unit__c);
                    }
                    else {
                        blockIds.add(rec.Customer__c + '_');
                    }
                    
                }
            }
            
            for(PropStrength__Application_Booking__c bookingRec : bookingList) {
                if(bookingRec.PropStrength__Broker_Account__c != null && blockIds.contains(bookingRec.PropStrength__Broker_Account__c+'')) {
                    bookingRec.addError('Booking can not be created as the Channel Partner is blacklisted.');
                    continue;
                }
                if(bookingRec.PropStrength__Primary_Customer__c != null && bookingRec.PropStrength__Property__c != null && (blockIds.contains(bookingRec.PropStrength__Primary_Customer__c+'_'+bookingRec.PropStrength__Property__c) || blockIds.contains(bookingRec.PropStrength__Primary_Customer__c+'_'))) {
                    bookingRec.addError('Booking can not be created as the customer is blacklisted.');
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 25-01-24 to update Property checkboxes when booking is rellocated
    public static void updatePropertyCBOnRelocated(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Property__c> propList = new List<PropStrength__Property__c>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.PropStrength__Property__c != null && book.PropStrength__Old_Booking__c == null && book.PropStrength__New_Booking__c == null && book.PropStrength__Status__c == 'Booking Reallocated' && book.PropStrength__Status__c != oldBookMap.get(book.Id).PropStrength__Status__c) {
                propList.add(new PropStrength__Property__c(Id = book.PropStrength__Property__c, PropStrength__Allotted__c = false, PropStrength__Property_on_hold_for_Reallocation__c = true));
            }
        }
        
        if(!propList.isEmpty()) {
            update propList;
        }
    }
    
    //Added by Nishank Manwani on 01-02-2024 to update User field on booking
    public static void fillUserfield(List<PropStrength__Application_Booking__c> bookList) {
        String crmDoc = '%'+System.Label.CrmDocumentController+'%';
        String sellerRepre = '%'+System.Label.SellerRepresentative+'%';
        
        List<User> userList = [SELECT Id, Email FROM User WHERE (Email LIKE :crmDoc OR Email LIKE :sellerRepre)];
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Docusign_Sales_Ops_Email__c == null || book.Docusign_Sales_Ops_Email__c == '') {
                book.Docusign_Sales_Ops_Email__c = System.label.DocusignSalesOpsEmail;
            }
            if(book.Docusign_Audit_Email__c == null || book.Docusign_Audit_Email__c == '') {
                book.Docusign_Audit_Email__c = System.label.DocusignAuditEmail;
            }
            
            for(User u : userList) {    
                if(u.Email == System.Label.CrmDocumentController) {
                    if(book.CRM_Document_Controller__c == null) {
                        book.CRM_Document_Controller__c = u.Id;
                    }
                }
                if(u.Email == System.Label.SellerRepresentative) {
                    if(book.Seller_Representative__c == null) {
                        book.Seller_Representative__c = u.Id;
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 07-02-2024 ro update Reminder_to_CRM_Executive_for_Slot__c field as per Handover_Notice_Sent_Date__c
    public static void fillRemindertoCRMExecutiveforSlot(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Handover_Notice_Sent_Date__c != null && book.Handover_Notice_Sent_Date__c != oldBookMap.get(book.Id).Handover_Notice_Sent_Date__c) {
                Time sevenPM = Time.newInstance(19, 0, 0, 0);
                DateTime reminderDateTime = DateTime.newInstance(book.Handover_Notice_Sent_Date__c.date(), sevenPM);
                book.Reminder_to_CRM_Executive_for_Slot__c = reminderDateTime;
            }
        }
    }
    
    //Added by Nishank Manwani on 14/02/2024 to send handover notice reminder
    public static void sendHandoverNoticeReminder(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Handover_Notice_Sent__c && book.Handover_Notice_Sent_Date__c != null && 
               !book.Handover_Completed__c && 
               book.Handover_Notice_Sent__c != oldBookMap.get(book.Id).Handover_Notice_Sent__c && 
               book.Handover_Notice_Sent_Date__c != oldBookMap.get(book.Id).Handover_Notice_Sent_Date__c) {
                   SendHandoverNoticeReminder.scheduleEmail(book.Id);
               }
        }
    }
    
    public static void sendSalesTeamToApproval(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Application_Booking__c> listOfSD = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> listOfSM = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if( ( book.New_Sales_Director__c != null && oldBookMap == null ) ||            
               (oldBookMap != null && book.New_Sales_Director__c != oldBookMap.get(book.Id).New_Sales_Director__c ) ) {
                   listOfSD.add(book);
               }
            if( ( book.New_Sales_Manager__c != null && oldBookMap == null ) ||            
               (oldBookMap != null && book.New_Sales_Manager__c != oldBookMap.get(book.Id).New_Sales_Manager__c ) ) {
                   listOfSM.add(book);
               }
        }
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(PropStrength__Application_Booking__c bookRec : listOfSD){            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(bookRec.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(bookRec.New_Sales_Director__c);           
            req1.setProcessDefinitionNameOrId('Sales_Director_Approval');
            req1.setSkipEntryCriteria(true);
            requests.add(req1);
            System.debug('requests*--'+requests);
            // Submit the approval request for the account
            //Approval.ProcessResult result = Approval.process(req1);
        }
        for(PropStrength__Application_Booking__c bookRec : listOfSM){            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(bookRec.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(bookRec.New_Sales_Manager__c);           
            req1.setProcessDefinitionNameOrId('Sales_Manager_Approval');
            req1.setSkipEntryCriteria(true);
            requests.add(req1);
            System.debug('requests*--'+requests);
            // Submit the approval request for the account
            //Approval.ProcessResult result = Approval.process(req1);
        }
        System.debug('requests*--'+requests);
        Approval.ProcessResult[] processResults = null;
        if(requests.size() > 0){
            try {
                processResults = Approval.process(requests, true);
            }catch (System.DmlException e) {
                System.debug('Exception Is ' + e.getMessage());
            }        
        }
    }
    
    public static void updateSalesTeam(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Application_Booking__c> listOfUpdateSD = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if( book.Approval_Status_for_Sales_Manager__c != oldBookMap.get(book.Id).Approval_Status_for_Sales_Manager__c  && book.Approval_Status_for_Sales_Manager__c =='Approved : New Sales Manager') {
                PropStrength__Application_Booking__c bookRec = new PropStrength__Application_Booking__c();  
                bookRec.Id = book.id;
                bookRec.Sales_Manager__c = book.New_Sales_Manager__c;
                listOfUpdateSD.add(bookRec);
            }
            if( book.Approval_Status_for_Sales_Director__c != oldBookMap.get(book.Id).Approval_Status_for_Sales_Director__c && book.Approval_Status_for_Sales_Director__c =='Approved : New Sales Director'  ) {
                PropStrength__Application_Booking__c bookRec = new PropStrength__Application_Booking__c();  
                bookRec.Id = book.id;
                bookRec.Sales_Director__c = book.New_Sales_Director__c;
                listOfUpdateSD.add(bookRec);
            }            
        }
        if(listOfUpdateSD.size() > 0){
            update listOfUpdateSD;
        }
    }
    // Added By Gourav Gour 15/04/2024
    public static void updateQualificationDate(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Booking_Form_Verified_by_Audit_Date__c != oldBookMap.get(book.Id).Booking_Form_Verified_by_Audit_Date__c  || book.X9_5_Payment_Received_Date__c != oldBookMap.get(book.Id).X9_5_Payment_Received_Date__c) {
                // Commented this code 2/8/2024 By Gourav Gour
                /* if(book.X9_5_Payment_Received_Date__c != null && book.Booking_Form_Verified_by_Audit_Date__c == null) {
book.Qualification_Date__c = book.X9_5_Payment_Received_Date__c;
}
else if(book.X9_5_Payment_Received_Date__c == null && book.Booking_Form_Verified_by_Audit_Date__c != null) {
book.Qualification_Date__c = book.Booking_Form_Verified_by_Audit_Date__c;
}
else */
                if(book.X9_5_Payment_Received_Date__c != null && book.Booking_Form_Verified_by_Audit_Date__c != null) {
                    if(book.X9_5_Payment_Received_Date__c <= book.Booking_Form_Verified_by_Audit_Date__c) {
                        book.Qualification_Date__c = book.Booking_Form_Verified_by_Audit_Date__c;
                    }
                    else {
                        book.Qualification_Date__c = book.X9_5_Payment_Received_Date__c;
                    }
                }
            }
        } 
    }
    
    public static void sendWelcomeEmail(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Qualification_Date__c != null && book.Qualification_Date__c != oldBookMap.get(book.Id).Qualification_Date__c) {
                bookId.add(book.Id);
            }
        }
        if(!bookId.isEmpty()) {
            BookingTriggerHelper.sendWelcomeEmailToApplicant(bookId);
        }
    }
    
    //Added by Nishank Manwani on 04-Jul-24 to update status value of booking to Qualified Sales
    public static void updateQualifiedSales(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Qualification_Date__c != null && book.Qualification_Date__c != oldBookMap.get(book.Id).Qualification_Date__c) {
                bookId.add(book.Id);
            }
        }
        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                       (SELECT Id FROM PropStrength__Transaction_Request__r WHERE RecordType.Name = 'SPA Process')
                                                                                                                       FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(bookMap.containsKey(book.Id) && book.Qualification_Date__c != null && book.Qualification_Date__c != oldBookMap.get(book.Id).Qualification_Date__c) {
                    if(bookMap.get(book.Id).PropStrength__Transaction_Request__r.isEmpty()) {
                        book.SPA_Status__c = 'Qualified Sales';
                    }
                }
            }
        }
    }
    
    @future(callOut=true)
    public static void sendWelcomeEmailToApplicant(set<Id> bookId) { 
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<PropStrength__Application_Booking__c> bookingList = new list<PropStrength__Application_Booking__c>();
        bookingList = [SELECT Id,PropStrength__Applicant_Email__c, Name,PropStrength__Status__c,
                       PropStrength__Project__c,PropStrength__Primary_Customer__c,
                       PropStrength__Project__r.Project_Registration_Date__c,
                       Booking_Form_Executed__c,PropStrength__Total_Paid_Percent__c,
                       PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,
                       PropStrength__Welcome_Letter__c,PropStrength__Welcome_Letter_Note__c,Welcome_Letter_Sent_Date__c,
                       PropStrength__Primary_Applicant_Name__c,
                       (SELECT Id, Name, ParentId FROM Attachments WHERE (Name = 'Pre-Registration Notice.pdf' OR Name = :'Welcome Letter.pdf')),
                       (SELECT ID, PropStrength__Applicant_Email__c, PropStrength__Applicant_Acc__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Applicant_Email__c != null AND PropStrength__Active__c = true)
                       FROM PropStrength__Application_Booking__c 
                       WHERE Id IN : bookId];
        if(!bookingList.isEmpty()) {
            StaticResource staticRes = [SELECT Body FROM StaticResource WHERE Name = 'KnowYourJourney'];
            Blob imageBlob = staticRes.Body;
            
            System.debug(imageBlob);
            
            List<Attachment> existingList = [SELECT Name,ParentId, Body, ContentType 
                                             FROM Attachment WHERE ParentId IN : bookId AND 
                                             (Name != 'Welcome Letter.pdf' AND Name != 'Pre-Registration Notice.pdf')];
            
            Map<String, List<Attachment>> mapOfBookingAttachment = new Map<String, List<Attachment>>();
            for(Attachment attach : existingList){
                if(mapOfBookingAttachment.containskey(attach.ParentId)){
                    mapOfBookingAttachment.get(attach.ParentId).add(attach);
                }
                else{
                    mapOfBookingAttachment.put(attach.ParentId, new List<Attachment>{attach});
                }
            }
            
            List<Attachment> deleteAtt = new List<Attachment>();
            List<Attachment> insertList = new List<Attachment>();
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE (DeveloperName =: 'Welcome_Email_Template' OR DeveloperName =: 'Welcome_Email_Template_Siniya')];
            
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
                if(!book.Attachments.isEmpty()) {
                    deleteAtt.addAll(book.Attachments);
                }
            }
            
            
            if(!deleteAtt.isEmpty()){
                delete deleteAtt;
            }
            
            if( !test.isrunningtest())
                owea = [SELECT id, DisplayName from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email OR DisplayName =: System.Label.Siniya_Contact_From_Address_Email limit 2]; 
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();                
                
                if(book.Id != null && mapOfBookingAttachment.containsKey(book.Id) && !mapOfBookingAttachment.get(book.Id).isEmpty()) {
                    for(Attachment oneAtt : mapOfBookingAttachment.get(book.Id)) {
                        if(attachmentMap.containskey(oneAtt.ParentId)) {
                            List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                            newPLI.add(oneAtt);
                            attachmentMap.put(oneAtt.ParentId, newPLI);
                        } else {
                            attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                        }
                    }
                }
                
                String tempId = '';
                
                for(EmailTemplate empTem : emailTemplate) {
                    if(empTem.DeveloperName == 'Welcome_Email_Template_Siniya' && book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        tempId = empTem.Id;
                    } else if(empTem.DeveloperName == 'Welcome_Email_Template') {
                        tempId = empTem.Id;
                    }
                }
                for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                    PageReference pdf2;
                    pdf2 =  Page.PreRegistrationNoticeAppbook;
                    pdf2.getParameters().put('id',(String)appDet.id); 
                    pdf2.setRedirect(true);
                    Blob b2;
                    if(Test.isRunningTest()){
                        b2 = blob.valueOf('Unit.Test');
                    }else{
                        b2 = pdf2.getContent();
                    }
                    
                    Attachment att2 = new Attachment();
                    att2.ParentId = book.Id;
                    att2.Name = 'Pre-Registration Notice.pdf';
                    att2.Body = b2;
                    if(!book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        insertList.add(att2);
                    }
                    
                    
                    List<String> sendTo = new List<String>(); 
                    List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
                    sendTo.add(appDet.PropStrength__Applicant_Email__c);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(sendTo);
                    email.setWhatId(appDet.Id);
                    email.setTargetObjectId(appDet.PropStrength__Applicant_Acc__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    if (owea.size() > 0) {
                        for(OrgWideEmailAddress ow : owea) {
                            if(ow.DisplayName == System.Label.Siniya_Contact_From_Address_Email && book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                                email.setOrgWideEmailAddressId(ow.Id);
                                System.debug('innn');
                                System.debug(ow.Id);
                            } else if(ow.DisplayName == System.Label.Contact_From_Address_Email){
                                email.setOrgWideEmailAddressId(ow.Id);
                                System.debug('innn2');
                                System.debug(ow.Id);
                            }
                        }
                    }
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName('Pre-Registration Notice.pdf');
                    efa.setBody(att2.Body);
                    if(!book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        efalst.add(efa);
                    }
                    
                    if(imageBlob != null) {
                        Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
                        efa2.setFileName('Know Your Journey.jpg');
                        efa2.setBody(imageBlob);
                        efa2.setContentType('image/jpeg');
                        if(!book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                            efalst.add(efa2);
                        }
                    }
                    if(!efalst.isEmpty()) {
                        email.setFileAttachments(efalst);
                    }
                    mails.add(email);
                }
            }
            
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                    List<PropStrength__Application_Booking__c> updatebookingList = new List<PropStrength__Application_Booking__c>();
                    for(PropStrength__Application_Booking__c book : bookingList) {
                        book.PropStrength__Welcome_Letter__c = true;
                        //Commented By Gourav Gour 2/8/2024
                        if(book.PropStrength__Welcome_Letter_Note__c == null) {
                            book.PropStrength__Welcome_Letter_Note__c = system.today();
                        }
                        if(book.Welcome_Letter_Sent_Date__c == null) {
                            book.Welcome_Letter_Sent_Date__c = system.now();
                        }
                        updatebookingList.add(book);
                    }
                    if(!updatebookingList.isEmpty()){
                        update updatebookingList;
                    }
                    if(!insertList.isEmpty()){
                        insert insertList;
                    }
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
    public class requestBodyWrapper{
        String bookingID;
        String bookingStatus;
        String bookingName;
        String customerName;
        String customerEmail;
        DateTime handoverDate;
        Date actualHandoverDate;
        String sfUnitId;
        Date dlpDate;
    }
    
    public static void mapSalesUserFromOffer(List<PropStrength__Application_Booking__c> bookingList,  Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> offerId = new Set<Id>();
        for(PropStrength__Application_Booking__c book: bookingList) {
            if(oldBookMap == null) {
                if(book.PropStrength__Offer__c != null) {
                    offerId.add(book.PropStrength__Offer__c);
                }
            }
            else{
                if(book.PropStrength__Offer__c != null && book.PropStrength__Offer__c != oldBookMap.get(book.Id).PropStrength__Offer__c)  {
                    offerId.add(book.PropStrength__Offer__c);
                }
            }
        }
        
        if(!offerId.isEmpty()) {
            Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, Sales_Head__c, Sales_Manager__c, Secondary_Sales_Head__c, Secondary_Sales_Manager__c 
                                                                                            FROM PropStrength__Offer__c 
                                                                                            WHERE Id IN :offerId]);
            
            for(PropStrength__Application_Booking__c book: bookingList) {
                if(oldBookMap == null) {
                    if(book.PropStrength__Offer__c != null && offerMap.containsKey(book.PropStrength__Offer__c)) {
                        book.Sales_Head__c = offerMap.get(book.PropStrength__Offer__c).Sales_Head__c != null ? offerMap.get(book.PropStrength__Offer__c).Sales_Head__c : null;
                        book.Sales_Manager__c = offerMap.get(book.PropStrength__Offer__c).Sales_Manager__c != null ? offerMap.get(book.PropStrength__Offer__c).Sales_Manager__c : null;
                        book.Secondary_Sales_Head__c = offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Head__c != null ? offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Head__c : null;
                        book.Secondary_Sales_Manager__c = offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Manager__c != null ? offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Manager__c : null;
                    }
                }
                else {
                    if(book.PropStrength__Offer__c != null && book.PropStrength__Offer__c != oldBookMap.get(book.Id).PropStrength__Offer__c && offerMap.containsKey(book.PropStrength__Offer__c)) {
                        book.Sales_Head__c = offerMap.get(book.PropStrength__Offer__c).Sales_Head__c != null ? offerMap.get(book.PropStrength__Offer__c).Sales_Head__c : null;
                        book.Sales_Manager__c = offerMap.get(book.PropStrength__Offer__c).Sales_Manager__c != null ? offerMap.get(book.PropStrength__Offer__c).Sales_Manager__c : null;
                        book.Secondary_Sales_Head__c = offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Head__c != null ? offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Head__c : null;
                        book.Secondary_Sales_Manager__c = offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Manager__c != null ? offerMap.get(book.PropStrength__Offer__c).Secondary_Sales_Manager__c : null;
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 25-Apr-24 on update Snag Rectification Date Field
    public static void sendSnagFldEmail(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookIds = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.PropStrength__Active__c && book.Snag_Rectification_Date__c != null && oldBookMap.get(book.Id).Snag_Rectification_Date__c == null && book.Snag_Rectification_Date__c != oldBookMap.get(book.Id).Snag_Rectification_Date__c) {
                bookIds.add(book.Id);
            }
        }
        
        if(!bookIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookMail = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                                   (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE)  
                                                                   FROM PropStrength__Application_Booking__c WHERE Id IN :bookIds];
            
            String TempId;
            String searchTxt = 'SnagRectification';
            List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
            
            for(PropStrength__Application_Booking__c book : bookMail) {
                List<String> toAddList = new List<String>();
                for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                    toAddList.add(appDet.PropStrength__Applicant_Email__c);
                }
                
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                
                if(!toAddList.isEmpty()) {
                    emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                    emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                    emails.setWhatId(book.Id);
                    emails.setToAddresses(toAddList); 
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    if (owea.size() > 0) {
                        emails.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    emaillist.add(emails);
                }
            }
            
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    //Added by Nishank Manwani on 26-Apr-24 on update Home Orientation Slot Status Field
    public static void sendHomeOrienStatusEmail(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookIds = new Set<Id>();
        Set<Id> changeInStatus = new Set<Id>();
        Set<Id> changeInSlotStatus = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.PropStrength__Active__c && book.Home_Orientation_Slot_Status__c == 'Confirmed' && book.Home_Orientation_Slot_Status__c != oldBookMap.get(book.Id).Home_Orientation_Slot_Status__c) {
                bookIds.add(book.Id);
            }
            if(book.Home_Orientation_Slot_Status__c != null && book.PropStrength__Active__c && book.Home_Orientation_Slot_Status__c != oldBookMap.get(book.Id).Home_Orientation_Slot_Status__c) {
                changeInStatus.add(book.Id);
            }
            if(book.Slot_Status__c != null && book.PropStrength__Active__c && book.Slot_Status__c != oldBookMap.get(book.Id).Slot_Status__c) {
                changeInSlotStatus.add(book.Id);
            }
        }
        
        if(!bookIds.isEmpty()) {
            BookingTriggerHelper.sendAuthorizationLetterToApplicants(bookIds);
        }
        if(!changeInStatus.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookMail = [SELECT Id, PropStrength__Primary_Customer__c, CRM_Executive_Email__c, 
                                                                   (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE)  
                                                                   FROM PropStrength__Application_Booking__c WHERE Id IN :changeInStatus];
            
            String TempId;
            String searchTxt = 'HomeOrientationStatusChange';
            List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
            
            
            for(PropStrength__Application_Booking__c book : bookMail) {
                List<String> toAddList = new List<String>();
                for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                    toAddList.add(appDet.PropStrength__Applicant_Email__c);
                }
                
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                
                if(!toAddList.isEmpty()) {
                    emails.setWhatId(book.Id);
                    emails.setToAddresses(toAddList); 
                    if(book.CRM_Executive_Email__c != null) {
                        emails.setCcAddresses(new List<String>{book.CRM_Executive_Email__c});
                    }
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    if (owea.size() > 0) {
                        emails.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    emaillist.add(emails);
                }
            }
            
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
        if(!changeInSlotStatus.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookMail = [SELECT Id, PropStrength__Primary_Customer__c, CRM_Executive_Email__c, 
                                                                   (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE)  
                                                                   FROM PropStrength__Application_Booking__c WHERE Id IN :changeInSlotStatus];
            
            String TempId;
            String searchTxt = 'SlotStatusChange';
            List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
            
            
            for(PropStrength__Application_Booking__c book : bookMail) {
                List<String> toAddList = new List<String>();
                for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                    toAddList.add(appDet.PropStrength__Applicant_Email__c);
                }
                
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                
                if(!toAddList.isEmpty()) {
                    emails.setWhatId(book.Id);
                    emails.setToAddresses(toAddList); 
                    if(book.CRM_Executive_Email__c != null) {
                        emails.setCcAddresses(new List<String>{book.CRM_Executive_Email__c});
                    }
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    if (owea.size() > 0) {
                        emails.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    emaillist.add(emails);
                }
            }
            
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    //Added by Nishank Manwani on 26/04/2024 to send Authorization Letter to applicants on Confirmed status on Home Orientation Slot Status Field
    @future(callOut=true)
    public static void sendAuthorizationLetterToApplicants(set<Id> bookId) { 
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<PropStrength__Application_Booking__c> bookingList = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                                  (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE) ,
                                                                  (SELECT Name,ParentId, ContentType FROM Attachments WHERE Name =: 'Authority Letter.pdf' ORDER BY CreatedDate DESC LIMIT 1)
                                                                  FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];
        
        if(!bookingList.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'HomeOrientationSlot'];
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
            Map<String, Attachment> mapOfBookingAttachment = new Map<String, Attachment>();
            
            for(PropStrength__Application_Booking__c book : bookingList) {
                List<String> sendTo = new List<String>(); 
                Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
                
                List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();                
                
                if(!book.Attachments.isEmpty()) {
                    delete book.Attachments;
                    
                    List<Attachment> insertList = new List<Attachment>();
                    PageReference pdf;
                    pdf =  Page.AuthorityLetterOnBooking;
                    pdf.getParameters().put('id', book.Id);
                    Blob b;
                    if(Test.isRunningTest()){
                        b = blob.valueOf('Unit.Test');
                    }else{
                        b = pdf.getContent();
                    }
                    
                    Attachment att = new Attachment();
                    att.ParentId = book.Id;
                    att.Name = 'Authority Letter.pdf';
                    att.Body = b;
                    if(att != null) {
                        insert att;
                        if(att.Id != null) {
                            insertList.add(att);
                        }
                    }
                    for(Attachment oneAtt : insertList) {
                        if(attachmentMap.containskey(oneAtt.ParentId)) {
                            List<Attachment> attExist = attachmentMap.get(oneAtt.ParentId);
                            attExist.add(oneAtt);
                            attachmentMap.put(oneAtt.ParentId, attExist);
                        } else {
                            attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                        }
                    }
                } else {
                    List<Attachment> insertList = new List<Attachment>();
                    PageReference pdf;
                    pdf =  Page.AuthorityLetterOnBooking;
                    pdf.getParameters().put('id', book.Id); 
                    Blob b ;
                    if(Test.isRunningTest()){
                        b = blob.valueOf('Unit.Test');
                    }else{
                        b = pdf.getContent();
                    }
                    Attachment att = new Attachment();
                    att.ParentId = book.Id;
                    att.Name = 'Authority Letter.pdf';
                    att.Body = b;
                    if(att != null) {
                        try {
                            insert att;
                            if(att.Id != null) {
                                insertList.add(att);
                            }
                            for(Attachment oneAtt : insertList) {
                                if(attachmentMap.containskey(oneAtt.ParentId)) {
                                    List<Attachment> attExist = attachmentMap.get(oneAtt.ParentId);
                                    attExist.add(oneAtt);
                                    attachmentMap.put(oneAtt.ParentId, attExist);
                                } else {
                                    attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                                }
                            }
                        } catch(DMLException ex) {
                            System.debug('Error::'+ex.getMessage());
                        }
                    }
                }                
                
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                if(!attachmentMap.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                        sendTo.add(appDet.PropStrength__Applicant_Email__c);
                    }                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                    email.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                    email.setToAddresses(sendTo);
                    email.setWhatId(book.Id);
                    email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    if(attachmentMap.containskey(book.Id)){
                        for(Attachment att : attachmentMap.get(book.Id)) {
                            if(att.Name == 'Authority Letter.pdf') {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName('Authority Letter.pdf');
                                efa.setBody(att.Body);
                                efa.setContentType('application/pdf');
                                efa.setInline(false);
                                efalst.add(efa);
                                system.debug('====efalst======='+efalst);
                            }
                        }
                    }
                    
                    if(!efalst.isEmpty()) {
                        email.setFileAttachments(efalst);
                    }
                    mails.add(email); 
                }
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
    //Added by Nishank manwani on 07-05-2024 to update Handover_Reminder_Flow_Date__c
    //Modified by Nishank manwani on 08-05-2024 to update Notification_Sent_Dt_to_CRM_for_SPA__c field
    //Modified by Nishank manwani on 09-05-2024 to update Pre_Registration_Completed_Date__c field
    public static void updateHandoverReminderFlowDt(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Slot_Status__c != oldBookMap.get(book.Id).Slot_Status__c || book.Handover_Notice_Sent_Date__c != oldBookMap.get(book.Id).Handover_Notice_Sent_Date__c) {
                if(book.Handover_Notice_Sent_Date__c != null && book.Slot_Status__c != 'Confirmed' && book.Slot_Status__c != 'Completed') {
                    book.Handover_Reminder_Flow_Date__c = System.Today();
                }
            }
            if(book.Notification_to_CRM_Executive_for_SPA__c && book.Notification_to_CRM_Executive_for_SPA__c != oldBookMap.get(book.Id).Notification_to_CRM_Executive_for_SPA__c) {
                book.Notification_Sent_Dt_to_CRM_for_SPA__c = System.now();
            }
            if(book.Pre_Registration_Completed__c && book.Pre_Registration_Completed__c != oldBookMap.get(book.Id).Pre_Registration_Completed__c) {
                book.Pre_Registration_Completed_Date__c = System.now();
            }
        }
    }
    
    //Added by Nishank Manwani on 07-05-2024 to check  in case of "Yes" Handover Approval Attachment then check the HO Appointment Exception Field and in case of "No" send for Approval
    public static void checkHandoverApprovalAtt(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Early_Handover_Approval__c != oldBookMap.get(book.Id).Early_Handover_Approval__c) {
                if(book.Early_Handover_Approval__c == 'Yes') {
                    bookId.add(book.Id);
                } else if(book.Early_Handover_Approval__c == 'No') {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting Application/Booking for HO Appointment Exception Update.');
                    req1.setObjectId(book.Id);
                    req1.setProcessDefinitionNameOrId('Early_Handover_Approval_Process');
                    req1.setSkipEntryCriteria(true);  
                    Approval.ProcessResult result = Approval.process(req1);
                }
            }
        }
        
        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                       (SELECT Id FROM Attachments WHERE Name LIKE '%Handover Approval%'), 
                                                                                                                       (SELECT Id FROM ContentDocumentLinks WHERE ContentDocument.title LIKE '%Handover Approval%')
                                                                                                                       FROM PropStrength__Application_Booking__c
                                                                                                                       WHERE Id IN :bookId]);
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(book.Early_Handover_Approval__c != oldBookMap.get(book.Id).Early_Handover_Approval__c) {
                    if(book.Early_Handover_Approval__c == 'Yes') {
                        if(bookMap.containsKey(book.Id)) {
                            PropStrength__Application_Booking__c booking = bookMap.get(book.Id);
                            if(!booking.Attachments.isEmpty()) {
                                book.HO_Appointment_Exception__c = true;
                            } else if(!booking.ContentDocumentLinks.isEmpty()) {
                                book.HO_Appointment_Exception__c = true;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 21/05/2024 to send mail to CRM executive to update Home Orientation Schedule Date
    public static void sendHomeScheduleDtToCRM(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Home_Orientation_Scheduled_Date__c == null && book.Home_Orientation_Undertaking_Receive_Dt__c != null && book.Home_Orientation_Undertaking_Receive_Dt__c != oldBookMap.get(book.Id).Home_Orientation_Undertaking_Receive_Dt__c) {
                bookId.add(book.Id);
            }
        }
        
        if(!bookId.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'HomeOrientationScheduleAppointment'];
            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(book.Home_Orientation_Scheduled_Date__c == null && book.Home_Orientation_Undertaking_Receive_Dt__c != null && book.Home_Orientation_Undertaking_Receive_Dt__c != oldBookMap.get(book.Id).Home_Orientation_Undertaking_Receive_Dt__c) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{book.CRM_Executive_Email__c});
                    email.setWhatId(book.Id);
                    email.setTargetObjectId(book.CRM_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
            }
            
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    } 
    
    //Added by Nishank Manwani on 28-May-2024 to send Record for Cost_Deduction_Charges_Approval_Process whenever Cost_Deduction_Charges_Send_for_Approval__c field gets true
    public static void sendForCostDeductionChargesApprovalProcess(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Cost_Deduction_Charges__c != null && book.Cost_Deduction_Charges_Send_for_Approval__c && book.Cost_Deduction_Charges_Send_for_Approval__c != oldBookMap.get(book.Id).Cost_Deduction_Charges_Send_for_Approval__c) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Cost Deduction Charges Approval Process');
                req.setObjectId(book.Id);
                req.setSubmitterId(UserInfo.getUserId());
                req.setProcessDefinitionNameOrId('Cost_Deduction_Charges_Approval_Process');
                req.setSkipEntryCriteria(false);  
                Approval.ProcessResult result = Approval.process(req);
            }
        }
    }
    
    //Added by Nishank Manwani on 28-May-2024 to send email to sales ops queue whenever Current_Cancellation_Status_By_CRM__c field gets updated
    public static void sendMailSaleOpsOnCurrentCancellationStatusChange(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<String> listOfbookingIds = new List<String>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Current_Cancellation_Status_By_CRM__c != null && book.Current_Cancellation_Status_By_CRM__c != oldBookMap.get(book.Id).Current_Cancellation_Status_By_CRM__c) {
                listOfbookingIds.add(book.Id);
            }
        }
        if(listOfbookingIds.size() > 0){
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Current_Cancellation_Status_By_CRM'];
            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            List<String> sendTo = new List<String>();
            
            for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Sales_Ops')]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(book.Current_Cancellation_Status_By_CRM__c != null && book.Current_Cancellation_Status_By_CRM__c != oldBookMap.get(book.Id).Current_Cancellation_Status_By_CRM__c) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(sendTo);
                    email.setWhatId(book.Id);
                    email.setTargetObjectId(book.CRM_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
            }
            
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
    //Added by Nishank Manwani on 30-May-2024 to create task for welcome call when 9.5% is paid and booking form is executed
    public static void createWelcomeCallTask(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<Task> welcomeCallTask = new List<Task>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.Booking_Form_Executed__c && book.PropStrength__Total_Paid_Percent__c > 9.5 && (book.Booking_Form_Executed__c != oldBookMap.get(book.Id).Booking_Form_Executed__c || book.PropStrength__Total_Paid_Percent__c != oldBookMap.get(book.Id).PropStrength__Total_Paid_Percent__c)) {
                Task tsk = new Task();
                tsk.Subject = 'Please make a Welcome Call';
                tsk.Status = 'Not Started';
                tsk.Priority = 'High';
                tsk.WhatId = book.Id;
                if(book.CRM_Executive__c != null) {
                    tsk.OwnerId = book.CRM_Executive__c;
                }
                tsk.ActivityDate = date.today();
                tsk.ReminderDateTime = system.now();
                tsk.IsReminderSet = true;
                welcomeCallTask.add(tsk);
            }
        }
        if(!welcomeCallTask.isEmpty()) {
            insert welcomeCallTask;
        }
    }
    
    //Added by Manvendra - Create Payment for Income Charge Received
    public static void createICRPayemnt(List<PropStrength__Application_Booking__c> bookingList) {
        
        List<PropStrength__Received_Payment__c> createPayRec = new List<PropStrength__Received_Payment__c>();
        Id incChrgeDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Id incChrgeReceivedId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        Set<Id> bookingIds = new Set<Id>();
        Map<Id,PropStrength__Received_Payment__c> bookingIdWithICDPayment = new Map<Id,PropStrength__Received_Payment__c>();
        for(PropStrength__Application_Booking__c booking : bookingList) {
            bookingIds.add(booking.id); 
        }
        List<PropStrength__Received_Payment__c> paymentList = [SELECT id,PropStrength__Application_Booking__c FROM PropStrength__Received_Payment__c WHERE PropStrength__Application_Booking__c=:bookingIds AND RecordTypeId=:incChrgeDueId AND PropStrength__Amount_Due_Type__c='DLD Fees' order by createddate desc];
        for(PropStrength__Received_Payment__c payment : paymentList) {
            if(!bookingIdWithICDPayment.containskey(payment.PropStrength__Application_Booking__c)) {
                bookingIdWithICDPayment.put(payment.PropStrength__Application_Booking__c,payment );
            }
            
        }
        for(PropStrength__Application_Booking__c book : bookingList) {
            System.debug('Oqood_Fees_Amount__c: '+book.Oqood_Fees_Amount__c);
            if(book.PropStrength__Income_Charges_Adjusted__c != null) {
                //PropStrength__Demand_Email_Sent__c=TRUE, PropStrength__Demand_Generated__c=TRUE, PropStrength__Demand_Generated_By__c=UserInfo.getUserId(), PropStrength__Demand_Generation_Date__c=System.Today(), PropStrength__Demand_Status__c='Demand Generated'
                createPayRec.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c=book.Id, PropStrength__Amount_Due_Type__c='DLD Fees',
                                                                       RecordTypeId=incChrgeReceivedId, PropStrength__Amount__c=book.PropStrength__Income_Charges_Adjusted__c,
                                                                       PropStrength__Payment_Date__c=System.Today(), PropStrength__Income_Charge_Due__c = bookingIdWithICDPayment.get(book.Id).id));
            }
        }
        
        System.debug('createPayRec: '+createPayRec);
        
        if(!createPayRec.isEmpty()) {
            insert createPayRec;
        }
        
    }
    
    //Added By Nishank Manwani on 10-June-2024 to send mail to applicant for completion certificate
    public static void sendMailForCompletionCertificate(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<Id> bookId = new List<Id>();
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.PropStrength__Active__c && book.PropStrength__Completion_Certificate_Date__c != null && book.PropStrength__Completion_Certificate_Date__c != oldbookMap.get(book.Id).PropStrength__Completion_Certificate_Date__c) {
                bookId.add(book.Id);
            }
        }
        
        if(!bookId.isEmpty()) {
            BookingTriggerHelper.sendMailToApplicantCC(bookId);
        }
    }
    
    //Added by Nishank Manwani on 10-June-2024 to send mail to applicant for completion certificate
    @Future(Callout=true)
    public static void sendMailToApplicantCC(List<Id> bookId) {
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =: 'Notification_Receive_CC'];
        
        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                               (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r 
                                                                WHERE PropStrength__Active__c = TRUE AND PropStrength__Applicant_Acc__c != null) 
                                                               FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(!book.PropStrength__Applicant_Details__r.isEmpty()) {
                List<String> sendTo = new List<String>();
                
                for(PropStrength__Applicant_Detail__c apDet : book.PropStrength__Applicant_Details__r) {
                    if(apDet.PropStrength__Applicant_Email__c != null) {
                        sendTo.add(apDet.PropStrength__Applicant_Email__c);
                    }
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setWhatId(book.Id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email);
            }
        }
        
        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } Catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
        }
    } 
    
    
    //Added by Nishank Manwani on 03-Jul-24 to update Welcome_Letter_Sent_Date__c date on update of PropStrength__Welcome_Letter_Note__c
    //Commented Gourav gour 2/8/2024 As Welcome_Letter_Sent_Date__c this is directly updated from Email method.
    /*  public static void updateWelcomeLetterDate(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
for(PropStrength__Application_Booking__c book : bookList) {
if(oldBookMap != null && !oldBookMap.isEmpty()) {
if(oldBookMap.get(book.Id).PropStrength__Welcome_Letter_Note__c != book.PropStrength__Welcome_Letter_Note__c) {
book.Welcome_Letter_Sent_Date__c = book.PropStrength__Welcome_Letter_Note__c;
}   
} else if(oldBookMap == null && book.PropStrength__Welcome_Letter_Note__c != null) {
book.Welcome_Letter_Sent_Date__c = book.PropStrength__Welcome_Letter_Note__c;
}
}
}*/
    
    //Added by Nishank Manwani on 08-Jul-24 to Create Title Deed Transaction Request
    public static void createTitleDeedTR(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        Id titleDeedProcess = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if((oldBookMap.get(book.Id).Title_Deed_Process_Exception__c != book.Title_Deed_Process_Exception__c && book.Title_Deed_Process_Exception__c) || 
               ((oldBookMap.get(book.Id).PropStrength__Total_Paid_Percent__c != book.PropStrength__Total_Paid_Percent__c || oldBookMap.get(book.Id).SPA_Executed__c != book.SPA_Executed__c
                 || oldBookMap.get(book.Id).Pre_Registration_Completed__c != book.Pre_Registration_Completed__c || oldBookMap.get(book.Id).Handover_Completed__c != book.Handover_Completed__c || 
                 oldBookMap.get(book.Id).Title_Deed_Fees_Received__c != book.Title_Deed_Fees_Received__c) && 
                book.PropStrength__Total_Paid_Percent__c >= 100 && book.SPA_Executed__c && 
                book.Pre_Registration_Completed__c && book.Handover_Completed__c && book.Title_Deed_Fees_Received__c != null)){
                    trList.add(new PropStrength__Transaction_Requests__c(RecordTypeId = titleDeedProcess, PropStrength__Application_Booking__c = book.Id));
                }
        }
        
        if(!trList.isEmpty()) {
            insert trList;
        }
    }
    
    //Added by Nishank Manwani on 25-July-2024 to add validation on Home_Orientation_Docs_Received__c, Handover_Documents_Received__c fields
    public static void validateHomeOrientationDocsRec(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if((book.Home_Orientation_Docs_Received__c && book.Home_Orientation_Docs_Received__c != oldBookMap.get(book.Id).Home_Orientation_Docs_Received__c) || (book.Handover_Documents_Received__c && book.Handover_Documents_Received__c != oldBookMap.get(book.Id).Handover_Documents_Received__c)) {
                bookId.add(book.Id);
            }
        }
        
        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                       (SELECT Id, Name FROM Attachments), 
                                                                                                                       (SELECT Id, ContentDocument.title FROM ContentDocumentLinks)
                                                                                                                       FROM PropStrength__Application_Booking__c
                                                                                                                       WHERE Id IN :bookId]);
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(book.Home_Orientation_Docs_Received__c && book.Home_Orientation_Docs_Received__c != oldBookMap.get(book.Id).Home_Orientation_Docs_Received__c) {
                    if(book.Home_Orientation_Attended_By__c == 'POA') {
                        if(bookMap.containsKey(book.Id)) {
                            Boolean flag = true;
                            if(!bookMap.get(book.Id).Attachments.isEmpty()) {
                                for(Attachment att : bookMap.get(book.Id).Attachments) {
                                    if(att.Name.containsIgnoreCase('POA')) {
                                        flag = false;
                                    }
                                }
                            }
                            if(!bookMap.get(book.Id).ContentDocumentLinks.isEmpty()) {
                                for(ContentDocumentLink cdl : bookMap.get(book.Id).ContentDocumentLinks) {
                                    if(cdl.ContentDocument.title.containsIgnoreCase('POA')) {
                                        flag = false;
                                    }
                                }
                            }
                            
                            if(flag) {
                                book.addError('Please upload the relevant documents in the Notes & Attachments');
                            }
                        }
                    } else if(book.Home_Orientation_Attended_By__c == 'Authorised Representative') {
                        if(bookMap.containsKey(book.Id)) {
                            Boolean flag = true;
                            Boolean flag2 = true;
                            if(!bookMap.get(book.Id).Attachments.isEmpty()) {
                                for(Attachment att : bookMap.get(book.Id).Attachments) {
                                    if(att.Name.containsIgnoreCase('Authorization Letter')) {
                                        flag = false;
                                    } else if(att.Name.containsIgnoreCase('Authorized Persons ID')) {
                                        flag2 = false;
                                    }
                                }
                            }
                            if(!bookMap.get(book.Id).ContentDocumentLinks.isEmpty()) {
                                for(ContentDocumentLink cdl : bookMap.get(book.Id).ContentDocumentLinks) {
                                    if(cdl.ContentDocument.title.containsIgnoreCase('Authorization Letter')) {
                                        flag = false;
                                    } else if(cdl.ContentDocument.title.containsIgnoreCase('Authorized Persons ID')) {
                                        flag2 = false;
                                    }
                                }
                            }
                            
                            if(flag || flag2) {
                                book.addError('Please upload the relevant documents in the Notes & Attachments');
                            }
                        }
                    } else if(book.Home_Orientation_Attended_By__c == 'Third Party Inspection') {
                        Boolean flag = true;
                        if(!bookMap.get(book.Id).Attachments.isEmpty()) {
                            for(Attachment att : bookMap.get(book.Id).Attachments) {
                                if(att.Name.containsIgnoreCase('Third Party Undertaking Letter')) {
                                    flag = false;
                                }
                            }
                        }
                        if(!bookMap.get(book.Id).ContentDocumentLinks.isEmpty()) {
                            for(ContentDocumentLink cdl : bookMap.get(book.Id).ContentDocumentLinks) {
                                if(cdl.ContentDocument.title.containsIgnoreCase('Third Party Undertaking Letter')) {
                                    flag = false;
                                }
                            }
                        }
                        
                        if(flag) {
                            book.addError('Please upload the relevant documents in the Notes & Attachments');
                        }
                    }
                }
                if(book.Handover_Documents_Received__c && book.Handover_Documents_Received__c != oldBookMap.get(book.Id).Handover_Documents_Received__c) {
                    if(book.Handover_will_be_taken_by__c == 'POA – Owner' || book.Handover_will_be_taken_by__c == 'POA – Company') {
                        if(bookMap.containsKey(book.Id)) {
                            Boolean flag = true;
                            if(!bookMap.get(book.Id).Attachments.isEmpty()) {
                                for(Attachment att : bookMap.get(book.Id).Attachments) {
                                    if(att.Name.containsIgnoreCase('POA')) {
                                        flag = false;
                                    }
                                }
                            }
                            if(!bookMap.get(book.Id).ContentDocumentLinks.isEmpty()) {
                                for(ContentDocumentLink cdl : bookMap.get(book.Id).ContentDocumentLinks) {
                                    if(cdl.ContentDocument.title.containsIgnoreCase('POA')) {
                                        flag = false;
                                    }
                                }
                            }
                            
                            if(flag) {
                                book.addError('Please upload the relevant documents in the Notes & Attachments');
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void sendHandoverSlotTemp(List<PropStrength__Application_Booking__c> bookList, Map<Id, PropStrength__Application_Booking__c> oldBookMap) {
        set<id> bookid = new set<id>();
        if(!bookList.isEmpty()){
            for(PropStrength__Application_Booking__c book : bookList) {
                if((oldBookMap.get(book.Id).Slot_Status__c == '' || oldBookMap.get(book.Id).Slot_Status__c == 'Not yet scheduled') && book.Slot_Status__c  != oldBookMap.get(book.Id).Slot_Status__c && 
                   book.Slot_Status__c == 'Confirmed' && book.Slot_Scheduled_Date__c != null) { 
                       bookid.add(book.id);
                   }
            }
        }
        if(bookid != null){
            List<Id> PrIdList = new List<Id>();
            List<PropStrength__Application_Booking__c> firstBooking = [SELECT ID,Last_Handover_Reminder_Count__c,(SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name, PropStrength__Applicant_Acc__c 
                                                                                                                  FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) 
                                                                       FROM PropStrength__Application_Booking__c where id IN: bookid];
            
            if(!firstBooking.isEmpty() && !firstBooking[0].PropStrength__Applicant_Details__r.isEmpty()){
                PropStrength__Application_Booking__c book = firstBooking[0];
                
                Set<String> emailAddress = new Set<String>();
                List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                
                List<EmailTemplate> templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Handover_Slot_Confirmation' limit 1];
                
                Id TempId;
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                List<String> toList = new List<String>();
                emails.setWhatId(book.Id);
                
                for(PropStrength__Applicant_Detail__c appDetails : book.PropStrength__Applicant_Details__r) {
                    if(appDetails.PropStrength__Applicant_Email__c != null) {
                        toList.add(appDetails.PropStrength__Applicant_Email__c);
                    }
                }
                if(!toList.isEmpty()) {
                    emails.setToAddresses(toList); 
                }
                emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT id,Address from OrgWideEmailAddress where Address =: 'helpdesk@sobharealty.com' limit 1];
                
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emails.setTemplateId(TempId);
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(book.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Acc__c);
                emails.setTreatTargetObjectAsRecipient(false); 
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
        }
        
    }
    
    
    public static void createInterimPaymentOnInsert(List<PropStrength__Application_Booking__c> bookList) {
        Set<Id> offId = new Set<Id>();
        Map<Id, Id> offBookMap = new Map<Id, Id>();
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(book.PropStrength__Offer__c != null) {
                offId.add(book.PropStrength__Offer__c);
                offBookMap.put(book.PropStrength__Offer__c, book.Id);
            }
        }
        
        if(!offId.isEmpty()) {
            List<PropStrength__Offer__c> offList = [SELECT Id, 
                                                    (SELECT Id, Status__c, Mode__c, Application_Booking__c,Bank_name__c,
                                                     Towards_Other_Charges_Amount__c, Amount_Towards__c, Others__c, Payment__c,
                                                     Cheque_Date__c, Instrument_Date__c, Instrument_Number__c, Cheque_No__c, CreatedDate, Date_of_Initiation__c, 
                                                     Account_Master__c, Towards_Unit_Price_Amount__c, Towards_Pre_Registration_Amount__c 
                                                     FROM Payment_Requests__r WHERE Status__c = 'Approved') 
                                                    FROM PropStrength__Offer__c WHERE Id IN :offId];
            
            List<Payment_Request__c> updatePrList = new List<Payment_Request__c>();
            List<Payment_Request__c> prList = new List<Payment_Request__c>();
            
            for(PropStrength__Offer__c off : offList) {
                if(!off.Payment_Requests__r.isEmpty() && offBookMap.containsKey(off.Id)) {
                    for(Payment_Request__c pr : off.Payment_Requests__r) {
                        updatePrList.add(new Payment_Request__c(Id=pr.Id, Application_Booking__c = offBookMap.get(off.Id)));
                        pr.Application_Booking__c = offBookMap.get(off.Id);
                        prList.add(pr);
                    }
                }
            }
            
            if(!updatePrList.isEmpty()) {
                update updatePrList;
            }
            
            if(!prList.isEmpty()) {
                BookingTriggerHelper.createRecordIntPay(prList);
            }
        }
    }
    public static void UpdatePreviousSlotDate(List<PropStrength__Application_Booking__c> Booklist,map<Id,PropStrength__Application_Booking__c> oldMap) {
        if(!Booklist.isEmpty()){
            for(PropStrength__Application_Booking__c book: Booklist){
                system.debug('===book==='+book);
                if(book.Slot_Scheduled_Date__c != null && book.Slot_Scheduled_Date__c != oldMap.get(book.id).Slot_Scheduled_Date__c){
                    book.Previous_Slot_Date__c = (date.valueof(book.Slot_Scheduled_Date__c) - 1);
                }
            }
        }
    }
    public static void createRecordIntPay(List<Payment_Request__c> prList) {
        List<Interim_Payments__c> interimPaymentList = new List<Interim_Payments__c>();
        Id intPayRecTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id intPayIncChargeRecTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        Id payIncChargeDueRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        
        Set<Id> bookId = new Set<Id>();
        for(Payment_Request__c pr: prList) {
            if(pr.Status__c == 'Approved') {
                if(pr.Application_Booking__c != null) {
                    bookId.add(pr.Application_Booking__c);
                }
            }
        }
        
        Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>();
        Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>();
        if(!bookId.isEmpty()) {
            bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Amount_Due_Type__c, PropStrength__Balance__c FROM PropStrength__Payments_Cheques__r WHERE RecordType.Name = 'Income Charge Due'), PropStrength__Project__c, PropStrength__Super_Area__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookId AND PropStrength__Project__c != null AND PropStrength__Active__c = TRUE]);
            
            Set<Id> projId = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookMap.values()) {
                projId.add(book.PropStrength__Project__c);
            }
            
            if(!projId.isEmpty()) {
                projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, 
                                                                     (SELECT Id, PropStrength__Category__c, PropStrength__Type__c, PropStrength__Amount__c, PropStrength__Rate_Per_Unit_Area__c FROM PropStrength__Income_Charges__r WHERE PropStrength__Active__c = TRUE) 
                                                                     FROM PropStrength__Projects__c WHERE Id IN :projId]);
            }
        }
        
        List<PropStrength__Received_Payment__c> incomeChargeDuePay = new List<PropStrength__Received_Payment__c>();
        
        for(Payment_Request__c pr: prList) {
            if(pr.Status__c == 'Approved') {
                String mode = pr.Mode__c;
                String amountTowardsOther = String.valueOf(pr.Towards_Other_Charges_Amount__c);
                Boolean flag = true;
                if(pr.Application_Booking__c != null && bookMap.containsKey(pr.Application_Booking__c) && !bookMap.get(pr.Application_Booking__c).PropStrength__Payments_Cheques__r.isEmpty()) {
                    for(PropStrength__Received_Payment__c payRec : bookMap.get(pr.Application_Booking__c).PropStrength__Payments_Cheques__r) {
                        if(payRec.PropStrength__Amount_Due_Type__c == pr.Others__c && payRec.PropStrength__Balance__c > 0) {
                            flag = false;
                            break;
                        }
                    }
                }
                
                if(flag) {
                    if(mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card' || mode == 'Website' || mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                        if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                            if(pr.Application_Booking__c != null && bookMap.containsKey(pr.Application_Booking__c) 
                               && projectMap.containsKey(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c) 
                               && !projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r.isEmpty()) {
                                   PropStrength__Income_Charges__c selIncCharge = new PropStrength__Income_Charges__c();
                                   
                                   for(PropStrength__Income_Charges__c incCharge : projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r) {
                                       if(incCharge.PropStrength__Category__c == pr.Others__c) {
                                           selIncCharge = incCharge;
                                           break;
                                       }
                                   }
                                   
                                   if(selIncCharge != null && selIncCharge.Id != null) {
                                       if(selIncCharge.PropStrength__Amount__c > 0 || selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0) {
                                           if(selIncCharge.PropStrength__Amount__c > 0 && selIncCharge.PropStrength__Type__c == 'Fixed') {
                                               incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = selIncCharge.PropStrength__Amount__c));
                                           } else if(selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0 && selIncCharge.PropStrength__Type__c == 'Flexible' && bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c != null) {
                                               incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = (selIncCharge.PropStrength__Rate_Per_Unit_Area__c * bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c)));
                                           }
                                       } else {
                                           incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = Decimal.valueOf(amountTowardsOther)));
                                       }
                                   }
                               }
                        }
                    }
                    
                    if(mode == 'Cheque'){
                        if(pr.Amount_Towards__c != null && pr.Amount_Towards__c != 'undefined' && pr.Amount_Towards__c != '' && pr.Amount_Towards__c != 'null'){
                            if(pr.Amount_Towards__c == 'Other Amount') {
                                if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                                    if(pr.Application_Booking__c != null && bookMap.containsKey(pr.Application_Booking__c) 
                                       && projectMap.containsKey(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c) 
                                       && !projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r.isEmpty()) {
                                           PropStrength__Income_Charges__c selIncCharge = new PropStrength__Income_Charges__c();
                                           
                                           for(PropStrength__Income_Charges__c incCharge : projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r) {
                                               if(incCharge.PropStrength__Category__c == pr.Others__c) {
                                                   selIncCharge = incCharge;
                                                   break;
                                               }
                                           }
                                           
                                           if(selIncCharge != null && selIncCharge.Id != null) {
                                               if(selIncCharge.PropStrength__Amount__c > 0 || selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0) {
                                                   if(selIncCharge.PropStrength__Amount__c > 0 && selIncCharge.PropStrength__Type__c == 'Fixed') {
                                                       incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = selIncCharge.PropStrength__Amount__c));
                                                   } else if(selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0 && selIncCharge.PropStrength__Type__c == 'Flexible' && bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c != null) {
                                                       incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = (selIncCharge.PropStrength__Rate_Per_Unit_Area__c * bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c)));
                                                   }
                                               } else {
                                                   incomeChargeDuePay.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pr.Application_Booking__c, RecordTypeId = payIncChargeDueRecTypeId, PropStrength__Amount_Due_Type__c = selIncCharge.PropStrength__Category__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Demand_Generation_Date__c = System.Today(), PropStrength__Amount__c = Decimal.valueOf(amountTowardsOther)));
                                               }
                                           }
                                       }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Map<String, Id> mapIncChargedueMode = new Map<String, Id>();
        if(!incomeChargeDuePay.isEmpty()) {
            insert incomeChargeDuePay;
            
            for(PropStrength__Received_Payment__c pay : incomeChargeDuePay) {
                mapIncChargedueMode.put(pay.PropStrength__Amount_Due_Type__c + '##' + pay.PropStrength__Amount__c , pay.Id);
            }
        }
        Map<String,String> mapOfAccountAndName = new Map<String,String>();
        List<Account_Master__c > listOfAccountMaster = [SELECT Id, name from Account_Master__c where Name = 'TRADE RECEIVABLE' or Name = 'MAIN CASH'];
        for(Account_Master__c accMasterRec : listOfAccountMaster){
            mapOfAccountAndName.put(accMasterRec.Name , accMasterRec.Id);
        }
        for(Payment_Request__c pr: prList) {
            if(pr.Status__c == 'Approved') {
                
                System.debug(pr.Others__c);
                String mode = pr.Mode__c;
                String amountTowardsUnit = String.valueOf(pr.Towards_Unit_Price_Amount__c);
                String amountTowardsOther = String.valueOf(pr.Towards_Other_Charges_Amount__c);
                String amountTowardsPreReg = String.valueOf(pr.Towards_Pre_Registration_Amount__c);
                Decimal amountDue;
                
                if(pr.Application_Booking__c != null && bookMap.containsKey(pr.Application_Booking__c) 
                   && projectMap.containsKey(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c) 
                   && !projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r.isEmpty()) {
                       PropStrength__Income_Charges__c selIncCharge = new PropStrength__Income_Charges__c();
                       
                       for(PropStrength__Income_Charges__c incCharge : projectMap.get(bookMap.get(pr.Application_Booking__c).PropStrength__Project__c).PropStrength__Income_Charges__r) {
                           if(incCharge.PropStrength__Category__c == pr.Others__c) {
                               selIncCharge = incCharge;
                               break;
                           }
                       }
                       
                       if(selIncCharge != null && selIncCharge.Id != null) {
                           if(selIncCharge.PropStrength__Amount__c > 0|| selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0) {
                               if(selIncCharge.PropStrength__Amount__c > 0 && selIncCharge.PropStrength__Type__c == 'Fixed') {
                                   amountDue = selIncCharge.PropStrength__Amount__c;
                               } else if(selIncCharge.PropStrength__Rate_Per_Unit_Area__c > 0 && selIncCharge.PropStrength__Type__c == 'Flexible' && bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c != null) {
                                   amountDue = (selIncCharge.PropStrength__Rate_Per_Unit_Area__c * bookMap.get(pr.Application_Booking__c).PropStrength__Super_Area__c);
                               }
                           } else {
                               amountDue = Decimal.valueOf(amountTowardsOther);
                           }
                       }
                   }
                
                Date intPayInstDate = System.Today();
                String intPayInstNumber = '';
                
                if(pr.Cheque_Date__c != null) {
                    intPayInstDate = pr.Cheque_Date__c;
                } else if(pr.Instrument_Date__c != null) {
                    intPayInstDate = pr.Instrument_Date__c;
                }
                
                if(pr.Cheque_No__c != null) {
                    intPayInstNumber = pr.Cheque_No__c;
                } else if(pr.Instrument_Number__c != null) {
                    intPayInstNumber = pr.Instrument_Number__c;
                }
                
                
                DateTime chequeDate;
                {//Pulkit's code block - Requirement : capture Receipt and Cheque Dates in the IPR from PR 
                    if(mode == 'IWT(International)' || mode == 'DWT(Domestic)' || mode == 'CDM Cash (Cash Deposit in Machine)'){
                        chequeDate = pr.Date_of_Initiation__c;
                    }else if(mode == 'Cheque'){
                        chequeDate = pr.Cheque_Date__c;
                    }else if(mode == 'CDM Cheque (Cash Deposit in Machine)' || mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card'){
                        chequeDate = pr.Instrument_Date__c;
                    }else if(mode == 'Website'){
                        chequeDate = pr.CreatedDate;
                    }
                }
                
                String status = '';
                Id debitAccountId = null;
                Id creditAccountId = null;
                if(mode == 'IWT(International)' || mode == 'DWT(Domestic)' || mode == 'CDM Cash (Cash Deposit in Machine)' || mode == 'OTC Deposits(Cash counter)'){
                    status = 'Approved';
                    debitAccountId = pr.Account_Master__c ;
                    if(mode == 'OTC Deposits(Cash counter)'){
                        debitAccountId = mapOfAccountAndName.get('MAIN CASH');
                    }
                }
                else{
                    if(mode == 'CDM Cheque (Cheque Deposit in Machine)'){
                        debitAccountId = pr.Account_Master__c;
                    }
                    status = 'UnProcessed';
                }
                System.debug(mode+'*----*---'+status);
                System.debug(mode+'*----*---'+debitAccountId);
                
                System.debug(pr.Towards_Unit_Price_Amount__c+'--'+pr.Towards_Other_Charges_Amount__c+'----'+pr.Towards_Pre_Registration_Amount__c);
                if(pr.Towards_Unit_Price_Amount__c > 0) {
                    interimPaymentList.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c, 
                                                                   Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,//added by Pulkit
                                                                   Instrument_Number__c = intPayInstNumber, Instrument_Date__c = intPayInstDate, 
                                                                   Payment_Request__c = pr.Id, Payment_Date_Interim__c = System.Today(), 
                                                                   Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                                   Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                                   RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), 
                                                                   Amount_Type__c = 'Installment',Approval_Status_Interim__c = status,
                                                                   Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE')));
                    
                } 
                if(pr.Towards_Other_Charges_Amount__c > 0) {
                    Id incChargeDue = mapIncChargedueMode.get(pr.Others__c+'##'+amountDue);
                    incChargeDue = incChargeDue != null ? incChargeDue : pr.Payment__c;
                    interimPaymentList.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c, 
                                                                   Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,//added by Pulkit
                                                                   Payment__c = incChargeDue, Instrument_Number__c = intPayInstNumber, 
                                                                   Instrument_Date__c = intPayInstDate, Payment_Request__c = pr.Id, 
                                                                   Payment_Date_Interim__c = System.Today(), 
                                                                   Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                                   Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                                   RecordTypeId = intPayIncChargeRecTypeId, Amount_Type__c = pr.Others__c, 
                                                                   Amount_Interim__c = Double.valueOf(amountTowardsOther),
                                                                   Approval_Status_Interim__c = status, 
                                                                   Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE')));
                    
                }  
                if(pr.Towards_Pre_Registration_Amount__c > 0 ) {
                    interimPaymentList.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c,
                                                                   Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,//added by Pulkit
                                                                   Instrument_Number__c = intPayInstNumber, Instrument_Date__c = intPayInstDate, 
                                                                   Payment_Request__c = pr.Id, Payment_Date_Interim__c = System.Today(), 
                                                                   Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                                   Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                                   RecordTypeId = intPayIncChargeRecTypeId, 
                                                                   Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees',
                                                                   Approval_Status_Interim__c = status, 
                                                                   Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE')));
                    
                }  
                System.debug(interimPaymentList.size()+'**---***---**--'+interimPaymentList);
            }
        }
        System.debug(interimPaymentList.Size()+'--interimPaymentList--'+interimPaymentList);
        if(!interimPaymentList.isEmpty()) {
            insert interimPaymentList;
        }        
    }
    
    public static void sendEmailOnCancellationRequest(List<PropStrength__Application_Booking__c> booklist,map<Id,PropStrength__Application_Booking__c> oldMap){
        Set<Id> bookingIds = new Set<Id>();
        
        for(PropStrength__Application_Booking__c booking : booklist){
            if(booking.Cancellation_Requested__c != oldMap.get(booking.id).Cancellation_Requested__c && booking.Cancellation_Requested__c){
                bookingIds.add(booking.id);
            }
        }
        
        if(!bookingIds.isEmpty()){
            BookingTriggerHelper.sendMailToQueue(bookingIds);
        }        
    }
    
    @future
    public static void sendMailToQueue(Set<Id> bookingIds){
        List<PropStrength__Application_Booking__c> bookList  = [select PropStrength__Primary_Customer__c,Name,PropStrength__Property_Name__c,PropStrength__Broker_Account__c from  PropStrength__Application_Booking__c where id in : bookingIds];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        //GroupMember gm = [Select Id from Group where type='Queue' and Name='Brokerage & Commission Hold'];
        //List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Audit_Team_1'];
        List<String> sendTo = new List<String>(); 
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Brokerage_Commission_Hold')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }
        
        
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        
        
        if(!bookList.isEmpty()){
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Booking_Cancellation_Initiated_Email_Html'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Application_Booking__c book : bookList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(book.Id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
    /*public static void updateIncentivesOnBooking(List<PropStrength__Application_Booking__c> newBooking,map<Id,PropStrength__Application_Booking__c> oldMap){
        Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        
        Set<Id> bookingIds = new Set<Id>();
        for(PropStrength__Application_Booking__c booking : newBooking){
            if(oldMap == null && booking.DLD_Waiver__c != null && booking.PropStrength__BSP_Specific_Waiver__c != null ){
                bookingIds.add(booking.id);
            }
            if(oldMap != null && (booking.DLD_Waiver__c != oldMap.get(booking.id).DLD_Waiver__c || booking.PropStrength__BSP_Specific_Waiver__c != oldMap.get(booking.id).PropStrength__BSP_Specific_Waiver__c )){
                bookingIds.add(booking.id); 
            }
        }
        
        if(!bookingIds.isEmpty()) {
            system.debug('inside booking');
            Map<Id,PropStrength__Application_Booking__c> mapOfBookingPerc = new Map<Id,PropStrength__Application_Booking__c>();
            List<Incentive_Payouts__c> createIncentivePayoutList = new List<Incentive_Payouts__c>();
            List<Incentive_Payouts__c> updateIncentivePayoutList = new List<Incentive_Payouts__c>();
            Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate, Sales_Manager__c , 
                 PropStrength__Project__r.Master_Project__r.Incentive_Calculation__c,DLD_Waiver__c,PropStrength__BSP_Specific_Waiver__c,
                 Secondary_Sales_Manager_Incentive__c,Secondary_VP_Incentive__c,Secondary_SVP_Incentive__c,Secondary_CSO_Incentive__c,
                 
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c, 
                 Sales_Manager_Incentive__c, Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Director_Incentive__c,PropStrength__Project__r.Master_Project__c,
                 PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c, 
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,
                 CMO_Marketing_Incentive__c, GM_Marketing_Incentive__c, Incentive_Update_Option__c, Marketing_CP_Commission_Eligible__c,
                 DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, 
                 X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c, 
                 (SELECT Id, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :payRecRT), 
                 (SELECT Id, User_Role__c,Balance__c, Application_Booking__c, All_Payment_Of_Sale_Inn__c FROM Incentive_Payouts__r WHERE User_Role__c LIKE '%Sales%' OR User_Role__c LIKE 'Sales%') 
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
            //Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Id, Indirect_Sales__c, Direct_Sales__c, Loyalty_Sales__c, Approved_Discount_Sales__c,RecordType.Name,Brand_Evangelist_Split__c ,
                                                       Intl_Broker_New_Customer_Inc__c, VP_Channel_Relations_Split__c, RM_Channel_Split__c, TL_Channel_Relation_Split__c, 
                                                       Intl_Broker_Old_Customer_Inc__c, Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c, CMO_Channel_Relations_Split__c,
                                                       Marketing_Category__c, Marketing_Incentive__c, Loyalty_Sales_Executive_Split__c, Sales_Director_Split__c,
                                                       Marketing_Head_Split__c, Promoter_Split__c, Mall_Team_Lead_Split__c, Telesales_Agent_Split__c, Start_Date__c, End_Date__c,
                                                       Campaign_Manager_Split__c, Digital_Marketing_Head_Split__c, Employee_Referal_Inc__c,Team_Lead_Split__c, TeleSales_Head_Split__c, 
                                                       Sales_Head_Split__c, VP_Split__c, CSO_Split__c, Days_From__c, Days_To__c,CMO_Marketing_Split__c,GM_Marketing_Split__c
                                                       FROM Incentive_Slab__c where Siniya_Island_Project__c = false];
            List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Id, Indirect_Sales__c, Direct_Sales__c, Loyalty_Sales__c, Approved_Discount_Sales__c,RecordType.Name,Brand_Evangelist_Split__c ,
                                                                        Intl_Broker_New_Customer_Inc__c, VP_Channel_Relations_Split__c, RM_Channel_Split__c, TL_Channel_Relation_Split__c, 
                                                                        Intl_Broker_Old_Customer_Inc__c, Sobha_Connect_UAE_New_Inc__c,Employee_Referal_Inc__c,Sobha_Connect_UAE_Old_Inc__c, CMO_Channel_Relations_Split__c,
                                                                        Marketing_Category__c, Marketing_Incentive__c, Loyalty_Sales_Executive_Split__c, Sales_Director_Split__c,
                                                                        Marketing_Head_Split__c, Promoter_Split__c, Mall_Team_Lead_Split__c, Telesales_Agent_Split__c, Start_Date__c, End_Date__c,
                                                                        Campaign_Manager_Split__c, Digital_Marketing_Head_Split__c, Team_Lead_Split__c, TeleSales_Head_Split__c, 
                                                                        Sales_Head_Split__c, VP_Split__c, CSO_Split__c, Days_From__c, Days_To__c,CMO_Marketing_Split__c,GM_Marketing_Split__c
                                                                        FROM Incentive_Slab__c where Siniya_Island_Project__c = true];
            
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec = new Map<String, List<Incentive_Slab__c>>();
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec1 = new Map<String, List<Incentive_Slab__c>>();
            Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec2 = new Map<String, List<Incentive_Slab__c>>();
            
            if(interestSlabRec != null && interestSlabRec.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRec){
                    if(mapOfREcordTypeAndinterestSlabRec1.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec1.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec1.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            if(interestSlabRecWithSiniyaProject != null && interestSlabRecWithSiniyaProject.size() > 0){
                for(Incentive_Slab__c IncentiveRec : interestSlabRecWithSiniyaProject){
                    if(mapOfREcordTypeAndinterestSlabRec2.containskey(IncentiveRec.RecordType.Name)){
                        mapOfREcordTypeAndinterestSlabRec2.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
                    }
                    else{
                        mapOfREcordTypeAndinterestSlabRec2.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
                    }
                }
            }
            
            
            Map<Id,Map<String, List<Incentive_Slab__c>>> bookingSlabMap = new Map<Id,Map<String, List<Incentive_Slab__c>>>();
            for(PropStrength__Application_Booking__c bookRec : bookMap.values()){
                if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && !bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec1 );
                }
                else if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
                    bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec2 );
                }
                
            }
            
            Set<Id> towerIds = new Set<Id>();
            Map<Id, Id> bookingTowerId = new Map<Id, Id>();
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Property__c != null && booking.PropStrength__Property__r.PropStrength__Tower__c != null) {
                    towerIds.add(booking.PropStrength__Property__r.PropStrength__Tower__c);
                    bookingTowerId.put(booking.Id, booking.PropStrength__Property__r.PropStrength__Tower__c);
                }
            }
            
            Set<Id> projectIds = new Set<Id>();
            Map<Id, Id> bookingProjectId = new Map<Id, Id>();
            for(PropStrength__Application_Booking__c booking : bookMap.values()) {
                if(booking.PropStrength__Project__c != null ) {
                    projectIds.add(booking.PropStrength__Project__c);
                    bookingProjectId.put(booking.Id, booking.PropStrength__Project__c);
                }
            }    
            Map<Id, Map<String, Id>> projectIdAndRoleUsermap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String, Id>> projectIdAndRoleTeamIdMap = new  Map<Id, Map<String, Id>>();
            Map<Id, Map<String,Incentive_Month__c>> teamIdWithMonthMap = new Map<Id, Map<String, Incentive_Month__c>>();
            Map<String,Incentive_Month__c> projectIdTeamIdMonthIdAndMonth = new Map<String,Incentive_Month__c>();
            Map<String,Decimal> projectIdTeamIdMonthIdAndAmount = new Map<String, Decimal>();
            Map<Incentive_Month__c,Incentive_Month__c> upsertmonthsMap = new Map<Incentive_Month__c,Incentive_Month__c>();
            
            Set<Id> teamIds = new Set<Id>();
            if(projectIds.size() > 0){
                Map<Id, PropStrength__Projects__c> projectMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, (SELECT Id,Project__c,Incentive_User_Type__c,
                                                                                                                    User__c FROM Incentive_Team_Members__r) 
                                                                                                        FROM PropStrength__Projects__c 
                                                                                                        WHERE Id IN :projectIds]); 
                for( PropStrength__Projects__c  proj : projectMap.values()){
                    if(!projectIdAndRoleUsermap.containsKey(proj.id) && !projectIdAndRoleTeamIdMap.containsKey(proj.id)){
                        projectIdAndRoleUsermap.put(proj.id, new Map<String, Id>());
                        projectIdAndRoleTeamIdMap.put(proj.id, new Map<String, Id>());
                        for(Incentive_Team_Members__c  teamMember : proj.Incentive_Team_Members__r){
                            teamIds.add(teamMember.id);
                            if(teamMember.Incentive_User_Type__c != null && !projectIdAndRoleUsermap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c) && !projectIdAndRoleTeamIdMap.get(proj.id).containsKey(teamMember.Incentive_User_Type__c)){
                                projectIdAndRoleUsermap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.User__c);
                                projectIdAndRoleTeamIdMap.get(proj.id).put(teamMember.Incentive_User_Type__c, teamMember.Id);
                                
                            }
                        }
                    }
                    
                }
                if(teamIds.size() > 0){
                    Map<Id, Incentive_Team_Members__c> teamMembersMap = new Map<Id, Incentive_Team_Members__c>([SELECT Id,Project__c, (SELECT Id,Target_Acheived__c,Name,Incentive_Team_Member__c
                                                                                                                                       FROM Incentive_Month__r) 
                                                                                                                FROM Incentive_Team_Members__c 
                                                                                                                WHERE Id IN :teamIds]); 
                    for( Incentive_Team_Members__c  team  : teamMembersMap.values()){
                        if(!teamIdWithMonthMap.containsKey(team.id)){
                            teamIdWithMonthMap.put(team.id, new Map<String, Incentive_Month__c>());
                            for(Incentive_Month__c  teamMonth : team.Incentive_Month__r){
                                if(!teamIdWithMonthMap.get(team.id).containsKey(teamMonth.Name)){
                                    teamIdWithMonthMap.get(team.id).put(teamMonth.Name, teamMonth);
                                    projectIdTeamIdMonthIdAndMonth.put(team.Project__c+' '+team.id+ ' '+teamMonth.name, teamMonth);
                                }
                            }
                        }
                        
                    }
                }
            }
            Map<Id, PropStrength__Tower__c> towerMap = new Map<Id, PropStrength__Tower__c>([SELECT Id, (SELECT Id, Campaign_Manager_Influence__c, CMO_Channel_Relation__c, 
                                                                                                        CSO__c, Digital_Marketing_Head__c, Loyalty_Sales_Executive__c, Brand_Evangelist__c ,
                                                                                                        Mall_Team_Lead__c, Marketing_Head__c, Promoter__c, RM_Channel_Relation__c, 
                                                                                                        Sales_Director__c, Team_Lead__c, TeleSales_Agent__c, TeleSales_Head__c, TL_Channel_Relation__c, 
                                                                                                        VP_Channel_Relation__c, VP_Sales__c, GM_Marketing__c, CMO_Marketing__c FROM Incentive_Teams__r) 
                                                                                            FROM PropStrength__Tower__c 
                                                                                            WHERE Id IN :towerIds]);
            
            
            Map<Id, Integer> countBookingOnContactMap = new Map<Id, Integer>();
            Set<Id> contactId = new Set<Id>();
            
            Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap = new Map<Id, List<PropStrength__Application_Booking__c>>();
            Set<Id> brokerIds = new Set<Id>();
            for(PropStrength__Application_Booking__c book : bookMap.values()) {
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Primary_Customer__c != null) {
                    contactId.add(book.PropStrength__Primary_Customer__c);
                }
                if(book.PropStrength__Booking_Through__c == 'Broker' && book.PropStrength__Broker_Account__c != null) {
                    brokerIds.add(book.PropStrength__Broker_Account__c);
                }
            }
            
            System.debug('contactId: '+contactId);
            
            if(!contactId.isEmpty()) {
                List<Contact> contList = [SELECT Id, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];
                
                for(Contact cont : contList) {
                    if(!cont.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnContactMap.containsKey(cont.Id)) {
                            countBookingOnContactMap.put(cont.Id, cont.PropStrength__Applications_Bookings__r.size());
                        }
                    }
                }
            }
            
            System.debug('countBookingOnContactMap: '+countBookingOnContactMap);
            System.debug('brokerIds: '+brokerIds);
            
            if(!brokerIds.isEmpty()) {
                List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];
                
                for(Account brk : brokerAccList) {
                    if(!brk.PropStrength__Applications_Bookings__r.isEmpty()) {
                        if(!countBookingOnBrokerMap.containsKey(brk.Id)) {
                            countBookingOnBrokerMap.put(brk.Id, brk.PropStrength__Applications_Bookings__r);
                        }
                    }
                }
            }
            
            System.debug('countBookingOnBrokerMap: '+countBookingOnBrokerMap);
            System.debug('interestSlabRec: ' + interestSlabRec);
            //System.debug('salesManagerIncentiveId: ' + salesManagerIncentiveId);
            for(Id bookingId : bookMap.keyset()) {
                system.debug('inside payrec');
                
                PropStrength__Application_Booking__c tempBooking = bookMap.get(bookingId);
                mapOfREcordTypeAndinterestSlabRec = bookingSlabMap.get(bookingId);
                Decimal totalPastPaymentAmt = 0.00;
                if(!tempBooking.PropStrength__Payments_Cheques__r.isEmpty()) {
                    for(PropStrength__Received_Payment__c payRecord : tempBooking.PropStrength__Payments_Cheques__r) {
                        totalPastPaymentAmt += payRecord.PropStrength__Amount__c;                            
                    }
                }
                
                System.debug('totalPastPaymentAmt--> '+totalPastPaymentAmt);
                System.debug('tempBooking.PropStrength__Revised_Total_Sales_Consideration__c--> '+tempBooking.PropStrength__Revised_Total_Sales_Consideration__c);
                Decimal totalPercentage = 0; 
                if(tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c > 0)
                    totalPercentage = (totalPastPaymentAmt / (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c)) * 100;
                System.debug('totalPercentage--> '+totalPercentage);
                PropStrength__Application_Booking__c newbook = new PropStrength__Application_Booking__c(Id = tempBooking.Id);
                //, Total_Payment_Receive_Percent__c = totalPercentage*
                
                if(( tempBooking.PropStrength__Project__r.Master_Project__r != null && tempBooking.PropStrength__Project__r.Master_Project__r.Incentive_Calculation__c != null && totalPercentage >= tempBooking.PropStrength__Project__r.Master_Project__r.Incentive_Calculation__c)) {
                    // /********************************Sales Manager Incentive************************************************************ 
                    if(true) {
                        newbook.Id = tempBooking.Id;
                        Integer days = tempBooking.PropStrength__Booking_Date__c != null ? tempBooking.PropStrength__Booking_Date__c.daysBetween(System.Today()) : null;
                        Incentive_Slab__c fnlIsRec ; 
                        System.debug('--+++mapOfREcordTypeAndinterestSlabRec**---'+mapOfREcordTypeAndinterestSlabRec);
                        if(mapOfREcordTypeAndinterestSlabRec != null && !mapOfREcordTypeAndinterestSlabRec.isEmpty() && mapOfREcordTypeAndinterestSlabRec.containsKey('Sales Manager Incentive')) {
                            for(Incentive_Slab__c isRec : mapOfREcordTypeAndinterestSlabRec.get('Sales Manager Incentive')) {
                                System.debug(days+'-***--'+isRec.Days_From__c+ '**---'+isRec.Start_Date__c+'-*-*-*--'+isRec.End_Date__c);
                                if(days >= isRec.Days_From__c && days <= isRec.Days_To__c 
                                   && tempBooking.createddate >= isRec.Start_Date__c && tempBooking.createddate <= isRec.End_Date__c ) {
                                       fnlIsRec  = new Incentive_Slab__c();
                                       fnlIsRec  = isRec;
                                       break;
                                   }
                            }
                        }
                        
                        System.debug('fnlIsRec: ' + fnlIsRec);
                        
                        if(fnlIsRec != null && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                            Decimal salManInc = 0.0;
                            boolean check = false;
                            
                            if(tempBooking.PropStrength__Offer__r.Additional_Discount_Given__c && (tempBooking.PropStrength__Discount__c != null || tempBooking.DLD_Waiver__c != null || tempBooking.PropStrength__BSP_Specific_Waiver__c != null  ) 
                               && tempBooking.PropStrength__Offer__c != null && tempBooking.PropStrength__Offer__r.PropStrength__Request__c != null &&
                               tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Loyalty Sales' && fnlIsRec.Approved_Discount_Sales__c != null) {
                                   Decimal dldWaiver  = tempBooking.DLD_Waiver__c != null ? tempBooking.DLD_Waiver__c : 0;  
                                   Decimal bspWaiver  = tempBooking.PropStrength__BSP_Specific_Waiver__c != null ? tempBooking.PropStrength__BSP_Specific_Waiver__c : 0;  
                                   Decimal totalSales  = tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null ? tempBooking.PropStrength__Revised_Total_Sales_Consideration__c:0;  
                                   Decimal totalConsiderableSales = totalSales - dldWaiver - bspWaiver;
                                   Decimal totalConsiderableSalesPercent = totalConsiderableSales*fnlIsRec.Approved_Discount_Sales__c;
                                   
                                   salManInc = totalConsiderableSalesPercent/100;
                                   check = true;
                               }else {
                                   if(tempBooking.PropStrength__Offer__r.PropStrength__Offer_Through__c == 'Direct' && fnlIsRec.Direct_Sales__c != null) {
                                       salManInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*fnlIsRec.Direct_Sales__c)/100;
                                       check = true;  
                                   } else if(tempBooking.PropStrength__Offer__r.PropStrength__Offer_Through__c == 'Loyalty' && fnlIsRec.Loyalty_Sales__c != null) {
                                       salManInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*fnlIsRec.Loyalty_Sales__c)/100;
                                       check = true; 
                                   } else if(tempBooking.PropStrength__Offer__r.PropStrength__Offer_Through__c == 'Broker' && fnlIsRec.Indirect_Sales__c != null) {
                                       salManInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*fnlIsRec.Indirect_Sales__c)/100;
                                       check = true;
                                   }
                               }
                            system.debug(' check '+check);
                            if(check) {
                                newbook.Id = tempBooking.Id;
                                
                                
                                //newbook.X10_Payment_GL_Date__c = payRec.GL_Date__c != null ? Date.ValueOf(payRec.GL_Date__c) : null;   //@Deepak Added For GL Date
                                if(tempBooking.Secondary_Sales_Manager__c != null){
                                    newbook.Sales_Manager_Incentive__c = salManInc/2;
                                    newbook.Secondary_Sales_Manager_Incentive__c = salManInc/2;
                                    newbook.Sales_Incentive_Slab__c = fnlIsRec.Id;
                                    if(salManInc*fnlIsRec.Sales_Head_Split__c != null){
                                        Decimal finalValue = (salManInc*fnlIsRec.Sales_Head_Split__c)/100;
                                        newbook.Sales_Head_Incentive__c = finalValue/2;
                                        newbook.Secondary_Sales_Head_Incentive__c = finalValue/2;
                                    }
                                    
                                    if(salManInc*fnlIsRec.VP_Split__c != null){
                                        Decimal finalValue = (salManInc*fnlIsRec.VP_Split__c)/100;
                                        newbook.VP_Incentive__c = finalValue/2;
                                        newbook.Secondary_VP_Incentive__c = finalValue/2;
                                    }
                                    
                                    if(salManInc*fnlIsRec.CSO_Split__c != null){
                                        Decimal finalValue = (salManInc*fnlIsRec.CSO_Split__c)/100;
                                        newbook.CSO_Incentive__c =  finalValue/2;
                                        newbook.Secondary_CSO_Incentive__c =  finalValue/2;
                                    }
                                    
                                    if(fnlIsRec.Sales_Director_Split__c != null) {
                                        Decimal finalValue = (salManInc*fnlIsRec.Sales_Director_Split__c)/100;
                                        newbook.Sales_Director_Incentive__c = finalValue/2;
                                        newbook.Secondary_SVP_Incentive__c =finalValue/2;
                                    }
                                } 
                                else {
                                    newbook.Sales_Manager_Incentive__c = salManInc;
                                    newbook.Sales_Incentive_Slab__c = fnlIsRec.Id;
                                    if(salManInc*fnlIsRec.Sales_Head_Split__c != null)
                                        newbook.Sales_Head_Incentive__c = (salManInc*fnlIsRec.Sales_Head_Split__c)/100;
                                    if(salManInc*fnlIsRec.VP_Split__c != null)
                                        newbook.VP_Incentive__c = (salManInc*fnlIsRec.VP_Split__c)/100;
                                    if(salManInc*fnlIsRec.CSO_Split__c != null)
                                        newbook.CSO_Incentive__c = (salManInc*fnlIsRec.CSO_Split__c)/100;
                                    if(fnlIsRec.Sales_Director_Split__c != null) {
                                        newbook.Sales_Director_Incentive__c = (salManInc*fnlIsRec.Sales_Director_Split__c)/100;
                                    }
                                    if(fnlIsRec.Employee_Referal_Inc__c != null && tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null ){
                                        newBook.Employee_Referral_Incentive__c = (salManInc*fnlIsRec.Employee_Referal_Inc__c)/100;
                                    }
                                }
                                
                            }																																										
                            Decimal calFromPercentage = totalPercentage >= 20 ? 1.0 : totalPercentage >= 10 ? 0.5 : 0.0;
                            Boolean allPayment =  totalPercentage >= 20 ? true : false;
                            boolean payoutsCreateFlag = false;
                            System.debug(calFromPercentage+'--calFromPercentage*---'+newbook.X10_Payment_Received_Date__c+' --*---'+tempBooking.Booking_Form_Verified__c+'*---**--'+tempBooking.Oqood_Fees_Received__c);
                            if(calFromPercentage == 0.5 && tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
                               && ((tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
                                   || !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
                                       payoutsCreateFlag = true;
                                   }
                            if(calFromPercentage == 1.0 && tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
                               && ((tempBooking.SPA_Executed__c && tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
                                   || !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
                                       payoutsCreateFlag = true;
                                   }
                            system.debug('payoutsCreateFlag--- '+payoutsCreateFlag);
                            system.debug('calFromPercentage--- '+calFromPercentage);
                            if(calFromPercentage >= 0 && payoutsCreateFlag) {
                                system.debug('inside first if');
                                if(tempBooking.Sales_Manager__c != null && newbook.Sales_Manager_Incentive__c != null) {
                                    system.debug('inside second if ');
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Manager_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                } else if(newbook.Sales_Manager_Incentive__c != null){
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Manager_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                }
                                
                                if(tempBooking.Sales_Head__c != null && newbook.Sales_Head_Incentive__c != null) {
                                    system.debug('inside second if ');
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Head_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                } else if(newbook.Sales_Head_Incentive__c != null){
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Head_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                }
                                if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null && newbook.Employee_Referral_Incentive__c != null) {
                                    system.debug('inside second if ');
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Employee_Referral_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c , User_Role__c = 'Employee Referral'));
                                } else if(newbook.Employee_Referral_Incentive__c != null){
                                    newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                    createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Employee_Referral_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Employee Referral'));
                                }
                                if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                   !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty()) {
                                       if(towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Sales_Director__c != null && newbook.Sales_Director_Incentive__c != null) {
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Director_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Sales_Director__c, User_Role__c = 'Sales Director'));
                                       } else if(newbook.Sales_Director_Incentive__c != null){
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Director_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                       }
                                       
                                       if(towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Sales__c != null && newbook.VP_Incentive__c != null) {
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.VP_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Sales__c, User_Role__c = 'VP Sales'));
                                       } else if(newbook.VP_Incentive__c != null){
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.VP_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                       }
                                       
                                       if(towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CSO__c != null && newbook.CSO_Incentive__c != null) {
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.CSO_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CSO__c, User_Role__c = 'CSO Sales'));
                                       } else if(newbook.CSO_Incentive__c != null){
                                           newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                           createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.CSO_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                       }
                                   }
                                else{
                                    if(newbook.Sales_Director_Incentive__c != null){
                                        newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.Sales_Director_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                    }
                                    if(newbook.VP_Incentive__c != null){
                                        newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.VP_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                    }
                                    if(newbook.CSO_Incentive__c != null){
                                        newBook.Sales_Commission_Eligible_1st_Half__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = allPayment, Amount__c = newbook.CSO_Incentive__c * calFromPercentage, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                    }
                                }
                                
                            } 
                        }
                        
                        Boolean createPayoutsFlag = false;
                        if(tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
                           && ((tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
                               || !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
                                   createPayoutsFlag = true;
                               }
                        
                        //For Channel_Relation_Team_Incentive__c added by Nishank Manwani 08-Jan-2024  
                        ///********************************Channel Partner Incentive************************************************************                         
                        if(tempBooking.PropStrength__Booking_Through__c == 'Broker') {
                            System.debug(tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c+'--tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c--'+tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c);
                            if((tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Standard' && tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker International') ||
                               (tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Sobha Connect' && tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Sobha Connect International')) {
                                   system.debug('inside standard');
                                   if(!countBookingOnContactMap.isEmpty() && countBookingOnContactMap.containsKey(tempBooking.PropStrength__Primary_Customer__c) && countBookingOnContactMap.get(tempBooking.PropStrength__Primary_Customer__c) == 1) {
                                       system.debug('inside map');
                                       if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                           system.debug('inside channel');
                                           Decimal cusParInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Intl_Broker_New_Customer_Inc__c)/100;
                                           newbook.Id = tempBooking.Id;  
                                           
                                           newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
                                           newbook.Channel_Relation_Team_Incentive__c = cusParInc;
                                           newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
                                           newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
                                           newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
                                           if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
                                               newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
                                           }
                                           if(createPayoutsFlag) {
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c, User_Role__c = 'VP - Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP - Channel Relation'));
                                                  }
                                               
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c, User_Role__c = 'TL Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TL Channel Relation'));
                                                  }
                                               
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c, User_Role__c = 'RM - Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'RM - Channel Relation'));
                                                  }
                                               if(newbook.CMO_Channel_Relation_Incentive__c != null) {
                                                   if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && 
                                                      !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                      !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && 
                                                      towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
                                                          newBook.Marketing_CP_Commission_Eligible__c = true;
                                                          createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c, User_Role__c = 'Chief Marketing Officer'));
                                                      } else {
                                                          newBook.Marketing_CP_Commission_Eligible__c = true;
                                                          createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Chief Marketing Officer'));
                                                      }
                                               }
                                           }
                                       }
                                   } else if(!countBookingOnContactMap.isEmpty() && countBookingOnContactMap.containsKey(tempBooking.PropStrength__Primary_Customer__c) && countBookingOnContactMap.get(tempBooking.PropStrength__Primary_Customer__c) > 1) {
                                       if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                           Decimal cusParInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Intl_Broker_Old_Customer_Inc__c)/100;
                                           newbook.Id = tempBooking.Id;
                                           
                                           newbook.Channel_Relation_Team_Incentive__c = cusParInc;
                                           newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
                                           newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
                                           newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
                                           newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
                                           if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
                                               newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
                                           }
                                           if(createPayoutsFlag) {
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c, User_Role__c = 'VP - Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP - Channel Relation'));
                                                  }
                                               
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c, User_Role__c = 'TL Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TL Channel Relation'));
                                                  }
                                               
                                               if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                  !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c, User_Role__c = 'RM - Channel Relation'));
                                                  } else {
                                                      newBook.Marketing_CP_Commission_Eligible__c = true;
                                                      createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'RM - Channel Relation'));
                                                  }
                                               if(newbook.CMO_Channel_Relation_Incentive__c != null) {
                                                   if(!bookingTowerId.isEmpty() && 
                                                      bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && 
                                                      towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                      !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
                                                          newBook.Marketing_CP_Commission_Eligible__c = true;
                                                          createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c, User_Role__c = 'Chief Marketing Officer'));
                                                      } else {
                                                          newBook.Marketing_CP_Commission_Eligible__c = true;
                                                          createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Chief Marketing Officer'));
                                                      }
                                               }
                                           }
                                       }
                                   }
                               } 
                            else if((tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Standard' && ( tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker UAE' || tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker RERA' )) || 
                                    (tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Sobha Connect' && tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Sobha Connect UAE')) {
                                        if(!countBookingOnBrokerMap.isEmpty() && countBookingOnBrokerMap.containsKey(tempBooking.PropStrength__Broker_Account__c) && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c).isEmpty() == FALSE && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c).size() == 1) {
                                            if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                                Decimal cusParInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Sobha_Connect_UAE_New_Inc__c)/100;
                                                newbook.Id = tempBooking.Id;
                                                
                                                newbook.Channel_Relation_Team_Incentive__c = cusParInc;
                                                newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
                                                newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
                                                newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
                                                newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
                                                if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
                                                    newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
                                                }
                                                if(createPayoutsFlag) {
                                                    if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                       !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c, User_Role__c = 'VP - Channel Relation'));
                                                       } else {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP - Channel Relation'));
                                                       }
                                                    
                                                    if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                       !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c, User_Role__c = 'TL Channel Relation'));
                                                       } else {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TL Channel Relation'));
                                                       }
                                                    
                                                    if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                       !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c, User_Role__c = 'RM - Channel Relation'));
                                                       } else {
                                                           newBook.Marketing_CP_Commission_Eligible__c = true;
                                                           createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'RM - Channel Relation'));
                                                       }
                                                    if(newbook.CMO_Channel_Relation_Incentive__c != null) {
                                                        if(!bookingTowerId.isEmpty() && 
                                                           bookingTowerId.containsKey(tempBooking.Id) && 
                                                           !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c, User_Role__c = 'Chief Marketing Officer'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Chief Marketing Officer'));
                                                           }
                                                    }
                                                }
                                            }
                                        } else if(!countBookingOnBrokerMap.isEmpty() && countBookingOnBrokerMap.containsKey(tempBooking.PropStrength__Broker_Account__c) && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c).isEmpty() == FALSE && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c).size() > 1) {
                                            if(countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[0].PropStrength__Booking_Date__c != null && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[1].PropStrength__Booking_Date__c != null && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[1].PropStrength__Booking_Date__c.daysBetween(countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[0].PropStrength__Booking_Date__c) > 90) {
                                                if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                                    Decimal cusParInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Sobha_Connect_UAE_New_Inc__c)/100;
                                                    newbook.Id = tempBooking.Id;
                                                    
                                                    newbook.Channel_Relation_Team_Incentive__c = cusParInc;
                                                    newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
                                                    newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
                                                    newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
                                                    newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
                                                    if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
                                                        newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
                                                    }
                                                    if(createPayoutsFlag) {
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c, User_Role__c = 'VP - Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP - Channel Relation'));
                                                           }
                                                        
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c, User_Role__c = 'TL Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TL Channel Relation'));
                                                           }
                                                        
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c, User_Role__c = 'RM - Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'RM - Channel Relation'));
                                                           }
                                                        if(newbook.CMO_Channel_Relation_Incentive__c != null) {
                                                            if(!bookingTowerId.isEmpty() && 
                                                               bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && 
                                                               towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                               !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
                                                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c, User_Role__c = 'Chief Marketing Officer'));
                                                               } else {
                                                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Chief Marketing Officer'));
                                                               }
                                                        }
                                                    }
                                                }
                                            } else {
                                                if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                                                    Decimal cusParInc = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Sobha_Connect_UAE_Old_Inc__c)/100;
                                                    newbook.Id = tempBooking.Id;
                                                    
                                                    newbook.Channel_Relation_Team_Incentive__c = cusParInc;
                                                    newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
                                                    newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
                                                    newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
                                                    newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
                                                    if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
                                                        newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
                                                    }
                                                    if(createPayoutsFlag) {
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c, User_Role__c = 'VP - Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.VP_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP - Channel Relation'));
                                                           }
                                                        
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c, User_Role__c = 'TL Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TL_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TL Channel Relation'));
                                                           }
                                                        
                                                        if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c, User_Role__c = 'RM - Channel Relation'));
                                                           } else {
                                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.RM_Channel__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'RM - Channel Relation'));
                                                           }
                                                        if(newbook.CMO_Channel_Relation_Incentive__c != null) {
                                                            if(!bookingTowerId.isEmpty() && 
                                                               bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && 
                                                               towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                                               !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
                                                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c, User_Role__c = 'Chief Marketing Officer'));
                                                               } else {
                                                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Channel_Relation_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Chief Marketing Officer'));
                                                               }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                        }
                        //   /********************************Marketing Incentive************************************************************ 
                        //For Marketing_Team_Incentive__c added by Nishank Manwani 08-Jan-2024                            
                        // Modified code By Gourav Gour 16/05/2024 
                        Map<String, Incentive_Slab__c> slabVsCategoryMap = new Map<String, Incentive_Slab__c>();
                        if(!mapOfREcordTypeAndinterestSlabRec.isEmpty() && mapOfREcordTypeAndinterestSlabRec.containsKey('Marketing Incentive')) {
                            for(Incentive_Slab__c slab : mapOfREcordTypeAndinterestSlabRec.get('Marketing Incentive')) {
                                if(slab.Marketing_Category__c != null && !slabVsCategoryMap.containsKey(slab.Marketing_Category__c)) {
                                    slabVsCategoryMap.put(slab.Marketing_Category__c, slab);
                                }
                            }
                        }
                        if(tempBooking.PropStrength__Offer__c != null && tempBooking.PropStrength__Offer__r.PropStrength__Request__c != null) {
                            Incentive_Slab__c iss;
                            if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Loyalty Sales') {
                                if(slabVsCategoryMap.containsKey('Loyalty Sales') && (tempBooking.PropStrength__Discount__c == null ||(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Discount__c == 0.00))) {
                                    iss = slabVsCategoryMap.get('Loyalty Sales');
                                    newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales').Id;
                                }
                                else if(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Project__c != null && tempBooking.PropStrength__Project__r.NPV__c != null) {
                                    if(slabVsCategoryMap.containsKey('Loyalty Sales (saving 1% on discount)') && (tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) >= 1.0) {
                                        iss = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)');
                                        newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)').Id;
                                    }  
                                    else if(slabVsCategoryMap.containsKey('Loyalty Sales (with discount)') && 
                                            (tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) < 1.0 && 
                                            (tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) >= 0 ) {
                                                iss = slabVsCategoryMap.get('Loyalty Sales (with discount)');
                                                newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (with discount)').Id;
                                            }
                                }
                            }
                            else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Mall Stands/Kiosks Sales' || tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Stand Leads') {
                                if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c == null && slabVsCategoryMap.containsKey('Mall Stands/Kiosks Sales')) {
                                    iss = slabVsCategoryMap.get('Mall Stands/Kiosks Sales');
                                    newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Mall Stands/Kiosks Sales').Id;
                                }
                                else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c != null && slabVsCategoryMap.containsKey('Mall Stands/Kiosks Sales (with Telesales)')) {
                                    iss = slabVsCategoryMap.get('Mall Stands/Kiosks Sales (with Telesales)');
                                    newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Mall Stands/Kiosks Sales (with Telesales)').Id;
                                }
                                
                            }
                            else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Telesales' && slabVsCategoryMap.containsKey('Telesales')) {
                                iss = slabVsCategoryMap.get('Telesales');
                                newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Telesales').Id;
                            }
                            else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Walk-in' && slabVsCategoryMap.containsKey('Direct Walk-in')) {
                                iss = slabVsCategoryMap.get('Direct Walk-in');
                                newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Direct Walk-in').Id;
                            }
                            else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Digital Platform' && slabVsCategoryMap.containsKey('Digital Marketing Sales (Inc. Influencer)')) {
                                iss = slabVsCategoryMap.get('Digital Marketing Sales (Inc. Influencer)');
                                newbook.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Digital Marketing Sales (Inc. Influencer)').Id;
                            }
                            if(iss != null) {
                                if(iss.Marketing_Incentive__c != null) {
                                    newbook.Id = tempBooking.Id;
                                    
                                    if(mapOfREcordTypeAndinterestSlabRec.containskey('Marketing Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Marketing Incentive').size() > 0)
                                        
                                        newbook.Marketing_Team_Incentive__c = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*iss.Marketing_Incentive__c)/100;
                                    if(iss.Loyalty_Sales_Executive_Split__c != null) {
                                        newbook.Loyalty_Sales_Executive_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Loyalty_Sales_Executive_Split__c)/100;
                                    }
                                    if(iss.Marketing_Head_Split__c != null) {
                                        newbook.Marketing_Head_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Marketing_Head_Split__c)/100;
                                    }
                                    if(iss.Promoter_Split__c != null) {
                                        newbook.Promoter_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Promoter_Split__c)/100;
                                    }
                                    if(iss.Mall_Team_Lead_Split__c != null) {
                                        newbook.Mall_Team_Lead_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Mall_Team_Lead_Split__c)/100;
                                    }
                                    if(iss.Telesales_Agent_Split__c != null) {
                                        newbook.TeleSales_Agent_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Telesales_Agent_Split__c)/100;
                                    }
                                    if(iss.Campaign_Manager_Split__c != null) {
                                        newbook.Campaign_Manager_Influence_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Campaign_Manager_Split__c)/100;
                                    }
                                    if(iss.Digital_Marketing_Head_Split__c != null) {
                                        newbook.Digital_Marketing_Head_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Digital_Marketing_Head_Split__c)/100;
                                    }
                                    if(iss.Team_Lead_Split__c != null) {
                                        newbook.Team_Lead_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.Team_Lead_Split__c)/100;
                                    }
                                    if(iss.TeleSales_Head_Split__c != null) {
                                        newbook.TeleSales_Head_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.TeleSales_Head_Split__c)/100;
                                    }
                                    // Added By Gourav Gour 15/05/2024
                                    if(iss.CMO_Marketing_Split__c != null) {
                                        newbook.CMO_Marketing_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.CMO_Marketing_Split__c)/100;
                                    }
                                    if(iss.GM_Marketing_Split__c != null) {
                                        newbook.GM_Marketing_Incentive__c = (newbook.Marketing_Team_Incentive__c*iss.GM_Marketing_Split__c)/100;
                                    }
                                    // Added For Gourav Gour 15/05/2024
                                    if(createPayoutsFlag) {
                                        if(newbook.CMO_Marketing_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Marketing__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Marketing_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Marketing__c, User_Role__c = 'CMO Marketing'));
                                           } else if(newbook.CMO_Marketing_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.CMO_Marketing_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CMO Marketing'));
                                           }
                                        if(newbook.GM_Marketing_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].GM_Marketing__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.GM_Marketing_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].GM_Marketing__c, User_Role__c = 'GM Marketing'));
                                           } else if(newbook.GM_Marketing_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.GM_Marketing_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'GM Marketing'));
                                           }
                                        //
                                        
                                        if(newbook.Loyalty_Sales_Executive_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Loyalty_Sales_Executive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Loyalty_Sales_Executive_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Loyalty_Sales_Executive__c, User_Role__c = 'Loyalty Sale Executive'));
                                           } else if(newbook.Loyalty_Sales_Executive_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Loyalty_Sales_Executive_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Loyalty Sale Executive'));
                                           }
                                        
                                        if(newbook.Marketing_Head_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Marketing_Head__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Marketing_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Marketing_Head__c, User_Role__c = 'Marketing Head'));
                                           } else if(newbook.Marketing_Head_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Marketing_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Marketing Head'));
                                           }
                                        
                                        if(newbook.Promoter_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Promoter__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Promoter_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Promoter__c, User_Role__c = 'Promoter'));
                                           } else if(newbook.Promoter_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Promoter_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Promoter'));
                                           }
                                        
                                        if(newbook.Mall_Team_Lead_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Mall_Team_Lead__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Mall_Team_Lead_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Mall_Team_Lead__c, User_Role__c = 'Mall Team Lead'));
                                           } else if(newbook.Mall_Team_Lead_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Mall_Team_Lead_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Mall Team Lead'));
                                           }
                                        
                                        if(newbook.TeleSales_Agent_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TeleSales_Agent__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TeleSales_Agent_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TeleSales_Agent__c, User_Role__c = 'TeleSales Agent'));
                                           } else if(newbook.TeleSales_Agent_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TeleSales_Agent_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TeleSales Agent'));
                                           }
                                        
                                        if(newbook.Campaign_Manager_Influence_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Campaign_Manager_Influence__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Campaign_Manager_Influence_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Campaign_Manager_Influence__c, User_Role__c = 'Campaign Manager Influence'));
                                           } else if(newbook.Campaign_Manager_Influence_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Campaign_Manager_Influence_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Campaign Manager Influence'));
                                           }
                                        
                                        if(newbook.Digital_Marketing_Head_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Digital_Marketing_Head__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Digital_Marketing_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Digital_Marketing_Head__c, User_Role__c = 'Digital Marketing Head'));
                                           } else if(newbook.Digital_Marketing_Head_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Digital_Marketing_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Digital Marketing Head'));
                                           }
                                        
                                        if(newbook.Team_Lead_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Team_Lead__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Team_Lead_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Team_Lead__c, User_Role__c = 'Team Lead'));
                                           } else if(newbook.Team_Lead_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Team_Lead_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Team Lead'));
                                           }
                                        
                                        if(newbook.TeleSales_Head_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                           !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TeleSales_Head__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TeleSales_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TeleSales_Head__c, User_Role__c = 'TeleSales Head'));
                                           } else if(newbook.TeleSales_Head_Incentive__c != null) {
                                               newBook.Marketing_CP_Commission_Eligible__c = true;
                                               createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.TeleSales_Head_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TeleSales Head'));
                                           }
                                    }
                                }
                            }
                            
                        }                        
                        
                        //  /********************************Special Incentive************************************************************ 
                        if(mapOfREcordTypeAndinterestSlabRec.containskey('Special Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive').size() > 0 && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Brand_Evangelist_Split__c != null && tempBooking.PropStrength__Project__r.Special_Incentive_Applicable__c) {
                            newbook.Id = tempBooking.Id;
                            
                            if(mapOfREcordTypeAndinterestSlabRec.containskey('Special Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive').size() > 0 )
                                newbook.Brand_Evangelist_Incentive_Slab__c = mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Id;
                            newbook.Brand_Evangelist_Incentive__c = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c * mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Brand_Evangelist_Split__c)/100;
                            if(createPayoutsFlag && newbook.Brand_Evangelist_Incentive__c != null && !bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                               !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Brand_Evangelist__c != null) {
                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                   newbook.Brand_Evangelist__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Brand_Evangelist__c;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Brand_Evangelist_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Brand_Evangelist__c, User_Role__c = 'Brand Evangelist'));
                               } else if(newbook.Brand_Evangelist_Incentive__c != null && createPayoutsFlag) {
                                   newBook.Marketing_CP_Commission_Eligible__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = newbook.Brand_Evangelist_Incentive__c, Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Brand Evangelist'));
                               }
                        }
                    }
                }
                if((totalPercentage >= 20)) {
                    if(tempBooking.X20_Payment_Received_Date__c == null) {
                        newbook.Id = tempBooking.Id;
                        
                        newbook.X20_Payment_Received_Date__c = System.Today();
                        // newbook.X20_Payment_GL_Date__c = payRec.GL_Date__c != null ? Date.ValueOf(payRec.GL_Date__c) : null;   //@Deeapak Added For GL Date
                    }
                    if(!tempBooking.Incentive_Payouts__r.isEmpty() && (tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.SPA_Executed__c)
                       || !tempBooking.PropStrength__Project__r.RERA_Registered__c) {
                           for(Incentive_Payouts__c ipRec : tempBooking.Incentive_Payouts__r) {
                               if(ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                   if(tempBooking.Sales_Manager__c != null && newbook.Sales_Manager_Incentive__c != null) {
                                       system.debug('inside second if ');
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = newbook.Sales_Manager_Incentive__c / 2 , Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                   } else if(newbook.Sales_Manager_Incentive__c != null){
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = newbook.Sales_Manager_Incentive__c / 2 , Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                   }
                                   if(tempBooking.Sales_Head__c != null) {
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Head_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                   } else {
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Head_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                   }
                                   updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                               }
                               
                               
                               if(ipRec.User_Role__c == 'Employee Referral' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                   if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null && newbook.Employee_Referral_Incentive__c != null) {
                                       system.debug('inside second if ');
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = newbook.Employee_Referral_Incentive__c / 2 , Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c, User_Role__c = 'Employee Referral'));
                                   } else if(newbook.Employee_Referral_Incentive__c != null){
                                       newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                       createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = newbook.Employee_Referral_Incentive__c / 2 , Application_Booking__c = newBook.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Employee Referral'));
                                   }
                                   updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                               }
                               
                               if(ipRec.User_Role__c == 'Sales Director' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                   if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                      !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Sales_Director__c != null) {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Director_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Sales_Director__c, User_Role__c = 'Sales Director'));
                                      } else {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Director_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                      }
                                   updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                               }
                               
                               if(ipRec.User_Role__c == 'VP Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                   if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                      !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Sales__c != null) {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.VP_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Sales__c, User_Role__c = 'VP Sales'));
                                      } else {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.VP_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                      }
                                   updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                               }
                               
                               if(ipRec.User_Role__c == 'CSO Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                   if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
                                      !towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CSO__c != null) {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.CSO_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CSO__c, User_Role__c = 'CSO Sales'));
                                      } else {
                                          newBook.Sales_Commission_Eligible_2nd_Half__c = true;
                                          createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.CSO_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                      }
                                   updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                               }
                           }
                       }
                }
                if(newBook != null && newBook.Id != null) {
                    mapOfBookingPerc.put(newBook.Id,newbook);
                }
                
            }
            
            if(!mapOfBookingPerc.isEmpty() && !Test.isRunningTest()) {
                update mapOfBookingPerc.values();
                
                
                
                
            }
        }
    } */
    /* public static void updateChannelPartnerIncentivesOnQualifiedDate(List<PropStrength__Application_Booking__c> newBookings, Map<Id, PropStrength__Application_Booking__c> oldMap){
Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
Set<Id> brokerId = new Set<Id>();
Map<Id,List<PropStrength__Application_Booking__c>> brokerIdAndOBookingMap = new Map<Id,List<PropStrength__Application_Booking__c>>();
Map<Id,List<PropStrength__Application_Booking__c>> brokerIdAndListOfBookings = new Map<Id,List<PropStrength__Application_Booking__c>>();
Map<Id,List<PropStrength__Application_Booking__c>> updatedBrokerIdAndListOfBookings = new Map<Id,List<PropStrength__Application_Booking__c>>();

Map<Id, PropStrength__Application_Booking__c> updateBookingMap = new Map<Id,PropStrength__Application_Booking__c>();
Set<Id> bookingIds = new Set<Id>();
Map<Id,PropStrength__Application_Booking__c> newBookingsMap = new Map<Id,PropStrength__Application_Booking__c>();
for(PropStrength__Application_Booking__c booking : newBookings ){
bookingIds.add(booking.id);
if(booking.Qualification_Date__c != null && booking.Qualification_Date__c != oldMap.get(booking.id).Qualification_Date__c){
if(booking.PropStrength__Broker_Account__c != null){
brokerId.add(booking.PropStrength__Broker_Account__c);
}
}
}

if(brokerId.size() > 0){

List<Incentive_Slab__c> interestSlabRec = [SELECT Id, Indirect_Sales__c, Direct_Sales__c, Loyalty_Sales__c, Approved_Discount_Sales__c,RecordType.Name,Brand_Evangelist_Split__c ,
Intl_Broker_New_Customer_Inc__c, VP_Channel_Relations_Split__c, RM_Channel_Split__c, TL_Channel_Relation_Split__c, 
Intl_Broker_Old_Customer_Inc__c, Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c, CMO_Channel_Relations_Split__c,
Marketing_Category__c, Marketing_Incentive__c, Loyalty_Sales_Executive_Split__c, Sales_Director_Split__c,
Marketing_Head_Split__c, Promoter_Split__c, Mall_Team_Lead_Split__c, Telesales_Agent_Split__c, Start_Date__c, End_Date__c,
Campaign_Manager_Split__c, Digital_Marketing_Head_Split__c, Team_Lead_Split__c, TeleSales_Head_Split__c, 
Sales_Head_Split__c, VP_Split__c, CSO_Split__c, Days_From__c, Days_To__c,CMO_Marketing_Split__c,GM_Marketing_Split__c
FROM Incentive_Slab__c where Siniya_Island_Project__c = false];

List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Id, Indirect_Sales__c, Direct_Sales__c, Loyalty_Sales__c, Approved_Discount_Sales__c,RecordType.Name,Brand_Evangelist_Split__c ,
Intl_Broker_New_Customer_Inc__c, VP_Channel_Relations_Split__c, RM_Channel_Split__c, TL_Channel_Relation_Split__c, 
Intl_Broker_Old_Customer_Inc__c, Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c, CMO_Channel_Relations_Split__c,
Marketing_Category__c, Marketing_Incentive__c, Loyalty_Sales_Executive_Split__c, Sales_Director_Split__c,
Marketing_Head_Split__c, Promoter_Split__c, Mall_Team_Lead_Split__c, Telesales_Agent_Split__c, Start_Date__c, End_Date__c,
Campaign_Manager_Split__c, Digital_Marketing_Head_Split__c, Team_Lead_Split__c, TeleSales_Head_Split__c, 
Sales_Head_Split__c, VP_Split__c, CSO_Split__c, Days_From__c, Days_To__c,CMO_Marketing_Split__c,GM_Marketing_Split__c
FROM Incentive_Slab__c where Siniya_Island_Project__c = true];
Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec1 = new Map<String, List<Incentive_Slab__c>>();
Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec2 = new Map<String, List<Incentive_Slab__c>>();

if(interestSlabRec.size() > 0){
for(Incentive_Slab__c IncentiveRec : interestSlabRec){
if(mapOfREcordTypeAndinterestSlabRec1.containskey(IncentiveRec.RecordType.Name)){
mapOfREcordTypeAndinterestSlabRec1.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
}
else{
mapOfREcordTypeAndinterestSlabRec1.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
}
}
}

if(interestSlabRecWithSiniyaProject.size() > 0){
for(Incentive_Slab__c IncentiveRec : interestSlabRecWithSiniyaProject){
if(mapOfREcordTypeAndinterestSlabRec2.containskey(IncentiveRec.RecordType.Name)){
mapOfREcordTypeAndinterestSlabRec2.get(IncentiveRec.RecordType.Name).add(IncentiveRec);
}
else{
mapOfREcordTypeAndinterestSlabRec2.put(IncentiveRec.RecordType.Name, new List<Incentive_Slab__c>{IncentiveRec});
}
}
}


Map<Id,Map<String, List<Incentive_Slab__c>>> bookingSlabMap = new Map<Id,Map<String, List<Incentive_Slab__c>>>();




Set<Id> towerIds = new Set<Id>();
Map<Id, Id> bookingTowerId = new Map<Id, Id>();
for(PropStrength__Application_Booking__c booking : newbookings) {
if(booking.PropStrength__Property__c != null && booking.PropStrength__Property__r.PropStrength__Tower__c != null) {
towerIds.add(booking.PropStrength__Property__r.PropStrength__Tower__c);
bookingTowerId.put(booking.Id, booking.PropStrength__Property__r.PropStrength__Tower__c);
}
}

Map<Id, PropStrength__Tower__c> towerMap = new Map<Id, PropStrength__Tower__c>([SELECT Id, (SELECT Id, Campaign_Manager_Influence__c, CMO_Channel_Relation__c, 
CSO__c, Digital_Marketing_Head__c, Loyalty_Sales_Executive__c, Brand_Evangelist__c ,
Mall_Team_Lead__c, Marketing_Head__c, Promoter__c, RM_Channel_Relation__c, 
Sales_Director__c, Team_Lead__c, TeleSales_Agent__c, TeleSales_Head__c, TL_Channel_Relation__c, 
VP_Channel_Relation__c, VP_Sales__c, GM_Marketing__c, CMO_Marketing__c FROM Incentive_Teams__r) 
FROM PropStrength__Tower__c 
WHERE Id IN :towerIds]);






List<PropStrength__Application_Booking__c> oldBookingList = [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate, Sales_Manager__c , 
PropStrength__Project__r.Master_Project__r.Incentive_Calculation__c,DLD_Waiver__c,PropStrength__BSP_Specific_Waiver__c,
Secondary_Sales_Manager_Incentive__c,Secondary_VP_Incentive__c,Secondary_SVP_Incentive__c,Secondary_CSO_Incentive__c,
Secondary_Sales_Head_Incentive__c,Secondary_Sales_Manager__c,Qualification_Date__c,
PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c, 
PropStrength__Project__r.Master_Project__c,
PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,

Sales_Manager_Incentive__c, Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Director_Incentive__c, 
PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,
CMO_Marketing_Incentive__c, GM_Marketing_Incentive__c, Incentive_Update_Option__c, Marketing_CP_Commission_Eligible__c,
DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, 
X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c, 
(SELECT Id, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :payRecRT) 
FROM PropStrength__Application_Booking__c  where PropStrength__Broker_Account__c in :brokerId ORDER BY CreatedDate asc];

for(PropStrength__Application_Booking__c booking : oldBookingList ){
if(booking.PropStrength__Broker_Account__c != null){
if(!brokerIdAndOBookingMap.containsKey(booking.PropStrength__Broker_Account__c)){
brokerIdAndOBookingMap.put(booking.PropStrength__Broker_Account__c, new List<PropStrength__Application_Booking__c>());
}
brokerIdAndOBookingMap.get(booking.PropStrength__Broker_Account__c).add(booking);

}

}


for(PropStrength__Application_Booking__c bookRec : oldBookingList){
if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && !bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec1 );
}
else if(bookRec.PropStrength__Project__c != null && bookRec.PropStrength__Project__r.Master_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c != null && bookRec.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c ){
bookingSlabMap.put(bookRec.Id, mapOfREcordTypeAndinterestSlabRec2 );
}

}
system.debug('brokerIdAndOBookingMap +++'+ brokerIdAndOBookingMap);
system.debug(' brokerIdAndOBookingMap.get(booking.PropStrength__Broker_Account__c) '+brokerIdAndOBookingMap.get(newBookings[0].PropStrength__Broker_Account__c));
for(PropStrength__Application_Booking__c booking : newBookings){
if(booking.PropStrength__Broker_Account__c != null && brokerIdAndOBookingMap.containsKey(booking.PropStrength__Broker_Account__c)){
for(PropStrength__Application_Booking__c bookingRec : brokerIdAndOBookingMap.get(booking.PropStrength__Broker_Account__c)){
if(bookingRec.createddate > booking.createddate){

PropStrength__Application_Booking__c book = updateChannelIncentives(bookingRec,bookingSlabMap.get(bookingRec.Id),booking,bookingTowerId,towerMap);
if(book != null){
updateBookingMap.put(book.id,book);
}
break;
}
}
}
}



}
if(updateBookingMap.size() > 0){
update updateBookingMap.values();
}

}




public static PropStrength__Application_Booking__c updateChannelIncentives(PropStrength__Application_Booking__c tempBooking,Map<String, List<Incentive_Slab__c>>  mapOfREcordTypeAndinterestSlabRec,PropStrength__Application_Booking__c oldBooking,  Map<Id, Id> bookingTowerId,Map<Id, PropStrength__Tower__c> towerMap){

Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();

PropStrength__Application_Booking__c newbook = new PropStrength__Application_Booking__c();

Boolean createPayoutsFlag = false;
if(tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
&& ((tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
|| !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
createPayoutsFlag = true;
}
if(tempBooking.PropStrength__Booking_Through__c == 'Broker'){
if((tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Standard' && ( tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker UAE' || tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Broker RERA' )) || 
(tempBooking.PropStrength__Broker_Account__r.PropStrength__Broker_Type__c == 'Sobha Connect' && tempBooking.PropStrength__Broker_Account__r.Broker_Sub_Type__c == 'Sobha Connect UAE')) {



if(oldBooking.PropStrength__Booking_Date__c != null  ) {
// && brokerIdAndTodaysBookingsMap.get(tempBooking.PropStrength__Broker_Account__c).PropStrength__Booking_Date__c != null && countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[1].PropStrength__Booking_Date__c.daysBetween(countBookingOnBrokerMap.get(tempBooking.PropStrength__Broker_Account__c)[0].PropStrength__Booking_Date__c) > 90
if(mapOfREcordTypeAndinterestSlabRec.containskey('Channel Partner Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive').size() > 0 && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
Decimal cusParInc;
if(tempbooking.PropStrength__Booking_Date__c != null && oldBooking.PropStrength__Booking_Date__c.daysBetween(tempbooking.PropStrength__Booking_Date__c) > 90 )
{
cusParInc=   (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Sobha_Connect_UAE_New_Inc__c)/100;
newbook.Id = tempBooking.Id;
}
else {
cusParInc=   (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Sobha_Connect_UAE_Old_Inc__c)/100;
newbook.Id = tempBooking.Id;
} 

newbook.Channel_Relation_Team_Incentive__c = cusParInc;
newbook.Channel__c = mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].Id;
newbook.VP_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].VP_Channel_Relations_Split__c)/100;
newbook.TL_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].TL_Channel_Relation_Split__c)/100;
newbook.RM_Channel__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].RM_Channel_Split__c)/100;
if(mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c != null) {
newbook.CMO_Channel_Relation_Incentive__c = (cusParInc*mapOfREcordTypeAndinterestSlabRec.get('Channel Partner Incentive')[0].CMO_Channel_Relations_Split__c)/100;
}
if(createPayoutsFlag) {
if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
!towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].VP_Channel_Relation__c != null) {
newBook.Marketing_CP_Commission_Eligible__c = true;
} else {
newBook.Marketing_CP_Commission_Eligible__c = true;
}

if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
!towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].TL_Channel_Relation__c != null) {
newBook.Marketing_CP_Commission_Eligible__c = true;
} else {
newBook.Marketing_CP_Commission_Eligible__c = true;
}

if(!bookingTowerId.isEmpty() && bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
!towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].RM_Channel_Relation__c != null) {
newBook.Marketing_CP_Commission_Eligible__c = true;
} else {
newBook.Marketing_CP_Commission_Eligible__c = true;
}
if(newbook.CMO_Channel_Relation_Incentive__c != null) {
if(!bookingTowerId.isEmpty() && 
bookingTowerId.containsKey(tempBooking.Id) && !towerMap.isEmpty() && 
towerMap.containsKey(bookingTowerId.get(tempBooking.Id)) && 
!towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r.isEmpty() && towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].CMO_Channel_Relation__c != null) {
newBook.Marketing_CP_Commission_Eligible__c = true;
} else {
newBook.Marketing_CP_Commission_Eligible__c = true;
}
}
}
}
}


}
}

if(newBook != null && newBook.Id != null) {
return newBook;
}
else{
return null;
}
}
*/
    public static void updateSBTRFromBooking(List<PropStrength__Application_Booking__c> newBookings, Map<Id, PropStrength__Application_Booking__c> oldMap) {
        List<Update_SBTR_Field_Values__mdt> updateSBTRFields = [SELECT Id, Object_Field_API__c, Object_Name__c, SBTR_Field_API__c FROM Update_SBTR_Field_Values__mdt WHERE Object_Name__c = 'PropStrength__Application_Booking__c' ];
        Set<String> bookIds = new Set<String>();
        Map<String, String> updateSBTRFieldsMap = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Application_Booking__c').getDescribe().fields.getMap();
        
        for(Update_SBTR_Field_Values__mdt mdRec : updateSBTRFields) {
            if(fieldMap.containsKey(mdRec.Object_Field_API__c)) {
                updateSBTRFieldsMap.put(mdRec.Object_Field_API__c, mdRec.SBTR_Field_API__c);
            }
        }
        for(PropStrength__Application_Booking__c book : newBookings) {
            for(String fieldST : updateSBTRFieldsMap.keySet()) {
                if(book.get(fieldST) != null && (book.get(fieldST) != oldMap.get(book.Id).get(fieldST))) {
                    bookIds.add(book.Id);
                    break;
                }
            }
        }
        if(bookIds.size() > 0) {
            BookingTriggerHelper.updateSBTROnBookingUpdate(bookIds, updateSBTRFieldsMap);
        }
    }
    @future
    Public static void updateSBTROnBookingUpdate(Set<String> bookingId, Map<String, String> updateSBTRFieldsMap) {
        String query = 'SELECT ';
        for(String st : updateSBTRFieldsMap.keySet()) {
            query += st+', ';
        }
        query += ' Id FROM PropStrength__Application_Booking__c WHERE Id IN: bookingId';
        Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> bookList = Database.query(query);
        for(PropStrength__Application_Booking__c rec : bookList) {
            bookMap.put(rec.Id, rec);
        }
        /*List<SBTR__c> sbtrList = [SELECT Id, Booking__c FROM SBTR__c WHERE Booking__c IN : bookMap.keySet()];
        List<SBTR__c> updateSBTRList = new List<SBTR__c>();
        for(SBTR__c sb : sbtrList) {
            if(bookMap.containsKey(sb.Booking__c)) {
                SBTR__c sbRec = new SBTR__c();
                sbRec.Id = sb.Id;
                for(String st : updateSBTRFieldsMap.keyset()) {
                    if(bookMap.get(sb.Booking__c).get(st) != null) {
                        sbRec.put(updateSBTRFieldsMap.get(st), bookMap.get(sb.Booking__c).get(st));
                    }
                    else {
                        sbRec.put(updateSBTRFieldsMap.get(st), null);
                    }
                }
                updateSBTRList.add(sbRec);
            }
        }
        if(!updateSBTRList.isEmpty()) {
            update updateSBTRList;
        }*/
    }
    
}