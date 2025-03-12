import { LightningElement, api } from 'lwc';
import updatePaymentStatus from '@salesforce/apex/MagnatiPaymentController.updatePaymentStatus';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PaymentRequestStatusCall extends LightningElement {

    @api recordId;
    showSpinner;
    message;
    isSuccess = false;
    isError = false;
    isHeader = true;

    
    updateStatus() {
        console.log(this.recordId);
        this.showSpinner = true;
        updatePaymentStatus({ paymentRequestId: this.recordId })
            .then(result => {
                console.log(result);
                if(result == 'SUCCESS') {
                    this.message = 'Status updated successfully';
                    this.isSuccess = true;
                    this.isHeader = false;
                } else if(result == 'ERROR'){
                    this.message = 'Failed to update the status. Please contact system administrator';
                    this.isError = true;
                    this.isHeader = false;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log(error);
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    
}