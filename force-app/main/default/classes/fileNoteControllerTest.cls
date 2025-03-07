@isTest
public class fileNoteControllerTest {

    @isTest
    public static void testFileNote() {
        Mobile_TestUtil.createBooking();
        Booking__c thisBooking = [SELECT Id from Booking__c LIMIT 1];
         Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project1');
       
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordMap.get('OPPORTUNITY');
        q.Unit__c = recordMap.get('UNIT');
        q.Payment_Plan__c = recordMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        q.Booking__c = thisBooking.Id;
        insert q;               
        Applicant_Details__c app = new Applicant_Details__c();
        app.name = 'test';
        app.Booking__c = thisBooking.id;
        app.City__c = 'Dubai';
        app.Mailing_City__c = 'Dubai';
        app.State__c = 'Dubai';
        app.Mailing_State__c = 'Dubai';
        app.Country__c = 'uae';
        app.Mailing_country__c = 'uae';
        app.Mailing_Address__c = 'uae';
        app.Permanent_Address__c = 'uae';
        app.Pincode__c = 000;
        app.Mailing_Pincode__c = 000;
        insert app;
        
        Test.startTest();
        PageReference pRef = Page.fileNotePage;
        Test.setCurrentPage(pRef);   
        
        ApexPages.currentPage().getParameters().put('id', thisBooking.id);
        filenoteController fController = new filenoteController();
        filenoteController.PMWrapper wrap = new filenoteController.PMWrapper(1.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(2.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(3.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(4.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(5.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(6.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(7.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(8.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(9.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(10.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(11.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(12.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(13.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(14.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(15.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(16.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(17.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(18.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(19.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(20.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(21.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(22.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(23.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(24.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(25.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(26.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(27.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(28.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(29.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(30.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(31.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(32.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(33.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(34.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(35.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(36.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(37.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(38.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(39.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(40.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(40.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(41.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(42.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(43.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(44.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(45.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(46.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(47.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(48.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(49.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(50.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        wrap = new filenoteController.PMWrapper(51.0,System.Today(),'test', 'test',1.0,True, 'test',1.0);
        filenoteController.ADWrapper wrap2 = new filenoteController.ADWrapper(app);
        filenoteController.CarParkWrapper wrap3 = new filenoteController.CarParkWrapper();
        filenoteController.dummyMethod();
        Test.stoptest();
    }
}