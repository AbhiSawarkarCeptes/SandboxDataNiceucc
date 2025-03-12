import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eztapCancelTransaction from '@salesforce/apex/InitiateEztapController.eztapCancelTransaction';

export default class EztapCancelTransaction extends LightningElement {
    @api recordId;
    showSpinner = false;
    @track status = '';

    connectedCallback() {
        this.showSpinner = true;
        setTimeout(() => {
            eztapCancelTransaction({ prId: this.recordId })
                .then(result => {
                    this.showSpinner = false;
                    let res = result;
                    if (res.split('#')[0] == 'SUCCESS') {
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: 'Eztab transaction has been canceled.',
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        eval("$A.get('e.force:refreshView').fire();");
                    }
                    if (res.split('#')[0] == 'FAILURE') {
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: res.split('#')[1],
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        eval("$A.get('e.force:refreshView').fire();");
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                });
        }, 1000);
    }
}