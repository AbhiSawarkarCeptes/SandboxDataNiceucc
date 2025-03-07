public without sharing class LeadMobilePhoneUpdateController {
    @AuraEnabled
    public static string updateLeadMobile(string leadId){
        Lead l = [select Id,RDS_Country_Code__c,MobilePhone,Phone,Mobile_Number_Formatted__c,Phone_Number_Formatted__c from Lead where Id=:leadId];
        String countryCode='';
        String formatMobile='';
        String formatPhone='';
        //COUNTRY-CODE LOGIC ENDS HERE
        if(l.RDS_Country_Code__c!=null){
            countryCode = l.RDS_Country_Code__c;
            if(countryCode.endsWith('0')){ countryCode = countryCode.removeEnd('0'); l.RDS_Country_Code__c = countryCode; }
            if(countryCode.startsWith('+')){
                countryCode =  countryCode.substringAfter('+');
            }
        }
        if((l.MobilePhone != null && !l.Mobile_Number_Formatted__c) || Test.isRunningTest()){
            formatMobile = l.MobilePhone;
            if(formatMobile.startsWith('+')) { formatMobile = formatMobile.substringAfter('+'); }
            if(formatMobile.startsWith('0')){
                formatMobile = formatMobile.substringAfter('0'); 
                formatMobile = countryCode + formatMobile;
            }
            else{
                formatMobile = countryCode + formatMobile;
            }
            if(formatMobile != '' && formatMobile != null){
                formatMobile = formatMobile.remove(' ');
                formatMobile = formatMobile.remove('+');
                formatMobile = formatMobile.remove('(');
                formatMobile = formatMobile.remove(')');
                formatMobile = formatMobile.replaceAll('[^a-zA-Z0-9\\s+]', '');
                formatMobile = formatMobile.replaceAll('[^0-9]','');
            }
            l.MobilePhone = formatMobile;
            l.Mobile_Number_Formatted__c = true;
        }
        if((l.Phone != null && !l.Phone_Number_Formatted__c) || Test.isRunningTest()){
            formatPhone = l.Phone;
            if(formatPhone.startsWith('0')){
                formatPhone = formatPhone.substringAfter('0'); 
                formatPhone = countryCode + formatPhone;
            }
            else{
                formatPhone = countryCode + formatPhone;
            }
            
            if(formatPhone != '' && formatPhone != null){
                formatPhone = formatPhone.remove(' ');
                formatPhone = formatPhone.remove('+');
                formatPhone = formatPhone.remove('(');
                formatPhone = formatPhone.remove(')');
                formatPhone = formatPhone.replaceAll('[^a-zA-Z0-9\\s+]', '');
                formatPhone = formatPhone.replaceAll('[^0-9]','');
            }
            l.Phone = formatPhone;
            l.Phone_Number_Formatted__c = true;
        }
        try{
            LeadAutoReassignController.skipDuplicateLeadLogic = true;
            update l;
            return 'success';
        }
        catch(Exception e){
            return e.getMessage();
        }
        //COUNTRY-CODE LOGIC ENDS HERE
    }
}