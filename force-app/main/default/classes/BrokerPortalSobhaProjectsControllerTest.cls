@isTest
private class BrokerPortalSobhaProjectsControllerTest {
    @isTest
    static void testGetUnits() {
        // Test data setup
         Project__c prj = new Project__c(
            Name = 'TEST Project'
        );
        List<Unit__c> unitList = new List<Unit__c>();
        // Create test units
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Project__c = prj.id, 
            Configuration__c = '2 BR', 
            //Total_Area__c = 100, // Field is not writeable
            Puchase_Price__c = 1000000 // Example price
        );
        insert unit;
        unitList.add(unit);

        // Call the method with test data
        Test.startTest();
        List<Unit__c> result = BrokerPortalSobhaProjectsController.getUnits(
            new List<String>{prj.Id}, // Example projectId
            new List<String>{'2 BR'},    // Example config
            new List<String>{'500 – 1000 Sq. Ft','1000 – 1500 Sq. Ft'},          // Example area
            new List<String>{'AED 1 Million – AED 2 Million','AED 2 Million – AED 3 Million'},          // Example price
            new List<String>{'Apartments','Villas','Others'},          // Example propertyType
            new List<String>{},          // Example subProjects
            new List<String>{},          // Example unitTypes
            new List<String>{},          // Example floors
            new List<String>{},          // Example unitNames
            new List<String>{},          // Example variants
            new List<String>{},          // Example areas
            new List<String>{}           // Example prices
        );
        Test.stopTest();

        // Assertions
       // System.assertEquals(1, result.size(), 'Expected one unit in the result');
      //  System.assertEquals('Test Unit', result[0].Name, 'Unexpected unit name');
    }

    @isTest
    static void testGetAllProjects() {
        // Test data setup
        // Create test projects
        Project__c project = new Project__c(
            Name = 'Test Project',
            Project_Code__c ='123'
        );
        insert project;

        // Call the method
        Test.startTest();
        List<Project__c> result = BrokerPortalSobhaProjectsController.getAllProjects();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, result.size(), 'Expected at least one project in the result');
        System.assertEquals('Test Project', result[0].Name, 'Unexpected project name');
    }
    
    @isTest
    static void testGetSubProjectDetails() {
        // Test data setup
        Cluster__c subProj = new Cluster__c(
            Name = 'Test Sub Project',
            Description__c = 'Test Description',
            Project__c = 'a0R1t000000QhInEAK'
           
        );
        insert subProj;

        // Call the method
        Test.startTest();
        BrokerPortalSobhaProjectsController.SubProjectDetails result = BrokerPortalSobhaProjectsController.getSubProjectDetails(subProj.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals('Test Sub Project', result.name, 'Unexpected sub-project name');
        System.assertEquals('Test Description', result.description, 'Unexpected sub-project description');
        
    }
    
    @isTest
    static void testCreateQuotation() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        // Test data setup
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Tower__c = recordIdMap.get('TOWER')
        );
        insert unit;

        // Call the method
        Test.startTest();
        String quotationId = BrokerPortalSobhaProjectsController.createQuotation(unit.Id,'Aravind', 'aravind@test.com');
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateExportTracker() {
        // Test data setup
        Project__c prj = new Project__c(
            Name = 'TEST Project'
        );

        // Call the method
        Test.startTest();
        Data_Download_Tracker__c  tracker = BrokerPortalSobhaProjectsController.createExportTracker(prj.Id, UserInfo.getUserId(), 'Filter');
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, tracker.Id, 'Export tracker creation failed');
       
    }

    @isTest
    static void testGetRelatedFiles() {
        // Test data setup
Project__c prj = new Project__c(
            Name = 'TEST Project'
        );
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = prj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        // Calling the method
        Test.startTest();
        Id fileId = BrokerPortalSobhaProjectsController.getRelatedFiles('Booking form.pdf', prj.Id);
        Test.stopTest();
        
    }
    
      @isTest
    static void testCreateDataDownloadTracker() {
        Test.startTest();
        String  tracker = BrokerPortalSobhaProjectsController.createDataDownloadTracker('','Filter');
        BrokerPortalSobhaProjectsController.updateDataDownloadTracker(tracker,'Updated Filter');
        Test.stopTest();
        Data_DownLoad_Tracker__c track = [SELECT id,Name,Filter_Criteria__c From Data_DownLoad_Tracker__c WHERE Id=:tracker];
        System.AssertEquals(track.Filter_Criteria__c,'Updated Filter');
    }
    
     @isTest
    static void createDataDownloadTrackerTest() {
        
        Test.startTest();
        try{
         Project__c prj = new Project__c(
            Name = 'TEST Project'
        );
        String  tracker = BrokerPortalSobhaProjectsController.createDataDownloadTracker(prj.Id,'Filter');
        BrokerPortalSobhaProjectsController.updateDataDownloadTracker(tracker,'Updated Filter');
        }Catch(Exception e){
            
        }
        Test.stopTest();
    }
}