import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MobilePhone from '@salesforce/schema/Account.PersonMobilePhone';
import createTask from '@salesforce/apex/TeleSalesUtil.createTaskOnAccount';
const fields = [MobilePhone];

export default class TelecallAccount extends LightningElement {  

    @api recordId;
    showSpinner = false;
    taskCreated = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    Account;

    renderedCallback() {
        var mobileNumber = (getFieldValue(this.Account.data, MobilePhone) != null && getFieldValue(this.Account.data, MobilePhone) != '' && getFieldValue(this.Account.data, MobilePhone) != undefined) ? getFieldValue(this.Account.data, MobilePhone) : '';
        console.log('renderedCallback() : ' + mobileNumber);
        if (mobileNumber != undefined && mobileNumber != null && mobileNumber != '' && this.taskCreated == false) {
            console.log('inside if : ' + mobileNumber);
            this.showSpinner = true;
            this.createTaskOnAccount(this.recordId, mobileNumber);
            this.taskCreated = true;
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            console.log('before clickToDial.click() : ' + mobileNumber);
            clickToDial.click();
            console.log('after clickToDial.click() : ' + mobileNumber);
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    get mobileNumber() {
        var mobileNumber = (getFieldValue(this.Account.data, MobilePhone) != null && getFieldValue(this.Account.data, MobilePhone) != '' && getFieldValue(this.Account.data, MobilePhone) != undefined) ? getFieldValue(this.Account.data, MobilePhone) : '';
        console.log('get mobileNumber() : ' + mobileNumber);
        return mobileNumber;
    }

    createTaskOnAccount(accId, mobileNo) {
        createTask({ accId: accId, mobileNumber: mobileNo })
            .then(result => {
                console.log(result);
            })
            .catch(error => {
            });
    }

}