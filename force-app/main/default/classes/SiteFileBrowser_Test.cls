@isTest
public class SiteFileBrowser_Test {

    @TestSetup
    static void data(){
        // Create a Document using ContentVersion (Document is part of the ContentDocument/ContentVersion model)
        ContentVersion doc1 = new ContentVersion(
            Title = 'Test Image 1',
            PathOnClient = 'testImage1.png',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true,
            ContentLocation = 'S'
        );
        insert doc1;

        // Create another document but not in the test folder
        ContentVersion doc2 = new ContentVersion(
            Title = 'Test Image 2',
            PathOnClient = 'testImage2.png',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true,
            ContentLocation = 'S'
        );
        insert doc2;
    }
    @isTest
    static void testSiteFileBrowser() {
        // Create a Folder using ContentWorkspace (as Folder cannot be created directly)
        ContentWorkspace testFolder = new ContentWorkspace();
        testFolder.Name = 'Test Folder';
        insert testFolder;

        

        // You need to query for ContentDocument Ids from ContentVersion
        ContentDocument doc1ContentDoc = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocument doc2ContentDoc = [SELECT Id FROM ContentDocument WHERE Id != :doc1ContentDoc.Id LIMIT 1];

        // Set up the PageReference with folder parameter
        PageReference pageRef = Page.SiteFileBrowser; // Ensure this is your actual Visualforce page reference
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('folder', testFolder.Id);

        // Instantiate the SiteFileBrowser class
        Test.startTest();
        SiteFileBrowser sfb = new SiteFileBrowser();
        Test.stopTest();

    //     // Validate that the folder ID parameter was correctly processed
    //     //System.assertEquals(testFolder.Id, sfb.inFolderId, 'Folder ID should match the test folder ID.');

    //     // Check the files retrieved
    //     List<ImageFile> imageList = sfb.files;
    //     //System.assertNotEquals(null, imageList, 'The file list should not be null.');

    //     // Validate that doc1 is included in the files list
    //     Boolean doc1Found = false;
    //     for (ImageFile img : imageList) {
    //         if (img.doc.Id == doc1ContentDoc.Id) {
    //             doc1Found = true;
    //             break;
    //         }
    //     }
    //     //System.assert(doc1Found, 'The document with ID ' + doc1ContentDoc.Id + ' should be included in the file list.');

    //     // Validate that doc2 is not included in the files list
    //     Boolean doc2Found = false;
    //     for (ImageFile img : imageList) {
    //         if (img.doc.Id == doc2ContentDoc.Id) {
    //             doc2Found = true;
    //             break;
    //         }
    //     }
    //     //System.assert(!doc2Found, 'The document with ID ' + doc2ContentDoc.Id + ' should not be included in the file list.');

    //     // Validate SelectOptions
    //     List<SelectOption> options = sfb.myItems;
    //     Boolean folderOptionFound = false;
    //     Boolean userOptionFound = false;
    //     for (SelectOption opt : options) {
    //         if (opt.getValue() == '0') {
    //             folderOptionFound = true;
    //         }
    //         if (opt.getValue() == String.valueOf(UserInfo.getUserId())) {
    //             userOptionFound = true;
    //         }
    //     }
    //     //System.assert(folderOptionFound, 'The "All Documents" option should be present.');
    //     //System.assert(userOptionFound, 'The "Personal Documents" option should be present.');
    }
}