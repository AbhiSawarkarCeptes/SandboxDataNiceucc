import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getNPSSurveyMobileNumber from '@salesforce/apex/TeleCallButtonController.getNPSSurveyMobileNumber';

export default class NpsSurvey extends LightningElement {
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
            getNPSSurveyMobileNumber({ recordId: this.recordId })
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
                    this.showSpinner = false;
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