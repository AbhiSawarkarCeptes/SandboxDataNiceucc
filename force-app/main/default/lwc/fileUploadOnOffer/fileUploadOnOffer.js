import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOffer from '@salesforce/apex/FileUploadOnOfferController.updateOfferFields';

export default class FileUploadOnOffer extends LightningElement {

    @api recordId;
    
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    connectedCallback() {
    }
    
    handlePassportUploadFinished(event) {
        updateOffer({offerId : this.recordId, uplodDocName : 'Passport' }).then((res) => {
            return new Promise(resolve => {
                if(res.includes('Success')){
                    resolve(res);
                }else{
                    resolve(null);
                    this.showSpinner = false;
                    this.showToast('Error',res,'Error');
                }
            })
        }).catch((error) => {
            return new Promise(resolve => {
                this.showSpinner = false;
                resolve(null);
                this.showToast('Error',error,'Error');
            })
        })
        const uploadedFiles = event.detail.files.length;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: uploadedFiles + ' File(s) uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        window.location.reload()
    }

    handleEmiratesUploadFinished(event) {
        updateOffer({offerId : this.recordId, uplodDocName : 'Emirates' }).then((res) => {
            return new Promise(resolve => {
                
            })
        }).catch((error) => {
            return new Promise(resolve => {
                
            })
        })
        const uploadedFiles = event.detail.files.length;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: uploadedFiles + ' File(s) uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        window.location.reload()
    }

    handleVisaUploadFinished(event) {
        updateOffer({offerId : this.recordId, uplodDocName : 'Visa' }).then((res) => {
            return new Promise(resolve => {
              
            })
        }).catch((error) => {
            return new Promise(resolve => {
                this.showSpinner = false;
                resolve(null);
                this.showToast('Error',error,'Error');
            })
        })
        const uploadedFiles = event.detail.files.length;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: uploadedFiles + ' File(s) uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        window.location.reload()
    }
}