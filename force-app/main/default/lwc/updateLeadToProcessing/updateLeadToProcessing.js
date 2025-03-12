import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Phone from '@salesforce/schema/Lead.Phone';
import MobilePhone from '@salesforce/schema/Lead.MobilePhone';
import updateLeadToProcessing from '@salesforce/apex/LeadAutoReassignController.updateLeadToProcessing';
const fields = [Phone, MobilePhone];

export default class UpdateLeadToProcessing extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    leadUpdated = false;
    @wire(getRecord, { recordId: '$recordId', fields })
    Lead;

    renderedCallback() {
        if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.leadUpdated == false) {
            this.showSpinner = true;
            this.leadUpdated = true;
            this.updateLead(this.recordId);
        }
    }


    updateLead(leadId) {
        updateLeadToProcessing({ leadId: leadId })
            .then(result => {
                const evt = new ShowToastEvent({
                    variant: 'success',
                    message: 'Lead is in processing.',
                });
                this.dispatchEvent(evt);
                eval("$A.get('e.force:refreshView').fire();");
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
            });
    }
}