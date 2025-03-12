import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MobilePhone from '@salesforce/schema/Opportunity.Account_Mobile_Number__c';
import createTask from '@salesforce/apex/TeleSalesUtil.createTask';
const fields = [MobilePhone];

export default class TeleCallOpportunity extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    taskCreated = false;
    @wire(getRecord, { recordId: '$recordId', fields })
    Opportunity;

    renderedCallback() {
        var mobileNumber = (getFieldValue(this.Opportunity.data, MobilePhone) != null && getFieldValue(this.Opportunity.data, MobilePhone) != '' && getFieldValue(this.Opportunity.data, MobilePhone) != undefined) ? getFieldValue(this.Opportunity.data, MobilePhone) : '';
        console.log('renderedCallback() : ' + mobileNumber);
        if (mobileNumber != undefined && mobileNumber != null && mobileNumber != '' && this.taskCreated == false) {
            console.log('inside if : ' + mobileNumber);
            this.showSpinner = true;
            this.createTaskOnOpportunity(this.recordId, mobileNumber);
            this.taskCreated = true;
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            console.log('before clickToDial.click() : ' + mobileNumber);
            clickToDial.click();
            console.log('after clickToDial.click() : ' + mobileNumber);
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    get mobileNumber() {
        var mobileNumber = (getFieldValue(this.Opportunity.data, MobilePhone) != null && getFieldValue(this.Opportunity.data, MobilePhone) != '' && getFieldValue(this.Opportunity.data, MobilePhone) != undefined) ? getFieldValue(this.Opportunity.data, MobilePhone) : '';
        console.log('get mobileNumber() : ' + mobileNumber);
        return mobileNumber;
    }

    createTaskOnOpportunity(opptyId, mobileNo) {
        createTask({ opptyId: opptyId, mobileNumber: mobileNo })
            .then(result => {
                console.log(result);
            })
            .catch(error => {
            });
    }
}