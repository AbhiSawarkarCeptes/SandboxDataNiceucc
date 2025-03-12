import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import brokerRegistrationCSS from '@salesforce/resourceUrl/brokerRegistrationCSS';

export default class BrokerRegistrationRera extends LightningElement {
    @track _record = {};
    @track files = {};

    @api
    get record() {
        return this._record;
    }

    set record(data) {
        this._record = JSON.parse(JSON.stringify(data));
    }

    connectedCallback() {
        loadStyle(this, brokerRegistrationCSS);
    }

    handleSubmit(event) {
        if( !this.validate() ) {
            return;
        }
        const submitEvent = new CustomEvent('submit', {detail: {record: this.record}});
        this.dispatchEvent(submitEvent);
    }

    handleChange(event) {
        this.record[event.target.name] = event.target.value;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.files[event.target.name] = uploadedFiles[0].name;
    }

    validate() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

}