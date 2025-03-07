public class demandCheckController {
    public Date demandDate{get; set;}
    public Booking__c demand{get; set;}
    public string Ref{get; set;}
    public Id demandId ;
    public Set<string> towerexception = new Set<string>();
    public demandCheckController(){
        demandId = (Id) ApexPages.currentPage().getParameters().get('demandId');
        demandDate = System.today();
        demand = [SELECT Id,Primary_Applicant_Name__c,Opportunity__r.Other_Applicants_Name__c, 
                            Opportunity__r.Permanent_Address__c,Primary_Applicant_Email__c, PrimaryMobileNumber__c,Unit__r.name, Unit__r.Tower__r.Name,
                            Unit__r.Tower__r.RDS_Company_Code__r.Name,Unit__r.Tower__r.Address__c, Unit__r.Project__r.Name, Unit__r.Chargeable_Area__c,
                            Booking_Date__c, Agreement_Value__c, Tax_on_Purchase_Price__c , (SELECT Id,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c from Demands__r order by createddate desc LIMIT 1)
                            FROM Booking__c where Id = :demandId];
        towerexception.addAll(system.label.TowerException_For_Demand.split(','));
        if(demand.Unit__r.Name != null && String.isNotBlank(demand.Unit__r.Name))
        Ref = demand.Unit__r.Name + ', ';  
        if((demand.Unit__r.Tower__r.Name != null) && (String.isNotBlank(demand.Unit__r.Tower__r.Name)) && (!towerexception.contains(demand.Unit__r.Tower__r.Name)))
        Ref += demand.Unit__r.Tower__r.Name + ', ';
        if(demand.Unit__r.Tower__r.RDS_Company_Code__r.Name != null && String.isNotBlank(demand.Unit__r.Tower__r.RDS_Company_Code__r.Name))
        Ref += demand.Unit__r.Tower__r.RDS_Company_Code__r.Name + ', ';
        if(demand.Unit__r.Tower__r.Address__c != null && String.isNotBlank(demand.Unit__r.Tower__r.Address__c))
        Ref += demand.Unit__r.Tower__r.Address__c;
        if(Ref.substring(Ref.length()-2,Ref.length()-1) == ',')
        Ref = Ref.substring(0,Ref.length()-2);
        
    }
}