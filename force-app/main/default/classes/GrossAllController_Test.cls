@isTest
public class GrossAllController_Test {

    @testSetup 
    static void createData(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

        PropStrength__Assignment_Group_Name__c assgmtGroup = TestDataFactorySobha.createAssignmentGroup(null);
        insert assgmtGroup;

        PropStrength__Request__c request = TestDataFactorySobha.createEnquiry(null);
        insert request;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;

        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;
        
        PropStrength__Milestone_Group__c milestoneGrp = TestDataFactorySobha.createMilestoneGroup(null);
        insert milestoneGrp;
        
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        
        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        appBookObj.PropStrength__Status__c = 'Audit Approved';
        appBookObj.Termination_Process_Status__c = 'Rejected by Audit';
        insert appBookObj;
    }

    @isTest static void getBookingsByBucketTest1(){
        PropStrength__Projects__c project = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        
        Test.startTest();        
        PropStrength__Payment_Plan_Details__c planDetails1 = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails1.PropStrength__Amount_Due__c = 1000;
        planDetails1.PropStrength__Is_Milestone_Completed__c = true;
        insert planDetails1;
        
        PropStrength__Payment_Plan_Details__c planDetails2 = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails2.PropStrength__Amount_Due__c = 1000;
        planDetails2.PropStrength__Is_Milestone_Completed__c = true;
        insert planDetails2;
        
        GrossAllController.getProjects();
        GrossAllController.getBookingsByBucket(project.id, 'All','Gross All', 'Green');
        GrossAllController.getBookingsByBucket(project.id, 'All','Gross All', 'White');
        GrossAllController.getBookings(project.id, tower.Id);
        Test.stopTest();
    }
    
    @isTest static void getBookingsByBucketTest2(){
        PropStrength__Projects__c project = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        
        PropStrength__Payment_Plan_Details__c planDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails.PropStrength__Amount_Due__c = 1000;
        planDetails.PropStrength__Is_Milestone_Completed__c = true;
        planDetails.PropStrength__Final_Payment_Date__c = (System.now().addDays(-40)).date();
        insert planDetails;
        
        Test.startTest();
        GrossAllController.getBookingsByBucket(project.id, tower.Id, 'Gross All', 'Yellow');
        GrossAllController.getBookings(project.id, tower.Id);
        Test.stopTest();
    }
    
    @isTest static void getBookingsByBucketTest3(){
        PropStrength__Projects__c project = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Payment_Plan_Details__c planDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails.PropStrength__Amount_Due__c = 1000;
        planDetails.PropStrength__Is_Milestone_Completed__c = true;
        planDetails.PropStrength__Final_Payment_Date__c = (System.now().addDays(-70)).date();
        insert planDetails;
        
        Test.startTest();
        GrossAllController.getBookingsByBucket(project.id, 'All','Gross All', 'Amber');
        Test.stopTest();
    }
    
    @isTest static void getBookingsByBucketTest4(){
        PropStrength__Projects__c project = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Payment_Plan_Details__c planDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails.PropStrength__Amount_Due__c = 1000;
        planDetails.PropStrength__Is_Milestone_Completed__c = true;
        planDetails.PropStrength__Final_Payment_Date__c = (System.now().addDays(-100)).date();
        insert planDetails;
        
        Test.startTest();
        GrossAllController.getBookingsByBucket(project.id, 'All','Gross All', 'Red');
        Test.stopTest();
    }
    
    @isTest static void getBookingsByBucketTest5(){
        PropStrength__Projects__c project = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Payment_Plan_Details__c planDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails.PropStrength__Amount_Due__c = 1000;
        planDetails.PropStrength__Is_Milestone_Completed__c = true;
        insert planDetails;
        
        Test.startTest();
        GrossAllController.getBookingsByBucket(project.id, 'All','Gross All', 'White');
        Test.stopTest();
    }
    
    @isTest static void sendEmailTest(){
        Test.startTest();
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];  
        PropStrength__Payment_Plan_Details__c planDetails1 = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails1.PropStrength__Amount_Due__c = 1000;
        planDetails1.PropStrength__Is_Milestone_Completed__c = true;
        insert planDetails1;
        
        PropStrength__Payment_Plan_Details__c planDetails2 = TestDataFactorySobha.createPaymentPlanDetail(null);
        planDetails2.PropStrength__Amount_Due__c = 1000;
        planDetails2.PropStrength__Is_Milestone_Completed__c = true;
        insert planDetails2;
              
        String taskId = GrossAllController.createTaskOnCall(booking.Id);   
        GrossAllController.updateLastActionOnBooking('', booking.Id, taskId, '');   
        GrossAllController.ppdSubmitted(new List<String>{booking.Id});
        Test.stopTest();        
    }
    
    @isTest static void sendBankDetailsEmailTest(){
        Test.startTest(); 
        PropStrength__Property__c unit = [SELECT Id FROM PropStrength__Property__c LIMIT 1];        
        PropStrength__Application_Booking__c booking = TestDataFactorySobha.createApplicationBooking(null);
        booking.PropStrength__Status__c = 'Audit Approved';
        booking.PropStrength__Applicant_Email__c = 'username@email.com';
        booking.PropStrength__Property__c = unit.Id;
        insert booking;
               
        PropStrength__Broker_Payment_Milestone__c paymtMilestone = new PropStrength__Broker_Payment_Milestone__c();
        paymtMilestone.PropStrength__Booking_ID__c = booking.Id;
        paymtMilestone.PropStrength__Brokerage_Paid__c = 500;
        paymtMilestone.PropStrength__Due_Date__c = Date.Today();
        insert paymtMilestone;
        
        PropStrength__Broker_Payment_Milestone__c paymtMilestone2 = new PropStrength__Broker_Payment_Milestone__c();
        paymtMilestone2.PropStrength__Booking_ID__c = booking.Id;
        paymtMilestone2.PropStrength__Brokerage_Paid__c = 500;
        paymtMilestone2.PropStrength__Due_Date__c = Date.today() + 180;
        insert paymtMilestone2;
        
        try{
            GrossAllController.sendBankDetailsEmail(unit.Id);    
        }
        catch(Exception e){}
        GrossAllController.createTask(new List<String>{booking.Id}); 
        GrossAllController.getMonthList();  
        
        Test.stopTest();        
    }
    
    @isTest static void getTowerDataTest(){
        Test.startTest();
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        
        PropStrength__Property__c unit = [SELECT Id FROM PropStrength__Property__c LIMIT 1];        
        PropStrength__Application_Booking__c booking2 = TestDataFactorySobha.createApplicationBooking(null);
        booking2.PropStrength__Status__c = 'Audit Approved';
        booking2.Termination_Process_Status__c = 'Rejected by Audit';
        booking2.PropStrength__Property__c = unit.Id;
        insert booking2;
        
        PropStrength__Broker_Payment_Milestone__c paymtMilestone = new PropStrength__Broker_Payment_Milestone__c();
        paymtMilestone.PropStrength__Booking_ID__c = booking.Id;
        paymtMilestone.PropStrength__Brokerage_Paid__c = 500;
        paymtMilestone.PropStrength__Due_Date__c = Date.Today();
        insert paymtMilestone;
        
        PropStrength__Broker_Payment_Milestone__c paymtMilestone2 = new PropStrength__Broker_Payment_Milestone__c();
        paymtMilestone2.PropStrength__Booking_ID__c = booking2.Id;
        paymtMilestone2.PropStrength__Brokerage_Paid__c = 500;
        paymtMilestone2.PropStrength__Due_Date__c = Date.Today();
        insert paymtMilestone2;
        
        PropStrength__Broker_Payment_Milestone__c paymtMilestone3 = new PropStrength__Broker_Payment_Milestone__c();
        paymtMilestone3.PropStrength__Booking_ID__c = booking.Id;
        paymtMilestone3.PropStrength__Brokerage_Paid__c = 500;
        paymtMilestone3.PropStrength__Due_Date__c = Date.today() + 180;
        insert paymtMilestone3;
        
        GrossAllController.getTowerData('All');
        GrossAllController.getTowerData(tower.Id);
        GrossAllController.getTargetData();
        GrossAllController.getCategoryData('All');
        GrossAllController.getCategoryData(tower.Id);
        GrossAllController.getAgeingData('All');
        GrossAllController.getAgeingData(tower.Id);
        Test.stopTest();
    }
}