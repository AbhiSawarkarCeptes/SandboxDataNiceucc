public class ReminderLetterController {
    public date todayDate{get;set;}
    public static String receivedPaymentName{get;set;}
    public list<PropStrength__Received_Payment__c> paylist {get;set;}
    public PropStrength__Received_Payment__c pay {get;set;}
    public string receivedPaymentId;

    public ReminderLetterController() {
        todayDate = Date.today();
        System.debug('url------'+ApexPages.currentPage().getParameters());
        receivedPaymentId = ApexPages.currentPage().getParameters().get('id');
        paylist = new list<PropStrength__Received_Payment__c>();
        pay = new PropStrength__Received_Payment__c();
        receivedPaymentName = '';
        System.debug('--Id---'+receivedPaymentId);
        mymethod();
      
    }
    public void mymethod(){
        if(receivedPaymentId != null){
        paylist = [Select Id,Name FROM PropStrength__Received_Payment__c where Id =:receivedPaymentId];
                   if(!paylist.isEmpty()){
                      pay =  paylist[0];
                       
                       receivedPaymentName  =pay.name; 
                   }   
                               
    }    
}
       

}