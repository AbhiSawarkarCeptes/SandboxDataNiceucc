import { LightningElement, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	
import { NavigationMixin } from 'lightning/navigation';
export default class CreateSBTRApprovalRecord extends NavigationMixin(LightningElement) {
    @api recordId;
    checkval = false;;
    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ this.checkval+'test');
        event.preventDefault();       // stop the form from submitting
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                console.log('field'+ field.name); 
                console.log('field.value'+ field.value); 
                if(field.value != null && field.value != '' && field.name != 'Send_For_Approval__c' && field.name != 'SBTR__c' ){
                    this.checkval = true;
                    console.log('In If'); 
                }
               
            });
        }
        console.log('In submit '+this.checkval);
        if(this.checkval){
            console.log('In submit If');
   this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        }
        else{
            console.log('In submit else');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please update atleast one field!!',
                    message: '',
                    variant: 'ERROR',
                }),
            );
        }
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handlevalue(event){
        console.log('event.target.value'+ event.target.value);
 
       
        console.log('event.target.value After'+ this.checkval);
    }
}