public class SalesMeetTrckTrgHelper {
    private static Map<string,string> emailMapwithRole= new Map<string,string>();
    private static String sender;
    public static List<Id> ParentUserId = new List<Id>();
    Public static Map<Id,user> getUserRelatedInfo()
    {
        String userId= UserInfo.getUserId();
        getParrentId(userId);
        map<Id,User> users =new Map<Id, User>([SELECT Id, Name,Email,Manager_Name__c,UserRole.Name from User WHERE Id IN :ParentUserId]);
        system.debug(users);
        return users;
    }
    
    Public static void findUserAndManager(List<Sales_Meeting_Tracker__c> newList)
    {
        
        Map<Id,user> userAndRoleMap=getUserRelatedInfo();
        emailMapwithRole = new Map<string,string>();
        for(Sales_Meeting_Tracker__c smt:newList)
        {	
         smt.Broker_Name__c=smt.Broker_category__c == 'Registered'? smt.CP_OR_CS_Name__c: smt.Broker_Name__c;
            for( Id idee:ParentUserId)
            {
                if(userAndRoleMap.get(idee).UserRole.Name.startsWithIgnoreCase('sales manager'))
                {
                    smt.Sales_manager__c=idee;
                    emailMapwithRole.put('sales manager',userAndRoleMap.get(idee).Email);
                    if(sender==null)
                    {
                        sender=userAndRoleMap.get(idee).Name;
                    }
                }
                
                if(userAndRoleMap.get(idee).UserRole.Name.startsWithIgnoreCase('sales head'))
                { 
                    smt.Sales_Head__c=idee;
                    emailMapwithRole.put('sales head',userAndRoleMap.get(idee).Email);
                    if(sender==null)
                    {
                        sender=userAndRoleMap.get(idee).Name;
                    }
                }
                
                if(userAndRoleMap.get(idee).UserRole.Name.startsWithIgnoreCase('vice president'))
                {
                    smt.Vice_president__c=idee;
                    emailMapwithRole.put('vice president',userAndRoleMap.get(idee).Email);
                    if(sender==null)
                    {
                        sender=userAndRoleMap.get(idee).Name;
                    }
                }  
                
                if(userAndRoleMap.get(idee).UserRole.Name.startsWithIgnoreCase('senior vice president'))
                {
                    smt.Senior_Vice_President__c=idee;
                    emailMapwithRole.put('senior vice president',userAndRoleMap.get(idee).Email);
                    if(sender==null)
                    {
                        sender=userAndRoleMap.get(idee).Name;
                    }
                } 
                if(userAndRoleMap.get(idee).UserRole.Name.startsWithIgnoreCase('chief sales officer'))
                {
                    emailMapwithRole.put('chief sales officer',userAndRoleMap.get(idee).Email);
                    if(sender==null)
                    {
                        sender=userAndRoleMap.get(idee).Name;
                    }
                }  
            }
        }        
    }    
    
    public static void sendEmail(List<Sales_Meeting_Tracker__c> newList)
    {
        String htmlText;
        for (Sales_Meeting_Tracker__c smt:newList)
        {
            
            if(smt.Broker_category__c=='Registered')
            {
            String cpOrScId= smt.CP_OR_CS_Id__c;
            htmlText='<p><h3>Dear '+sender+',</h3></p><p>  Please note that the Sales Meeting '+smt.Name+' with the broker '+smt.Broker_Name__c+' has been REGISTERED as an activity. To review the details submitted in Salesforce, please click on the following link.<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+smt.Id+'">click here</a></p><p>Date of Meeting: '+smt.Meeting_Date__c+'</p><p>Time of Meeting: '+smt.Time_of_meeting__c+'</p><p>Broker Full Name: '+smt.Broker_Name__c+'</p>'+'<p> SC/CP Id: '+cpOrScId+'</p><p>Meeting Agenda: '+smt.Plan_of_Meeting__c+'</p><p>Meeting Status: '+smt.Meeting_Status__c+'</p><p>Meeting remarks: '+smt.Meeting_Remarks__c+'</p><p><b>  Regards,<br />Salesforce</b></p>';
                system.debug('the cpOrScId is ---->>>>>>>'+cpOrScId);
            }
            else
            { htmlText='<p><h3>Dear '+sender+',</h3></p><p>  Please note that the Sales Meeting '+smt.Name+' with the broker '+smt.Broker_Name__c+' has been REGISTERED as an activity. To review the details submitted in Salesforce, please click on the following link.<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+smt.Id+'">click here</a></p><p>Date of Meeting: '+smt.Meeting_Date__c+'</p><p>Time of Meeting: '+smt.Time_of_meeting__c+'</p><p>Broker Full Name: '+smt.Broker_Name__c+'</p><p>Meeting Agenda: '+smt.Plan_of_Meeting__c+'</p><p>Meeting Status: '+smt.Meeting_Status__c+'</p><p>Meeting remarks: '+smt.Meeting_Remarks__c+'</p><p><b>  Regards,<br />Salesforce</b></p>'; }
         
            system.debug('the html text is ---->>>>>>>'+htmlText);
            Map<string,string> EmailRecievers=emailMapwithRole;
            String htmlTextBody=htmlText;
            list<string> emailRecieversList = new list<string>();
            if(EmailRecievers.get('sales manager')!=null)
            {
                emailRecieversList.add(EmailRecievers.get('sales manager'));
                emailRecieversList.add(EmailRecievers.get('sales head'));
                emailRecieversList.add(EmailRecievers.get('vice president'));
            }
            else if(EmailRecievers.get('sales head')!=null)
            {
                emailRecieversList.add(EmailRecievers.get('sales head'));
                emailRecieversList.add(EmailRecievers.get('vice president'));
                emailRecieversList.add(EmailRecievers.get('senior vice president'));
            }
            else if(EmailRecievers.get('vice president')!=null)
            {
                emailRecieversList.add(EmailRecievers.get('vice president'));
                emailRecieversList.add(EmailRecievers.get('senior vice president'));
                emailRecieversList.add(EmailRecievers.get('chief sales officer'));
            }
            else if(EmailRecievers.get('senior vice president')!=null)
            {
                emailRecieversList.add(EmailRecievers.get('senior vice president'));
                emailRecieversList.add(EmailRecievers.get('chief sales officer'));
            }
            else if(EmailRecievers.get('chief sales officer')!=null)
            {
                emailRecieversList.add(EmailRecievers.get('chief sales officer'));
            }
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                list<string> sender1=new list<string>();
                if(!emailRecieversList.isEmpty())
                {
                    sender1.add(emailRecieversList.Remove(0)) ;
                     //sender1.add('roshan.bande@ceptes.com') ;
                    mail.setToAddresses(sender1);
                    if(!emailRecieversList.isEmpty()){
                        for (Integer i = emailRecieversList.size() - 1; i >= 0; i--) {
                            if (emailRecieversList[i] == null) {
                                emailRecieversList.remove(i);
                            }
                        }
                        mail.setCcAddresses(emailRecieversList);
                    }
                    mail.setSubject('New Sales-Broker Meeting Notification');
                    mail.setHtmlBody(htmlTextBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
        }
        
    }
    
    public static void getParrentId(Id i){    
        User ur = new User();
        ur = [select
              Id,
              Name,
              Manager.Id,
              Manager.Manager.Id,
              Manager.Manager.Manager.Id,
              Manager.Manager.Manager.Manager.Id,
              Manager.Manager.Manager.Manager.Manager.Id
              from User
              where Id =: i];
        ParentUserId.add(ur.Id);
        if(ur.Manager.Id!=null)
            ParentUserId.add(ur.Manager.Id);
        if(ur.Manager.Manager.Id!=null)
            ParentUserId.add(ur.Manager.Manager.Id);
        if(ur.Manager.Manager.Manager.Id!=null)
            ParentUserId.add(ur.Manager.Manager.Manager.Id);
        if(ur.Manager.Manager.Manager.Manager.Id!=null)
            ParentUserId.add(ur.Manager.Manager.Manager.Manager.Id);    }
    
}