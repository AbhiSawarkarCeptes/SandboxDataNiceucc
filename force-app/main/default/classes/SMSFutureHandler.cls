public class SMSFutureHandler
{

    @future(Callout=true) 
    public static void outboundSMS(set<id> smsIds)
    {
             string myphone = '';
             string mymsg = '';
             string strURL = '';  
             string phonewithcode = ''; 
         system.debug('Inside the SendSMSNewFutureHandler...');
            
        if(smsIds != null && smsIds.size() > 0 ) 
        {
            system.debug('Inside If Condition:' + smsIds);
            
            List <Lead> lead = new List<Lead>();
            List <Account> account = new List<Account>();
            
            List<SMS_Schedule_SMS_c__c> smslist = new List<SMS_Schedule_SMS_c__c> ();
            smslist = [SELECT Id, Name, Sender_Mobile__c, SMS_Long_text__c, Project_Interested__c, SMS_Text__c 
                       FROM SMS_Schedule_SMS_c__c WHERE Id in :smsIds];                                  
            system.debug('smslist  : ' + smslist );  
            
            for(SMS_Schedule_SMS_c__c newsms :smslist)
            {
                        if(newsms.Sender_Mobile__c!= null)
                        {      
                            myphone = newsms.Sender_Mobile__c; 
                            System.debug('myphone::: ' + myphone);                                                   

                        }       
                        if(newsms.SMS_Long_text__c!= null)
                        {
                            System.debug('inside LONG SMS TEXT');
                            mymsg = newsms.SMS_Long_text__c;
                        }
             }                                                 
                                  
             if(myphone != null){

                    lead = [SELECT Id, RDS_Country_Code__c FROM Lead WHERE MobilePhone = :myphone OR Phone = :myphone];
                    account = [SELECT Id, Country_Code__c FROM Account WHERE PersonMobilePhone = :myphone OR Phone = :myphone];
                    
                    if(lead.size() > 0 && lead[0].RDS_Country_Code__c != null){
                        phonewithcode = lead[0].RDS_Country_Code__c + myphone;
                    }
                    if(account.size() > 0 && account[0].Country_Code__c != null){
                         phonewithcode = account[0].Country_Code__c + myphone;
                    }                                                           
             }
             
                phonewithcode = phonewithcode.substring(1);
  
                mymsg = EncodingUtil.URLENCODE(mymsg,'UTF-8');
                mymsg = mymsg.replace('%2B%E2%80%9D','%20');
                mymsg = mymsg.replace('%2B%E2%80%9C','%20');
                mymsg = mymsg.replace('+','%20');
                system.debug('phonewithcode:::' + phonewithcode); 
                system.debug('mymsg : ' + mymsg); 
                
                 List <Vendor__c> vendorlist = new List<Vendor__c>();       
                 vendorlist = [SELECT id, Name, Vendor_URL__c, Param_1_Name__c, Param_1_Value__c,  Param_1_Status__c, 
                          Param_2_Name__c, Param_2_Value__c, Param_2_Status__c,
                          Param_3_Name__c, Param_3_Value__c, Param_3_Status__c, Param_4_Name__c, Param_4_Value__c, Param_4_Status__c,
                          Param_5_Name__c, Param_5_Status__c, Param_6_Name__c, Param_6_Value__c, Param_6_Status__c,
                          Param_7_Name__c, Param_7_Status__c, Param_8_Name__c, Param_8_Value__c, Param_8_Status__c
                          FROM Vendor__c WHERE Vendor_Status__c = true limit 1];                    
                 system.debug('vendorlist : ' + vendorlist);
                
                If((lead.size() > 0 && lead[0].RDS_Country_Code__c == '+971') || (account.size() > 0 && account[0].Country_Code__c == '+971')) {        
               
                    if(vendorlist[0].Param_1_Status__c == TRUE && vendorlist[0].Param_2_Status__c == TRUE && vendorlist[0].Param_8_Status__c  == TRUE && vendorlist[0].Param_4_Status__c == TRUE && vendorlist[0].Param_5_Status__c  == TRUE && vendorlist[0].Param_6_Status__c == TRUE && vendorlist[0].Param_7_Status__c  == TRUE ) 
                    {        
                            system.debug('Inside IF Dubai');
                            
                            strURL = vendorlist[0].Vendor_URL__c + 
                            '?' + vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c + 
                            '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c + 
                            '&' + vendorlist[0].Param_8_Name__c + '=' + vendorlist[0].Param_8_Value__c +  
                            '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c +  
                            '&' + vendorlist[0].Param_5_Name__c + '=' + phonewithcode +
                            '&' + vendorlist[0].Param_6_Name__c + '=' + vendorlist[0].Param_6_Value__c +  
                            '&' + vendorlist[0].Param_7_Name__c + '=' +  mymsg;                                     
                    }  
              } 
               else {
                   if(vendorlist[0].Param_1_Status__c == TRUE && vendorlist[0].Param_2_Status__c == TRUE && vendorlist[0].Param_3_Status__c  == TRUE && vendorlist[0].Param_4_Status__c == TRUE && vendorlist[0].Param_5_Status__c  == TRUE && vendorlist[0].Param_6_Status__c == TRUE && vendorlist[0].Param_7_Status__c  == TRUE ) 
                        {        
                                system.debug('Inside IF India');
                                
                                strURL = vendorlist[0].Vendor_URL__c + 
                                '?' + vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c + 
                                '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c + 
                                '&' + vendorlist[0].Param_3_Name__c + '=' + vendorlist[0].Param_3_Value__c +  
                                '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c +  
                                '&' + vendorlist[0].Param_5_Name__c + '=' + phonewithcode +
                                '&' + vendorlist[0].Param_6_Name__c + '=' + vendorlist[0].Param_6_Value__c +  
                                '&' + vendorlist[0].Param_7_Name__c + '=' +  mymsg;                                     
                        }              
               }           
                system.debug('strURL in Handler Class : ' + strURL);  
                
              if(!Test.isRunningTest())       
               sendSMSClass.mySMS(strURL);     
          }
     } 
}