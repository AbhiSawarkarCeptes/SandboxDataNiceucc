public class BrokerPortalFooterController {
    public String u_Id {get; set;}
    public String con_Id {get; set;}
    public BrokerPortalFooterController() {
        u_Id = ApexPages.currentPage().getParameters().get('userId') != null ? ApexPages.currentPage().getParameters().get('userId') : '';
        con_Id = ApexPages.currentPage().getParameters().get('userContactId') != null ? ApexPages.currentPage().getParameters().get('userContactId') : '';
    }
}