@isTest
public class X_Test_RequestMetadata {
   @isTest
    static void testMetadata() {
        // Retrieve existing Xpedeon_API_Metadata__mdt record for Customer_Post
        Xpedeon_API_Metadata__mdt existingMetadataAPI = [SELECT Id, DeveloperName, End_Point__c, Method_Name__c FROM Xpedeon_API_Metadata__mdt WHERE DeveloperName = 'Customer_Post' LIMIT 1];

        Test.startTest();

        // Instantiate X_RequestMetadata
        X_RequestMetadata requestMetadata = new X_RequestMetadata(existingMetadataAPI.DeveloperName);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, requestMetadata.metadataAPI);
        System.assertNotEquals(null, requestMetadata.metadataHeaders);
        System.assertNotEquals(null, requestMetadata.staticMetadata);

       
    }

}