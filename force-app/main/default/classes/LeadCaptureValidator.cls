public class LeadCaptureValidator {
    public static void validateEndDate(List<Lead_Capture__c> leadCaptures) {
        Set<String> campaignCodes = new Set<String>();
        
        // Collect all Campaign Codes from Lead Captures
        for (Lead_Capture__c leadCapture : leadCaptures) {
            if (leadCapture.Campaign_Code__c != null) {
                campaignCodes.add(leadCapture.Campaign_Code__c.toLowerCase()); // Normalize to lowercase
            }
        }
        System.debug('campaignCodes:' + campaignCodes);
        
        // Query Events based on Campaign Codes
        Map<String, Events__c> campaignCodeToEventMap = new Map<String, Events__c>();
        for (Events__c event : [SELECT Id, Name, Date_Of_Event__c, End_Date_Of_Event__c, Campaign_Code__c 
                               FROM Events__c 
                               WHERE Campaign_Code__c IN :campaignCodes]) {
            if (event.Campaign_Code__c != null) {
                campaignCodeToEventMap.put(event.Campaign_Code__c.toLowerCase(), event); // Normalize to lowercase
            }
        }
        
        // Perform validation
        for (Lead_Capture__c leadCapture : leadCaptures) {
            if (leadCapture.Campaign_Code__c != null) {
                String normalizedCampaignCode = leadCapture.Campaign_Code__c.toLowerCase(); // Normalize to lowercase
                if (campaignCodeToEventMap.containsKey(normalizedCampaignCode)) {
                    Events__c relatedEvent = campaignCodeToEventMap.get(normalizedCampaignCode);
                    System.debug('relatedEvent:' + relatedEvent.End_Date_Of_Event__c);
                    System.debug('RelateEventEndDate' + relatedEvent.End_Date_Of_Event__c.addDays(2) + ':Today:' + Date.Today());
                    if (relatedEvent.End_Date_Of_Event__c.addDays(2) >= Date.today()) {
                        // Validation passed
                    } else {
                        leadCapture.addError(System.Label.End_Date_Error_Message);
                    }
                }
            }
        }
    }
}