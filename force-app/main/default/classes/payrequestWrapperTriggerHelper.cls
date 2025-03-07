public class payrequestWrapperTriggerHelper {
    public static void updateMode(List<Payment_Request_Wrapper__c> prList) {
        Schema.SObjectType projectType = Payment_Request_Wrapper__c.SObjectType;
        Map<String, String> picklistValueMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = projectType.getDescribe().fields.getMap().get('Mobile_Mode_App__c').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickVal : picklistValues) {
            picklistValueMap.put(pickVal.getValue(), pickVal.getLabel());
        }
        System.debug('picklistValueMap: ' + picklistValueMap);
        List<Payment_Request_Wrapper__c> updateList = new List<Payment_Request_Wrapper__c>();
        if(!picklistValueMap.isEmpty()) {
            for(Payment_Request_Wrapper__c pr : prList) {
                if(!String.isBlank(pr.Mobile_Mode_App__c) &&
                   picklistValueMap.containsKey(pr.Mobile_Mode_App__c)) {
                       Payment_Request_Wrapper__c pr1 = new Payment_Request_Wrapper__c();
                       pr1.Id = pr.Id;
                       pr1.Mode__c = picklistValueMap.get(pr.Mobile_Mode_App__c);
                       updateList.add(pr1);
                   }
            }
        }
        if(!updateList.isEmpty()) {
            update updateList;
        }
    }
}