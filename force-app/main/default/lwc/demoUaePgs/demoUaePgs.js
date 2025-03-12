import { LightningElement } from 'lwc';
import sendPaymentRequest from '@salesforce/apex/demoUAEPGSController.sendPaymentRequest';


export default class DemoUaePgs extends LightningElement {
    
    responseMessage;

    handlePayment() {
        sendPaymentRequest()
            .then(response => {
                this.responseMessage = response;
                console.log('API Response:', response);
            })
            .catch(error => {
                console.error('Error:', error);
                this.responseMessage = 'Error in processing payment';
            });
    }
}