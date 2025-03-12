import { LightningElement, api } from 'lwc';

export default class DatatableDateFld extends LightningElement {
    @api label;
    @api flag;
    @api context;

    handleChange(event) {
         //show the selected value on UI
        this.remark = event.detail.value;
        console.log('Datatable picklist : '+event.detail.valuel);
        console.log('Datatable picklist : '+this.flag);
        console.log('Datatable picklist : '+event.detail.value);
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('datechanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { label : this.label, flag: event.detail.value, context: this.context }
            }
        }));
    }

}