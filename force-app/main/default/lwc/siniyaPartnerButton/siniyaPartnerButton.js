import { LightningElement, api, wire } from 'lwc';
import AccountClone from '@salesforce/apex/SiniyaPartnerController.AccountClone';
import { CurrentPageReference } from 'lightning/navigation';

export default class SiniyaPartnerButton extends LightningElement {
    @api recordId;
    msg;
    urlShow = false;
    @wire(CurrentPageReference) currentPageReference;
    isLoading = false; // Boolean to control spinner visibility
    connectedCallback() {
        this.isLoading = true; // Show spinner
        this.recordId = this.currentPageReference?.state?.recordId;
        console.log('result--Vi1', this.recordId);
        if (this.recordId) {
            AccountClone({ recordId: this.recordId })
                .then(result => {
                    console.log('result--Vi1', result);
                    this.msg = 'The Siniya Account has been created successfully!!';
                    this.isLoading = false; // Show spinner
                    this.url  = result;
                    this.urlShow = true;
                })
                .catch(
                    error => {
                        this.isLoading = false; // Show spinner
                        console.log('error', error);
                        this.msg = 'The record has not been created !!';

                    }
                );
        }
    }
    openUrl(){
        const url_var = window.location.origin;
        let url = url_var +'/'+this.url.Id;
        window.open(url);
    }
}