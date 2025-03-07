public class BRC_PR_AllocationTriggerHandler{
    
    static final Set<String> ACCOUNT_MATCH_VALIDATION_AVOIDANCE_MODES = new Set<String>{
        'website',
        'cheque',
        'credit card',
        'otc deposits',
        'cdm cheque'
    };
    static Map<Id,Bank_Receipt__c> parentBrcMap;
    static Map<Id,Payment_Request__c> parentPrMap;
    
    static Map<String,Set<String>> brcModeToPrModesMapping = new Map<String,Set<String>>{
        'cheque' => new Set<String>{'cheque','cdm cheque'},
        'mc' => new Set<String>{'cheque','cdm cheque'},
        'cd' => new Set<String>{'cdm cash'},
        'tt' => new Set<String>{'international wire transfer','domestic wire transfer'},
        'cc' => new Set<String>{'credit card'},
        'website' => new Set<String>{'website'},
        'otc' =>  new Set<String>{'otc deposits'},
        'otc ho' =>  new Set<String>{'otc deposits'}
    };
    
    public static void beforeInsert(List<BRC_PR_Allocation__c> bpas){
        Set<Id> parentBrcIds = new Set<Id>();
        Set<Id> parentPrIds = new Set<Id>();
        for(BRC_PR_Allocation__c bpa : bpas){
            parentBrcIds.add(bpa.Bank_Receipt__c);
            parentPrIds.add(bpa.Payment_Request__c);
        }
        
        parentBrcMap = new Map<Id,Bank_Receipt__c>([SELECT id,Name,BRC_Mode__c,PR_Mode__c,Credit_Amount__c,Account_Master__c,Account_Master__r.Name,(SELECT Id,PR_Amount__c FROM BRC_PR_Allocations__r WHERE Deallocated__c = FALSE) FROM Bank_Receipt__c WHERE Id IN :parentBrcIds]);
        parentPrMap = new Map<Id,Payment_Request__c>([SELECT id,Name,Mode__c,Status__c,Account_Master__c,Account_Master__r.Name,Amount__c FROM Payment_Request__c WHERE Id IN :parentPrIds]);
        
        beforeInsertValidations(bpas);
        beforeInsertProcess(bpas);
    }
    
    public static void beforeInsertValidations(List<BRC_PR_Allocation__c> bpas){
        
        
        for(BRC_PR_Allocation__c bpa : bpas){
            Bank_Receipt__c parentBRC = parentBrcMap.get(bpa.Bank_Receipt__c);
            Payment_Request__c parentPR = parentPrMap.get(bpa.Payment_Request__c);
            String errorString = '';
            //PR isnt Approved
            if(parentPR.Status__c == 'Approved' || parentPR.Status__c == 'PR was Approved- Booking is cancelled' || parentPR.Status__c == 'Approved by Accounts'){
                errorString = '';
            }else{
                //bpa.addError('BRC can only be allocated via Approved PRs! Please use an Approved PR!');
                errorString+=' - BRC can only be allocated via Approved PRs! Please use an Approved PR!';
            }
            
            //Duplication control as a process
            bpa.PR_Duplicate_Control__c = bpa.Payment_Request__c;
            
            //BRC vs PR Mode validity
            if(!brcModeToPrModesMapping.get(parentBRC.BRC_Mode__c.toLowerCase()).contains(parentPR.Mode__c.toLowerCase())){
                //bpa.addError('Incompatible PR Mode('+parentPR.Mode__c+') being allocated for BRC Mode('+parentBRC.PR_Mode__c+')!');
                errorString+=' - Incompatible PR Mode('+parentPR.Mode__c+') being allocated for BRC Mode('+parentBRC.PR_Mode__c+')!';
            }
            
            //PR aggregate vs BRC Credit Amount
            Double totalAllocatedPrAmount = 0.0;
            for(BRC_PR_Allocation__c siblingBPAs : parentBRC.BRC_PR_Allocations__r){
                totalAllocatedPrAmount += siblingBPAs.PR_Amount__c;
            }
            totalAllocatedPrAmount += parentPR.Amount__c;//The current allocation of BRC amount, i.e. the Amount on PR
            if(parentBRC.Credit_Amount__c < totalAllocatedPrAmount){
                //bpa.addError('Aggregate PR amount allocation('+totalAllocatedPrAmount+') cannot exceed BRC Amount('+parentBRC.Credit_Amount__c+')!');
                errorString+=' - Aggregate PR amount allocation('+totalAllocatedPrAmount+') cannot exceed BRC Amount('+parentBRC.Credit_Amount__c+')!';
            }
            
            //PR AM same as BRC AM
            if(parentBRC.Account_Master__c != parentPR.Account_Master__c && !ACCOUNT_MATCH_VALIDATION_AVOIDANCE_MODES.contains(parentPR.Mode__c.toLowerCase())){
                //bpa.addError('BRC Account('+parentBRC.Account_Master__r.Name+') and PR Account('+parentPR.Account_Master__r.Name+') do not match!');
                errorString+=' - BRC Account('+parentBRC.Account_Master__r.Name+') and PR Account('+parentPR.Account_Master__r.Name+') do not match!';
            }
            if(String.isNotBlank(errorString)) bpa.addError('Issues with allocation'+errorString);
        }
    }
    
    public static void beforeInsertProcess(List<BRC_PR_Allocation__c> bpas){
        for(BRC_PR_Allocation__c bpa : bpas){
            bpa.PR_Amount__c = parentPrMap.get(bpa.Payment_Request__c).Amount__c;
            bpa.BRC_PR_Number_Snapshot__c = parentBrcMap.get(bpa.Bank_Receipt__c).Name + ' - ' + parentPrMap.get(bpa.Payment_Request__c).Name;
        }
    }
    
}