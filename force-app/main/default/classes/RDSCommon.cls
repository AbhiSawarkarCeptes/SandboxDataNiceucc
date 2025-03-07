// This Class is used as Common class for All TestClass
// --------------------------------------------------------------------------------------------- 

@istest
public class RDSCommon
 {
 
    
    public Static Legal_Entity__c CreateLegalEntity(Legal_Entity__c objlglentity)
    {
      insert objlglentity;            
       return objlglentity;
    }    
 /*   public Static Broker__c CreateBroker(Broker__c objBroK)
    {
      insert objBroK;            
       return objBroK;
    }*/
    public Static Project__c CreateProject(Project__c objpr )
    {
      insert objpr;            
       return objpr;
    }
  
     public Static Tower__c CreateTower(Tower__c t )
    {
      insert t;            
       return t;
    }
     
     public Static Tax_Slab__c CreateTaxSlab(Tax_Slab__c t )
    {
      insert t;            
      return t;
    }
    
    
/*    public Static Project_Unit_Type__c CreateProjectUnitType( Project_Unit_Type__c objProjectUnitType)
    {
      insert objProjectUnitType;            
       return objProjectUnitType;
    }*/
    public Static Rate_List__c CreateRateList(Rate_List__c rld)
    {
         
      insert rld;            
       return rld;
    }
    public Static ProjectCharges__c CreateProjectCharges(ProjectCharges__c PCharge )
    {
         
      insert PCharge;            
       return PCharge;
    }
    public Static Unit__c CreateProjectUnit(Unit__c  objPU)
    {
         
      insert objPU;             
       return objPU;
    }
    
    public Static Payment_Plan__c CreatePaymentPlan(Payment_Plan__c pp)
    {
         
      insert pp;             
       return pp;
    }
    
     public Static Receipt__c CreateReceipt(Receipt__c objRec  )
    {
      insert objRec;             
       return objRec;
    }
    public Static Receipt_Details__c CreateReceiptDetail(Receipt_Details__c objRecDtl)
    {
      insert objRecDtl;           
       return objRecDtl;
    }
       public Static Booking__c CreateBooking(Booking__c objBk)
    {
         
         insert objBk;
            
       return objBk;
    }
   
    public static Opportunity CreateOpportunity(Opportunity objopportunity)
   {
        
        insert objopportunity;
        return  objopportunity;
    }
   public static Account CreateAccount(Account ObjAcc)
   {
      insert objAcc;
   return ObjAcc;
   }
}