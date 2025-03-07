@isTest
public class UnholdPropertyAfter24_Test {
	@isTest
    static void testMethod1() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Expiry_Days__c = 10, Name = 'Test Project', PropStrength__Active__c = TRUE, T_link_Demand_Days__c = 12);
        insert proj;

        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request__c pr7 = new Payment_Request__c();
        pr7.Mode__c = 'Cheque';
        pr7.Status__c = 'Partially Approved';
        pr7.Towards_Unit_Price_Amount__c = 1000;
        pr7.Towards_Other_Charges_Amount__c = 1000;
        pr7.Towards_Pre_Registration_Amount__c = 1000;
        pr7.Amount_Towards__c = 'Other Amount';
        pr7.X1st_Level_Approved__c = true;
        pr7.Property__c = prop.Id;
        pr7.X1st_Level_Approved_Date__c = System.now().addMinutes(-11);
        pr7.Enquiry_Source__c = 'Web';
        insert pr7;
        
        Database.executeBatch(new UnholdPropertyAfter24());
    }
}