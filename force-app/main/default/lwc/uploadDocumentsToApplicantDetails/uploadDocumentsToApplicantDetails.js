import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicantDetails from '@salesforce/apex/BookingUploadSignedDocumentsController.getApplicantDetails';
import updateContentDocumentTitle from '@salesforce/apex/BookingUploadSignedDocumentsController.updateContentDocumentTitle';

export default class UploadDocumentsToApplicantDetails extends NavigationMixin(LightningElement) {
    @api applicantId;
    @api bookingId;
    @track UAE = false;
    @track nonUAE = false;
    @track incorporatedUAE = false;
    @track incorporatedJurisdictions = false;
@api applicant;
    applicantNumber = '';
    currentUploadedFileName = ''
    showSpinner = false;
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    connectedCallback() {
        this.loadApplicantDetails();
    }

    loadApplicantDetails() {
        getApplicantDetails({ applicantId: this.applicantId })
            .then(result => {
                this.applicantNumber = result.Applicant_Number__c;
                this.UAE = (result.Subtype_Of_Applicant__c == 'UAE Resident') ? true : false;
                this.nonUAE = (result.Subtype_Of_Applicant__c == 'Non-UAE Resident') ? true : false;
                this.incorporatedUAE = (result.Subtype_Of_Applicant__c == 'Companies incorporated in the UAE') ? true : false;
                this.incorporatedJurisdictions = (result.Subtype_Of_Applicant__c == 'Companies incorporated in (free zone) permitted jurisdictions') ? true : false;
            })
            .catch(error => {
            });
    }

    onUploadClick(event) {
        this.currentUploadedFileName = this.applicantNumber + '-' + event.currentTarget.name;
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        const uploadedFiles = event.detail.files;
        let uploadedFileName = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileName = uploadedFiles[i].name;
        }
        var currentUploadedFileName = this.currentUploadedFileName;
        if(currentUploadedFileName.includes('Non-residency Letter')){
            currentUploadedFileName = '.Non-residencyLetter';
        }else{
            currentUploadedFileName = currentUploadedFileName.split('-')[1];
            currentUploadedFileName = currentUploadedFileName.replace(/ /g, '')
            currentUploadedFileName = '.' + currentUploadedFileName;
        }
       
        console.log('currentUploadedFileName===',currentUploadedFileName);
        updateContentDocumentTitle({ fileName: this.currentUploadedFileName ,applicantId : this.applicantId,bookingId :this.bookingId})
            .then(result => {
                const evt = new CustomEvent("refreshparent");
                this.dispatchEvent(evt);
                this.showSpinner = false;
                this.template.querySelector(currentUploadedFileName).innerHTML = uploadedFileName;
       
            })
            .catch(error => {
            });
    }
}