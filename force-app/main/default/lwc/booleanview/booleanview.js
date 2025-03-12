import { LightningElement,api } from 'lwc';
export default class Booleanview extends LightningElement {
    @api label;
    @api flag;
    @api context;

    handleChange(event) {
        //show the selected value on UI
        this.remark = event.detail.value;
        console.log('Datatable picklist : '+event.detail);
        console.log('Datatable picklist : '+this.flag);
        if(this.flag == false)
         this.flag =true;
        else 
         this.flag =false;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('flagchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { label : this.label, flag: this.flag, context: this.context }
            }
        }));
    }
}