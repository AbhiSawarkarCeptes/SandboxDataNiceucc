@isTest
public class ProjectTriggerHelper_Test {
    @TestSetup
    static void setup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    }
    
    @isTest
    static void Test1(){
        PropStrength__Projects__c project = new PropStrength__Projects__c();
        project.Name = 'Test Project 1'+String.valueOf(Math.random()).substring(0,5);
        project.Master_Project__c = null;
        project.Min_Area__c = null;
        project.Max_Area__c = null;
        project.PropStrength__Description__c = 'Description';
        insert project;
        
        Amenity__c amenity = new Amenity__c();
        amenity.Name = 'Test Amenity' ;
        amenity.Type__c = 'GYM' ;
        amenity.Project_PS__c = project.Id;
        insert amenity;
        
        Attractions__c attract = new Attractions__c();
        attract.Name = 'Test Attraction';
        attract.Attraction_Type__c = 'Cinemas';
        attract.Project_PS__c = project.Id;
        insert attract;
        
        project.Name = 'Test Project 2';
        update project;
        
    }
}