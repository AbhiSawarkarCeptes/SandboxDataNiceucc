global class BrokerRegFieldUpdateReqEmailController {
    global static Id currentId {get;set;}
    global static List<Broker_Registration_Approval_Request__c> brokerAppReqList {get;set;}
	
    public static Broker_Registration__c getrelatedTo() {
        List<String> statusFilter = new List<String>{'Pending With CHRM OPS Manager', 'Pending With CHRM OPS Manager'};
        Broker_Registration__c brg =  [Select Id, frmBrokerRegistrationName__c, Name from  Broker_Registration__c where Id=:currentId];
        brokerAppReqList = [Select Id, Status__c, Broker_Registration__c, Label__c, Old_Value__c, New_Value__c from Broker_Registration_Approval_Request__c where Broker_Registration__c =: currentId AND Status__c IN:statusFilter];
        return brg;
    }
    
}