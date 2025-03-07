public  class IncentiveSlabHelper {
   /* public static void updateIncentivesOnBooking(List<Incentive_Slab__c> newIncentiveList ){
        system.debug('inside updateIncentivesOnBooking ');
        Set<Id> incentiveSlabIds = new Set<Id>();
        for(Incentive_Slab__c incentiveSlab : newIncentiveList) {
            incentiveSlabIds.add(incentiveSlab.Id);
        }
        Map<Id, Incentive_Slab__c> incentiveSlabMap = new Map<Id, Incentive_Slab__c>([select id, Start_Date__c, End_Date__c from Incentive_Slab__c where id in: incentiveSlabIds] );
        System.debug('incentiveSlabIds**-'+incentiveSlabIds);
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>([select id,Sales_Manager_Incentive__c, Channel_Relation_Team_Incentive__c ,Brand_Evangelist_Incentive_Slab__c, 
                                                                                                                 Sales_Head_Incentive__c,CMO_Channel_Relation_Incentive__c, Sales_Director_Incentive__c,Channel__c,
                                                                                                                 VP_Channel_Relation_Incentive__c, VP_Incentive__c, TL_Channel_Relation_Incentive__c,Marketing_Incentive_Slab__c,
                                                                                                                 CSO_Incentive__c, RM_Channel__c, Brand_Evangelist_Incentive__c, CreatedDate,Sales_Incentive_Slab__c 
                                                                                                                 from PropStrength__Application_Booking__c 
                                                                                                                 where Sales_Incentive_Slab__c In : incentiveSlabIds OR Brand_Evangelist_Incentive_Slab__c In : incentiveSlabIds
                                                                                                                 OR Channel__c In : incentiveSlabIds OR Marketing_Incentive_Slab__c In : incentiveSlabIds]);
        
        Set<Id> bookingIds = new Set<Id>();
        
        for(PropStrength__Application_Booking__c booking : bookingList) {
            if(incentiveSlabMap.containskey(booking.Sales_Incentive_Slab__c) && booking.CreatedDate >= incentiveSlabMap.get(booking.Sales_Incentive_Slab__c).Start_Date__c && booking.CreatedDate <= incentiveSlabMap.get(booking.Sales_Incentive_Slab__c).End_Date__c) {
                bookingIds.add(booking.Id);
            }
            if( incentiveSlabMap.containskey(booking.Brand_Evangelist_Incentive_Slab__c) && booking.CreatedDate >= incentiveSlabMap.get(booking.Brand_Evangelist_Incentive_Slab__c).Start_Date__c && booking.CreatedDate <= incentiveSlabMap.get(booking.Brand_Evangelist_Incentive_Slab__c).End_Date__c) {
                bookingIds.add(booking.Id);
            }
            if( incentiveSlabMap.containskey(booking.Channel__c) && booking.CreatedDate >= incentiveSlabMap.get(booking.Channel__c).Start_Date__c && booking.CreatedDate <= incentiveSlabMap.get(booking.Channel__c).End_Date__c) {
                bookingIds.add(booking.Id);
            }
            if( incentiveSlabMap.containskey(booking.Marketing_Incentive_Slab__c) && booking.CreatedDate >= incentiveSlabMap.get(booking.Marketing_Incentive_Slab__c).Start_Date__c && booking.CreatedDate <= incentiveSlabMap.get(booking.Marketing_Incentive_Slab__c).End_Date__c) {
                bookingIds.add(booking.Id);
            }
        }
        System.debug('bookingIds*---'+bookingIds);
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
            List<Incentive_Payouts__c> createIncentivePayoutList = new List<Incentive_Payouts__c>();
            List<Incentive_Payouts__c> updateIncentivePayoutList = new List<Incentive_Payouts__c>();
            Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, createddate,  
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name,PropStrength__Discount__c, PropStrength__Project__c, PropStrength__Project__r.NPV__c, PropStrength__Project__r.Special_Incentive_Applicable__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, Brand_Evangelist_Incentive__c, Brand_Evangelist__c,
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c ,
                 VP_Channel_Relation_Incentive__c ,
                 Campaign_Manager_Influence_Incentive__c,Channel_Relation_Team_Incentive__c,CMO_Channel_Relation_Incentive__c, 
                 Sales_Manager_Incentive__c, Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Director_Incentive__c,  
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c,
                 CMO_Marketing_Incentive__c, GM_Marketing_Incentive__c, Incentive_Update_Option__c,CP_Team_Incentive__c,
                 Digital_Marketing_Head_Incentive__c,Loyalty_Sales_Executive_Incentive__c,Mall_Team_Lead_Incentive__c,Marketing_Head_Incentive__c,PropStrength__Project__r.Master_Project__c,
                 PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,
                 Marketing_Incentive__c,Marketing_Team_Incentive__c,Promoter_Incentive__c,Team_Lead_Incentive__c,TeleSales_Agent_Incentive__c,
                 TeleSales_Head_Incentive__c,TL_Channel_Relation_Incentive__c,     Booked_Date__c, PropStrength__Discount_Type__c,          
                 Sales_Commission_Eligible_1st_Half__c ,Sales_Commission_Eligible_2nd_Half__c,Marketing_CP_Commission_Eligible__c,
                 DLD_Fees_Received__c, DLD_Fees_Due__c, Booking_Form_Verified__c, Oqood_Fees_Received__c, SPA_Executed__c, PropStrength__Project__r.RERA_Registered__c, 
                 X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c  ,
                 (SELECT id,User_Role__c, Amount__c, Balance__c, Application_Booking__c,All_Payment_Of_Sale_Inn__c from Incentive_Payouts__r)
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]); 
            
            Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
            List<Incentive_Slab__c> interestSlabRec = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                       CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                       Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                       Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                       LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,
                                                       Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                       Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                       Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                       Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                       VP_Split__c FROM Incentive_Slab__c where id in :incentiveSlabIds and Siniya_Island_Project__c = false];
            
            List<Incentive_Slab__c> interestSlabRecWithSiniyaProject = [SELECT Approved_Discount_Sales__c,Brand_Evangelist_Split__c,Campaign_Manager_Split__c,CMO_Channel_Relations_Split__c,
                                                                        CMO_Marketing_Split__c,CreatedById,CreatedDate,CSO_Split__c,Days_From__c,Days_To__c,
                                                                        Digital_Marketing_Head_Split__c,Direct_Sales__c,End_Date__c,GM_Marketing_Split__c,Id,RecordType.name,
                                                                        Indirect_Sales__c,Intl_Broker_New_Customer_Inc__c,Intl_Broker_Old_Customer_Inc__c,IsDeleted,LastActivityDate,
                                                                        LastModifiedById,LastModifiedDate,Loyalty_Sales_Executive_Split__c,
                                                                        Loyalty_Sales__c,Mall_Team_Lead_Split__c,Marketing_Category__c,Marketing_Head_Split__c,Marketing_Incentive__c,
                                                                        Name,OwnerId,Promoter_Split__c,RecordTypeId,RM_Channel_Split__c,Sales_Director_Split__c,Sales_Head_Split__c,
                                                                        Sobha_Connect_UAE_New_Inc__c,Sobha_Connect_UAE_Old_Inc__c,Start_Date__c,SystemModstamp,Team_Lead_Split__c,
                                                                        Telesales_Agent_Split__c,TeleSales_Head_Split__c,TL_Channel_Relation_Split__c,VP_Channel_Relations_Split__c,
                                                                        VP_Split__c FROM Incentive_Slab__c where id in :incentiveSlabIds and Siniya_Island_Project__c = true];
            
            
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
                List<Contact> contList = [SELECT Id, (SELECT Id,Booked_Date__c FROM PropStrength__Applications_Bookings__r) FROM Contact WHERE Id IN :contactId];
                
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
                List<Account> brokerAccList = [SELECT Id, (SELECT Id, PropStrength__Booking_Date__c,Booked_Date__c FROM PropStrength__Applications_Bookings__r ORDER BY PropStrength__Booking_Date__c DESC) FROM Account WHERE Id IN :brokerIds];
                
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
            System.debug('salesManagerIncentiveId: ' + salesManagerIncentiveId);
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
                System.debug('mapOfUserRoleAmountOnPayout*---'+mapOfUserRoleAmountOnPayout);
                PropStrength__Application_Booking__c updateBookRec = PaymentTriggerHandler.updatePercentageBooking1(bookRec, bookingSlabMap.get(bookRec.id), countBookingOnContactMap, countBookingOnBrokerMap,'Incentive Slab',mapOfUserRoleAmountOnPayout, mapOfUserRoleANDPayout); 
                listOfBookingRec.add(updateBookRec); 
            }           
            System.debug('listOfBookingRec*---'+listOfBookingRec);
            if(listOfBookingRec.size() > 0){
                update listOfBookingRec;
            }
        }
    }*/
    public static void incentiveSlabValidation(List<Incentive_Slab__c> newIncentiveList, Map<Id,Incentive_Slab__c> oldIncentiveMap) {
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Map<Id, List<Incentive_Slab__c>> recordTypeIdAndIncentiveList = new Map<Id, List<Incentive_Slab__c>>();
        List<Incentive_Slab__c> existingIncentiveSlab = [SELECT Id, RecordTypeId, Marketing_Category__c, Start_Date__c, End_Date__c, Days_From__c, Days_To__c FROM Incentive_Slab__c WHERE NOT(Id IN :newIncentiveList)];
        for(Incentive_Slab__c rec : existingIncentiveSlab) {
            if(!recordTypeIdAndIncentiveList.containsKey(rec.RecordTypeId)) {
                recordTypeIdAndIncentiveList.put(rec.RecordTypeId, new List<Incentive_Slab__c>());
            }
            recordTypeIdAndIncentiveList.get(rec.RecordTypeId).add(rec);
        }
        
        List<Incentive_Slab__c> needToBeValidate = new List<Incentive_Slab__c> ();
        for(Incentive_Slab__c rec : newIncentiveList) {
            if(oldIncentiveMap == null || (oldIncentiveMap != null && (rec.Start_Date__c != oldIncentiveMap.get(rec.Id).Start_Date__c || rec.End_Date__c != oldIncentiveMap.get(rec.Id).End_Date__c))) {
                needToBeValidate.add(rec);
            }
        }
        
        for(Incentive_Slab__c rec : needToBeValidate) {
            if(recordTypeIdAndIncentiveList.containsKey(rec.RecordTypeId)) {
                for(Incentive_Slab__c existRec : recordTypeIdAndIncentiveList.get(rec.RecordTypeId)) {
                    if(rec.Marketing_Category__c == existRec.Marketing_Category__c 
                       && !(rec.Start_Date__c > existRec.End_Date__c || rec.End_Date__c < existRec.Start_Date__c)
                       && (rec.RecordTypeId != salesManagerIncentiveId 
                           || (rec.RecordTypeId == salesManagerIncentiveId 
                               && ((rec.Days_From__c >= existRec.Days_From__c && rec.Days_From__c <= existRec.Days_To__c)
                                   || (rec.Days_To__c >= existRec.Days_From__c && rec.Days_To__c <= existRec.Days_To__c))))) { 
                                       rec.addError('The Incentive Slab is already existed in given Date Range');
                                   }
                }
            }
        }
    }
}