import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import updatePaymentRequest from '@salesforce/apex/PaymentRequestButtonController.updatePaymentRequest';
export default class UpdatePaymentRequest extends LightningElement {
    @api recordId;
    showSpinner = false;

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.showSpinner = true;
        updatePaymentRequest({ prId: this.recordId, instrumentNumber: fields.Instrument_Number__c, instrumentDate: fields.Instrument_Date__c, referenceNumber: fields.Reference_Number__c })
            .then(result => {
                this.showSpinner = false;
                if (result == 'SUCCESS') {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
            });
    }
}