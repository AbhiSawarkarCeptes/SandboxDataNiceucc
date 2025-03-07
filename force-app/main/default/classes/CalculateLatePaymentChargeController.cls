/* Class Name - CalculateLatePaymentChargeController
 * PurPose - This Class is used to Calculate the Late Payment Charges for Booking and all related Demands
 * Created By - Ashwin Kushwah
 * Used - as a controller for CalculateLatePaymentCharge component
 * Modified By - 
 * Modification Reason - 
*/

public class CalculateLatePaymentChargeController {
    public Static Decimal totalInterest = 0;	
    @AuraEnabled
    public static void calculateLatePayment(String bookingId){
        List<Demand__c> demandListToUpdate = new List<Demand__c>();
        Booking__c booking = [Select Id,Total_On_Account_Money_With_Registration__c,Total_Interest_Till_Date__c	 From Booking__c Where Id =: bookingId];
        List<Demand__c> demandList =  [SELECT Id,Booking__r.Total_On_Account_Money_With_Registration__c,Milestone_Name__c,Due_Date__c,
                                      Total_Amount_Demanded__c,Installment__c,Payment_Milestones__r.Charge1Percentage__c,
                                      Date_for_Late_Payment_Calculation__c,Demand_Age__c,OutStanding_days_calculated__c,
                                      No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c From Demand__C
                                      Where Payment_Milestones__c != Null and Demand_Status__c !='Reversed' and Booking__c =: booking.id ORDER BY Date_for_Late_Payment_Calculation__c ASC];
        System.debug('The booking in actual is -- '+ booking);
        List<LatePaymentWrapper> latePaymentList = new List<LatePaymentWrapper>();
		
        //Initializing the wrapper list
        for(Demand__c d : demandList){
            LatePaymentWrapper l = new LatePaymentWrapper();
            latePaymentList.add(l);
        }
        
        if(!demandList.isEmpty()){
            System.debug('The demand record is --' + demandList[0]);
           // demandList[0].Balance_Amount__c	 = 
            latePaymentList[0].balanceAmount = (Integer)(demandList[0].Total_Amount_Demanded__c - booking.Total_On_Account_Money_With_Registration__c);
       		latePaymentList[0].latePaymentDueDate = demandList[0].Date_for_Late_Payment_Calculation__c;
       		latePaymentList[0].demand = demandList[0];
        }
        
        //Calculating the Balance Amount of Remaining Demands
        for(Integer i=1; i<demandList.size(); i++){
             System.debug('The demand record is --' + demandList[i]);

            if(latePaymentList[i-1].balanceAmount < 0){
                
                latePaymentList[i].balanceAmount = (Integer)(demandList[i].Total_Amount_Demanded__c - (latePaymentList[i-1].balanceAmount * -1));
             }
            else{
                latePaymentList[i].balanceAmount = (Integer)demandList[i].Total_Amount_Demanded__c;
            }
             latePaymentList[i].latePaymentDueDate	= demandList[i].Date_for_Late_Payment_Calculation__c;
             latePaymentList[i].demand = demandList[i];
             //latePaymentList[i].demand.OutStanding_days_calculated__c = '';
        }
    	
        //Calculating the Interest of each Demand
        for(Integer i=0; i<latePaymentList.size(); i++){
            System.debug('The demand record is in process--' +latePaymentList[i].demand);
            System.debug('The balance amount for this demand is -- '+ latePaymentList[i].balanceAmount);
            if(latePaymentList[i].balanceAmount <= 0){ 
                latePaymentList[i].interestCharges = 0;
                latePaymentList[i].outStandingDays = 'Paid';
                latePaymentList[i].noOfMonths = 0;
                latePaymentList[i].displayBalanceAmount = 0;
                
                
                //assiging the demand related fields
                latePaymentList[i].demand.Interest_Charges__c = 0;
                latePaymentList[i].demand.Balance_Amount__c = 0;
                latePaymentList[i].demand.OutStanding_days_calculated__c = 'Paid';
                latePaymentList[i].demand.No_of_days__c = 0;
                latePaymentList[i].demand.No_of_Months__c = 0;
            } else{
                if(latePaymentList[i].balanceAmount > 10000){
                    Integer days=0;
                    if(latePaymentList[i].latePaymentDueDate != null){
                    days = (latePaymentList[i].latePaymentDueDate).daysBetween(Date.today());
                    } 
                    if(days <= 30){
                        latePaymentList[i].demand.Balance_Amount__c = latePaymentList[i].balanceAmount;
                        latePaymentList[i].outStandingDays = String.valueOf(days); 
                        latePaymentList[i].noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR);
                        latePaymentList[i].demand.OutStanding_days_calculated__c = latePaymentList[i].outStandingDays;
                        latePaymentList[i].demand.No_of_days__c = Integer.valueOf(latePaymentList[i].outStandingDays);
                        latePaymentList[i].demand.No_of_Months__c = latePaymentList[i].noOfMonths;	
                        latePaymentList[i].demand.Interest_Charges__c = 0;
                    } else{
                        latePaymentList[i].outStandingDays = String.valueOf(days);
                        System.debug('The vale of day is -- ' + days);
                        latePaymentList[i].noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR); 
                        Long chargeOnBalance = (Math.exp(latePaymentList[i].noOfMonths * Math.log(1.01)) * latePaymentList[i].balanceAmount).round(System.RoundingMode.HALF_EVEN); //rounding up or down
                        latePaymentList[i].interestCharges = chargeOnBalance - latePaymentList[i].balanceAmount;  
                        latePaymentList[i].displayBalanceAmount = latePaymentList[i].balanceAmount;
                        
                        //assigning the demand related fields
                        latePaymentList[i].demand.Interest_Charges__c = chargeOnBalance - latePaymentList[i].balanceAmount;
                        latePaymentList[i].demand.Balance_Amount__c	 = latePaymentList[i].balanceAmount;
                        latePaymentList[i].demand.OutStanding_days_calculated__c = latePaymentList[i].outStandingDays;
                        latePaymentList[i].demand.No_of_days__c = Integer.valueOf(latePaymentList[i].outStandingDays);
                        latePaymentList[i].demand.No_of_Months__c = latePaymentList[i].noOfMonths;
                    }
                }else{
                    latePaymentList[i].demand.OutStanding_days_calculated__c = 'No LP Balance Amount is : '+latePaymentList[i].balanceAmount;
                    latePaymentList[i].demand.Interest_Charges__c = 0;
                }
                
            }
           // update latePaymentList[i].demand;
        	demandListToUpdate.add(latePaymentList[i].demand); 
            totalInterest = totalInterest + latePaymentList[i].demand.Interest_Charges__c;
        
    } 
        //updating the booking record values
        booking.Total_Interest_Till_Date__c = totalInterest;
        System.debug('update demand List Size is '+demandListToUpdate.size());
        System.debug('update demand List is '+demandListToUpdate);
       
        if(booking != null){
          update booking;
        }
       
        
        if(demandListToUpdate.size()>0){
           update demandListToUpdate;
        }
        
   }
       class LatePaymentWrapper {
       public Demand__c demand;
       public Integer balanceAmount;
       public Long interestCharges;
       public Integer displayBalanceAmount; 
       public Decimal noOfMonths;
       public String outStandingDays; 
       public Date latePaymentDueDate;
       public Date todayDate;        
    }
}