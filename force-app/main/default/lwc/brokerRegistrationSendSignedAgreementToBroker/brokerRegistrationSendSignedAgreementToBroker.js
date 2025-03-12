import { LightningElement, api } from 'lwc';
import sendAgreement from '@salesforce/apex/BrokerRegistrationSendToBroker.sendAgreementAndNOCToBroker';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BrokerRegistrationSendSignedAgreementToBroker extends LightningElement {
    showSpinner = false;
    @api recordId;

    @api invoke() {
        this.showSpinner = true;
        sendAgreement({
            recordId: this.recordId
        }).then(data => {
            if(data=='yes'){
                this.toast('Success', 'Signed Agreement successfully send to broker', 'success');
            } else {
                this.toast('Error', 'Error Sending Agreement to Broker', 'error');
            }
            this.refreshCurrentPage();
        }).catch(error => {
            console.log('~~~~~~~~~'+JSON.stringify(error));
            this.toast('Error', error.body.message, 'error');
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    refreshCurrentPage(){
        setTimeout(function(){
        window.location.reload();
        }, 1500);
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