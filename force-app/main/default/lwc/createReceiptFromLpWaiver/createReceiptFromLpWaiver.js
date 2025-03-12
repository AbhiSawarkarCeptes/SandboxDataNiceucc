import { LightningElement, track, api } from 'lwc';
import createReceipt from '@salesforce/apex/LatePaymentWaiverController.createReceipt';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateReceiptFromLpWaiver extends LightningElement {

    @api recordId;
    @track showSpinner;
    receiptCreated = false;

    renderedCallback() {
        if (this.recordId != undefined && !this.receiptCreated) {
            this.showSpinner = true;
            this.receiptCreated = true;
            createReceipt({ lpWaiverId: this.recordId })
                .then(result => {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Receipt created successfully.',
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch(error => {
                    this.showSpinner = false;
                });
        }
    }
}