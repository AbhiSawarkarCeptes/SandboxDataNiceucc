public class AppBookingTriggerHandler { 
   /* public static BookingTriggerSupport.WrapperOfPayoutAndMonths updateIncetiveOnBooking(PropStrength__Application_Booking__c tempBooking, Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec,  
                                                                                         Map<Id, Integer> countBookingOnContactMap, Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap, 
                                                                                         Map<Id, Id> bookingTowerId, Map<Id, PropStrength__Tower__c> towerMap, map<Id,PropStrength__Application_Booking__c> oldMap, 
                                                                                         map<String,boolean> mapOfUserRoleAmountOnPayout,Map<Id, Map<String, Id>> projectIdAndRoleUsermap,Map<Id, 
                                                                                         Map<String, Id>> projectIdAndRoleTeamIdMap,Map<Id, Map<String,Incentive_Month__c>> teamIdWithMonthMap, 
                                                                                         Map<String,Incentive_Month__c> projectIdTeamIdMonthIdAndMonth, Map<String,Decimal> projectIdTeamIdMonthIdAndAmount ) {
                                                                                             Map<Incentive_Month__c, Incentive_Month__c> upsertmonthsMap = new Map<Incentive_Month__c,Incentive_Month__c>();
                                                                                             Map<Integer, String> monthMap = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December' };
                                                                                                 List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
                                                                                             Map<Id, Incentive_Month__c> mapOfMonthsToUpdate = new Map<Id,Incentive_Month__c>();
                                                                                             List<Incentive_Month__c> monthsListToInsert = new List<Incentive_Month__c>();
                                                                                             List<Incentive_Payouts__c> createIncentivePayoutList = new List<Incentive_Payouts__c>();
                                                                                             List<Incentive_Payouts__c> updateIncentivePayoutList = new List<Incentive_Payouts__c>();
                                                                                             String picklistOption1 = 'Differential incentive due created due to change in incentive slab percentage.';
                                                                                             String picklistOption2 = 'Differential incentive due created due to change in area.';
                                                                                             Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
                                                                                             if(tempBooking.Sales_Commission_Eligible_1st_Half__c) {
                                                                                                 //    /******Sales Manager Incentive****           
                                                                                                 Integer days = tempBooking.PropStrength__Booking_Date__c.daysBetween(System.Today());
                                                                                                 Incentive_Slab__c fnlIsRec = new Incentive_Slab__c(); 
                                                                                                 System.debug('--+++mapOfREcordTypeAndinterestSlabRec**---'+mapOfREcordTypeAndinterestSlabRec);
                                                                                                 if(mapOfREcordTypeAndinterestSlabRec != null && mapOfREcordTypeAndinterestSlabRec.containsKey('Sales Manager Incentive')){
                                                                                                     for(Incentive_Slab__c isRec : mapOfREcordTypeAndinterestSlabRec.get('Sales Manager Incentive')) {
                                                                                                         System.debug(days+'-***--'+isRec.Days_From__c+ '**---'+isRec.Start_Date__c+'-*-*-*--'+isRec.End_Date__c);
                                                                                                         if(days >= isRec.Days_From__c && days <= isRec.Days_To__c 
                                                                                                            && tempBooking.createddate >= isRec.Start_Date__c && tempBooking.createddate <= isRec.End_Date__c ) {
                                                                                                                fnlIsRec = isRec;
                                                                                                                break;
                                                                                                            }
                                                                                                     }
                                                                                                 }            
                                                                                                 System.debug('fnlIsRec: ' + fnlIsRec);   
                                                                                                 BookingTriggerSupport.WrapperOfPayoutAndMonths obj = BookingTriggerSupport.createSalesIncentives( tempBooking,  mapOfREcordTypeAndinterestSlabRec,  countBookingOnContactMap, 
                                                                                                                                                                                                  countBookingOnBrokerMap, bookingTowerId,  towerMap, 
                                                                                                                                                                                                  oldMap,  mapOfUserRoleAmountOnPayout,    fnlIsRec, projectIdAndRoleUsermap,projectIdAndRoleTeamIdMap,
                                                                                                                                                                                                  teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount,monthMap);
                                                                                                 createIncentivePayoutList.addall(obj.incentivePayout);
                                                                                                 monthsListToInsert.addall(obj.incentiveMonths);
                                                                                                 
                                                                                                 Boolean createPayoutsFlag = false;
                                                                                                 if(tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
                                                                                                    && ((tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
                                                                                                        || !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
                                                                                                            createPayoutsFlag = true;
                                                                                                        }
                                                                                                 
                                                                                                 //For Channel_Relation_Team_Incentive__c added by Nishank Manwani 08-Jan-2024  
                                                                                                 //  /********************************Channel Partner Incentive************************************************************ 
                                                                                                 BookingTriggerSupport.WrapperOfPayoutAndMonths obj1 =  BookingTriggerSupport.updateIncetiveOnBooking(tempBooking, mapOfREcordTypeAndinterestSlabRec, countBookingOnContactMap, countBookingOnBrokerMap, bookingTowerId,towerMap,oldMap, mapOfUserRoleAmountOnPayout,createPayoutsFlag,projectIdAndRoleUsermap,projectIdAndRoleTeamIdMap,teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount,monthMap);
                                                                                                 createIncentivePayoutList.addall(obj1.incentivePayout);
                                                                                                 monthsListToInsert.addall(obj1.incentiveMonths);
                                                                                                 
                                                                                                 // /********************************Marketing Incentive************************************************************ 
                                                                                                 //For Marketing_Team_Incentive__c added by Nishank Manwani 08-Jan-2024                            
                                                                                                 // Modified code By Gourav Gour 16/05/2024 
                                                                                                 BookingTriggerSupport.WrapperOfPayoutAndMonths obj2 = BookingTriggerSupport.createMarketingIncentive(tempBooking,mapOfREcordTypeAndinterestSlabRec,countBookingOnContactMap,countBookingOnBrokerMap,bookingTowerId,towerMap,oldMap,mapOfUserRoleAmountOnPayout,fnlIsRec,projectIdAndRoleUsermap,projectIdAndRoleTeamIdMap,teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount,createPayoutsFlag,monthMap);
                                                                                                 createIncentivePayoutList.addAll(obj2.incentivePayout);
                                                                                                 
                                                                                                 monthsListToInsert.addAll(obj2.incentiveMonths);
                                                                                                 
                                                                                                 //  /********************************Special Incentive************************************************************ 
                                                                                                 if(mapOfREcordTypeAndinterestSlabRec.containskey('Special Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive').size() > 0 && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Brand_Evangelist_Split__c != null && (tempBooking.PropStrength__Project__r.Special_Incentive_Applicable__c ||  tempBooking.PropStrength__Property__r.Special_Incentive_Applicable__c ||
                                                                                                                                                                                                                                                                                                                                                       tempBooking.PropStrength__Property__r.PropStrength__Tower__r.Special_Incentive_Applicable__c)) {
                                                                                                                                                                                                                                                                                                                                                           if(createPayoutsFlag){
                                                                                                                                                                                                                                                                                                                                                               Decimal amountDifference = ( (tempBooking.Brand_Evangelist_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Brand_Evangelist_Incentive__c ?? 0 ) );
                                                                                                                                                                                                                                                                                                                                                               if(amountDifference > 0){
                                                                                                                                                                                                                                                                                                                                                                   if( tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Brand Evangelist') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist') != null) {
                                                                                                                                                                                                                                                                                                                                                                       system.debug('create 74');
                                                                                                                                                                                                                                                                                                                                                                       tempBooking.Brand_Evangelist__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist');
                                                                                                                                                                                                                                                                                                                                                                       createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,Amount__c = ( amountDifference ), Balance__c = ( amountDifference ) , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'), User_Role__c = 'Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                       if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                                                                                                                                                                                                                                                           Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                                                                                                                                                                                                                                                           mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                           if(mont.id == null){
                                                                                                                                                                                                                                                                                                                                                                               upsertmonthsMap.remove(mont);
                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                           }                      
                                                                                                                                                                                                                                                                                                                                                                           mont.Target_Acheived__c +=  amountDifference ; 
                                                                                                                                                                                                                                                                                                                                                                           upsertmonthsMap.put(mont,mont);    
                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                       }
                                                                                                                                                                                                                                                                                                                                                                       else {
                                                                                                                                                                                                                                                                                                                                                                           Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                           mont.Target_Acheived__c = ( amountDifference ) ;  
                                                                                                                                                                                                                                                                                                                                                                           projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                           upsertmonthsMap.put(mont,mont);
                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                       }
                                                                                                                                                                                                                                                                                                                                                                   } else {
                                                                                                                                                                                                                                                                                                                                                                       system.debug('create 75');
                                                                                                                                                                                                                                                                                                                                                                       createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,Amount__c = ( amountDifference ), Balance__c = ( amountDifference ) , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                   }
                                                                                                                                                                                                                                                                                                                                                               }
                                                                                                                                                                                                                                                                                                                                                               else if(amountDifference < 0){
                                                                                                                                                                                                                                                                                                                                                                   if(mapOfUserRoleAmountOnPayout.containskey( 'Brand Evangelist'  ) && mapOfUserRoleAmountOnPayout.get( 'Brand Evangelist' )){
                                                                                                                                                                                                                                                                                                                                                                       if( tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Brand Evangelist') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist') != null) {
                                                                                                                                                                                                                                                                                                                                                                           system.debug('create 074');
                                                                                                                                                                                                                                                                                                                                                                           tempBooking.Brand_Evangelist__c = towerMap.get(bookingTowerId.get(tempBooking.Id)).Incentive_Teams__r[0].Brand_Evangelist__c;
                                                                                                                                                                                                                                                                                                                                                                           createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,Amount__c = ( amountDifference ), Balance__c = ( amountDifference ) , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'), User_Role__c = 'Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                           if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                                                                                                                                                                                                                                                               Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                                                                                                                                                                                                                                                               mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                               if(mont.id == null){
                                                                                                                                                                                                                                                                                                                                                                                   upsertmonthsMap.remove(mont);
                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                               }                      
                                                                                                                                                                                                                                                                                                                                                                               mont.Target_Acheived__c +=  amountDifference ; 
                                                                                                                                                                                                                                                                                                                                                                               upsertmonthsMap.put(mont,mont);    
                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                           }
                                                                                                                                                                                                                                                                                                                                                                           else {
                                                                                                                                                                                                                                                                                                                                                                               Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                               mont.Target_Acheived__c = ( amountDifference ) ;  
                                                                                                                                                                                                                                                                                                                                                                               projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                               upsertmonthsMap.put(mont,mont);
                                                                                                                                                                                                                                                                                                                                                                           }
                                                                                                                                                                                                                                                                                                                                                                       } else {
                                                                                                                                                                                                                                                                                                                                                                           system.debug('create 075');
                                                                                                                                                                                                                                                                                                                                                                           createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,Amount__c = ( amountDifference ), Balance__c = ( amountDifference ) , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Brand Evangelist'));
                                                                                                                                                                                                                                                                                                                                                                       }
                                                                                                                                                                                                                                                                                                                                                                   }
                                                                                                                                                                                                                                                                                                                                                               }
                                                                                                                                                                                                                                                                                                                                                           }
                                                                                                                                                                                                                                                                                                                                                       }
                                                                                                 
                                                                                             }
                                                                                             if(tempBooking.Sales_Commission_Eligible_2nd_Half__c) {
                                                                                                 
                                                                                                 if(!tempBooking.Incentive_Payouts__r.isEmpty() && (tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.SPA_Executed__c)
                                                                                                    || !tempBooking.PropStrength__Project__r.RERA_Registered__c) {
                                                                                                        for(Incentive_Payouts__c ipRec : tempBooking.Incentive_Payouts__r) {
                                                                                                            Decimal amountDifference = ( (tempBooking.Sales_Manager_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Sales_Manager_Incentive__c ?? 0 ) );
                                                                                                            if(amountDifference > 0){   
                                                                                                                if(ipRec.User_Role__c == 'Sales Manager' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                    if(tempBooking.Sales_Head__c != null) {
                                                                                                                        system.debug('create 76');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                                                                                                    } else{  
                                                                                                                        system.debug('create 77');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                            }
                                                                                                            else if(amountDifference < 0){
                                                                                                                if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Manager' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Manager' )){
                                                                                                                    if(ipRec.User_Role__c == 'Sales Manager' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                        if(tempBooking.Sales_Head__c != null) {
                                                                                                                            system.debug('create 076');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )  ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                                                                                                        } else{
                                                                                                                            system.debug('create 077');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                            //  /** seconadry sales manager  
                                                                                                            if(tempBooking.Secondary_Sales_Manager__c != null){
                                                                                                                amountDifference = ( (tempBooking.Secondary_Sales_Manager_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Secondary_Sales_Manager_Incentive__c ?? 0 ) );
                                                                                                                if(amountDifference > 0){   
                                                                                                                    if(ipRec.User_Role__c == 'Sales Manager' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                        if(tempBooking.Sales_Head__c != null) {
                                                                                                                            system.debug('create 76');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                                                                                                        } else{  
                                                                                                                            system.debug('create 77');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                                else if(amountDifference < 0){
                                                                                                                    if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Manager' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Manager' )){
                                                                                                                        if(ipRec.User_Role__c == 'Sales Manager' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                            if(tempBooking.Sales_Head__c != null) {
                                                                                                                                system.debug('create 076');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )  ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager'));
                                                                                                                            } else{
                                                                                                                                system.debug('create 077');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager'));
                                                                                                                            }
                                                                                                                            updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                            
                                                                                                            
                                                                                                            // /**  
                                                                                                            amountDifference = ( (tempBooking.Sales_Head_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Sales_Head_Incentive__c ?? 0 ) );
                                                                                                            if(amountDifference > 0){   
                                                                                                                if(ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                    if(tempBooking.Sales_Head__c != null) {
                                                                                                                        system.debug('create 76');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                                                                                                    } else{
                                                                                                                        system.debug('create 77');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                            }
                                                                                                            else if(amountDifference < 0){
                                                                                                                if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Head' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Head')){
                                                                                                                    if(ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                        if(tempBooking.Sales_Head__c != null) {
                                                                                                                            system.debug('create 076');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                                                                                                        } else{
                                                                                                                            system.debug('create 077');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                            
                                                                                                            amountDifference = ( (tempBooking.Employee_Referral_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Employee_Referral_Incentive__c ?? 0 ) );
                                                                                                            if(amountDifference > 0){   
                                                                                                                if(ipRec.User_Role__c == 'Employee Referral' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                    if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null) {
                                                                                                                        system.debug('create 76');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c, User_Role__c = 'Employee Referral'));
                                                                                                                    } else{
                                                                                                                        system.debug('create 77');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Employee Referral'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                            }
                                                                                                            else if(amountDifference < 0){
                                                                                                                if(mapOfUserRoleAmountOnPayout.containskey( 'Employee Referral' ) && mapOfUserRoleAmountOnPayout.get( 'Employee Referral')){
                                                                                                                    if(ipRec.User_Role__c == 'Employee Referral' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                        if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null) {
                                                                                                                            system.debug('create 076');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c, User_Role__c = 'Employee Referral'));
                                                                                                                        } else{
                                                                                                                            system.debug('create 077');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Employee Referral'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                            // /* seconadry sales head 
                                                                                                            if(tempBooking.Secondary_Sales_Manager__c != null){
                                                                                                                amountDifference = ( (tempBooking.Secondary_Sales_Head_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Secondary_Sales_Head_Incentive__c ?? 0 ) );
                                                                                                                if(amountDifference > 0){   
                                                                                                                    if(ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                        if(tempBooking.Sales_Head__c != null) {
                                                                                                                            system.debug('create 76');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                                                                                                        } else{
                                                                                                                            system.debug('create 77');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                                else if(amountDifference < 0){
                                                                                                                    if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Head' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Head')){
                                                                                                                        if(ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                                                                                                                            if(tempBooking.Sales_Head__c != null) {
                                                                                                                                system.debug('create 076');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head'));
                                                                                                                            } else{
                                                                                                                                system.debug('create 077');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head'));
                                                                                                                            }
                                                                                                                            updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                            //   /*
                                                                                                            if(ipRec.User_Role__c == 'Sales Director' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                                                                                                amountDifference = ( (tempBooking.Sales_Director_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Sales_Director_Incentive__c ?? 0 ) );
                                                                                                                if(amountDifference > 0){  
                                                                                                                    if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Sales Director') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director') != null ) {
                                                                                                                        system.debug('create 78');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director'), User_Role__c = 'Sales Director'));
                                                                                                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                            
                                                                                                                            if(mont.id == null){
                                                                                                                                upsertmonthsMap.remove(mont);
                                                                                                                                
                                                                                                                            }                      
                                                                                                                            mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                            upsertmonthsMap.put(mont,mont);    
                                                                                                                            
                                                                                                                        }
                                                                                                                        else {
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director'));
                                                                                                                            mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                            
                                                                                                                            upsertmonthsMap.put(mont,mont);
                                                                                                                        }
                                                                                                                        
                                                                                                                    } 
                                                                                                                    else {
                                                                                                                        system.debug('create 79');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                                else if(amountDifference > 0){ 
                                                                                                                    if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Director' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Director')){
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Sales Director') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director') != null ) {
                                                                                                                            system.debug('create 78');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director'), User_Role__c = 'Sales Director'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);     
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont);}
                                                                                                                        } 
                                                                                                                        else {
                                                                                                                            system.debug('create 79');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                                // /* seconadry svp 
                                                                                                                if(tempBooking.Secondary_Sales_Manager__c != null){
                                                                                                                    amountDifference = ( (tempBooking.Secondary_SVP_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Secondary_SVP_Incentive__c ?? 0 ) );
                                                                                                                    if(amountDifference > 0){  
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Sales Director') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director') != null ) {
                                                                                                                            system.debug('create 78');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director'), User_Role__c = 'Sales Director'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);    
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont);}
                                                                                                                        } 
                                                                                                                        else {
                                                                                                                            system.debug('create 79');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                    else if(amountDifference > 0){ 
                                                                                                                        if(mapOfUserRoleAmountOnPayout.containskey( 'Sales Director' ) && mapOfUserRoleAmountOnPayout.get( 'Sales Director')){
                                                                                                                            if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Sales Director') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director') != null ) {
                                                                                                                                system.debug('create 78');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director'), User_Role__c = 'Sales Director'));
                                                                                                                                if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                    mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                    
                                                                                                                                    if(mont.id == null){
                                                                                                                                        upsertmonthsMap.remove(mont);
                                                                                                                                        
                                                                                                                                    }                      
                                                                                                                                    mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                    upsertmonthsMap.put(mont,mont);     
                                                                                                                                }
                                                                                                                                else {
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director'));
                                                                                                                                    mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                    projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                    
                                                                                                                                    upsertmonthsMap.put(mont,mont); }
                                                                                                                            } 
                                                                                                                            else {
                                                                                                                                system.debug('create 79');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director'));
                                                                                                                            }
                                                                                                                            updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                                
                                                                                                                // /* 
                                                                                                            }
                                                                                                            
                                                                                                            if(ipRec.User_Role__c == 'VP Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                                                                                                amountDifference = ( (tempBooking.VP_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).VP_Incentive__c ?? 0 ) );
                                                                                                                if(amountDifference > 0){ 
                                                                                                                    if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('VP Sales') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales') != null) {
                                                                                                                        system.debug('create 80');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales'), User_Role__c = 'VP Sales'));
                                                                                                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                            
                                                                                                                            if(mont.id == null){
                                                                                                                                upsertmonthsMap.remove(mont);
                                                                                                                                
                                                                                                                            }                      
                                                                                                                            mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                            upsertmonthsMap.put(mont,mont);     
                                                                                                                        }
                                                                                                                        else {
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales'));
                                                                                                                            mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                            
                                                                                                                            upsertmonthsMap.put(mont,mont);}
                                                                                                                    } else {
                                                                                                                        system.debug('create 81');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                                else if(amountDifference < 0){
                                                                                                                    if(mapOfUserRoleAmountOnPayout.containskey('VP Sales' ) && mapOfUserRoleAmountOnPayout.get('VP Sales' )){
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('VP Sales') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales') != null ) {
                                                                                                                            system.debug('create 80');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales'), User_Role__c = 'VP Sales'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);     
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont); }
                                                                                                                        } else {
                                                                                                                            system.debug('create 81');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,
                                                                                                                                                                                   All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, 
                                                                                                                                                                                   RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                                if(tempBooking.Secondary_Sales_Manager__c != null){
                                                                                                                    amountDifference = ( (tempBooking.Secondary_VP_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Secondary_VP_Incentive__c ?? 0 ) );
                                                                                                                    if(amountDifference > 0){ 
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('VP Sales') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales') != null ) {
                                                                                                                            system.debug('create 80');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales'), User_Role__c = 'VP Sales'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);    
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont);}
                                                                                                                        } else {
                                                                                                                            system.debug('create 81');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                    else if(amountDifference < 0){
                                                                                                                        if(mapOfUserRoleAmountOnPayout.containskey('VP Sales' ) && mapOfUserRoleAmountOnPayout.get('VP Sales' )){
                                                                                                                            if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('VP Sales') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales') != null ) {
                                                                                                                                system.debug('create 80');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales'), User_Role__c = 'VP Sales'));
                                                                                                                                if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                    mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                    
                                                                                                                                    if(mont.id == null){
                                                                                                                                        upsertmonthsMap.remove(mont);
                                                                                                                                        
                                                                                                                                    }                      
                                                                                                                                    mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                    upsertmonthsMap.put(mont,mont);    
                                                                                                                                }
                                                                                                                                else {
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales'));
                                                                                                                                    mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                    projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                    
                                                                                                                                    upsertmonthsMap.put(mont,mont);
                                                                                                                                }
                                                                                                                            } else {
                                                                                                                                system.debug('create 81');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales'));
                                                                                                                            }
                                                                                                                            updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                        }
                                                                                                                    }
                                                                                                                    
                                                                                                                    
                                                                                                                }
                                                                                                                
                                                                                                            }
                                                                                                            
                                                                                                            if(ipRec.User_Role__c == 'CSO Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                                                                                                                amountDifference = ( (tempBooking.CSO_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).CSO_Incentive__c ?? 0 ) );
                                                                                                                if(amountDifference > 0){ 
                                                                                                                    if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CSO') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO') != null) {
                                                                                                                        system.debug('create 82');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO'), User_Role__c = 'CSO Sales'));
                                                                                                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                            
                                                                                                                            if(mont.id == null){
                                                                                                                                upsertmonthsMap.remove(mont);
                                                                                                                                
                                                                                                                            }                      
                                                                                                                            mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                            upsertmonthsMap.put(mont,mont);     
                                                                                                                        }
                                                                                                                        else {
                                                                                                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO'));
                                                                                                                            mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                            
                                                                                                                            upsertmonthsMap.put(mont,mont); }
                                                                                                                    } else {
                                                                                                                        system.debug('create 83');
                                                                                                                        createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                                                                                                    }
                                                                                                                    updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                }
                                                                                                                else if(amountDifference < 0){
                                                                                                                    if(mapOfUserRoleAmountOnPayout.containskey( 'CSO Sales' ) && mapOfUserRoleAmountOnPayout.get( 'CSO Sales' )){
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CSO') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO') != null ) {
                                                                                                                            system.debug('create 82');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO'), User_Role__c = 'CSO Sales'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);     
                                                                                                                                
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont);}
                                                                                                                        } else {
                                                                                                                            system.debug('create 83');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                }
                                                                                                                
                                                                                                                //  /*  seconadry cso  incentive 
                                                                                                                if(tempBooking.Secondary_Sales_Manager__c != null){
                                                                                                                    amountDifference = ( (tempBooking.Secondary_CSO_Incentive__c ?? 0 ) - (oldMap.get(tempBooking.Id).Secondary_CSO_Incentive__c ?? 0 ) );
                                                                                                                    if(amountDifference > 0){ 
                                                                                                                        if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CSO') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO') != null ) {
                                                                                                                            system.debug('create 82');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO'), User_Role__c = 'CSO Sales'));
                                                                                                                            if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                
                                                                                                                                if(mont.id == null){
                                                                                                                                    upsertmonthsMap.remove(mont);
                                                                                                                                    
                                                                                                                                }                      
                                                                                                                                mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                upsertmonthsMap.put(mont,mont);     
                                                                                                                                
                                                                                                                            }
                                                                                                                            else {
                                                                                                                                Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO'));
                                                                                                                                mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                
                                                                                                                                upsertmonthsMap.put(mont,mont);  }
                                                                                                                        } else {
                                                                                                                            system.debug('create 83');
                                                                                                                            createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                                                                                                        }
                                                                                                                        updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                    }
                                                                                                                    else if(amountDifference < 0){
                                                                                                                        if(mapOfUserRoleAmountOnPayout.containskey( 'CSO Sales' ) && mapOfUserRoleAmountOnPayout.get( 'CSO Sales' )){
                                                                                                                            if(tempBooking.PropStrength__Project__c != null && projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CSO') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO') != null ) {
                                                                                                                                system.debug('create 82');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO'), User_Role__c = 'CSO Sales'));
                                                                                                                                if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                    mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                    
                                                                                                                                    if(mont.id == null){
                                                                                                                                        upsertmonthsMap.remove(mont);
                                                                                                                                        
                                                                                                                                    }                      
                                                                                                                                    mont.Target_Acheived__c +=  (amountDifference)/2 ; 
                                                                                                                                    upsertmonthsMap.put(mont,mont);     
                                                                                                                                    
                                                                                                                                }
                                                                                                                                else {
                                                                                                                                    Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO'));
                                                                                                                                    mont.Target_Acheived__c = ( amountDifference )/2 ;  
                                                                                                                                    projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                    
                                                                                                                                    upsertmonthsMap.put(mont,mont);
                                                                                                                                }
                                                                                                                            } else {
                                                                                                                                system.debug('create 83');
                                                                                                                                createIncentivePayoutList.add(new Incentive_Payouts__c( Differential_Incentive_Due__c = true , Differential_Incentive_Remarks__c = tempBooking.Incentive_Update_Option__c == 'Incentive Slab' ?  picklistOption1 : ( tempBooking.Incentive_Update_Option__c != null ? picklistOption1 : '' )   ,All_Payment_Of_Sale_Inn__c = true, Amount__c = ( amountDifference )/2,Balance__c = ( amountDifference )/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales'));
                                                                                                                            }
                                                                                                                            updateIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                                // /* 
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                             }
                                                                                             
                                                                                             System.debug('updateBookingPerc****'+updateBookingPerc);
                                                                                             
                                                                                             System.debug('createIncentivePayoutList****'+createIncentivePayoutList);
                                                                                             BookingTriggerSupport.WrapperOfPayoutAndMonths obj = new BookingTriggerSupport.WrapperOfPayoutAndMonths();
                                                                                             obj.incentivePayout = createIncentivePayoutList;
                                                                                             if(upsertmonthsMap.size() > 0){
                                                                                                 monthsListToInsert.addAll(upsertmonthsMap.values());
                                                                                             }
                                                                                             obj.incentiveMonths = monthsListToInsert;
                                                                                             return obj;
                                                                                             //return createIncentivePayoutList;       
                                                                                         }*/
   /* public static BookingTriggerSupport.wrapper createIncetiveOnBooking(PropStrength__Application_Booking__c tempBooking, Map<String, List<Incentive_Slab__c>> mapOfREcordTypeAndinterestSlabRec,  Map<Id, Integer> countBookingOnContactMap, Map<Id, List<PropStrength__Application_Booking__c>> countBookingOnBrokerMap,Map<Id, Id> bookingTowerId, Map<Id, PropStrength__Tower__c> towerMap,Map<Id, Map<String, Id>> projectIdAndRoleUsermap,Map<Id, Map<String, Id>> projectIdAndRoleTeamIdMap,Map<Id, Map<String,Incentive_Month__c>> teamIdWithMonthMap, Map<String,Incentive_Month__c> projectIdTeamIdMonthIdAndMonth, Map<String,Double> projectIdTeamIdMonthIdAndAmount ) {
        system.debug('inside createIncetiveOnBooking ');
        Map<Incentive_Month__c,Incentive_Month__c> upsertmonthsMap = new Map<Incentive_Month__c,Incentive_Month__c>();
        Map<Integer, String> monthMap = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December' };
            
            List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
        Map<Id, Incentive_Month__c> mapOfMonthsToUpdate = new Map<Id,Incentive_Month__c>();
        List<Incentive_Month__c> monthsListToInsert = new List<Incentive_Month__c>();
        List<Incentive_Payouts__c> createIncentivePayoutList = new List<Incentive_Payouts__c>();
        List<Incentive_Payouts__c> updateIncentivePayoutList = new List<Incentive_Payouts__c>();
        String picklistOption1 = 'Differential incentive due created due to change in incentive slab percentage.';
        String picklistOption2 = 'Differential incentive due created due to change in area.';
        Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
        if(tempBooking.X10_Payment_Received_Date__c != null && ( (tempBooking.Sales_Commission_Eligible_1st_Half__c != null && tempBooking.Sales_Commission_Eligible_1st_Half__c == false) ||(tempBooking.Marketing_CP_Commission_Eligible__c != null &&  tempBooking.Marketing_CP_Commission_Eligible__c == false )) ) {
            // /********************************Sales Manager Incentive************************************************************ 
            if(true) {
                Integer days = tempBooking.PropStrength__Booking_Date__c != null ? tempBooking.PropStrength__Booking_Date__c.daysBetween(System.Today()) : null;
                
                Incentive_Slab__c fnlIsRec = new Incentive_Slab__c(); 
                System.debug('--+++mapOfREcordTypeAndinterestSlabRec**---'+mapOfREcordTypeAndinterestSlabRec);
                if(mapOfREcordTypeAndinterestSlabRec != null && mapOfREcordTypeAndinterestSlabRec.containsKey('Sales Manager Incentive')){
                    for(Incentive_Slab__c isRec : mapOfREcordTypeAndinterestSlabRec.get('Sales Manager Incentive')) {
                        System.debug(days+'-***--'+isRec.Days_From__c+ '**---'+isRec.Start_Date__c+'-*-*-*--'+isRec.End_Date__c);
                        if(days != null && isRec.Days_From__c != null && isRec.Days_To__c != null && days >= isRec.Days_From__c && days <= isRec.Days_To__c 
                           && isRec.Start_Date__c != null    && tempBooking.createddate >= isRec.Start_Date__c &&  isRec.End_Date__c != null && tempBooking.createddate <= isRec.End_Date__c ) {
                               fnlIsRec = isRec;
                               break;
                           }
                    }
                }
                
                
                System.debug('fnlIsRec: ' + fnlIsRec);
                
                if(fnlIsRec != null  && fnlIsRec.id != null && tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null) {
                    
                    BookingTriggerSupport.wrapper obj = BookingTriggerSupport.createSalesIncentiveWithoutDifference(tempBooking,mapOfREcordTypeAndinterestSlabRec,countBookingOnContactMap,countBookingOnBrokerMap,bookingTowerId,towerMap,projectIdAndRoleUsermap,projectIdAndRoleTeamIdMap,teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount,monthMap);
                    createIncentivePayoutList.addAll(obj.incentivePayout);
                    
                    monthsListToInsert.addAll(obj.incentiveMonth);
                    tempbooking = obj.tempbooking;
                }
                
                Boolean createPayoutsFlag = false;
                if(tempBooking.X10_Payment_Received_Date__c != null && tempBooking.Booking_Form_Verified__c && tempBooking.Oqood_Fees_Received__c 
                   && ((tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.DLD_Fees_Received__c != null && tempBooking.DLD_Fees_Due__c != null && tempBooking.DLD_Fees_Received__c >= tempBooking.DLD_Fees_Due__c)
                       || !tempBooking.PropStrength__Project__r.RERA_Registered__c)) {
                           createPayoutsFlag = true;
                       }
                if(tempBooking.Marketing_CP_Commission_Eligible__c == false ){
                    //For Channel_Relation_Team_Incentive__c added by Nishank Manwani 08-Jan-2024  
                    //  /********************************Channel Partner Incentive************************************************************ *                       
                    // chsnnel partner incentives without difference
                    BookingTriggerSupport.wrapper obj = BookingTriggerSupport.createChannelPartnerPayoutsWithoutDifference(tempBooking,mapOfREcordTypeAndinterestSlabRec,countBookingOnContactMap,countBookingOnBrokerMap,bookingTowerId,towerMap,projectIdAndRoleUsermap,projectIdAndRoleTeamIdMap,teamIdWithMonthMap,projectIdTeamIdMonthIdAndMonth,projectIdTeamIdMonthIdAndAmount,createPayoutsFlag,monthMap);
                    createIncentivePayoutList.addAll(obj.incentivePayout);            
                    monthsListToInsert.addAll(obj.incentiveMonth);
                    tempbooking = obj.tempbooking;
                    //   /********************************Marketing Incentive************************************************************ 
                    //For Marketing_Team_Incentive__c added by Nishank Manwani 08-Jan-2024                            
                    // Modified code By Gourav Gour 16/05/2024 
                    Map<String, Incentive_Slab__c> slabVsCategoryMap = new Map<String, Incentive_Slab__c>();
                    for(Incentive_Slab__c slab : mapOfREcordTypeAndinterestSlabRec.get('Marketing Incentive')) {
                        if(slab.Marketing_Category__c != null && !slabVsCategoryMap.containsKey(slab.Marketing_Category__c)) {
                            slabVsCategoryMap.put(slab.Marketing_Category__c, slab);
                        }
                    }
                    if(tempBooking.PropStrength__Offer__c != null && tempBooking.PropStrength__Offer__r.PropStrength__Request__c != null) {
                        Incentive_Slab__c iss;
                        if(tempBooking.PropStrength__Discount_Type__c == 'Loyalty Sales' && tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Loyalty Sales') {
                            if(slabVsCategoryMap.containsKey('Loyalty Sales') && (tempBooking.PropStrength__Discount__c == null ||(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Discount__c == 0.00))) {
                                iss = slabVsCategoryMap.get('Loyalty Sales');
                                tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales').Id;
                            }
                            else if(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Project__c != null && tempBooking.PropStrength__Property_Type__r.Loyalty_Discount__c != null) {
                                if(slabVsCategoryMap.containsKey('Loyalty Sales (saving 1% on discount)') && (tempBooking.PropStrength__Property_Type__r.Loyalty_Discount__c - tempBooking.PropStrength__Discount__c) >= 1.0) {
                                    iss = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)');
                                    tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)').Id;
                                }  
                                else if(slabVsCategoryMap.containsKey('Loyalty Sales (with discount)') && 
                                        (tempBooking.PropStrength__Property_Type__r.Loyalty_Discount__c - tempBooking.PropStrength__Discount__c) < 1.0 && 
                                        (tempBooking.PropStrength__Property_Type__r.Loyalty_Discount__c - tempBooking.PropStrength__Discount__c) >= 0 ) {
                                            iss = slabVsCategoryMap.get('Loyalty Sales (with discount)');
                                            tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (with discount)').Id;
                                        }
                            }
                        }
                        else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Mall Stands/Kiosks Sales' || tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Stand Leads') {
                            if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c == null && slabVsCategoryMap.containsKey('Mall Stands/Kiosks Sales')) {
                                iss = slabVsCategoryMap.get('Mall Stands/Kiosks Sales');
                                tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Mall Stands/Kiosks Sales').Id;
                            }
                            else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Presales_Agent__c != null && slabVsCategoryMap.containsKey('Mall Stands/Kiosks Sales (with Telesales)')) {
                                iss = slabVsCategoryMap.get('Mall Stands/Kiosks Sales (with Telesales)');
                                tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Mall Stands/Kiosks Sales (with Telesales)').Id;
                            }
                            
                        }
                        else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Telesales' && slabVsCategoryMap.containsKey('Telesales')) {
                            iss = slabVsCategoryMap.get('Telesales');
                            tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Telesales').Id;
                        }
                        else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Walk-in' && slabVsCategoryMap.containsKey('Direct Walk-in')) {
                            iss = slabVsCategoryMap.get('Direct Walk-in');
                            tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Direct Walk-in').Id;
                        }
                        else if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Digital Platform' && slabVsCategoryMap.containsKey('Digital Marketing Sales (Inc. Influencer)')) {
                            iss = slabVsCategoryMap.get('Digital Marketing Sales (Inc. Influencer)');
                            tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Digital Marketing Sales (Inc. Influencer)').Id;
                        }
                        if(iss != null) {
                            if(iss.Marketing_Incentive__c != null) {                           
                                
                                // Added For Gourav Gour 15/05/2024
                                if(createPayoutsFlag) {
                                    // if(Marketing_Incentive_Slab__c!=null){
                                    
                                    // }
                                    if(tempBooking.CMO_Marketing_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CMO - Marketing') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.CMO_Marketing_Incentive__c, Balance__c = tempBooking.CMO_Marketing_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing'), User_Role__c = 'CMO Marketing'  , Total_Incentive_Amount__c = tempBooking.CMO_Marketing_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.CMO_Marketing_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.CMO_Marketing_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CMO - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont); 
                                        }
                                    } else if(tempBooking.CMO_Marketing_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.CMO_Marketing_Incentive__c, Balance__c = tempBooking.CMO_Marketing_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CMO Marketing', Total_Incentive_Amount__c = tempBooking.CMO_Marketing_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    if(tempBooking.GM_Marketing_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('GM - Marketing') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.GM_Marketing_Incentive__c, Balance__c = tempBooking.GM_Marketing_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing'), User_Role__c = 'GM Marketing', Total_Incentive_Amount__c = tempBooking.GM_Marketing_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.GM_Marketing_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.GM_Marketing_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('GM - Marketing')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont); 
                                        }
                                    } else if(tempBooking.GM_Marketing_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.GM_Marketing_Incentive__c, Balance__c = tempBooking.GM_Marketing_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'GM Marketing', Total_Incentive_Amount__c = tempBooking.GM_Marketing_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    //
                                    
                                    if(tempBooking.Loyalty_Sales_Executive_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Loyalty Sales Executive') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Loyalty_Sales_Executive_Incentive__c, Balance__c = tempBooking.Loyalty_Sales_Executive_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive'), User_Role__c = 'Loyalty Sale Executive', Total_Incentive_Amount__c = tempBooking.Loyalty_Sales_Executive_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Loyalty_Sales_Executive_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Loyalty_Sales_Executive_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Loyalty Sales Executive')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont); 
                                        }
                                    } else if(tempBooking.Loyalty_Sales_Executive_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Loyalty_Sales_Executive_Incentive__c, Balance__c = tempBooking.Loyalty_Sales_Executive_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Loyalty Sale Executive', Total_Incentive_Amount__c = tempBooking.Loyalty_Sales_Executive_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Marketing_Head_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Marketing Head') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Marketing Head') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Marketing_Head_Incentive__c, Balance__c = tempBooking.Marketing_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Marketing Head'), User_Role__c = 'Marketing Head', Total_Incentive_Amount__c = tempBooking.Marketing_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Marketing_Head_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Marketing Head'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Marketing_Head_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont); 
                                        }
                                        
                                    } else if(tempBooking.Marketing_Head_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Marketing_Head_Incentive__c, Balance__c = tempBooking.Marketing_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Marketing Head', Total_Incentive_Amount__c = tempBooking.Marketing_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Promoter_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Promoter') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Promoter') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Promoter_Incentive__c, Balance__c = tempBooking.Promoter_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Promoter'), User_Role__c = 'Promoter', Total_Incentive_Amount__c = tempBooking.Promoter_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Promoter')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Promoter')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Promoter_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Promoter'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Promoter_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Promoter')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont); 
                                        }
                                    } else if(tempBooking.Promoter_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Promoter_Incentive__c, Balance__c = tempBooking.Promoter_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Promoter', Total_Incentive_Amount__c = tempBooking.Promoter_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Mall_Team_Lead_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Mall Team Lead') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Mall_Team_Lead_Incentive__c, Balance__c = tempBooking.Mall_Team_Lead_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead'), User_Role__c = 'Mall Team Lead', Total_Incentive_Amount__c = tempBooking.Mall_Team_Lead_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Mall_Team_Lead_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Mall_Team_Lead_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Mall Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.Mall_Team_Lead_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Mall_Team_Lead_Incentive__c, Balance__c = tempBooking.Mall_Team_Lead_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Mall Team Lead', Total_Incentive_Amount__c = tempBooking.Mall_Team_Lead_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.TeleSales_Agent_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('TeleSales Agent') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.TeleSales_Agent_Incentive__c, Balance__c = tempBooking.TeleSales_Agent_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent'), User_Role__c = 'TeleSales Agent', Total_Incentive_Amount__c = tempBooking.TeleSales_Agent_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.TeleSales_Agent_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent'));
                                            mont.Target_Acheived__c = (tempBooking.TeleSales_Agent_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Agent')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.TeleSales_Agent_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.TeleSales_Agent_Incentive__c, Balance__c = tempBooking.TeleSales_Agent_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TeleSales Agent', Total_Incentive_Amount__c = tempBooking.TeleSales_Agent_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Campaign_Manager_Influence_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Campaign Manager Influence') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Campaign_Manager_Influence_Incentive__c, Balance__c = tempBooking.Campaign_Manager_Influence_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence'), User_Role__c = 'Campaign Manager Influence', Total_Incentive_Amount__c = tempBooking.Campaign_Manager_Influence_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Campaign_Manager_Influence_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Campaign_Manager_Influence_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Campaign Manager Influence')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.Campaign_Manager_Influence_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Campaign_Manager_Influence_Incentive__c, Balance__c = tempBooking.Campaign_Manager_Influence_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Campaign Manager Influence', Total_Incentive_Amount__c = tempBooking.Campaign_Manager_Influence_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Digital_Marketing_Head_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Digital Marketing Head') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Digital_Marketing_Head_Incentive__c, Balance__c = tempBooking.Digital_Marketing_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head'), User_Role__c = 'Digital Marketing Head', Total_Incentive_Amount__c = tempBooking.Digital_Marketing_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Digital_Marketing_Head_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Digital_Marketing_Head_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Digital Marketing Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.Digital_Marketing_Head_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Digital_Marketing_Head_Incentive__c, Balance__c = tempBooking.Digital_Marketing_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Digital Marketing Head', Total_Incentive_Amount__c = tempBooking.Digital_Marketing_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.Team_Lead_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Team Lead') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Team Lead') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Team_Lead_Incentive__c, Balance__c = tempBooking.Team_Lead_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Team Lead'), User_Role__c = 'Team Lead', Total_Incentive_Amount__c = tempBooking.Team_Lead_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.Team_Lead_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Team Lead'));
                                            
                                            mont.Target_Acheived__c = (tempBooking.Team_Lead_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Team Lead')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.Team_Lead_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Team_Lead_Incentive__c, Balance__c = tempBooking.Team_Lead_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Team Lead', Total_Incentive_Amount__c = tempBooking.Team_Lead_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                    }
                                    
                                    if(tempBooking.TeleSales_Head_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('TeleSales Head') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head') != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.TeleSales_Head_Incentive__c , Balance__c = tempBooking.TeleSales_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head'), User_Role__c = 'TeleSales Head', Total_Incentive_Amount__c = tempBooking.TeleSales_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c));
                                        
                                        if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                            Incentive_Month__c mont = new Incentive_Month__c(); 
                                            mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                            
                                            if(mont.id == null){
                                                upsertmonthsMap.remove(mont);
                                                
                                            }                      
                                            mont.Target_Acheived__c += (tempBooking.TeleSales_Head_Incentive__c); 
                                            upsertmonthsMap.put(mont,mont);
                                            
                                        }
                                        else {
                                            Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head'));
                                            mont.Target_Acheived__c = (tempBooking.TeleSales_Head_Incentive__c);  
                                            projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('TeleSales Head')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                            
                                            upsertmonthsMap.put(mont,mont);
                                        }
                                    } else if(tempBooking.TeleSales_Head_Incentive__c != null) {
                                        tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                        createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.TeleSales_Head_Incentive__c , Balance__c = tempBooking.TeleSales_Head_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'TeleSales Head', Total_Incentive_Amount__c = tempBooking.TeleSales_Head_Incentive__c , IncentiveSlab__c = tempBooking.Marketing_Incentive_Slab__c ));
                                    }
                                }
                            }
                        }
                        
                    }                        
                    
                    //  /********************************Special Incentive************************************************************ 
                    if(mapOfREcordTypeAndinterestSlabRec.containskey('Special Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive').size() > 0 && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Brand_Evangelist_Split__c != null && (tempBooking.PropStrength__Project__r.Special_Incentive_Applicable__c || tempBooking.PropStrength__Property__r.Special_Incentive_Applicable__c ||
                                                                                                                                                                                                                                                                          tempBooking.PropStrength__Property__r.PropStrength__Tower__r.Special_Incentive_Applicable__c)) {
                                                                                                                                                                                                                                                                              // if(Brand_Evangelist_Incentive_Slab__c!=null){
                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                              // }
                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                              if(mapOfREcordTypeAndinterestSlabRec.containskey('Special Incentive') && mapOfREcordTypeAndinterestSlabRec.get('Special Incentive').size() > 0 )
                                                                                                                                                                                                                                                                                  tempBooking.Brand_Evangelist_Incentive_Slab__c = mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Id;
                                                                                                                                                                                                                                                                              tempBooking.Brand_Evangelist_Incentive__c = (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c * mapOfREcordTypeAndinterestSlabRec.get('Special Incentive')[0].Brand_Evangelist_Split__c)/100;
                                                                                                                                                                                                                                                                              if(tempBooking.Brand_Evangelist_Incentive__c != null && tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Brand Evangelist') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist') != null) {
                                                                                                                                                                                                                                                                                  tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                                                                                                                                                                                                                                                                  tempBooking.Brand_Evangelist__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist');
                                                                                                                                                                                                                                                                                  createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Brand_Evangelist_Incentive__c, Balance__c = tempBooking.Brand_Evangelist_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'), User_Role__c = 'Brand Evangelist', Total_Incentive_Amount__c = tempBooking.Brand_Evangelist_Incentive__c , IncentiveSlab__c = tempBooking.Brand_Evangelist_Incentive_Slab__c));
                                                                                                                                                                                                                                                                                  if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                                                                                                                                                                                                                                                                      Incentive_Month__c mont = new Incentive_Month__c(); 
                                                                                                                                                                                                                                                                                      mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                      if(mont.id == null){
                                                                                                                                                                                                                                                                                          upsertmonthsMap.remove(mont);
                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                      }                      
                                                                                                                                                                                                                                                                                      mont.Target_Acheived__c += (tempBooking.Brand_Evangelist_Incentive__c); 
                                                                                                                                                                                                                                                                                      upsertmonthsMap.put(mont,mont);
                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                  else {
                                                                                                                                                                                                                                                                                      Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist'));
                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                      mont.Target_Acheived__c = (tempBooking.Brand_Evangelist_Incentive__c);  
                                                                                                                                                                                                                                                                                      projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Brand Evangelist')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                      upsertmonthsMap.put(mont,mont);
                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                              } else if(tempBooking.Brand_Evangelist_Incentive__c != null && createPayoutsFlag) {
                                                                                                                                                                                                                                                                                  tempBooking.Marketing_CP_Commission_Eligible__c = true;
                                                                                                                                                                                                                                                                                  createIncentivePayoutList.add(new Incentive_Payouts__c(Amount__c = tempBooking.Brand_Evangelist_Incentive__c, Balance__c = tempBooking.Brand_Evangelist_Incentive__c, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Brand Evangelist', Total_Incentive_Amount__c = tempBooking.Brand_Evangelist_Incentive__c , IncentiveSlab__c = tempBooking.Brand_Evangelist_Incentive_Slab__c));
                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                          }
                }
            }
        }
        if(tempBooking.X20_Payment_Received_Date__c != null && tempBooking.Sales_Commission_Eligible_2nd_Half__c == false) {            
            if(!tempBooking.Incentive_Payouts__r.isEmpty() && (tempBooking.PropStrength__Project__r.RERA_Registered__c && tempBooking.SPA_Executed__c)
               || !tempBooking.PropStrength__Project__r.RERA_Registered__c) {
                   Boolean SalesManagerFlag = true;
                   Boolean SalesHeadFlag = true;
                   Boolean SalesDirectorFlag = true;
                   Boolean VPSalesFlag = true;
                   Boolean CSOSalesFlag = true;
                   
                   for(Incentive_Payouts__c ipRec : tempBooking.Incentive_Payouts__r) {                      
                       if( ipRec.User_Role__c == 'Sales Head' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                           if(SalesManagerFlag && tempBooking.Sales_Head_Incentive__c != null){
                               if(tempBooking.Sales_Head__c != null) {
                                   SalesManagerFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Head_Incentive__c/2, Balance__c = tempBooking.Sales_Head_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Head',Total_Incentive_Amount__c = tempBooking.Sales_Head_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               } else {
                                   SalesManagerFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Head_Incentive__c/2, Balance__c = tempBooking.Sales_Head_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Head',Total_Incentive_Amount__c = tempBooking.Sales_Head_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               }                               
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                       if( ipRec.User_Role__c == 'Employee Referral' && !ipRec.All_Payment_Of_Sale_Inn__c ) {
                           if(SalesManagerFlag && tempBooking.Employee_Referral_Incentive__c != null){
                               if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c != null) {
                                   SalesManagerFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Employee_Referral_Incentive__c/2, Balance__c = tempBooking.Employee_Referral_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.PropStrength__Offer__r.PropStrength__Request__r.Referred_By__c, User_Role__c = 'Employee Referral',Total_Incentive_Amount__c = tempBooking.Employee_Referral_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               } else {
                                   SalesManagerFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Employee_Referral_Incentive__c/2, Balance__c = tempBooking.Employee_Referral_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Employee Referral',Total_Incentive_Amount__c = tempBooking.Employee_Referral_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               }                               
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                       if( ipRec.User_Role__c == 'Sales Manager' && !ipRec.All_Payment_Of_Sale_Inn__c) {   
                           if(SalesHeadFlag){
                               if(tempBooking.Sales_Manager__c != null && tempBooking.Sales_Manager_Incentive__c != null) {
                                   SalesHeadFlag = false;
                                   system.debug('inside second if ');
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Manager_Incentive__c / 2 , Balance__c = tempBooking.Sales_Manager_Incentive__c / 2 , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = tempBooking.Sales_Head__c, User_Role__c = 'Sales Manager',Total_Incentive_Amount__c = tempBooking.Sales_Manager_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               } else if(tempBooking.Sales_Manager_Incentive__c != null){
                                   SalesHeadFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Manager_Incentive__c / 2 , Balance__c = tempBooking.Sales_Manager_Incentive__c / 2 , Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Manager',Total_Incentive_Amount__c = tempBooking.Sales_Manager_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               }
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                       
                       if(ipRec.User_Role__c == 'Sales Director' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                           if(SalesDirectorFlag && tempBooking.Sales_Director_Incentive__c != null){
                               if(tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('Sales Director') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director') != null) {
                                   SalesDirectorFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Director_Incentive__c/2, Balance__c = tempBooking.Sales_Director_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('Sales Director'), User_Role__c = 'Sales Director',Total_Incentive_Amount__c = tempBooking.Sales_Director_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                                   if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                       Incentive_Month__c mont = new Incentive_Month__c(); 
                                       mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                       
                                       if(mont.id == null){
                                           upsertmonthsMap.remove(mont);
                                           
                                       }                      
                                       mont.Target_Acheived__c += (tempBooking.Sales_Director_Incentive__c); 
                                       upsertmonthsMap.put(mont,mont);
                                       
                                   }
                                   else {
                                       Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director'));
                                       
                                       mont.Target_Acheived__c = (tempBooking.Sales_Director_Incentive__c)/2;  
                                       projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('Sales Director')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                       
                                       upsertmonthsMap.put(mont,mont);
                                   }
                               } else {
                                   SalesDirectorFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.Sales_Director_Incentive__c/2, Balance__c = tempBooking.Sales_Director_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'Sales Director',Total_Incentive_Amount__c = tempBooking.Sales_Director_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               }
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                       
                       if(ipRec.User_Role__c == 'VP Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                           if(VPSalesFlag && tempBooking.VP_Incentive__c != null){
                               if(tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('VP Sales') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales') != null) {
                                   VPSalesFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.VP_Incentive__c/2, Balance__c = tempBooking.VP_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('VP Sales'), User_Role__c = 'VP Sales',Total_Incentive_Amount__c = tempBooking.VP_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                                   if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                       Incentive_Month__c mont = new Incentive_Month__c(); 
                                       mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                       
                                       if(mont.id == null){
                                           upsertmonthsMap.remove(mont);
                                           
                                       }                      
                                       mont.Target_Acheived__c += (tempBooking.VP_Incentive__c); 
                                       upsertmonthsMap.put(mont,mont);
                                       
                                   }
                                   else {
                                       Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales'));
                                       
                                       mont.Target_Acheived__c = (tempBooking.VP_Incentive__c)/2;  
                                       projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('VP Sales')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                       
                                       upsertmonthsMap.put(mont,mont);
                                   }
                               } else {
                                   VPSalesFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.VP_Incentive__c/2, Balance__c = tempBooking.VP_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'VP Sales',Total_Incentive_Amount__c = tempBooking.VP_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               }
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                       
                       if(ipRec.User_Role__c == 'CSO Sales' && !ipRec.All_Payment_Of_Sale_Inn__c) {
                           if(CSOSalesFlag && tempBooking.CSO_Incentive__c != null){
                               if(tempBooking.PropStrength__Project__c != null &&  projectIdAndRoleUsermap.containsKey(tempBooking.PropStrength__Project__c) &&  projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).containsKey('CSO') && projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO') != null) {
                                   CSOSalesFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.CSO_Incentive__c/2, Balance__c = tempBooking.CSO_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), Payable_To__c = projectIdAndRoleUsermap.get(tempBooking.PropStrength__Project__c).get('CSO'), User_Role__c = 'CSO Sales',Total_Incentive_Amount__c = tempBooking.CSO_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                                   if(projectIdTeamIdMonthIdAndMonth.containsKey(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year()  )){
                                       Incentive_Month__c mont = new Incentive_Month__c(); 
                                       mont = projectIdTeamIdMonthIdAndMonth.get(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year());
                                       if(mont.id == null){
                                           upsertmonthsMap.remove(mont);
                                           
                                       }                      
                                       mont.Target_Acheived__c += (tempBooking.CSO_Incentive__c); 
                                       upsertmonthsMap.put(mont,mont);
                                       
                                   }
                                   else {
                                       Incentive_Month__c mont = new Incentive_Month__c(Name = monthMap.get(system.today().month())+' '+System.today().year(), Incentive_Team_Member__c = projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO'));
                                       
                                       mont.Target_Acheived__c = (tempBooking.CSO_Incentive__c)/2;  
                                       projectIdTeamIdMonthIdAndMonth.put(tempBooking.PropStrength__Project__c+' '+projectIdAndRoleTeamIdMap.get(tempBooking.PropStrength__Project__c).get('CSO')+' '+monthMap.get(system.today().month())+ ' '+ system.today().year(),mont);
                                       
                                       upsertmonthsMap.put(mont,mont);
                                   }
                               } else {
                                   CSOSalesFlag = false;
                                   tempBooking.Sales_Commission_Eligible_2nd_Half__c = true;
                                   createIncentivePayoutList.add(new Incentive_Payouts__c(All_Payment_Of_Sale_Inn__c = true, Amount__c = tempBooking.CSO_Incentive__c/2, Balance__c = tempBooking.CSO_Incentive__c/2, Application_Booking__c = tempBooking.Id, RecordTypeId = incentiveDueRecTypeId, Payment_Date__c = System.Today(), User_Role__c = 'CSO Sales',Total_Incentive_Amount__c = tempBooking.CSO_Incentive__c , IncentiveSlab__c = tempBooking.Sales_Incentive_Slab__c));
                               } 
                           }
                           createIncentivePayoutList.add(new Incentive_Payouts__c(Id = ipRec.Id, All_Payment_Of_Sale_Inn__c = true));
                       }
                   }
               }
        } 
        BookingTriggerSupport.wrapper wrap = new BookingTriggerSupport.wrapper();
        wrap.incentivePayout = createIncentivePayoutList;
        wrap.incentiveMonth = upsertmonthsMap.values();
        wrap.tempBooking = tempBooking;
        return wrap;                
    } */
    public  Class wrapper{
        public List<Incentive_Payouts__c> incentivePayout;
        public PropStrength__Application_Booking__c tempBooking;
    }
    
    public static void sendToMobileAPI(String a, String b,  Boolean c){
    }
      /*if(tempBooking.PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c == 'Loyalty Sales') {
if(slabVsCategoryMap.containsKey('Loyalty Sales') && (tempBooking.PropStrength__Discount__c == null ||(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Discount__c == 0.00))) {
iss = slabVsCategoryMap.get('Loyalty Sales');
tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales').Id;
}
else if(tempBooking.PropStrength__Discount__c != null && tempBooking.PropStrength__Project__c != null && tempBooking.PropStrength__Project__r.NPV__c != null) {
if(slabVsCategoryMap.containsKey('Loyalty Sales (saving 1% on discount)') && (tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) >= 1.0) {
iss = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)');
tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (saving 1% on discount)').Id;
}  
else if(slabVsCategoryMap.containsKey('Loyalty Sales (with discount)') && 
(tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) < 1.0 && 
(tempBooking.PropStrength__Project__r.NPV__c - tempBooking.PropStrength__Discount__c) >= 0 ) {
iss = slabVsCategoryMap.get('Loyalty Sales (with discount)');
tempBooking.Marketing_Incentive_Slab__c = slabVsCategoryMap.get('Loyalty Sales (with discount)').Id;
}
}
}*/
                      
}