import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation'
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicationDetails1 from '@salesforce/apex/BookingUploadSignedDocumentsController.getApplicationDetails';
import updateContentDocumentTitle from '@salesforce/apex/BookingUploadSignedDocumentsController.updateContentDocumentTitle';
import sendEmail from '@salesforce/apex/BookingUploadSignedDocumentsController.sendEmail';
import assignSBFUser from '@salesforce/apex/BookingUploadSignedDocumentsController.updateSBEUser';
import { loadStyle } from 'lightning/platformResourceLoader';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

import CUSTOMCSS from '@salesforce/resourceUrl/CSSForMultipleLineToast';
export default class BookingUploadSignedDocuments extends NavigationMixin(LightningElement) {

    recordId;
    isDataLoaded = false;
    bookingObj = {};
    firstApplicant = {};
    secondApplicant = {};
    thirdApplicant = {};
    fourthApplicant = {};
    fifthApplicant = {};
    isFirstApplicant = false;
    isSecondApplicant = false;
    isThirdApplicant = false;
    isFourthApplicant = false;
    isFifthApplicant = false;
    isBookingUpdated = false;
    disableSignedFormUpload = false;
    @track signedBookingFormName = '';
    showSpinner = false;
    isCssLoaded = false;
    uploadEnable = true;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    @wire(getRecord , {recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('profile name is : ',data.fields.Profile.value);
            if(data.fields.Profile.value != null && data.fields.Profile.value.fields.Name.value== 'Sales'){
                this.uploadEnable = false;
            }
            /* if (data.fields.Profile.value != null && data.fields.Profile.value.fields.Name.value=='System Administrator') {
                this.isSystemAdministrator = true;
            } */
        }
    }

    connectedCallback() {
        this.recordId = this.currentPageReference.state.c__refRecordId;
        this.getApplicationDetails();
    }

    getApplicationDetails() {
        getApplicationDetails1({ bookingId: this.recordId }).then(result => {
            this.isDataLoaded = true
            this.bookingObj.Name = result.bookingObj.Name;
            this.bookingObj.BookingDate = result.bookingObj.Booking_Date__c;
            this.bookingObj.ProjectName = result.bookingObj.Project_Name__c;
            this.bookingObj.Unit = result.bookingObj.Unit__r.Name;
            this.bookingObj.Id = result.bookingObj.Id;
            this.disableSignedFormUpload = result.disableSignedBookingFormUpload;
            console.log(' result.applicationDetails===', result.applicationDetails);
            result.applicationDetails.forEach(element => {
                const obj = {
                    Name: element.Name,
                    ApplicantType: element.Type_Of_Applicant__c,
                    ApplicantNumber: element.Applicant_Number__c,
                    SubtypeApplicant: element.Subtype_Of_Applicant__c,
                    VisaCopy: element.Visa_Copy__c,
                    PassportCopy: element.Passport_Copy__c,
                    Id: element.Id,
                    NationalIdVerified : element.National_Id_Uploaded__c,
                    NonResidencyLetterVerified:element.Non_Residency_Letter_Uploaded__c,
                    OtherDocumentsVerified : element.Other_Documents_Uploaded__c,
                    PassportCopyAutorizedVerified : element.Passport_Copy_of_Authorized_Uploaded__c,
                    PassportVerified : element.Passport_Uploaded__c,PowerOfAttorneyVerified : element.Power_Of_Attorney_Uploaded__c,
                    RegistrationLicenseVerified : element.Registration_License_Uploaded__c,VisaCopyVerified : element.Visa_Copy_Uploaded__c,
                    CertificateOfGoodStandingVerified : element.Certificate_of_Good_Standing_Uploaded__c,
                    CertificateOfIncorporationVerified:element.Certificate_Of_Incorporation_Uploaded__c,
                    EmiratesIdVerified : element.Emirates_Id_Uploaded__c,
                    MemoradumArticlesVerified : element.Memoradum_Articles_Uploaded__c,
                    EmiratedIDAutorizedVerified : element.Emirates_ID_of_Authorized_Uploaded__c,
                    LetterOfUndertakingIfCustomerIsMinorVerified : element.Letter_of_undertaking_uploaded__c,
                    VisaCopyAutorizedVerified : element.Visa_copy_of_Authorized_Uploaded__c,
                    TradeLicenseVerified : element.Trade_License_Uploaded__c,
                    PassportCopyAttorneyVerified : element.Passport_Copy_Of_Attorney_Uploaded__c

                };
                
                console.log('obj---',obj);
                if (element.Applicant_Number__c == 'Primary Applicant') {
                    this.firstApplicant = obj;
                    this.isFirstApplicant = true;
                } else if (element.Applicant_Number__c == 'Second Applicant') {
                    this.secondApplicant = obj;
                    this.isSecondApplicant = true;
                } else if (element.Applicant_Number__c == 'Third Applicant') {
                    this.thirdApplicant = obj;
                    this.isThirdApplicant = true;
                } else if (element.Applicant_Number__c == 'Fourth Applicant') {
                    this.fourthApplicant = obj;
                    this.isFourthApplicant = true;
                } else if (element.Applicant_Number__c == 'Fifth Applicant') {
                    this.fifthApplicant = obj;
                    this.isFifthApplicant = true;
                }

            });
        }).catch(error => {

        });
    }
    tabContent = '';

    handleActive(event) {
        const tab = event.target;
        this.tabContent = 'Tab ${event.target.value} is now active';
    }

    Close() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.bookingObj.Id,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    renderedCallback(){
        if(this.isCssLoaded) return
       
        loadStyle(this,CUSTOMCSS).then(()=>{
            console.log('loaded');
            this.isCssLoaded = true;
        })
        .catch(error=>{
            console.log('error to load');
        });
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFileName = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileName = uploadedFiles[i].name;
        }
        this.signedBookingFormName = uploadedFileName;

        updateContentDocumentTitle({ fileName: 'Signed Booking Form',applicantId:null, bookingId:this.recordId }).then(() => {
            this.disableSignedFormUpload = true;
            return refreshApex(this.bookingObj);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });
    }

    doSendEmail(bookingId, templateName) {
        sendEmail({ bookingId: bookingId, templateDeveloperName: templateName })
            .then(result => {
                this.Close();
            })
            .catch(error => {

            });
    }

    /*assignSBFUser(bookingId) {
        assignSBFUser({ bookingId: bookingId })
            .then(result => {
            })
            .catch(error => {

            });
    }*/

    uploadDocuments() {
        var errorForRequiredFiles = '';
        var allFilePresent = true;
        this.showSpinner = true;
        getApplicationDetails1({ bookingId: this.recordId }).then(result => {
            result.applicationDetails.forEach(element => {
                console.log(element.Subtype_Of_Applicant__c);
               if(element.Subtype_Of_Applicant__c == 'UAE Resident'){
                    if(element.Passport_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Passport is required for UAE Resident\n';
                    }
                    if(element.Visa_Copy_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Visa Copy is required for UAE Resident\n';
                    }
                    if(element.Emirates_Id_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Emirates ID is required for UAE Resident\n';
                    }
                }
                if(element.Subtype_Of_Applicant__c == 'Non-UAE Resident'){
                    if(element.Passport_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Passport is required for Non-UAE Resident\n';
                    }
                    if(element.National_Id_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- National ID is required for Non-UAE Resident\n';
                    }
                    
                }
                if(element.Subtype_Of_Applicant__c == 'Companies incorporated in the UAE'){
                    if(element.Passport_Copy_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Passport Copy of Authorized Signatory is required for Companies Incorporated in UAE\n';
                    }
                    if(element.Emirates_ID_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Emirates ID of Authorized Singatory is required for Companies Incorporated in UAE\n';
                    }
                    if(element.Visa_copy_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Visa Copy of Authorized Signatory is required for Companies Incorporated in UAE\n';
                    }
                    if(element.Trade_License_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Trade License is required for Companies Incorporated in UAE\n';
                    }
                    if(element.Memoradum_Articles_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Memoradom of Association is required for Companies Incorporated in UAE\n';
                    }
                }
                if(element.Subtype_Of_Applicant__c == 'Companies incorporated in (free zone) permitted jurisdictions'){
                    if(element.Passport_Copy_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Passport Copy of Authorized Signatory is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    }
                    if(element.Emirates_ID_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Emirates ID of Authorized Signatory is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                    if(element.Visa_copy_of_Authorized_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Visa Copy of Authorized Signatory is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                    if(element.Trade_License_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Trade License is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                    if(element.Memoradum_Articles_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Memoradum Articles of Association is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                    if(element.Certificate_Of_Incorporation_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Certificate of Incorporation is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                    if(element.Certificate_of_Good_Standing_Uploaded__c == false){
                        allFilePresent = false;
                        errorForRequiredFiles +=element.Applicant_Number__c+ '- Certificate of Good Standing is required for Companies incorporated in (free zone) permitted jurisdictions\n';
                    
                    }
                }
                    
                
            });
            if(allFilePresent == false){
                this.showSpinner =false;
                const evt = new ShowToastEvent({
                    variant: 'error',
                    message: errorForRequiredFiles,
                });
                this.dispatchEvent(evt);
                
            }else{
               //this.assignSBFUser(this.bookingObj.Id);
                this.doSendEmail(this.bookingObj.Id, 'Booking_Form_Submitted');
                this.doSendEmail(this.bookingObj.Id, 'Booking_Form_Submitted_SM');
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    variant: 'success',
                    message: 'Documents uploaded successfully!',
                });
                this.dispatchEvent(evt);
                
                
            }
        });
      
       
    }

}