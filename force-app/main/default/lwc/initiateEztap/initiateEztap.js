import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllEztapDevices from '@salesforce/apex/InitiateEztapController.getAllEztapDevices';
import checkExistingRequest from '@salesforce/apex/InitiateEztapController.checkExistingRequest';
import startEztap from '@salesforce/apex/InitiateEztapController.startEztap';

export default class InitiateEztap extends LightningElement {
    @api recordId;
    @track devices = [];
    showSpinner = false;
    selectedDevice = '';
    @track loadComponent = false;

    connectedCallback() {
        setTimeout(() => {
            this.checkExistingRequest();
            this.loadDevices();
        }, 1000);

    }

    checkExistingRequest() {
        this.showSpinner = true;
        console.log('Checking existing');
        checkExistingRequest({ prId: this.recordId })
            .then(result => {
                console.log('result here :' + result);
                this.showSpinner = false;
                if (result == 'INITIATED') {
                    const evt = new ShowToastEvent({
                        variant: 'warning',
                        message: 'Ezetap transaction has already been initiated. Please wait for the transaction to complete.',
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else if (result == 'AUTHORIZED') {
                    const evt = new ShowToastEvent({
                        variant: 'warning',
                        message: 'Ezetap transaction has already been AUTHORIZED for this Payment Request.',
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else {

                }
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadDevices() {
        this.loadComponent = true;
        this.showSpinner = true;
        getAllEztapDevices()
            .then(result => {
                this.devices = result;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    onDeviceChange(event) {
        this.selectedDevice = event.target.value;
    }

    handleProceed() {
        this.showSpinner = true;
        startEztap({ deviceId: this.selectedDevice, prId: this.recordId })
            .then(result => {
                if (result == 'Ezetap transaction has been successfully initiated.') {
                    setTimeout(() => {
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: result,
                        });
                        this.dispatchEvent(evt);
                        this.showSpinner = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        eval("$A.get('e.force:refreshView').fire();");
                    }, 4000);
                } else if (result.includes('Ezetap transaction has already been initiated')) {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'warning',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                } else if (result.includes('Ezetap transaction has already been AUTHORIZED')) {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'warning',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();");
    }
}