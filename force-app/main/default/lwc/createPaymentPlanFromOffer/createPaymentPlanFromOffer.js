import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import checkValidate from '@salesforce/apex/CreatePaymentPlanFromOfferController.checkValidation';

export default class CreatePaymentPlanFromOffer extends  NavigationMixin(LightningElement) {
    @api recordId;
    message;
    @wire(checkValidate, { offerId: '$recordId' })
    createOne({ error, data }) {
        if(data) {
            this.message = data;
            if(data == 'URL') {
                // window.open('/apex/PropStrength__OfferPaymentPlanRedirect?id='+this.recordId, '_blank');
                // this.dispatchEvent(new CloseActionScreenEvent());
               this.navigateToVFPage();
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: data,
                    variant: 'error',
                    mode: 'error'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } else if(error) {
        }
    }

    navigateToVFPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/PropStrength__OfferPaymentPlanRedirect?id='+this.recordId
            }
        });
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}