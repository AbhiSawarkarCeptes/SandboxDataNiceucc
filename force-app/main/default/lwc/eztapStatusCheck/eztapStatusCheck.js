import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eztapStatusCheck from '@salesforce/apex/InitiateEztapController.eztapStatusCheck';

export default class EztapStatusCheck extends LightningElement {
    @api recordId;
    showSpinner = false;
    @track status = '';
    @track errorMessage = '';
    @track msgCode = '';

    connectedCallback() {
        this.showSpinner = true;
        setTimeout(() => {
            eztapStatusCheck({ prId: this.recordId })
                .then(result => {
                    let res = result;
                    this.status = res.split('#')[0];
                    this.errorMessage = res.split('#')[1];
                    this.msgCode = res.split('#')[2];
                    this.showSpinner = false;
                    eval("$A.get('e.force:refreshView').fire();");
                })
                .catch(error => {
                    this.showSpinner = false;
                });
        }, 1000);
    }
}