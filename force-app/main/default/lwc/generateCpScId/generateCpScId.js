import { LightningElement, api } from 'lwc';
import generate from '@salesforce/apex/GenerateCpScIdController.generate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GenerateCpScId extends LightningElement {
    showSpinner = false;
    @api recordId;

    @api invoke() {
        this.showSpinner = true;
        generate({
            recordId: this.recordId
        }).then(data => {
            if(data=='yes'){
                this.toast('Success', 'CP/SC ID created as Emergency ID', 'success');
            } else {
                this.toast('Success', 'CP/SC ID generated successfully', 'success');
            }
            this.refreshCurrentPage();
        }).catch(error => {
            this.toast('Error', error.body.message, 'error');
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    refreshCurrentPage(){
        setTimeout(function(){
        window.location.reload();
        }, 2000);
    }

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