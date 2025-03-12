import { LightningElement, api } from 'lwc';
import sendEmail from '@salesforce/apex/SendResaleNocDocController.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SendResaleNocDoc extends LightningElement {
    @api recordId;
    showSpinner = false;

    // _recordId;
    // set recordId(recordId) {
    //     if (recordId !== this._recordId) {
    //         this._recordId = recordId;
    //     }
    // }

    @api invoke() {
        console.log('recordId: ', this.recordId);
        this.showSpinner = true;
        sendEmail({
            resaleId: this.recordId
        })
            .then(data => {
                this.toast('Success', 'Document Sent Successfully', 'success');
            })
            .catch(error => {
                console.log('~~~Error'+JSON.stringify(error));
                this.toast('Error', error.body.message, 'error');
            })
            .finally(() => this.showSpinner = false);
    }
    // connectedCallback() {
    //     this.showSpinner = true;
    //     sendEmail({
    //         resaleId: this.recordId
    //     })
    //         .then(data => {
    //             this.toast('Success', 'Document Sent Successfully', 'success');
    //         })
    //         .catch(error => {
    //             console.log('~~~Error'+JSON.stringify(error));
    //             this.toast('Error', error.body.message, 'error');
    //         })
    //         .finally(() => this.showSpinner = false);
    // }

    toast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            }),
        );
    }

}