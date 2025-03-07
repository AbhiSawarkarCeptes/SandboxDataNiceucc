@isTest
public class N_ScreenPopControllerTest{
    
    @isTest
    private static void TestScreenPop1(){
    
       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
        Campaign camparent = new Campaign();
        camparent.Name = 'Test P Camp';
        camparent.IsActive = True;
        camparent.StartDate = System.today().addDays(0);
        camparent.EndDate = System.today().addDays(2); 
        camparent.Digital_Maketing_Campaign_Code__c= '+918068442375';
       // camparent.Project__c = p.id;
        insert camparent;
         
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '+918209989078');
        ApexPages.currentPage().getParameters().put('countryCode', '+91');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
    }

    @isTest
    private static void TestScreenPop2(){
    
        Id NewRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        System.debug('Id::: ' + NewRecordTypeId );
        Account a = new Account(lastName = 'Test2', PersonMobilePhone  = '8209989055', RecordTypeId = NewRecordTypeId, Country_Code__c = '+91');
        insert a;
        
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '8209989055');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
    }
    
    @isTest
    private static void TestScreenPop3(){
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '8209989011');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
    }
        
    @isTest
    private static void TestScreenPop4(){
    
       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998955';
        //l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '061820998955');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
    }
    
    @isTest
    private static void TestScreenPop5(){
    
      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
       
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998911';
       // l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '060820998911');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
    }

  @isTest
  private static void TestScreenPop6(){

        /*Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
   
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998777';
       // l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '0971820998777');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
  }

  @isTest
  private static void TestScreenPop7(){

       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
       
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998444';
       // l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '0965820998444');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
  }
    
    @isTest
  private static void TestScreenPop8(){

       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
       
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998123';
        //l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '0966820998123');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
  }
    
    @isTest
  private static void TestScreenPop9(){

       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
       
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998456';
       // l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '0974820998456');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
  }

    @isTest
  private static void TestScreenPop10(){

      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
       
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998789';
       // l1.Project__c=p.Id;
        insert l1;       
    
        Test.startTest();
        PageReference pRef = Page.N_ScreenPop;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '+918068442375');
        Apexpages.currentPage().getParameters().put('phone', '0968820998789');
        N_ScreenPopController sc = new N_ScreenPopController();
        sc.openScreen();
        Test.stopTest();
        
  }

    @isTest
  private static void TestScreenPop11(){

     /*   Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
       
      Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998780';
       // l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '0973820998780');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
  }
    
    @isTest
  private static void TestScreenPop12(){
    
       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
   
      Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998782';
       // l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '065820998782');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
  }
    
    @isTest
  private static void TestScreenPop13(){

      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
        Lead l1 = new Lead(); 
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '820998767';
        //l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '0852820998767');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
    
  }
    
    @isTest
  private static void TestScreenPop14(){

      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
            
        Lead l1 = new Lead(); 
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '82099878';
        //l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '097482099878');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
  }

   @isTest
  private static void TestScreenPop15(){

       /* Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
            
        Lead l1 = new Lead(); 
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '82099866';
       // l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '096882099866');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
  }
    
    @isTest
  private static void TestScreenPop16(){

      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
            
        Lead l1 = new Lead(); 
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '82099866';
       // l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '097382099866');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
  }

    @isTest
  private static void TestScreenPop17(){
    
      /*  Company_Master__c cm = TestDataFactory.createCompanyMaster('Test Company Master');
        Project_Group__c pg = TestDataFactory.createProjectGroup('Test Project Group');
        Tax__c tax = TestDataFactory.createTax('Text Tax');
        Project__c p = TestDataFactory.createProject('Test Project', cm.Id, pg.Id, tax.Id);*/
        
        Lead l1 = new Lead(); 
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.MobilePhone = '82099876';
      //  l1.Project__c=p.Id;
        insert l1;       

      Test.startTest();
      PageReference pRef = Page.N_ScreenPop;
      Test.setCurrentPage(pRef);
      Apexpages.currentPage().getParameters().put('did', '+918068442375');
      Apexpages.currentPage().getParameters().put('phone', '06582099876');
      N_ScreenPopController sc = new N_ScreenPopController();
      sc.openScreen();
      Test.stopTest();
    
  }
}