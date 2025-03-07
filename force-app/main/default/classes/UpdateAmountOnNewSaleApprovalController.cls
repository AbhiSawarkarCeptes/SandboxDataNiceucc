public without sharing class UpdateAmountOnNewSaleApprovalController {
    @AuraEnabled(cacheable=true)
    public static wrapperObj getNewSaleApproval(String recordId){
        try {
            map<string,decimal> currToRate = new map<string,decimal>();
            for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
                currToRate.put(currRate.MasterLabel,currRate.Rate__c);
            }
            wrapperObj obj = new wrapperObj();
            obj.existingDpAmount2 = 0;
            obj.existingDldAmount2 = 0;
            obj.existingDldAmount1 = 0;
            obj.showBothDpAndDldField = false;
            obj.currToRate = currToRate;
            obj.showAmountConfirmError = false;
            obj.isPrimaryPR = true;
            obj.skip2PercentError = false;
            obj.differentloggedinUserError = false;
            
            Payment_Request__c pr = [SELECT ID ,Unit_Purchase_Amount__c,amount__c, unit__r.unit_hold_min_percentage__c,mode__c,mode_option__c,payment_request__c,currency__c,payment_request__r.currency__c,payment_request__r.total_Amount__c,payment_request__r.mode__c,
            total_Amount__c,Status__c,payment_request__r.Status__c,secondary_mode__c, account_type__c, payment_request__r.account_type__c  FROM Payment_Request__c where id = :recordId];
            obj.accountType = pr.Account_Type__c;
            obj.accountTypePrimary = pr.payment_request__r.account_type__c;

            //Aayushi :SOB-403 added cdm cash condition
            if(pr.mode_option__c == 'Multi Mode' && pr.mode__c != null && (pr.mode__c.tolowercase() == 'international wire transfer' || pr.mode__c.tolowercase() == 'domestic wire transfer'
            || pr.mode__c.tolowercase() == 'cdm cash')){
                if(pr.total_Amount__c != null && pr.total_Amount__c > 0 && pr.secondary_mode__c != null){
                    obj.isPrimaryPR = false;
                }
                obj.skip2PercentError = true;
               
                List<unit_hold_request__c> nsaList = [select id,ownerId,Payment_Request__c,dld_amount__c,dp_amount__c,payment_request__r.amount__c,dp_amount_2__c,
                dld_amount_2__c,payment_request__r.total_amount__c,Sales_Value__c, payment_request__r.Unit__r.Unit_Hold_min_percentage__c from unit_hold_request__c where 
                ( Approval_Status__c='Approved by Sales Ops' or Approval_Status__c='Pending' 
                 or Approval_Status__c = 'Approved by Sales VP' or Approval_Status__c = 'Approved by Sales Head' or Approval_Status__c = 'Approved')
                 AND (Payment_Request__c =: recordId or Payment_Request__c =: pr.payment_request__c)];
                 if(!nsaList.isEmpty() ){
                    obj.Unithold = nsaList[0];
                    obj.amount = pr.amount__c ;
                    obj.saleValue = pr.Unit_Purchase_Amount__c;
                    obj.existingDpAmount2 = (obj.Unithold.dp_amount_2__c!=null)?obj.Unithold.dp_amount_2__c:0;
                    obj.existingDldAmount2 = (obj.Unithold.dld_amount_2__c!=null)?obj.Unithold.dld_amount_2__c:0;
                    obj.existingDldAmount1 = (obj.Unithold.dld_amount__c!=null)?obj.Unithold.dld_amount__c:0;
                    //obj.saleValue = pr.Unit__r.Unit_Hold_min_percentage__c;
                    obj.currency1 = pr.currency__c;
                    obj.currency2 = pr.payment_request__r.currency__c;
                 }
                 //Aayushi :SOB-403 added cdm cash condition
            
                 if(pr.payment_request__c != null && (pr.payment_request__r.mode__c.tolowercase() == 'international wire transfer' || pr.payment_request__r.mode__c.tolowercase() == 'domestic wire transfer'
                 || pr.payment_request__r.mode__c.tolowercase() == 'cdm cash')){
                    obj.amount =pr.total_Amount__c != null && pr.total_Amount__c != 0? pr.total_Amount__c : pr.payment_request__r.total_Amount__c;
                    obj.showBothDpAndDldField = true;
                    if(pr.Status__c != 'Approved' || pr.payment_request__r.status__c != 'Approved'){
                        obj.showAmountConfirmError = true;
                    }
                }   
               
                       
              
            }else{
                List<unit_hold_request__c> nsaList =  [select id,ownerId,Payment_Request__c,dld_amount__c,dp_amount__c,payment_request__r.amount__c,payment_request__r.currency__c,
                payment_request__r.total_amount__c,Sales_Value__c, payment_request__r.Unit__r.Unit_Hold_min_percentage__c from unit_hold_request__c where 
                ( Approval_Status__c='Approved by Sales Ops' or Approval_Status__c='Pending' 
                 or Approval_Status__c = 'Approved by Sales VP' or Approval_Status__c = 'Approved by Sales Head' or Approval_Status__c = 'Approved')
                 AND Payment_Request__c =: recordId];
                 if(!nsaList.isEmpty()){
                    obj.unithold = nsaList[0];
                    obj.amount = obj.unithold.payment_request__r.total_amount__c != null ?obj.unithold.payment_request__r.total_amount__c : obj.unithold.payment_request__r.amount__c ;
                   
                       obj.saleValue = obj.unithold.Sales_Value__c;
                       obj.currency1 = obj.unithold.payment_request__r.currency__c;
                 }
           
                 
                
            }
            if(obj.unithold.ownerID != userInfo.getUserId()){
                obj.differentloggedinUserError = true;
               
            }
            return obj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class wrapperObj{
        @AuraEnabled
        public unit_hold_request__c unithold;
        @AuraEnabled
        public decimal amount;
        @AuraEnabled
        public boolean skip2PercentError ;
        @AuraEnabled
        public decimal salevalue;
        @AuraEnabled
        public decimal existingDpAmount2;
        @AuraEnabled
        public string currency1;
        @AuraEnabled
        public string currency2;
        @AuraEnabled
        public map<string,decimal> currToRate;
        @AuraEnabled
        public boolean showBothDpAndDldField;
        @AuraEnabled
        public boolean showAmountConfirmError;
        @AuraEnabled
        public boolean isPrimaryPR;
        @AuraEnabled
        public decimal existingDldAmount2;
        @AuraEnabled
        public decimal existingDldAmount1;
        @AuraEnabled
        public boolean differentloggedinUserError;
        @AuraEnabled
        public String accountType;
        @AuraEnabled
        public String accountTypePrimary;
    }
}