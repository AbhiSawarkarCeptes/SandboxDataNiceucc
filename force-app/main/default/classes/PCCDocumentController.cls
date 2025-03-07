public class PCCDocumentController {
    public String bookindId = null; 
    
    public PCCDocumentController() { 
        bookindId = ApexPages.currentPage().getParameters().get('Id');
    }
}