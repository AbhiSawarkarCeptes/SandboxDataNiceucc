import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNPSSurveyStatus from '@salesforce/apex/TeleCallButtonController.getNPSSurveyStatus';
import updateNPSSurveyStatus from '@salesforce/apex/TeleCallButtonController.updateNPSSurveyStatus';

export default class UpdateNPSStatus extends LightningElement {
    @api recordId;
    @track statusValue;
    @track isDataLoaded = false;
    showSpinner = false;
    @track apiCalled = false;

    renderedCallback() {
        if (this.recordId != null && this.recordId != undefined && this.recordId != '' && this.apiCalled == false) {
            this.showSpinner = true;
            getNPSSurveyStatus({ recordId: this.recordId })
                .then(result => {
                    this.apiCalled = true;
                    this.isDataLoaded = true;
                    this.showSpinner = false;
                    if (result != null)
                        this.statusValue = result;
                })
                .catch(error => {
                    this.isDataLoaded = true;
                    this.showSpinner = false;
                    console.log('connectedCallback error');
                    console.log(error);
                });
        }
    }

    updateNPSSurveyStatus() {
        this.showSpinner = true;
        updateNPSSurveyStatus({ recordId: this.recordId, status: this.statusValue })
            .then(result => {
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    variant: 'success',
                    message: 'NPS Survey Status Updated Successfully!',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('connectedCallback error');
                console.log(error);
            });
    }

    get options() {
        return [
            { label: 'Call Completed', value: 'Call Completed' },
            { label: 'Did Not Pick', value: 'Did Not Pick' },
            { label: 'Not Interested', value: 'Not Interested' },
            { label: 'Wrong Number / Non-Contactable', value: 'Wrong Number / Non-Contactable' },
        ];
    }

    handleChange(event) {
        this.statusValue = event.detail.value;
    }
}