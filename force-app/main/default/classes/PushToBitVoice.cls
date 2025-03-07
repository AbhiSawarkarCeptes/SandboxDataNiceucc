Public With Sharing Class PushToBitVoice {
    
    ApexPages.StandardSetController setCon;
    
    Public PushToBitVoice(ApexPages.StandardSetController controller) {
        setCon = controller;
    }
    
    Public Void push() {
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        Map<String, Churned_Leads__c> profiles = Churned_Leads__c.getAll();
        if(profiles.keySet().contains(u.Profile.Name)) {
            String numbers = '';
            List<Lead> leadList = [SELECT Id, Primary_Number_Formula__c FROM Lead WHERE Id IN: (Lead[])setCon.getSelected()];
            for(Lead l : leadList) {
                if(l.Primary_Number_Formula__c.length() > 8) {
                    numbers += ',"'+l.Primary_Number_Formula__c+'"';
                    l.Pushed__c = true;
                }
            }
            System.debug('========== '+numbers);
            if(numbers.length() > 8) {
                numbers = '['+numbers.subString(1, numbers.length())+']';
                try {
                    if(ClickToDial.pushBulkCalls(numbers)) {
                        update leadList;
                    }
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm, 'Records has been processed...'));
                }catch(Exception ex) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
                }
            }else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Selected Lead records has no Phone Numbers to process...'));
            }
        }else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You are not Authorized for this Action !!!'));
        }
    }
}