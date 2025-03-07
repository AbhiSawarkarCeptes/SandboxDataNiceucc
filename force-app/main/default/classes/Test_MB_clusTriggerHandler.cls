@isTest
public class Test_MB_clusTriggerHandler {
	
    @TestSetup
    static void testSetup(){
        List<Cluster__c> clusterList = new List<Cluster__c>();
        for(Integer i=0; i<6; i++){
            Cluster__c clus = new Cluster__c();
            if(i==1){
               clus = new Cluster__c( Name='PROJ'+i, Description__c='Ready to Move in (RTMI)',
                                     Min_Area__c = 100,
            						Max_Area__c = 200
                                     ); 
            } else {
            	clus = new Cluster__c( Name='PROJ'+i, Description__c='Ready to Move in (RTMI)',
                                     Min_Area__c = 100,
            						Max_Area__c = 200);
            }
            clusterList.add(clus);
        }
        insert clusterList;
        List<Amenity__c> ametiryList = new List<Amenity__c>();
        for(Integer i=0; i<5; i++){
            Amenity__c amt = new Amenity__c(Name ='TestAMT'+i, Type__c='PlayGround', Sub_Project__c=clusterList[i].Id);
            ametiryList.add(amt);
        }
        insert ametiryList;
        
        list<Attractions__c> attractionList = new List<Attractions__c>();
        for(Integer i=0; i<5; i++){
            Attractions__c attr = new Attractions__c(Name ='TestAMT'+i, Attraction_Type__c='Mall', Sub_Project__c=clusterList[i].Id);
            attractionList.add(attr);
        }
        insert attractionList;
    }
    
    @isTest
    static void testInsertMethod(){
        Map<Id, Cluster__c> oldMapData = new Map<Id, Cluster__c>();
    	List<Cluster__c> clusList = [SELECT Id, Name, Min_Area__c,Max_Area__c,  
                                        Description__c
                                       FROM Cluster__c];
       	system.debug('~~~~N: '+clusList);
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        	clusTriggerHandler.sendToMobileAPI(JSON.serialize(clusList), null);
       	Test.stopTest();
    }
    
    @isTest
    static void testUpdateMethod(){
        Map<Id, Cluster__c> projectMap = new Map<Id, Cluster__c>([SELECT Id,Name, Min_Area__c,Max_Area__c,  
                                        Description__c
                                       FROM Cluster__c]);
        
        List<Cluster__c> projectList2 = [SELECT Id,Name, Min_Area__c,Max_Area__c,  
                                        Description__c
                                       FROM Cluster__c];
        
        List<Cluster__c> projectList3 = new List<Cluster__c>();
        Integer k=6;
        
        for(Cluster__c prj : projectList2){
            if(k!=6){
                prj.name = 'TestProjectPR'+k;
                prj.Min_Area__c = 600;
                prj.Max_Area__c = 700;
                prj.Description__c = 'desc'+k;
            }
            if(k==8){
            	prj.name = null;
                prj.Min_Area__c = 600;
                prj.Max_Area__c = 700;
                prj.Description__c = 'desc'+k;
            }
            k++;
            projectList3.add(prj);
        }
        update projectList3;
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Success';
        Test.startTest(); 
       		Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        	clusTriggerHandler.sendToMobileAPI(JSON.serialize(projectList3), JSON.serialize(projectMap));
        Test.stopTest();
    }
}