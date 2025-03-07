trigger Dial_After_3_Hours_n_Default_Sub on Task (Before Insert, Before Update) {
    for(Task t : Trigger.New) {
        if(t.Subject == '' || t.Subject == null) {
            t.Subject = 'Call';
        }
        if(t.Call_Attempt_Status__c == 'No Contact') {
            if(t.Next_Action_Date__c == NULL) {
                t.Next_Action_Date__c = System.Now().addHours(3);
            }else if(t.Next_Action_Date__c <= System.Now()) {
                t.Next_Action_Date__c = System.Now().addHours(3);
            }
        }
    }
}