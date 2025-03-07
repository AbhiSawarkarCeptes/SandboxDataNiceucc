/*********************************************************************
 * Class Name  :   SPADocusignDocumentCreator
 * Description :   Helper Class of Flow Send SPA for Docusign (Flow)
 * Created Date:   15/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 15/01/2024
 *********************************************************************/
public class SPADocusignDocumentCreator {
    @InvocableMethod
    public static void spaAttacher(List<Id> transactionReqIds){
        Id trId = transactionReqIds[0];
        List<Attachment> attList = [SELECT Id, Name FROM Attachment WHERE ParentId = :trId AND Name = 'SPA Letter.pdf'];

        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:trId 
                                            AND ContentDocument.title = 'SPA Letter.pdf'];
                                                
    }
}