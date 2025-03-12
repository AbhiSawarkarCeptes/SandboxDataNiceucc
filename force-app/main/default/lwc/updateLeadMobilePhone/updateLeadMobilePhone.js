import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateLeadMobile from '@salesforce/apex/LeadMobilePhoneUpdateController.updateLeadMobile';

export default class UpdateLeadMobilePhone extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    leadUpdated = false;
    renderedCallback() {
        if (this.recordId != undefined && this.leadUpdated == false) {
            this.showSpinner = true;
            this.leadUpdated = true;
            this.updateLeadMobilePhone(this.recordId);
        }
    }

    updateLeadMobilePhone(leadId) {
        updateLeadMobile({ leadId: leadId })
            .then(result => {
                this.showSpinner = false;
                if (result == 'success') {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Mobile Number updated successfully.',
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error => {
            });
    }
}