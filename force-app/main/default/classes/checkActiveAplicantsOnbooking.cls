public class checkActiveAplicantsOnbooking {
    @InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> trIds) {
        Id mySourceId = trIds[0];
        System.debug('test----');
        List<String> envelopExist ; 
        List<PropStrength__Applicant_Detail__c> applicants = [SELECT Id, Name,Signed_By_Applicant__c , PropStrength__Applicant_Email__c,PropStrength__Applicant_Acc__c, PropStrength__Applicant_Mobile__c, PropStrength__Type__c, 
                                                              PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c, PropStrength__Applicant_Acc__r.name
                                                              FROM PropStrength__Applicant_Detail__c
                                                              WHERE PropStrength__Application__c = :mySourceId AND PropStrength__Active__c = TRUE AND Send_for_Docusign__c = true 
                                                              ORDER BY PropStrength__Type__c ASC];
        System.debug('applicants*---'+applicants.size());
       
        if(applicants.size() > 0){
            envelopExist = new List<String>();
            envelopExist.add('True');
        }
        System.debug('envelopExist*---'+envelopExist);
        return envelopExist;
    }
}