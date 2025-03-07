@isTest
public class trgReceiptTest {

     @testSetup
    static void setupTestData() {
        
        // Create User Group
        Group testUserGroup = new Group(
            Name = 'Test User Group',
            DeveloperName = 'Test_User_Group',
            Type = 'Regular'
            //RelatedId = null // Set to null for standalone group
        );
        insert testUserGroup;

        // Create Users
        List<User> testUsers = new List<User>();

        for(Integer i = 0; i < 5; i++) {
            User u = new User(
                FirstName = 'Test0' + i,
                LastName = 'User0',
                Email = 'testuser0' + i + '@example.com',
                Username = 'testuser00' + i + '@example123.com.invalid',
                Alias = 'tuser0' + i,
                CommunityNickname = 'tuser0' + i,
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            testUsers.add(u);
        }
        insert testUsers;

        // Assign Users to the User Group
        List<GroupMember> groupMembers = new List<GroupMember>();
        for(User u : testUsers) {
            GroupMember gm = new GroupMember(
                GroupId = testUserGroup.Id,
                UserOrGroupId = u.Id
                // Type can be 'User' or 'Group'
                //Type = 'User'
            );
            groupMembers.add(gm);
        }
        insert groupMembers;
    }

    @isTest
    static void testAuditApproval() {
        
    }
    @isTest public static void method1(){
         test.starttest();
        List<Demand__c> demandList = new List<Demand__c>();
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Date dat = system.today() + 50 ;
        Payment_Milestones__c pm = NewCustomerSOAControllerTest.createPaymentMilestone(q.Id,dat);
        
      
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';      
        insert b;
        
        test.Stoptest();
        
        Quotation__c q1 = new Quotation__c();
        q1.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q1.Unit__c = recordIdMap.get('UNIT');
        q1.Payment_Plan__c = recordIdMap.get('PLAN');
        q1.Quote_Status__c = 'Valid';
        insert q1;
        
        Payment_Milestones__c pm1 = NewCustomerSOAControllerTest.createPaymentMilestone(q1.Id,dat);

        user usr=[SELECT id, Name from User limit 1];
        Payment_Request__c preq= new Payment_Request__c();
       // preq.Name='Payment req 1';
        preq.Email__c='test@test.com';
        preq.Mobile_Number__c='986754352';
        preq.Emirates_Id_Passport_Number__c='343435436456';
        preq.Mode_Option__c='Single Mode';
        preq.Mode__c='Cheque';
        preq.Amount__c=2323232323.00;
        preq.Unit__c=recordIdMap.get('UNIT2');
        preq.Final_Approver__c=usr.Id;
        insert preq;
        
        
       
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c =recordIdMap.get('PROJECT');
        objRec.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec.Project_Unit__c = recordIdMap.get('UNIT');
        objRec.Booking__c = b.Id; 
        objRec.Receipt_Status__c = 'UnProcessed';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 500;
        objRec.Total_Amount__c = 500;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        objRec.Payment_Request__c=preq.Id;
        insert objRec; 
        objRec.Receipt_Status__c = 'Cleared';
        Update objRec;
        objRec.Receipt_Status__c = 'Cancelled';
        objRec.Cancellation_Reason__c = 'Insufficient Fund';
        Update objRec;
        
        Receipt__c objRec1 = new Receipt__c();
        objRec1.Project__c =recordIdMap.get('PROJECT');
        objRec1.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec1.Project_Unit__c = recordIdMap.get('UNIT');
        objRec1.Booking__c = b.Id; 
        objRec1.Receipt_Status__c = 'Cleared';
        objRec1.Mode__c = 'Cheque';
        objRec1.Cheque_DD__c = '12';
        objRec1.Remarks__c = true;
        objRec1.Amount_Rs__c = 500;
        objRec1.Total_Amount__c = 500;
        objRec1.Receipt_Date__c = System.today().addDays(-1);
        objRec1.Cheque_DD_Date__c = System.today();
        objRec1.Token_Amount_Receipt__c = true;
        objRec1.On_Account_Money__c = 0;
        objRec1.Currency__c = 'Indian Rupee';
        insert objRec1;
    }
}