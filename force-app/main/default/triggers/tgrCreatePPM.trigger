/* Bypass Framework Enabled */
trigger tgrCreatePPM on Payment_Plan__c (after insert) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    List<Payment_Plan_Milestones__c> ppmilestone = new List <Payment_Plan_Milestones__c>();
    Set<Id> pIdSet = new Set<Id>();
    Set<Id> tIdSet = new Set<Id>();
    //Map <Id, List <projectCharges__c> > projectChargesMap = new Map < Id, List < projectCharges__c> >();
    Map <String, projectCharges__c> projectChargesMap = new Map < String, projectCharges__c >();
    List<Payment_plan__C> paymentList = new List<Payment_plan__c>(); 
    List<projectCharges__c> projectCList = new List<projectCharges__c>();
    for(Payment_Plan__c pp: trigger.new) {
        pIdSet.add(pp.Id);
    }
    if(!pIdSet.isEmpty()) {
        paymentList = [Select Id,NoofMilestones__c, Tower__c from Payment_plan__c where Id IN: pIdSet];
    }
    if(!paymentList.isEmpty()) {
        for(Payment_plan__c pl : paymentList) {
            tIdSet.add(pl.Tower__c); 
        }
    }
    if(!tIdSet.isEmpty()) {
        projectCList = [Select Id, Name, Active__c,Project__c,Tower__c from projectCharges__c where Tower__c IN : tIdSet and Active__c = true ORDER BY Code_Formula__c ASC];//Code__c 
    }
    
    if(!projectCList.isEmpty()) {
        Integer count = 1;
        for( projectCharges__c pc : projectCList) {
            projectChargesMap.put(pc.Tower__c+' '+count,pc);
            count ++;
            /*if(projectChargesMap.containsKey(pc.Tower__c))
                projectChargesMap.get(pc.Tower__c).add(pc);
            else{
                List<projectCharges__c> tempList = new List <projectCharges__c>();
                tempList.add(pc);
                projectChargesMap.put(pc.Tower__c, tempList);
            }
            */
        }
    }
    
    for(Payment_plan__c pp : paymentList) {
        for(Integer i=1;i<=pp.NoofMilestones__c;i++) {   
            Payment_Plan_Milestones__c ppm  = new Payment_Plan_Milestones__c();
            
             //ppm.Name='Milestone'+i;
             ppm.MilestoneNumber__c=i;  
             ppm.Payment_Plan__c=pp.Id;      
             for(Integer j=1; j<=25; j++) {
                 if(projectChargesMap.containsKey(pp.Tower__c+' '+j)) { 
                     ppm.put('Charge' + j + 'Value__c' , 0);
                     ppm.put('Charge' + j + 'Type__c' , 'Percentage');
                     ppm.put('Charge' + j + 'Name__c' , projectChargesMap.get(pp.Tower__c+' '+j).Name);
                     ppm.put('Charge_' + j + '_Lookup__c' , projectChargesMap.get(pp.Tower__c+' '+j).Id);
                 }
             }
             ppmilestone.add(ppm);
        }
    }
    insert ppmilestone; 
}