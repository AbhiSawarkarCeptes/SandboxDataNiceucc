public class generateUniqueIDonAccount 
{
	@InvocableMethod(label = 'generateUniqueIDonAccount')
    public static void  generateUniqueID(List<Id> Oppids)
    {
        System.debug('Running generateUniqueIDonAccount class');
        List<Id> accIds = new List<Id>();
        List<Account> acclst= New List<Account>();
        List<Account> acc = [Select Id, Unique_Customer_ID__c from Account where Unique_Customer_ID__c <> null order by Unique_Customer_ID__c desc Limit 1];
        System.debug('Acc: '+acc);
        for(Opportunity opp :[Select Id, AccountId from Opportunity where Id in :Oppids])
        {
           accIds.add(opp.AccountId);
        }
        for(Account genAcc : [Select Id, Unique_Customer_ID__c  from Account Where Id in :accIds])
        {
           System.debug('Verifying id exists, before generating'+genAcc.Unique_Customer_ID__c);
           If(genAcc.Unique_Customer_ID__c == null)
           {
              If(acc.isEmpty())
              {
                genAcc.Unique_Customer_ID__c=String.valueOf(100000); 
              }
               else
               {
                   Integer nextUniqueCounter = Integer.valueOf(acc[0].Unique_Customer_ID__c) +1 ;
                   genAcc.Unique_Customer_ID__c= String.valueOf(nextUniqueCounter);
               } 
               acclst.add(genAcc);
           }
        }
		if(!acclst.isEmpty())
        {
            ApplicantTriggerHandler.applicationTriggerProcess = true;
            update acclst;
            ApplicantTriggerHandler.applicationTriggerProcess = false;
        } 
    }
}