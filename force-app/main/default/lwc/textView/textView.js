import { LightningElement,api } from 'lwc';

export default class TextView extends LightningElement {
    @api label;
    @api remark;
    @api context;
    showIcon = false;

    handleChange(event) {
        //show the selected value on UI
        this.remark = event.detail.value;
        if (this.remark.length > 0) {
            this.showIcon = true;
        } else {
            this.showIcon = false;
        }
    }

    saveChange() {
        console.log('Datatable picklist : '+this.remark);
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('textchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { label : this.label, remark: this.remark, context: this.context }
            }
        }));

        this.showIcon = false;
    }
}