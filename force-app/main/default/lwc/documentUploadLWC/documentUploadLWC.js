import { LightningElement, api, track } from 'lwc';
import updateBookings from '@salesforce/apex/DocumentUploadLWCController.updateBookings'
import uploadFiles from '@salesforce/apex/DocumentUploadLWCController.uploadFiles'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DocumentUploadLWC extends NavigationMixin(LightningElement) {

    @api isLoaded = false;
    selectedBooking;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];
    @api recordId;
    @api idName;
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
    @track preApproved = false;
    @track finalOffer = false;
    @track signedMortgage = false;
    @track NOC = false;
    @track managersCheque = false;
    @track fileName;
    @track fileNames;
    @track fileNames1;
    @track fileNames2;
    @track fileNames3;
    @track fileNames4;
    @track showSpinner = false;

    connectedCallback() {
        if(this.idName != '' && this.idName != null && this.idName != undefined) {
            this.selectedBooking = this.idName;
        }
    }
    handleBookingSelection(event) {
        this.selectedBooking = event.target.value;
    }

    handleFileUploaded(event) {
        var btnName = event.target.id;
        if (event.target.id.includes('preApprove')) {
            this.fileNames = null;
            } else if (event.target.id.includes('finalOffer')) {
                this.fileNames1 = null;
            } else if (event.target.id.includes('signmor')) {
                this.fileNames2 = null;
            } else if (event.target.id.includes('nocFrmBank')) {
                this.fileNames3 = null;
            } else if (event.target.id.includes('copyOfMng')) {
                this.fileNames4 = null;
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
                    this.preApproved = false;
                    this.finalOffer = false;
                    this.signedMortgage = false;
                    this.NOC = false;
                    this.managersCheque = false;
                    console.log("in");
                    console.log(file.name);
                    console.log(btnName);
                    var fileNameTemp = '';
                    if (btnName.includes('preApprove')) {
                        fileNameTemp = 'PRE-APPROVAL DOCUMENT '+file.name;
                    } else if (btnName.includes('finalOffer')) {
                        fileNameTemp = 'FINAL OFFER DOCUMENT '+file.name;
                    } else if (btnName.includes('signmor')) {
                        fileNameTemp = 'SIGN MORTGAGE CONTRACT DOCUMENT '+file.name;
                    } else if (btnName.includes('nocFrmBank')) {
                        fileNameTemp = 'NOC FROM BANK DOCUMENT '+file.name;
                    } else if (btnName.includes('copyOfMng')) {
                        fileNameTemp = 'COPY OF THE MANAGER\'S CHEQUE DOCUMENT '+file.name;
                    }

                    console.log(fileNameTemp);

                    this.filesUploaded.push({ PathOnClient: file.name, Title: fileNameTemp, VersionData: fileContents });
                };
                reader.readAsDataURL(file);
            }

            if (event.target.id.includes('preApprove')) {
                this.fileNames = fn;
            } else if (event.target.id.includes('finalOffer')) {
                this.fileNames1 = fn;
            } else if (event.target.id.includes('signmor')) {
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
        console.log('in');
        this.isLoaded = true;
        this.showSpinner = true;
        uploadFiles({ files: this.filesUploaded, selectedBooking: this.selectedBooking })
            .then(result => {
                console.log('in2');
                console.log( result);
                if (result == true) {
                    updateBookings({
                        files: this.filesUploaded, recordId: this.selectedBooking, PreApprovalDate: this.PreApprovalDate, FinalOfferDate: this.FinalOfferDate, SignedMortgageDate: this.SignedMortgageDate,
                        NOCDate: this.NOCDate, ManagersChequeDate: this.ManagersChequeDate, PreApprovalEXDate: this.PreApprovalEXDate, FinalOfferEXDate: this.FinalOfferEXDate,
                        SignedMortgageEXDate: this.SignedMortgageEXDate, NOCEXDate: this.NOCEXDate, ManagersChequeEXDate: this.ManagersChequeEXDate
                    })
                        .then(result => {
                            console.log('in3');
                            console.log(result);
                            if (result == true) {
                                let bookingIds = this.selectedBooking;
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: bookingIds,
                                        objectApiName: 'PropStrength__Application_Booking__c',
                                        actionName: 'view'
                                    }
                                })
                                this.showSpinner = false;
                                if(this.idName != '' && this.idName != null && this.idName != undefined) {
                                    var urlVal = window.location.href;
                                    console.log(urlVal.substring(0, urlVal.indexOf('.com') + 4) + '/lightning/r/PropStrength__Application_Booking__c/' + this.selectedBooking+'/view');
                                    window.open(urlVal.substring(0, urlVal.indexOf('.com') + 4) + '/lightning/r/PropStrength__Application_Booking__c/' + this.selectedBooking+'/view', "_self");
                                }
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
    }

    handlePreApprovalChange(event) {
        this.PreApprovalDate = event.target.value;
        if(this.fileName != null){
            this.preApproved = false;
        } else if(this.PreApprovalDate != null) {
            this.preApproved = true;
        } else if(this.PreApprovalEXDate != null) {
            this.preApproved = true;
        } else {
            this.preApproved = false;
        }
    }

    handlePreEXApprovalChange(event) {
        this.PreApprovalEXDate = event.target.value;
        if(this.fileName != null){
            this.preApproved = false;
        } else if(this.PreApprovalEXDate != null) {
            this.preApproved = true;
        } else if(this.PreApprovalDate != null) {
            this.preApproved = true;
        } else {
            this.preApproved = false;
        }
    }

    handleFinalChange(event) {
        this.FinalOfferDate = event.target.value;
        if(this.fileName != null){
            this.finalOffer = false;
        } else if(this.FinalOfferDate != null) {
            this.finalOffer = true;
        } else if(this.FinalOfferEXDate != null) {
            this.finalOffer = true;
        } else {
            this.finalOffer = false;
        }
    }

    handleFinalEXChange(event) {
        this.FinalOfferEXDate = event.target.value;
        if(this.fileName != null){
            this.finalOffer = false;
        } else if(this.FinalOfferEXDate != null) {
            this.finalOffer = true;
        } else if(this.FinalOfferDate != null) {
            this.finalOffer = true;
        } else {
            this.finalOffer = false;
        }
    }

    handleSignedMortgageDateChange(event) {
        this.SignedMortgageDate = event.target.value;
        if(this.fileName != null){
            this.signedMortgage = false;
        } else if(this.SignedMortgageDate != null) {
            this.signedMortgage = true;
        } else if(this.SignedMortgageEXDate != null) {
            this.signedMortgage = true;
        } else {
            this.signedMortgage = false;
        }
    }

    handleSignedMortgageEXDateChange(event) {
        this.SignedMortgageEXDate = event.target.value;
        if(this.fileName != null){
            this.signedMortgage = false;
        } else if(this.SignedMortgageEXDate != null) {
            this.signedMortgage = true;
        } else if(this.SignedMortgageDate != null) {
            this.signedMortgage = true;
        } else {
            this.signedMortgage = false;
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