public with sharing class UpdateConsStageNew {
  public Id projectId {get;set;}
  public Project__c p {get;set;}
  public Id towerId {get;set;}
  public Id stageId {get;set;}
  public Date dueDate {get;set;}
  public Date plannedDate {get;set;} 
  public String updateType {get;set;}
  
  public attachment objattachment {
    get {
      if (objattachment == null) objattachment = new attachment();
      return objattachment;
    }
    set;
  }
  // constructor to intialize the project id based on the URL parameter
  public UpdateConsStageNew() {
    ProjectID = Apexpages.currentPage().getParameters().get('Pid');
    towerId = null;
    stageId = null;
    dueDate = null;
    plannedDate = null;
    updateType = ''; 
    if (ProjectID != null) {
      List < Project__c > lstProj = [select id, Name from Project__c where id = : ProjectID];
      if (lstProj.size() > 0) {
        p = lstProj[0];
      }
    }
  }
  // list of towers in this project
  public List <SelectOption> getTowerSelectList() {
    List <SelectOption> options = new List <Selectoption> ();
    List <Tower__c> qResult = new List <Tower__c> ([Select Id, Name from Tower__c where Project__c = : projectID order by Name]);
    options.add(new SelectOption('', 'Select a Tower'));
    for (Tower__c t: qResult) {
      options.add(new SelectOption(t.Id, t.Name));
    }
    return options;
  }

  // getting the list of construction stage related to the chosen tower
  public List <SelectOption> getConstructionSelectList() {
    List <Project_Construction_Stages__c> lstPConStg = [Select p.Id, p.Name from Project_Construction_Stages__c p
    where p.Project__c = :ProjectID and Tower__c = :towerId and Tower__c != null];
    System.debug('lstPConStg::: ' + lstPConStg);
    List <SelectOption> options = new List <SelectOption> ();
    if (lstPConStg.size() > 0) {
      options.add(new SelectOption('', 'Select a Stage'));
      for (Project_Construction_Stages__c PConStg: lstPConStg) {
        options.add(new SelectOption(PConStg.id, PConStg.Name));
      }
    }
    return options;
  }

  public list<SelectOption> updateOptions{
        get{
          list<SelectOption> searchOptions = new list<SelectOption>();
             searchOptions.add(new SelectOption('plannedDate', 'Planned Date'));
             searchOptions.add(new SelectOption('completionDate', 'Completion Date'));
            return searchOptions;
        }
        set;
    }
  // save method: updates the due date the project construction stage record, upload the arch certificate
  // as an attachment, updates the customer pay plan records associated with this construction stage mile stone.
  public pageReference save() {
    System.debug('Due Date:' + dueDate);
    System.debug('Planned Date:' + plannedDate);
    System.debug('update type:' + updateType);
    // planned Date logic
    if(String.isBlank(updateType)) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select a date to update'));
      return null;
    }
    if(updateType.equals('plannedDate') &&  plannedDate == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select a planned date'));
      return null;
    } 
   //// Added by Neha on 6/6/19 to restrict user from entering future date 
  /*  if(updateType.equals('plannedDate') &&  plannedDate != null && plannedDate > System.Today()) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Planned date cannot be future date'));
      return null;
    }*/
    else if(updateType.equals('plannedDate') &&  plannedDate != null){ // update the planned completionDate  
      try {
        Project_Construction_Stages__c pcons = new Project_Construction_Stages__c(id = stageId, Planned_date_of_completion__c = plannedDate);
        upsert pcons;
        System.debug('Due Date before calling update:' + DueDate);
        UpdCustPayPlanDueDatesforSoldUnits(plannedDate);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Planned Date Updated'));
      } catch (Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'error updating stage:' + e.getMessage()));
      } finally {
        stageId = null;
        towerId = null;
        dueDate = null;
        plannedDate = null;
        updateType = '';
        objattachment = null;
        return null;
      }
    } else if (updateType.equals('completionDate') && dueDate == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select an actual completion date'));
      return null;
    } else if (updateType.equals('completionDate') && dueDate != null && dueDate > System.Today()) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Completion date cannot be future date'));
      return null;
    } else if ( dueDate != null && (objattachment.name == null || objattachment.name == '')) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Architect certificate upload is mandatory for milestone completion'));
      return null;
    } else if(duedate != null){ //update the actual completion date
      try {
        upload();
        Project_Construction_Stages__c pcons = new Project_Construction_Stages__c(id = stageId, Actual_date_of_completion__c = dueDate);
        upsert pcons;
        System.debug('Due Date before calling update:' + DueDate);
        UpdCustPayPlanDueDatesforSoldUnits(dueDate);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Completion Date Updated'));
      } catch (Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'error updating stage:' + e.getMessage()));

      } finally {
        stageId = null;
        towerId = null;
        dueDate = null;
        plannedDate = null;
        updateType = '';
        objattachment = null;
        return null;
      }      
    } else {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occurred, due to incorrect data entered'));
    }
    return null;
  }

  // takes the user back to the project detail page
  public PageReference cancel() {
    PageReference pv = new PageReference('/' + p.Id);
    return pv;
  }

  // just a method for action function to call and then rerender the output panels
  // facing some issues with rerender, required input and page specific validations
  public void dummy() {
  }
  
  public PageReference refresh() {
    PageReference pRef = Apexpages.currentPage();
    pRef.setredirect(true);
    return pRef;
  }
  // method for uploading the architect certificate
  public boolean upload() {
    objattachment.OwnerId = UserInfo.getUserId();
    objattachment.IsPrivate = true;
    objattachment.ParentId = stageId;
    if (objattachment.ParentId != null) {
      insert objattachment;
      return true;
    }
    return false;
  }

  // method for updating the existing customer payplan records that
  // are linked to this specific milestone.
  public PageReference UpdCustPayPlanDueDatesforSoldUnits(Date d) {
      System.debug('Date received:' + d);
      List <Unit__c> lstProjectUnit = new List < Unit__c > ();
      set<id> quotIds = new Set<id>();
      List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
      List<Payment_Milestones__c> pmListForUpdate = new List<Payment_Milestones__c>();
      string QueryforUnit = null;
      
      QueryforUnit = 'Select id, Chargeable_Area__c, Booking__c, Booking__r.Quotation__c from Unit__c where ';
      QueryforUnit = QueryforUnit + ' createddate != null AND Booking__c != null AND Project__c = \'' + p.Id + '\' AND Tower__c = \'' + towerID + '\'';
      lstprojectunit = Database.query(QueryforUnit);
      
       if (lstprojectunit != null && !lstprojectunit.isEmpty()){
           for(Unit__C uObj : lstprojectunit){
               quotIds.add(uObj.Booking__r.Quotation__c);
           }    
       }
       if(!quotIds.isEmpty()){
           pmList = [select id, name, Quotation__c,Project_Construction_Stages__c,Milestone_Type_edit__c,Milestone_Due_Date__c,Milestone_Complete_At_Booking__c,Demand_Raised__c,Number_Of_Days__c,Quotation__r.Booking__r.Booking_Date__c,Time_Period__c,Is_Combination_Milestone__c,  
                     Quotation__r.Booking__c, Quotation__r.Name  from Payment_Milestones__c
                     where Project_Construction_Stages__c =:stageID AND Quotation__r.Booking__c != null AND
                     ((Milestone_Type_edit__c = 'Date Linked' AND Is_Combination_Milestone__c = true) OR 
                     Milestone_Type_edit__c = 'Construction Linked') AND is_demand_raised__c = false AND Quotation__c IN:quotIds];
       }
       if(pmList != null && !pmList.isEmpty()){       
           for(Payment_Milestones__c pm : pmList){
                if(updateType.equals('completionDate')) {
                    pm.Milestone_Due_Date__c = d;
                    if(pm.Milestone_Type_edit__c == 'Date Linked' && pm.Is_Combination_Milestone__c == true){
                        Date dt; 
                         if(pm.Number_Of_Days__c != null){
                            if(pm.Time_Period__c == 'Days')
                                dt = pm.Quotation__r.Booking__r.Booking_Date__c.date().addDays(Integer.valueOf(pm.Number_Of_Days__c));
                            else
                                dt = pm.Quotation__r.Booking__r.Booking_Date__c.date().addDays(Integer.valueOf(pm.Number_Of_Days__c) * 30);    
                        }
                        if(pm.Milestone_Due_Date__c > dt){
                        
                        }else if(pm.Milestone_Due_Date__c <= dt){
                            pm.Milestone_Due_Date__c = dt;
                        }
                    } else if(pm.Milestone_Type_edit__c == 'Construction Linked' && pm.Number_Of_Days__c != 0){
                        if(pm.Time_Period__c == 'Days')
                            pm.Milestone_Due_Date__c = d.addDays(Integer.valueOf(pm.Number_Of_Days__c));
                        else
                            pm.Milestone_Due_Date__c = d.addDays(Integer.valueOf(pm.Number_Of_Days__c) * 30);  
                    }
                    pm.Demand_Raised__c = True;
                    pmListForUpdate.add(pm); 
                }
                else if(updateType.equals('plannedDate')){
                    pm.Milestone_Due_Date__c = d;
                    pmListForUpdate.add(pm);
                }
                else{                
                }
           }                         
       }
       if(pmListForUpdate != null && !pmListForUpdate.isEmpty()){
           update pmListForUpdate;
       }
      return null;
  }
}