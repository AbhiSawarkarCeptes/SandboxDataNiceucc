import { LightningElement, api, track, wire } from 'lwc';
import createPreRegistration from '@salesforce/apex/CreateBusinessProcess.createPreRegistration';
import getProcessFlows from '@salesforce/apex/CreateBusinessProcess.getProcessFlows';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class LwcCreatePreRegistration extends LightningElement {
    @api recordId;
    selectedValue;
    error;
/*
    handleClick(){

        createPreRegistration({bookingId:this.recordId,processName:'Pre-Registration - 5 days'})
        .then(result=>{
            console.log('result ' + result);
            console.log('result Stringify' + JSON.stringify(result));
            
            const toastEvent = new ShowToastEvent({
            title:'Success!',
            message:'Business process created successfully',
            variant:'success'
            });
            this.dispatchEvent(toastEvent);
            this.closeAction();
        })
        .catch(error=>{
            this.error=error.message;
            console.log(this.error);
        });
    }
*/
    processFlows = [];
    selectedProcessFlowId;

    @wire(getProcessFlows, { recId: '$recordId' })
    wiredProcessFlows({ error, data }) {
        if (data) {
            this.processFlows = data.map(item => ({
                label: item.Name,
                value: item.Id
            }));
        } else if (error) {
            console.error('Error loading process flows', error);
        }
    }
    handleProcessFlowChange(event) {
        this.selectedProcessFlowId = event.target.value;
        // Handle the selected process flow ID as needed
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      connectedCallback() {
        console.log('inside connectedCallback');
    } 
    
    /*@track options = [
        { label: 'SPA - 13 days (Release of SPA to Customer 2 Days)', value: 'spa' },
        { label: 'Pre-Registration - 5 days', value: 'preregistration' },
        { label: 'PCC - 3 days', value: 'pcc' },
        { label: 'Title Deed - 5 days', value: 'titledeed' },
        { label: 'Internal Cancellation - 18 days (including 14 Days notice period to Customers)', value: 'internalcancellation' },
        { label: 'Ownership Change - 7 days', value: 'ownershipchange' },
        { label: 'Name Addition/Deletion - 7 days', value: 'nameadddelete' }
    ]; */   

    handleChange(event) {
        this.selectedValue = event.target.value;
    }

    /*initiateProcess(){
        console.log('this.selectedValue '+this.selectedValue);
        if(this.selectedValue!=null && this.selectedValue!=undefined){
            console.log('value selected1 '+this.selectedValue);

            if(this.selectedValue==='preregistration'){
                this.error = '';
                this.handleClick2(this.selectedValue);
            }else{
                this.error = 'Functionality not yet implemented';
            }

        }else{
            this.error = 'Please select the process to initiate.';
        }
    }*/
    handleClick2(event){

        createPreRegistration({bookingId:this.recordId,processId:this.selectedProcessFlowId})
        .then(result=>{
            if(result == 'Selected Process Already Created..!'){
                const toastEvent = new ShowToastEvent({
                title:'Error!',
                message:'Selected Business process already created',
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
            }
            else{
                let recordName = 'Business Process';
                const message = `Record ${recordName} created successfully. Link : ${window.location.origin}/${result}`;
                //const message = `Record <lightning-formatted-url value="/${result}" label="${recordName}"></lightning-formatted-url> created successfully.`;
                const toastEvent = new ShowToastEvent({
                title:'Success!',
                message:message,
                variant:'success',
                mode: 'sticky'
                });
            this.dispatchEvent(toastEvent);
            }
            //window.location.reload();
            this.closeAction();
        })
        .catch(error=>{
            console.log('error1: '+error.body.message);
            this.error=error.body.message;
        });
    }
}