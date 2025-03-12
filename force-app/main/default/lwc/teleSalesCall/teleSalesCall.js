import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Phone from '@salesforce/schema/Lead.Phone';
import MobilePhone from '@salesforce/schema/Lead.MobilePhone';
const fields = [Phone, MobilePhone];

export default class TeleSalesCall extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    taskCreated = false;
    @wire(getRecord, { recordId: '$recordId', fields })
    Lead;

    renderedCallback() {
        var mobileNumber = (getFieldValue(this.Lead.data, MobilePhone) != null && getFieldValue(this.Lead.data, MobilePhone) != '' && getFieldValue(this.Lead.data, MobilePhone) != undefined) ? getFieldValue(this.Lead.data, MobilePhone) : getFieldValue(this.Lead.data, Phone);
        console.log('renderedCallback() : ' + mobileNumber);
        if (mobileNumber != undefined && mobileNumber != null && mobileNumber != '' && this.taskCreated == false) {
            console.log('inside if : ' + mobileNumber);
            this.showSpinner = true;
            this.taskCreated = true;
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            console.log('before clickToDial.click() : ' + mobileNumber);
            clickToDial.click();
            console.log('after clickToDial.click() : ' + mobileNumber);
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    get mobileNumber() {
        var mobileNumber = (getFieldValue(this.Lead.data, MobilePhone) != null && getFieldValue(this.Lead.data, MobilePhone) != '' && getFieldValue(this.Lead.data, MobilePhone) != undefined) ? getFieldValue(this.Lead.data, MobilePhone) : getFieldValue(this.Lead.data, Phone);
        console.log('get mobileNumber() : ' + mobileNumber);
        return mobileNumber;
    }
}