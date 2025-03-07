@isTest
public class masterProjectTriggerHelper_test {
    
    @testSetup
    Static void makeData(){
        Master_Project__c project = new Master_Project__c(
            Name = 'Test Project',
            Street__c = '123 Test St',
            City__c = 'Test City',
            State_Province__c = 'TS',
            Zip_Postal_Code__c = '12345',
            Country__c = 'india',
            Max_Budget__c = 100000,
            Min_Budget__c = 50000,
            longitude__c = '123.456',
            latitude__c = '78.910',
            Status__c = 'On Hold',
            Type_of_Project__c = 'Retail'
        );
       
        insert project;
    }

    @isTest
    static void testSendToMobileMasterProject_Update() {
        
        List<Master_Project__c> mpList = [select id, name from Master_Project__c ];
        for(Master_Project__c mp : mpList){
			mp.name = mp.name + 'testUpdate';
        }
        
        Amenity__c amt = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Master_Project__c = mpList[0].Id);
        insert amt;
        
        Attractions__c attr = new Attractions__c(Name ='TestAMT', Attraction_Type__c='Cinemas', Master_Project__c = mpList[0].Id);
 		insert attr;
        update mpList;
    }
    
    @isTest
    static void testSendToMobileMasterProject_Insert() {
        // Setup test data

        
        Master_Project__c project = new Master_Project__c(
            Name = 'Test Project',
            Street__c = '123 Test St',
            City__c = 'Test City',
            State_Province__c = 'TS',
            Zip_Postal_Code__c = '12345',
            Country__c = 'india',
            Max_Budget__c = 100000,
            Min_Budget__c = 50000,
            longitude__c = '123.456',
            latitude__c = '78.910',
            Status__c = 'On Hold',
            Type_of_Project__c = 'Retail'
        );
        
        Test.startTest();
        
        // Insert record
        insert project;
        // for exception Coveraage
        project.Name = 'Test Project';
        update project;
        // Trigger should call the method
        Test.stopTest();

    }
    
    

    @isTest
    static void testSendToMobileMasterProject_TriggerFlagFalse() {
        // Setup test data
     
        Master_Project__c project = new Master_Project__c(
            Name = 'Test Project',
            Street__c = '123 Test St',
            City__c = 'Test City',
            State_Province__c = 'TS',
            Zip_Postal_Code__c = '12345',
            Country__c = 'india',
            Max_Budget__c = 100000,
            Min_Budget__c = 50000,
            longitude__c = '123.456',
            latitude__c = '78.910',
            Status__c = 'On Hold',
            Type_of_Project__c = 'Retail'
        );
        
        Test.startTest();
        insert project;
        Test.stopTest();
        
 
    }

    @isTest
    static void testSendToMobileAPIMasterProject() {
        // Setup test data
     
        Master_Project__c project = new Master_Project__c(
            Name = 'Test Project',
            Street__c = '123 Test St',
            City__c = 'Test City',
            State_Province__c = 'TS',
            Zip_Postal_Code__c = '12345',
            Country__c = 'india',
            Max_Budget__c = 100000,
            Min_Budget__c = 50000,
            longitude__c = '123.456',
            latitude__c = '78.910',
            Status__c = 'On Hold',
            Type_of_Project__c = 'Retail'
        );
         
        insert project;
        Test.startTest();
        masterProjectTriggerHelper.sendToMobileAPIMasterProject(new Set<Id>{project.Id});
        Test.stopTest();
 
    }
}