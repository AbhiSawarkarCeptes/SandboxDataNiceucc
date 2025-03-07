/*********************************************************************
 * Class Name  :   BookingFormDocusignDocumentCreatorClone
 * Description :   Helper Class of Flow Send Booking Form for Docusign Clone (Flow)
 * Created Date:   12/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 12/01/2024
 *********************************************************************/
public class BookingFormDocusignDocumentCreatorClone {
    @InvocableMethod
    public static void bookingFormAttacher(List<Id> appBookingIds){
        Id bookingId = appBookingIds[0];
        List<Attachment> attList = [SELECT Id, Name FROM Attachment WHERE ParentId = :bookingId AND Name = 'Booking_Form.pdf'];

        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:bookingId 
                                            AND ContentDocument.title = 'Booking Form.pdf'];
                                                
        /*if (attList.size() < 1 && docList.size() < 1) {
            PageReference PDf =  Page.Booking_Form;
            PDf.getParameters().put('id',bookingId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();

            Blob b ;
            if(Test.IsRunningTest())
                b= Blob.valueOf('This is Test');    
            else
                b= PDf.getContentAsPDF(); 

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = 'Booking_Form.pdf';
            contentVersion.Title = 'Booking_Form.pdf';
            contentVersion.VersionData = b;
            insert contentVersion;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = conDoc;
            contentDocumentLink.LinkedEntityId = bookingId;
            contentDocumentLink.ShareType = 'I';
            contentDocumentLink.Visibility = 'InternalUsers';
            insert contentDocumentLink;
        }*/
    }

    public static List<ContentDocumentLink> bookingFormAttacher1(List<Id> appBookingIds){
        Id bookingId = appBookingIds[0];
        
        PageReference PDf =  Page.Booking_Form;
        PDf.getParameters().put('id',bookingId);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();

        Blob b ;
        if(Test.IsRunningTest())
            b= Blob.valueOf('This is Test');    
        else
            b= PDf.getContentAsPDF(); 

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = 'Booking_Form.pdf';
        contentVersion.Title = 'Booking_Form.pdf';
        contentVersion.VersionData = b;
        insert contentVersion;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conDoc;
        contentDocumentLink.LinkedEntityId = bookingId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.Visibility = 'InternalUsers';
        insert contentDocumentLink;

        return [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:bookingId 
                                            AND ContentDocument.title = 'Booking_Form.pdf'];
    }
}