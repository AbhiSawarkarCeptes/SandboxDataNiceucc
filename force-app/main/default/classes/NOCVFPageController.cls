public class NOCVFPageController {
    public Account acc {get;set;}
    public NOCVFPageController() {
        String recId = ApexPages.currentPage().getParameters().get('id'); 
        acc = new Account();

        if(recId != null && recId != '') {
            acc = [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry FROM Account WHERE Id = :recId];
        }
    }
}