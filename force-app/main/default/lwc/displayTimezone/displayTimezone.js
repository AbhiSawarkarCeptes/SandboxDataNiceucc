import { LightningElement, api, track } from 'lwc';
import getTimezone from '@salesforce/apex/TeleCallButtonController.getTimezone';

export default class DisplayTimezone extends LightningElement {
    @api recordId;
    @track timezone = '';
    @track nationality = '';
    @track dataLoaded = false;
    showSpinner = false;

    renderedCallback() {
        if (this.recordId != null && this.recordId != undefined && this.recordId != '' && this.dataLoaded == false) {
            this.dataLoaded = true;
            console.log('inside connectedCallback(): ' + this.recordId);
            this.showSpinner = true;
            getTimezone({ recordId: this.recordId })
                .then(result => {
                    this.showSpinner = false;
                    if (result != null && result != undefined && result != '') {
                        if (result.includes('#')) {
                            this.timezone = result.split('#')[0];
                            this.nationality = result.split('#')[1];
                        }
                        else {
                            this.timezone = result;
                        }
                    }
                })
                .catch(error => {
                    console.log('connectedcallback error');
                    console.log(error);
                });
        }
    }

}