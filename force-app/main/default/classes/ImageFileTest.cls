@IsTest
public class ImageFileTest {
    
    @IsTest
    static void testImageFileConstructor() {
        Document testDocument = new Document(
            Name = 'Test Document',
            Body = Blob.valueOf('Test body'),
            ContentType = 'text/plain',
            FolderId = System.Userinfo.getUserId()
        );
        
        insert testDocument;
        
        String testUrl = 'http://example.com/testimage.png';
        
        ImageFile imageFile = new ImageFile(testDocument, testUrl);
    }
}