import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import resubmitToSM from '@salesforce/apex/PaymentRequestButtonController.resubmitToSM';

export default class UpdateDocumentStatus extends LightningElement {
    @api recordId;
    showSpinner = false;

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.showSpinner = true;
        resubmitToSM({ prId: this.recordId, remarks: fields.Remarks__c })
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