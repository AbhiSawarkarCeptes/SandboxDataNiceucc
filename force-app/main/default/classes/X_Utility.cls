//TestClass : X_Test_ServiceController
public class X_Utility {
    
    
    //Get Demand Type
    Public Static String getDemandType(Demand__c demand){
        String demandType = '';
        
        /*Boolean isCDC = (
            String.isNotBlank(demand.Milestone_Name__c) && (demand.Milestone_Name__c.containsIgnoreCase('Cheque Dishonored Charges') || demand.Milestone_Name__c.containsIgnoreCase('Cheque Dishonoured Charges'))
        ) || (
            String.isNotBlank(demand.Other_Charges_Type__c) && (demand.Other_Charges_Type__c.containsIgnoreCase('Cheque Dishonored Charges') || demand.Other_Charges_Type__c.containsIgnoreCase('Cheque Dishonoured Charges'))
        );
        if((isCDC && demand.Demand_Status__c == 'Reversed') || (!isCDC && demand.Receipt__c != null)) return demandType;*/
        if(String.isNotBlank(demand.Demand_Status__c) && demand.Demand_Status__c.containsIgnoreCase('reverse')) return demandType;

        if(String.isNotBlank(demand.Xpedeon_Doc_Type__c)) return demand.Xpedeon_Doc_Type__c;
        
        List<String> psiKeywords = new List<String>{'area excess','area change'};
        List<String> otherChargesTypeList = new List<String>{'Cheque Dishonored Charges','Resale NOC (Title Deed)','Resale NOC (Oqood)','Maintenance Charges','Renewal of Resale NOC (expired in 30 days)','Upkeep/refurbishment Charges','DEWA Charges','NOC Charges','Admin Charges','Late Payment Charges','Cancellation Charges','Cheque Dishonoured Charges','Resale – NOC (Title Deed)','Resale – NOC (Off plan)','SPA Reissuance Fees','Ownership Change','Plot title Deed','Plot Resale NOC','SPA reissuance fees (per book)','Name addition/deletion','Ownership changes','Admin Charges (General)','Concept drawing NOC','Detailed design NOC','Construction NOC','Reissue of Plot NOC (other than construction)','Reissue of Plot NOC (construction)','1% Delayed Handover Charges','Plot - Construction Commencement/ Completion Delay Penalty'};
                
        List<String> otherChargesDLDTypeList = new List<String>{'Debit note for DLD Charges','Title Deed Charges','Oqood Charges','Mortgage Fees','Pre-registration To Pre-title Deed','Title Deed Fees (Units)','Title Deed Fees (Villas)','Title Deed Fees (Plots)','Mortgage Fees (Ejara)','Mortgage Fees (Traditonal)','DLD Cancellation Charges','Pre-registration to pre-title deed (completed projects)'};
                    
        Boolean isPSI = demand.Payment_Milestones__c != null;
        if(!isPSI && String.isNotBlank(demand.Milestone_Name__c)){
            for(String psiKeyword : psiKeywords){
                if(demand.Milestone_Name__c.containsIgnoreCase(psiKeyword)){
                    isPSI = true;
                    break;
                }
            }
        }

        Boolean isASI = !isPSI && String.isNotBlank(demand.Milestone_Name__c) && demand.Milestone_Name__c.equalsIgnoreCase('Late Payment Charges');
        if(!isPSI && !isASI && (String.isNotBlank(demand.Other_Charges_Type__c) || (String.isNotBlank(demand.Milestone_Name__c)))){
            for(String otherChargesType : otherChargesTypeList){
                if((String.isNotBlank(demand.Other_Charges_Type__c) && demand.Other_Charges_Type__c.equalsIgnoreCase(otherChargesType)) || (String.isNotBlank(demand.Milestone_Name__c) && demand.Milestone_Name__c.equalsIgnoreCase(otherChargesType))){
                    isASI = true;
                    break;
                }
            }
        }

        /*
        Boolean isDLDI = !isPSI && !isASI && String.isNotBlank(demand.Debit_Type__c) && demand.Debit_Type__c.equalsIgnoreCase('DLD Charges');
        if(!isPSI && !isASI && !isDLDI && (String.isNotBlank(demand.Other_Charges_Type__c) || (String.isNotBlank(demand.Milestone_Name__c)))){
            for(String otherChargesDLDType : otherChargesDLDTypeList){
                //if(demand.Other_Charges_Type__c.equalsIgnoreCase(otherChargesDLDType)){
                if((String.isNotBlank(demand.Other_Charges_Type__c) && demand.Other_Charges_Type__c.equalsIgnoreCase(otherChargesDLDType)) || (String.isNotBlank(demand.Milestone_Name__c) && demand.Milestone_Name__c.equalsIgnoreCase(otherChargesDLDType))){
                    isDLDI = true;
                    break;
                }
            }
        }
        */
        


       	if(isPSI){
           demandType = 'PSI';
        }else if(isASI){
            demandType = 'ASI';
        }/*else if(isDLDI){
            demandType = 'DLDI';
        }*/

        /*else if(otherChargesTypeList.Contains(demand.Other_Charges_Type__c)){
            demandType = 'ASI';
        }*/
        
        /*else if(demand.Debit_Type__c == 'DLD Charges' || otherChargesDLDTypeList.contains(demand.Other_Charges_Type__c)){//added by Pulkit
            demandType = 'DLDI';
        }*/
        
        return demandType;
    }
    
    //Get OtherType
    Public Static String getOtherType(String fieldName,String docType,String UnitType){
        String key;
        if(docType == 'PSI' && UnitType != null){
            key = fieldName+'_'+docType+'_'+unitType;
        }
        if(docType == 'ASI'){
            key = fieldName+'_'+docType;
        }
        if(docType == 'DLDI'){
            key = fieldName+'_'+docType;
        }
        
        return key != null ? KEY : null;
    }
    
    
    // Get EntityCode
    public static String getEntityCodeFor(Id bookingId){
        String entityCode = '';
        List<Booking__c> booking = Database.queryWithBinds('SELECT Id,Name,Unit__c,Unit__r.Name,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Account.Code__c FROM Booking__c WHERE Id = :bookingId',new Map<String,Object>{'bookingId'=>bookingId},AccessLevel.SYSTEM_MODE);
        if(booking.isEmpty() || String.isBlank(booking[0].Unit__c) || String.isBlank(booking[0].Opportunity__c) || String.isBlank(booking[0].Opportunity__r.AccountId)) return entityCode;
        
        //The existing XP Customer Master, that is to be retreived
        List<Xpedeon_Customer_Master__c> existingXpCustomerMaster = Database.queryWithBinds('SELECT Xpedeon_Customer_Code__c,Xpedeon_Customer_Name__c,Booking__c,Unit__c FROM Xpedeon_Customer_Master__c WHERE Account__c = :accountOnBooking',new Map<String,Object>{'accountOnBooking'=>booking[0].Opportunity__r.AccountId},AccessLevel.SYSTEM_MODE);
        
        if(existingXpCustomerMaster.isEmpty()){
            entityCode = (booking[0].Name + '-' + booking[0].Opportunity__r.Account.Code__c + '-' + booking[0].Unit__r.Name);
        }else{
            Set<String> xccs =  new Set<String>();
            for(Xpedeon_Customer_Master__c xcm : existingXpCustomerMaster){
                if(String.isNotBlank(xcm.Xpedeon_Customer_Code__c)) xccs.add(xcm.Xpedeon_Customer_Code__c);
                if(xcm.Booking__c == booking[0].Id && xcm.Unit__c == booking[0].Unit__c){//This Customer Entity is migrated from XP
                    entityCode = xcm.Xpedeon_Customer_Code__c;
                    break;
                }
            }
            
            if(String.isBlank(entityCode) && !xccs.isEmpty()){
                if(xccs.size() == 1){
                    entityCode = (booking[0].Name + '-' + new List<String>(xccs)[0] + '-' + booking[0].Unit__r.Name);
                }else{//If multiple XP customer codes exist for single SF Account, and this is a new entity 
                    entityCode = (booking[0].Name + '-' + booking[0].Opportunity__r.Account.Code__c + '-' + booking[0].Unit__r.Name);
                }
            }
        }
        
        return entityCode;
    }
    
    public static Decimal getTotalAllocationAmt(Decimal TowardsOtherChargesAmount,
                                                Decimal TowardsPreRegistrationAmount ,
                                                Decimal TowardsUnitPriceAmount){
                                                    // Initialize total allocation amount
                                                    Decimal totalAllocationAmount = 0;
                                                    
                                                    // Check and add Towards_Other_Charges_Amount__c
                                                    if (TowardsOtherChargesAmount != null) {
                                                        totalAllocationAmount += TowardsOtherChargesAmount;
                                                    }
                                                    
                                                    // Check and add Towards_Pre_Registration_Amount__c
                                                    if (TowardsPreRegistrationAmount != null) {
                                                        totalAllocationAmount += TowardsPreRegistrationAmount;
                                                    }
                                                    
                                                    // Check and add Towards_Unit_Price_Amount__c
                                                    if (TowardsUnitPriceAmount != null) {
                                                        totalAllocationAmount += TowardsUnitPriceAmount;
                                                    }
                                                    return totalAllocationAmount;                                
                                                }
    
    public static Decimal getTotalAllocationAmt(Decimal DP1,Decimal DP2,Decimal DLD1,Decimal DLD2){
        // Initialize total allocation amount
        Decimal totalAllocationAmount = 0;
        
        if(DP1 != null){totalAllocationAmount+=DP1;}
        if(DP2 != null){totalAllocationAmount+=DP2;}
        if(DLD1 != null){totalAllocationAmount+=DLD1;}
        if(DLD2 != null){totalAllocationAmount+=DLD2;}
        return totalAllocationAmount;
    }
    
    
    
    public static X_ReceiptMode getModeType(String modeValue){
        List<Xpedeon_Payment_Mode__mdt> metadataModes =[SELECT Type__c, Sub_Type__c 
                                                        FROM Xpedeon_Payment_Mode__mdt 
                                                        WHERE Mode__c=:modeValue];
        Xpedeon_Payment_Mode__mdt metadataMode = new Xpedeon_Payment_Mode__mdt();
        
        if(metadataModes.isEmpty()) return new X_ReceiptMode();
        
        return new X_ReceiptMode(metadataModes[0].Type__c,metadataModes[0].Sub_Type__c);
    }
    
    
    public class X_ReceiptMode{
        Public String modeType;
        Public String modeSubType;
        @TestVisible X_ReceiptMode(){
            modeType = '';
            modeSubType = '';
        }
        public X_ReceiptMode(String modeType,String modeSubType){
            this.modeType = modeType;
            this.modeSubType = modeSubType;
        }
    }
    
    
}