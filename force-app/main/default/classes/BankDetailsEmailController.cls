global class BankDetailsEmailController {
    
    global static Id currentId {get;set;}
    //public String customerName {get;set;}
    //global static List<Legal_Entity__c> LegalEntities {get;set;}
    
    global static String getCustomerName() {
        	Unit__c u = [Select id,Customers__r.Name From Unit__c where id=:currentId];
        	return u.Customers__r.Name;
    }
    
    public static Legal_Entity__c getLegalEntity() {
        Unit__c u = [Select id,Legal_Entity__c From Unit__c where id=:currentId];
        List<Legal_Entity__c> leList =  [Select id,Favouring__c ,Account_Number_Flat_Cost__c,IBAN__c ,MICR_Code_Flat_Cost__c ,
                							Bank_Name_Flat_Cost__c From Legal_Entity__c 
                                         	where id=:u.Legal_Entity__c];
        return leList[0];
    }
    
    

}