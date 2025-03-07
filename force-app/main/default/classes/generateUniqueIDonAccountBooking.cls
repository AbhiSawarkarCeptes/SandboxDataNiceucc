public class generateUniqueIDonAccountBooking
{
    @InvocableMethod(label = 'generateUniqueIDonAccountBooking')
    public static void  generateUniqueID(List<Id> Oppids)
    {
        System.debug('Booking Record creation');
        List<Id> accIds = new List<Id>();
        List<Account> acclst= New List<Account>(); 
        List<unit_hold_request__c> nsaLst = new List<unit_hold_request__c>();
        /* for(unit_hold_request__c nsa : [Select Id, Approval_Status__c from unit_hold_request__c where Opportunity__c= :Oppids]) 
{
if(nsa.Approval_Status__c=='Approved')
{
nsaLst.add(nsa); 
}
}
if(nsaLst.isEmpty())
{*/
        List<Account> acc = [Select Id, Unique_Customer_ID__c from Account where Unique_Customer_ID__c <> null order by Unique_Customer_ID__c desc Limit 1];
        for(Opportunity opp :[Select Id, AccountId from Opportunity where Id in :Oppids])
        {
            accIds.add(opp.AccountId);
        }
        for(Account genAcc : [Select Id, Unique_Customer_ID__c  from Account Where Id in :accIds])
        {
            If(genAcc.Unique_Customer_ID__c == null)
            {
                If(acc.isEmpty())
                {
                    genAcc.Unique_Customer_ID__c= String.valueOf(100000); 
                }
                else
                {
                    Integer nextUniqueCounter = Integer.valueOf(acc[0].Unique_Customer_ID__c) +1 ;
                    genAcc.Unique_Customer_ID__c= String.valueOf(nextUniqueCounter) ;
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