import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveAttachements from '@salesforce/apex/RequestUnitHoldController.saveAttachements';
import validateUnitAvailablity from '@salesforce/apex/RequestUnitHoldController.validateUnitAvailablity';
export default class RequestUnitHold  extends NavigationMixin(LightningElement) {
    showSpinner = false;
    currentUnitStatus;
    @api recordId; uploadFiles;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    
    connectedCallback(){  
        /*if(this.currentUnitStatus && this.currentUnitStatus =='Hold'){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Unit is already put on hold.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
           
        }*/
    }
    handleSubmit(event){
        event.preventDefault();
        if(!this.uploadFiles){
            this.toast('Error', 'Please upload the required documents.', 'error');
            return false;
        } 
        this.showSpinner = true;
        const fields = event.detail.fields;
        validateUnitAvailablity({unitId : fields.Unit__c}).then(response =>{
            if(response == null){
                fields.Unit_Hold_Requested__c = true;
                fields.Customer_Full_Name__c = fields.First_Name__c +' '+ fields.Last_Name__c;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
               
            }else{
                this.showSpinner = false;
                fields.Unit__c = null;
                this.toast('Error', response, 'error');
                return false;
            }
        }).catch(error =>{

        });
        //fields.Unit__c = this.recordId;
        
    }

    handleSuccess(event1) {
        this.recordId = event1.detail.id;
        
        saveAttachements({'recordId':this.recordId,'contentDocIds':this.uploadFiles}).then(response =>{
        this.showSpinner = false;
        const editForm = this.template.querySelector('lightning-record-edit-form');
        editForm.recordId = null;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach( field => {
            field.reset();
        })
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Request for Unit Hold created successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.showSpinner = false;
        this.navigateToWebPage();
        }
        ).catch(error =>{
            console.log('error',error);
        });
    }
    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
    handleError(event) {
        let message = event.detail.detail;
        //do some stuff with message to make it more readable
        console.log('message',message);
        this.showSpinner = false;
    }

    toast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            }),
        );
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        this.uploadFiles=[];
        uploadedFiles.forEach(temp =>{
            this.uploadFiles.push(temp.documentId);
        })
        console.log('~~~'+JSON.stringify(this.uploadFiles));
    }

}