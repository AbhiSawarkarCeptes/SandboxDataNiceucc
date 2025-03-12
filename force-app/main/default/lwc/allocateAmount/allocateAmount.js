import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AllocateAmount extends LightningElement {
    @api recordId;
    showSpinner = false;

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        var totalAmt = 0;
        
            if (String(fields.Towards_Unit_Price_Amount__c) != 'null' && String(fields.Towards_Unit_Price_Amount__c) != undefined && String(fields.Towards_Unit_Price_Amount__c) != '' && String(fields.Towards_Unit_Price_Amount__c) != null && fields.Towards_Unit_Price_Amount__c != undefined) {
                totalAmt = totalAmt + parseFloat(fields.Towards_Unit_Price_Amount__c);
            }
            if (String(fields.Towards_Pre_Registration_Amount__c) != 'null' && String(fields.Towards_Pre_Registration_Amount__c) != undefined && String(fields.Towards_Pre_Registration_Amount__c) != '' && String(fields.Towards_Pre_Registration_Amount__c) != null && fields.Towards_Pre_Registration_Amount__c != undefined) {
                totalAmt = totalAmt + parseFloat(fields.Towards_Pre_Registration_Amount__c);
            }
            if (String(fields.Towards_Other_Charges_Amount__c) != 'null' && String(fields.Towards_Other_Charges_Amount__c) != undefined && String(fields.Towards_Other_Charges_Amount__c) != '' && String(fields.Towards_Other_Charges_Amount__c) != null && fields.Towards_Other_Charges_Amount__c != undefined) {
                totalAmt = totalAmt + parseFloat(fields.Towards_Other_Charges_Amount__c);
            }
            totalAmt = totalAmt.toFixed(2);
            if (totalAmt != parseFloat(fields.Amount__c).toFixed(2)) {                
                const evt = new ShowToastEvent({
                    variant: 'warning',
                    message: 'Sum of Amount Towards Field(s) should be equal to Amount.',
                });
                this.dispatchEvent(evt);               
                
            }
            else {
                if (String(fields.Towards_Other_Charges_Amount__c) != 'null' && String(fields.Towards_Other_Charges_Amount__c) != undefined && String(fields.Towards_Other_Charges_Amount__c) != '' && String(fields.Towards_Other_Charges_Amount__c) != null && fields.Towards_Other_Charges_Amount__c > 0
                      && (String(fields.Others__c) == 'null' || String(fields.Others__c) == undefined || String(fields.Others__c) == '' || String(fields.Others__c) == null)) {                       
                        const evt = new ShowToastEvent({
                            variant: 'warning',
                            message: 'Please select the other charge',  
                        });
                        this.dispatchEvent(evt);
                }
                else{
                    this.showSpinner = true;
                    fields.Amount_Allocated__c = true;
                    fields.Status__c = 'Approved';
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            }
        
    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}