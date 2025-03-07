public class IssueManagementVR {

            public static void requiredField()
    {
        for(Issue__c issueNew:(List<Issue__c>)trigger.new)
        {
            if(trigger.isInsert)
            if(issueNew.Status__c == 'Analysis Done & Submitted' && (issueNew.Analysis_Description__c == null
              || issueNew.Analysis_Submitted_Date_Time__c == null 
              || issueNew.Estimated_Effort_Person_Days__c == null))
            issueNew.addError('As you have selected Status "Analysis Done & Submitted" you must have to enter following fields >Analysis Submitted Date & Time  >Analysis Description >Estimated Effort (Person Days)');
            
            if(trigger.isUpdate)
            for(Issue__c issueOld :(List<Issue__c>)trigger.old)
            {
            if(issueNew.Status__c == 'Analysis Done & Submitted' && (issueNew.Analysis_Description__c == null
              || issueNew.Analysis_Submitted_Date_Time__c == null 
              || issueNew.Estimated_Effort_Person_Days__c == null))
            issueNew.addError('As you have selected Status  "Analysis Done & Submitted" you must have to enter following fields >Analysis Submitted Date & Time> >Analysis Description >Estimated Effort (Person Days)');    
            }
            
         }
     }

}