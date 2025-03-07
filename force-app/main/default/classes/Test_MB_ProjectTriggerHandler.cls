@isTest
public class Test_MB_ProjectTriggerHandler {
	
    @TestSetup
    static void testSetup(){
        List<Project__c> projectList = new List<Project__c>();
        for(Integer i=0; i<6; i++){
            Project__c proj = new Project__c();
            if(i==1){
               proj = new Project__c( Project_Code__c='PROJ'+i, Expiry_Days__c=+i, PossessionRequirement__c='Ready to Move in (RTMI)', 
                                     Configuration__c = '1 BHK'); 
            } else {
            	proj = new Project__c( Name='TestProjePR'+i, Project_Code__c='PROJ'+i, Expiry_Days__c=+i, 
                                             PossessionRequirement__c='Ready to Move in (RTMI)', Min_Budget__c=2323+i, 
                                             Configuration__c = '1 BHK', Max_Budget__c=3434+i, Address__c='Test'+i,
                                            Project_Stage__c = 're-launch', Project_Property_Type__c='Residential');
            }
            projectList.add(proj);
        }
        insert projectList;
        
        List<Amenity__c> ametiryList = new List<Amenity__c>();
        for(Integer i=0; i<5; i++){
            Amenity__c amt = new Amenity__c(Name ='TestAMT'+i, Type__c='PlayGround', Project__c=projectList[i].Id);
            ametiryList.add(amt);
        }
        insert ametiryList;
        
        list<Attractions__c> attractionList = new List<Attractions__c>();
        for(Integer i=0; i<5; i++){
            Attractions__c attr = new Attractions__c(Name ='TestAMT'+i, Attraction_Type__c='Mall', Project__c=projectList[i].Id);
            attractionList.add(attr);
        }
        insert attractionList;
    } 
    
    @isTest
    static void testInsertMethod(){
        Map<Id, Project__c> oldMapData = new Map<Id, Project__c>();
    	List<Project__c> projectList = [SELECT Id, Max_Budget__c, Address__c, Name, Min_Budget__c, longitude__c, latitude__c, 
                                        Project_Stage__c, Project_Property_Type__c
                                       FROM Project__c];
       	system.debug('~~~~N: '+projectList);
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        	ProjectTriggerHandler.sendToMobileAPI(JSON.serialize(projectList), null);
       	Test.stopTest();
    }
    
    
    @isTest
    static void testUpdateMethod(){
        Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Max_Budget__c, Address__c, Name, Min_Budget__c, longitude__c, latitude__c, 
                                        Project_Stage__c, Project_Property_Type__c
                                       FROM Project__c]);
        
        List<Project__c> projectList2 = [SELECT Id, Max_Budget__c, Address__c, Name, Min_Budget__c, longitude__c, latitude__c, 
                                        Project_Stage__c, Project_Property_Type__c
                                       FROM Project__c];
        
        List<Project__c> projectList3 = new List<Project__c>();
        
        Integer k=6;
        for(Project__c prj : projectList2){
            if(k!=6){
                prj.name = 'TestProjectPR'+k;
                prj.Project_Code__c='PRO'+k;
                prj.PossessionRequirement__c='Ready to Move in (RTMI)';
                prj.Min_Budget__c=2323+k;
                prj.Max_Budget__c = 3434+k;
                prj.Address__c='Tests'+k;
            }
            if(k==8){
            	prj.name = null;
                prj.Project_Code__c='PRO'+k;
                prj.PossessionRequirement__c='Ready to Move in (RTMI)';
                prj.Min_Budget__c=null;
                prj.Max_Budget__c = null;
                prj.Address__c=null; 
            }
            k++;
            projectList3.add(prj);
        }
        update projectList3;
        
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest();
       		Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        	ProjectTriggerHandler.sendToMobileAPI(JSON.serialize(projectList3), JSON.serialize(projectMap));
        Test.stopTest();
    }
    
}