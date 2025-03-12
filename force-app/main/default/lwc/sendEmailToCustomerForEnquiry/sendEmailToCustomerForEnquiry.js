import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailToCustomer from '@salesforce/apex/EnquiryNurturingController.sendEmailToCustomer';
import loadEmailTemplate from '@salesforce/apex/EnquiryNurturingController.loadEmailTemplate';

export default class SendEmailToCustomerForEnquiry extends LightningElement {
    @api recordId;
    showSpinner = false;
    @track emailBody = '';
    @track dataLoaded = false;

    sendEmail() {
        this.showSpinner = true;
        sendEmailToCustomer({ dayTrackingId: this.recordId })
            .then(result => {
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    variant: 'success',
                    message: 'Email sent successfully.',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    connectedCallback() {
        this.showSpinner = true;
        setTimeout(() => {
            loadEmailTemplate({ dayTrackingId: this.recordId })
                .then(result => {
                    this.showSpinner = false;
                    this.emailBody = result;
                    this.dataLoaded = true;
                })
                .catch(error => {
                    this.showSpinner = false;
                });
        }, 1000);
    }
}