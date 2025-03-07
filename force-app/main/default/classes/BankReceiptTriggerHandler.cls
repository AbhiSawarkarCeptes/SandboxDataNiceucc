public class BankReceiptTriggerHandler{
    static Map<String,String> brcModeToModesMapping = new Map<String,String>{
        'cheque' => 'Cheque',
        'cd' => 'CDM Cash',
        'tt' => 'International Wire Transfer',
        'cc' => 'Credit Card',
        'website' => 'Website'
    };

    public static void beforeInsert(List<Bank_Receipt__c> newBRCs){
        beforeInsertValidations(newBRCs);
        beforeInsertProcess(newBRCs);
    }
    
    public static void beforeInsertValidations(List<Bank_Receipt__c> newBRCs){
        for(Bank_Receipt__c newBRC : newBRCs){
            if(newBRC.GL_Date__c > System.Today()){
               newBRC.addError('GL Date('+newBRC.GL_Date__c+') cannot be greater than current date!'); 
            }
        }
    }
    
    public static void beforeInsertProcess(List<Bank_Receipt__c> newBRCs){
        Map<String,Account_Master__c> acmsById = new Map<String,Account_Master__c>();
        Map<String,Account_Master__c> acmsByName = new Map<String,Account_Master__c>();
        Map<String,Account_Master__c> acmsByAccNo = new Map<String,Account_Master__c>();
        Map<String,Account_Master__c> acmsByXpAccNo = new Map<String,Account_Master__c>();
        
        for(Account_Master__c am : [SELECT id,Name,Account_Number__c,Xpedeon_Account_Number__c FROM Account_Master__c]){
            
            acmsById.put(am.Id,am);
            
            if(String.isNotBlank(am.Xpedeon_Account_Number__c)) acmsByXpAccNo.put((am.Xpedeon_Account_Number__c.toLowerCase()),am);
            if(String.isNotBlank(am.Name)) acmsByName.put((am.Name.toLowerCase()),am);
            if(String.isNotBlank(am.Account_Number__c)) acmsByAccNo.put((am.Account_Number__c.toLowerCase()),am);
        }
        
        for(Bank_Receipt__c brc : newBRCs){
            //brc.PR_Mode__c = brcModeToModesMapping.get(brc.BRC_Mode__c.toLowerCase());
            
            if(String.isNotBlank(brc.Account_Master__c)) continue;
            
            String accTextIdendifier = (brc.Account_Identifier__c+'').toLowerCase();
            if(acmsById.containsKey(accTextIdendifier)){
                brc.Account_Master__c = acmsById.get(accTextIdendifier).Id;
            }else if(acmsByXpAccNo.containsKey(accTextIdendifier)){
                brc.Account_Master__c = acmsByXpAccNo.get(accTextIdendifier).Id;
            }else if(acmsByName.containsKey(accTextIdendifier)){
                brc.Account_Master__c = acmsByName.get(accTextIdendifier).Id;
            }else if(acmsByAccNo.containsKey(accTextIdendifier)){
                brc.Account_Master__c = acmsByAccNo.get(accTextIdendifier).Id;
            }
        }
    }
    
}