import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UpdateDocumentStatus extends LightningElement {
    @api recordId;
    showSpinner = false;

    handleSubmit(event) {
        this.showSpinner = true;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}