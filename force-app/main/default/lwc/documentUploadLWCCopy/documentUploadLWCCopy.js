import { LightningElement, api, track, wire } from 'lwc';
import updateKYCCheckList from '@salesforce/apex/DocumentUploadLWCCopyController.updateKYCCheckList'
import uploadFiles from '@salesforce/apex/DocumentUploadLWCCopyController.uploadFiles'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DocumentUploadLWCCopy extends NavigationMixin(LightningElement) {

    @api isLoaded = false;
    selectedOffer;
    applicantType;
    residentialStatus;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];
    @api recordId;
    @api idName;
    @api offerId
    @track error;
    @track PreApprovalDate;
    @track FinalOfferDate;
    @track SignedMortgageDate;
    @track NOCDate;
    @track ManagersChequeDate;
    @track PreApprovalEXDate;
    @track FinalOfferEXDate;
    @track SignedMortgageEXDate;
    @track NOCEXDate;
    @track ManagersChequeEXDate;
    @track filesUploaded = [];
    @track passport = false;
    @track nationalID = false;
    @track emiratedId = false;
    @track NOC = false;
    @track managersCheque = false;
    @track fileName;
    @track fileNames;
    @track fileNames1;
    @track fileNames2;
    @track fileNames3;
    @track fileNames4;
    @track showSpinner = false;
    offerPresent = false;
    @track showEmirate = false;
    @track showNational = false;
    @track showPassport = false;

    connectedCallback() {
        console.log(this.offerId);
        if(this.offerId != '' && this.offerId != null && this.offerId != undefined) {
            this.selectedOffer = this.offerId;
            this.offerPresent = true;
        }
    }

    handleOfferSelection(event) {
        this.selectedOffer = event.target.value;
    }

    handleApplicantTypeSelection(event) {
        this.applicantType = event.target.value;
    }

    handleresidentialStatusSelection(event) {
        this.residentialStatus = event.target.value;
        
        if (event.target.value == 'Resident') {
            this.showEmirate = true;
            this.showNational = false;
            this.showPassport = true;
        } else if (event.target.value == 'Non-Resident') {
            this.showEmirate = false;
            this.showNational = true;
            this.showPassport = true;
        } else {
            this.showEmirate = false;
            this.showNational = false;
            this.showPassport = false;
        }
    }

    handleFileUploaded(event) {
        if (event.target.id.includes('passport')) {
            this.fileNames = null;
            } else if (event.target.id.includes('nationalID')) {
                this.fileNames1 = null;
            } else if (event.target.id.includes('emiratedId')) {
                this.fileNames2 = null;
            } else if (event.target.id.includes('nocFrmBank')) {
                this.fileNames3 = null;
            } else if (event.target.id.includes('copyOfMng')) {
                this.fileNames4 = null;
        }
        var fileNameSend;
        if (event.target.id.includes('passport')) {
            fileNameSend = 'Passport-';
        } else if (event.target.id.includes('nationalID')) {
            fileNameSend = 'National_ID-';
        } else if (event.target.id.includes('emiratedId')) {
            fileNameSend = 'Emirates_ID-';
        }
        
        if (event.target.files.length > 0) {
            let files = [];
            let fn = [];
            
            for (var i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
                fn.push(file.name);
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    //alert('file.name::' + file.name);
                    this.fileName = file.name;
                    
                    this.passport = false;
                    this.nationalID = false;
                    this.emiratedId = false;
                    this.NOC = false;
                    this.managersCheque = false;
                    console.log(fileNameSend);
                    console.log(fileNameSend+file.name);
                    this.filesUploaded.push({ PathOnClient: file.name, Title: fileNameSend+file.name, VersionData: fileContents });
                };
                reader.readAsDataURL(file);
            }
            if (event.target.id.includes('passport')) {
            this.fileNames = fn;
            } else if (event.target.id.includes('nationalID')) {
                this.fileNames1 = fn;
            } else if (event.target.id.includes('emiratedId')) {
                this.fileNames2 = fn;
            } else if (event.target.id.includes('nocFrmBank')) {
                this.fileNames3 = fn;
            } else if (event.target.id.includes('copyOfMng')) {
                this.fileNames4 = fn;
            }
        }
    }

    handleCancel() {
        this.isLoaded = true;
        var url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    attachFiles(event) {
        this.isLoaded = true;
        this.showSpinner = true;
        
        updateKYCCheckList({
            selOff: this.selectedOffer, resSta: this.residentialStatus, appTy: this.applicantType
        })
        .then(result => {
            if (result.length > 10) {
                console.log(result);
                var createdRecordId = result;
                uploadFiles({ files: this.filesUploaded, kycRecordId: createdRecordId })
                    .then(result => {
                        if (result == 'true') {
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: createdRecordId,
                                    objectApiName: 'KYC_Documents__c',
                                    actionName: 'view'
                                }
                            })
                            this.showSpinner = false;
                            if (this.createdRecordId != '' && this.createdRecordId != null && this.createdRecordId != undefined) {
                                var urlVal = window.location.href;
                                window.open(urlVal.substring(0, urlVal.indexOf('.com') + 4) + '/lightning/r/KYC_Documents__c/' + createdRecordId + '/view', "_blank");
                            }
                        } else if (result.includes('Please')) {
                            this.isLoaded = false;
                            this.showSpinner = false;
                            this.showToastMessage('Error', result, 'error');
                        } else {
                            this.isLoaded = false;
                            this.showSpinner = false;
                            this.showToastMessage('Error', 'Error uploading files', 'error');
                        }
                    })
                    .catch(error => {
                        this.isLoaded = false;
                        this.showSpinner = false;
                        this.showToastMessage('Error', error.body.message, 'error');
                    });
            } else {
                this.isLoaded = false;
                this.showSpinner = false;
                this.showToastMessage('Error', 'Error Booking Update', 'error');
            }
        })
        .catch(error => {
            this.isLoaded = false;
            this.showSpinner = false;
            this.showToastMessage('Error', error.body.message, 'error');
        });
    }

    handlePreApprovalChange(event) {
        this.PreApprovalDate = event.target.value;
        if(this.fileName != null){
            this.passport = false;
        } else if(this.PreApprovalDate != null) {
            this.passport = true;
        } else if(this.PreApprovalEXDate != null) {
            this.passport = true;
        } else {
            this.passport = false;
        }
    }

    handlePreEXApprovalChange(event) {
        this.PreApprovalEXDate = event.target.value;
        if(this.fileName != null){
            this.passport = false;
        } else if(this.PreApprovalEXDate != null) {
            this.passport = true;
        } else if(this.PreApprovalDate != null) {
            this.passport = true;
        } else {
            this.passport = false;
        }
    }

    handleFinalChange(event) {
        this.FinalOfferDate = event.target.value;
        if(this.fileName != null){
            this.nationalID = false;
        } else if(this.FinalOfferDate != null) {
            this.nationalID = true;
        } else if(this.FinalOfferEXDate != null) {
            this.nationalID = true;
        } else {
            this.nationalID = false;
        }
    }

    handleFinalEXChange(event) {
        this.FinalOfferEXDate = event.target.value;
        if(this.fileName != null){
            this.nationalID = false;
        } else if(this.FinalOfferEXDate != null) {
            this.nationalID = true;
        } else if(this.FinalOfferDate != null) {
            this.nationalID = true;
        } else {
            this.nationalID = false;
        }
    }

    handleSignedMortgageDateChange(event) {
        this.SignedMortgageDate = event.target.value;
        if(this.fileName != null){
            this.emiratedId = false;
        } else if(this.SignedMortgageDate != null) {
            this.emiratedId = true;
        } else if(this.SignedMortgageEXDate != null) {
            this.emiratedId = true;
        } else {
            this.emiratedId = false;
        }
    }

    handleSignedMortgageEXDateChange(event) {
        this.SignedMortgageEXDate = event.target.value;
        if(this.fileName != null){
            this.emiratedId = false;
        } else if(this.SignedMortgageEXDate != null) {
            this.emiratedId = true;
        } else if(this.SignedMortgageDate != null) {
            this.emiratedId = true;
        } else {
            this.emiratedId = false;
        }
    }

    handleDateChange(event) {
        this.NOCDate = event.target.value;
        if(this.fileName != null){
            this.NOC = false;
        } else if(this.NOCDate != null) {
            this.NOC = true;
        } else if(this.NOCEXDate != null) {
            this.NOC = true;
        } else {
            this.NOC = false;
        }
    }

    handleEXDateChange(event) {
        this.NOCEXDate = event.target.value;
        if(this.fileName != null){
            this.NOC = false;
        } else if(this.NOCEXDate != null) {
            this.NOC = true;
        } else if(this.NOCDate != null) {
            this.NOC = true;
        } else {
            this.NOC = false;
        }
    }

    handleManagersChequeDateChange(event) {
        this.ManagersChequeDate = event.target.value;
        if(this.fileName != null){
            this.managersCheque = false;
        } else if(this.ManagersChequeDate != null) {
            this.managersCheque = true;
        } else if(this.ManagersChequeEXDate != null) {
            this.managersCheque = true;
        } else {
            this.managersCheque = false;
        }
    }


    handleEXManagersChequeDateChange(event) {
        this.ManagersChequeEXDate = event.target.value;
        if(this.fileName != null){
            this.managersCheque = false;
        } else if(this.ManagersChequeEXDate != null) {
            this.managersCheque = true;
        } else if(this.ManagersChequeDate != null) {
            this.managersCheque = true;
        } else {
            this.managersCheque = false;
        }
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}