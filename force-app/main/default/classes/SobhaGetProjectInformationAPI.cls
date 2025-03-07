@RestResource(urlMapping='/sobhagetprojectinformation/')
global with sharing class SobhaGetProjectInformationAPI {
    
    @HttpGet
    global static List<Project__c> getProjectAndSubProjects(){
        RestRequest request = RestContext.request;
        List<Project__c> projectsWithSubProjects = [SELECT Id,Name,(SELECT Id,Name FROM Clusters__r) FROM Project__c LIMIT 49999];
        return projectsWithSubProjects;
    }
}