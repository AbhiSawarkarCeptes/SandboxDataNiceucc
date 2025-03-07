/*********************************************************************
 * Class Name  :   CreateBirthdayCallTask
 * Description :   Batch class to create birthday call task for crm executive on Application/ Booking
 * Created Date:   08/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 08/02/2024
 *********************************************************************/
global class CreateBirthdayCallTask implements Database.Batchable <sObject>, Schedulable {
    
    global List<PropStrength__Applicant_Detail__c> start(Database.BatchableContext BC) {
        List<PropStrength__Applicant_Detail__c> appDetList = new List<PropStrength__Applicant_Detail__c>();
        appDetList = [SELECT Id, PropStrength__Application__c, PropStrength__Application__r.CRM_Executive__c , PropStrength__Active__c, 
                    PropStrength__Application__r.PropStrength__Active__c, 
                    PropStrength__Customer_Name__c, PropStrength__Applicant_Acc__r.Birthdate, PropStrength__Applicant_Email__c FROM 
                    PropStrength__Applicant_Detail__c WHERE PropStrength__Application__r.PropStrength__Active__c = TRUE AND PropStrength__Active__c = TRUE];
        return appDetList;
    }

    public void execute(SchedulableContext context) {
        CreateBirthdayCallTask batch = new CreateBirthdayCallTask();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<PropStrength__Applicant_Detail__c> scope) {
        System.debug('Scope::&&&&');
        System.debug(scope);
        List<Task> birthdayCallTask = new List<Task>();
        for(PropStrength__Applicant_Detail__c appDet : scope) {
            if(appDet.PropStrength__Application__r.CRM_Executive__c != null && appDet.PropStrength__Applicant_Acc__r.Birthdate != null && appDet.PropStrength__Applicant_Acc__r.Birthdate.day() == System.Today().day() && appDet.PropStrength__Applicant_Acc__r.Birthdate.month() == System.Today().month()) {
                Task tsk = new Task();
                tsk.Subject = 'Please make a call for Birthday';
                tsk.Status = 'Not Started';
                tsk.Priority = 'High';
                tsk.WhatId = appDet.PropStrength__Application__c;
                tsk.OwnerId = appDet.PropStrength__Application__r.CRM_Executive__c;
                tsk.ActivityDate = date.today();
                tsk.ReminderDateTime = system.now();
                tsk.IsReminderSet = true;
                birthdayCallTask.add(tsk);
            }
        }
        if(!birthdayCallTask.isEmpty()) {
            insert birthdayCallTask;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.schedule('CreateBirthdayCallTask_Daily'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new CreateBirthdayCallTask() );
    }
}