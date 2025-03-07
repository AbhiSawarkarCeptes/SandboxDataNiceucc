@isTest
private class testEOIformController {

    @IsTest	
    private static  void testEOIformController(){
             
        Unit__c u =new Unit__c();
        u.Name='Test';
        U.Unit_Status__c ='Available';
        insert u;
        
         Channel_Partner__c CP = New Channel_Partner__c();
        CP.Name ='FAST WAY REAL ESTATE BROKER';
        insert CP;
              
        EOI_Form__c EOI =new EOI_Form__c();
        EOI.Unit_Number__c= u.Id;
        //EOI.CurrencyIsoCode = 'AED - UAE Dirham';
       EOI.Source_of_EOI__c ='Channel Partner';
        EOI.Channel_Partner__c = CP.id;
        Insert EOI;
        
       /* Unit__c u1 =new Unit__c();
        u1.Name='Test1';
        u1.Unit_Status__c ='Available';
        insert u1;
        
        Channel_Partner__c CP = New Channel_Partner__c();
        CP.Name ='FAST WAY REAL ESTATE BROKER';
        insert CP;
                
        EOI_Form__c EOI1 =new EOI_Form__c();
        EOI1.Unit_Number__c= u1.Id;
        //EOI.CurrencyIsoCode = 'AED - UAE Dirham';
        EOI1.Channel_Partner__c =CP.Id;
        EOI1.Source_of_EOI__c = 'Channel Partner'
        Insert EOI1; */
        
  
    PageReference pRef1 = Page.EOIform;
        Test.setCurrentPage(pRef1);          
        ApexPages.currentPage().getParameters().put('id', EOI.id);
        EOIformController spa = new EOIformController();        
       }   
   
    
}