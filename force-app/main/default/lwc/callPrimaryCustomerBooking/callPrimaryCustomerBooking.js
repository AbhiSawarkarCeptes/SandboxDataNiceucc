import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MobilePhone from '@salesforce/schema/Booking__c.PrimaryMobileNumber__c';
const fields = [MobilePhone];

export default class CallPrimaryCustomerBooking extends LightningElement {  

    @api recordId;
    showSpinner = false;
    taskCreated = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    Booking;

    renderedCallback() {
        var mobileNumber = (getFieldValue(this.Booking.data, MobilePhone) != null && getFieldValue(this.Booking.data, MobilePhone) != '' && getFieldValue(this.Booking.data, MobilePhone) != undefined) ? getFieldValue(this.Booking.data, MobilePhone) : '';
        console.log('renderedCallback() : ' + mobileNumber);
        if (mobileNumber != undefined && mobileNumber != null && mobileNumber != '' && this.taskCreated == false) {
            console.log('inside if : ' + mobileNumber);
            this.showSpinner = true;
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            console.log('before clickToDial.click() : ' + mobileNumber);
            clickToDial.click();
            console.log('after clickToDial.click() : ' + mobileNumber);
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    get mobileNumber() {
        var mobileNumber = (getFieldValue(this.Booking.data, MobilePhone) != null && getFieldValue(this.Booking.data, MobilePhone) != '' && getFieldValue(this.Booking.data, MobilePhone) != undefined) ? getFieldValue(this.Booking.data, MobilePhone) : '';
        console.log('get mobileNumber() : ' + mobileNumber);
        return mobileNumber;
    }

   

}