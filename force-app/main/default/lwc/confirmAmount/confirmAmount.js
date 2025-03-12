import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmAmount from '@salesforce/apex/PaymentRequestButtonController.confirmAmount';

export default class UpdateDocumentStatus extends LightningElement {
    @api recordId;
    showSpinner = false;

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        if (fields.Amount__c <= 0) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Amount cannot be 0',
            });
            this.dispatchEvent(evt);
        }
        else {
            this.showSpinner = true;
            confirmAmount({ amount: fields.Amount__c, referenceNo: fields.Reference_Number__c, accountReceivedDate: fields.Account_Received_Date__c, prId: this.recordId })
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
}