import { LightningElement,api } from 'lwc';
export default class Text_view extends LightningElement {
    @api label;
    @api remark;
    @api context;

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        console.log('Datatable picklist : '+this.remark);
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('textchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.remark, label: this.label }
            }
        }));
    }
}