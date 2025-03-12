import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import fetchOriginalNumber from '@salesforce/apex/ClickToCallEnquiryController.originalPhoneNumber';
export default class ClickToCallPhoneEnquiry extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    phonenum;

    @wire(fetchOriginalNumber, { enqId: '$recordId' })
    createOne({ error, data }) {
        if(data) {
            this.phonenum = data;
        } else if(error) {
        }
    }

    renderedCallback() {
        console.log('===> ' + this.phonenum);
        console.log('===> r ' + this.recordId);
        if(this.phonenum != undefined && this.phonenum != null && this.phonenum != '') {
            this.showSpinner = true;
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            clickToDial.click();
            const evet = new ShowToastEvent({
                title: 'Call connecting...',
                message: '',
                variant: 'success',
            });
            this.dispatchEvent(evet);
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}