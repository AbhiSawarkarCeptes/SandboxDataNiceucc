import { LightningElement, api, wire ,track} from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/DocumentVerificationController.getRelatedFilesByRecordId'
import verifyDocuments from '@salesforce/apex/DocumentVerificationController.verifyDocuments'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation'



import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class FilePreviewAndDownloads extends NavigationMixin(LightningElement) {

    @api recordId;
    filesList =[]
    showError = false;
    verifiedFiles = [];
    showSpinner = false;
    dataloaded = false;
    /*@wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){ 
            
        }
        if(error){ 
            console.log(error)
        }
    }*/
    connectedCallback(){
        
    }
    renderedCallback(){
        console.log('this.recordId',this.recordId);
        if(this.recordId && this.dataloaded == false){
            getRelatedFilesByRecordId({'recordId': this.recordId}).then(data =>{
                console.log(data);
                this.filesList = [];
               data.forEach(item=>{
                console.log('item===',item)
                this.filesList.push({"label":item.doctitle,
                 "value": item.docId,
                 "url":`/sfc/servlet.shepherd/document/download/${item.docId}`,
                 "verified" : item.verified
                 
                });})
                console.log('this.filesList--',this.filesList)
                if(this.filesList.length == 0){
                    this.showError = true
                }
                this.filesList.forEach(e=> {
                    if(e.verified == true){
                          this.verifiedFiles.push(e.label);
                    }
                  
                })
                    
                this.dataloaded = true;
                
                console.log(this.filesList)
            }).catch(error =>{
                console.log(error)
            });
        }
        
    }
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }


  
    trackVerifiedFiles(event){
       console.log('event---443543'+event.target.dataset.id)
       console.log('event.target.value ---'+event.target.checked)
       if(event.target.checked){
        this.verifiedFiles.push(event.target.dataset.id);
       }else{
        this.verifiedFiles = this.verifiedFiles.filter(e => e !== event.target.dataset.id); // will return ['A', 'C']
       }
       this.verifiedFiles = [...new Set(this.verifiedFiles)];
    }
    verifyDocumentsController(){
        console.log('this.verifiedFiles',this.verifiedFiles);
        this.showSpinner = true
       verifyDocuments({ verifiedFiles: this.verifiedFiles, bookingId: this.recordId }).then(result => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Verification done successfully',
                variant: 'success'
            })
           
        );
        this.showSpinner = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId ,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });
        }).catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error verifying documents',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.showSpinner = false;
        });
    }
}