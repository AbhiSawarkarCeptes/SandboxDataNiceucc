import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getLeadMobileNumber from '@salesforce/apex/TeleCallButtonController.getBookingMobileNumber';

export default class NpsSurveyCallLead extends LightningElement {
    @api recordId;
    showSpinner = false;
    taskCreated = false;
    @track mobilePhone;
    @track apiCalled = false;
    @track refreshFlag = false;

    renderedCallback() {
        if (this.recordId != null && this.recordId != undefined && this.recordId != '' && this.apiCalled == false) {
            this.apiCalled = true;
            console.log('inside connectedCallback(): ' + this.recordId);
            this.showSpinner = true;
            getLeadMobileNumber({ recordId: this.recordId })
                .then(result => {
                    this.showSpinner = false;
                    if (result != null && result.includes('NPS Survey cannot be made')) {
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: result,
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        return;
                    }

                    var mobileNumber = result;
                    this.mobilePhone = result;
                    this.refreshFlag = true;

                    console.log('connectedCallback() : ' + mobileNumber);
                    if (mobileNumber != undefined && mobileNumber != null && mobileNumber != '' && this.taskCreated == false) {
                        console.log('inside if : ' + mobileNumber);
                        this.taskCreated = true;
                        var temp = this.template;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        setTimeout(function () {
                            const clickToDial = temp.querySelector('lightning-click-to-dial');
                            console.log('before clickToDial.click() : ' + mobileNumber);
                            clickToDial.click();
                            console.log('after clickToDial.click() : ' + mobileNumber);
                        }, 500);
                    }

                })
                .catch(error => {
                    console.log('connectedcallback error');
                    console.log(error);
                });
        }
    }

    get mobileNumber() {
        console.log('get mobileNumber() : ' + this.mobilePhone);
        return this.mobilePhone;
    }
}