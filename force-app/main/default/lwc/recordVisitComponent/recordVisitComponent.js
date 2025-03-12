import { LightningElement,api ,wire} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import RECORD_VISIT_OBJECT from '@salesforce/schema/Record_Visit__c';
import Id from '@salesforce/user/Id';

export default class RecordVisitComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    userId = Id;
    
    connectedCallback(){
        
        if(this.objectApiName&& this.recordId){
            var fieldApiName = this.objectApiName;
            if(!fieldApiName.includes('__c')){
                fieldApiName = fieldApiName + '__c';
            }
            var fields = {
            'Visit_Time__c': new Date(),
        'Record_opened_by__c' : this.userId};
            fields[fieldApiName] = this.recordId;
            const recordInput = { apiName: RECORD_VISIT_OBJECT.objectApiName, fields };
            createRecord(recordInput)
            .then(response => {
            
            
            })
            .catch(error => {
            
            });
        }
       
    }
}