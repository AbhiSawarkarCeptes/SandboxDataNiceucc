import { LightningElement, track, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Username';
import ProfileNameFld from '@salesforce/schema/User.Profile.Name';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPaymentRequest from '@salesforce/apex/PaymentRequestFormControllerCopy.createPaymentRequest';
import searchPrimaryContact from '@salesforce/apex/PaymentRequestFormControllerCopy.searchPrimaryContact';
import unitDetails from '@salesforce/apex/PaymentRequestFormControllerCopy.unitDetails';
import getUnitId from '@salesforce/apex/PaymentRequestFormControllerCopy.getUnitId';
import getPaymentRequestDetails from '@salesforce/apex/PaymentRequestFormControllerCopy.getPaymentRequestDetails';
import checkPrCanCreateOrNot from '@salesforce/apex/PaymentRequestFormControllerCopy.checkPrCanCreateOrNot';
import getContactRecPassport from '@salesforce/apex/PaymentRequestFormControllerCopy.getContactRecPassport';
import getContactRecPassport2 from '@salesforce/apex/PaymentRequestFormControllerCopy.getContactRecPassport2';
import getContactRecPassport3 from '@salesforce/apex/PaymentRequestFormControllerCopy.getContactRecPassport3';
import getPOPPdfFile from '@salesforce/apex/PaymentRequestFormControllerCopy.getPOPPdfFile';
import getPOPImgFile from '@salesforce/apex/PaymentRequestFormControllerCopy.getPOPImgFile';
import getCurrencyRate from '@salesforce/apex/PaymentRequestFormControllerCopy.getCurrencyRate';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateUploadedFileName from '@salesforce/apex/PaymentRequestFormControllerCopy.updateUploadedFileName';
import getContactRecFromOffer from '@salesforce/apex/PaymentRequestFormControllerCopy.getContactRecFromOffer';
import getContactRecFromBooking from '@salesforce/apex/PaymentRequestFormControllerCopy.getContactRecFromBooking';
import PR_OTC_Booking_Level_Restriction_Msg from '@salesforce/label/c.PR_OTC_Booking_Level_Restriction_Msg';
import PR_OTC_14_Percent_Validation_Msg from '@salesforce/label/c.PR_OTC_14_Percent_Validation_Msg';
import PR_Mortgage_Validation from '@salesforce/label/c.PR_Mortgage_Validation';
import Payment_Request_Creation_Note from '@salesforce/label/c.Payment_Request_Creation_Note';
import PR_OTC_Skip_Validation_Usernames from '@salesforce/label/c.PR_OTC_Skip_Validation_Usernames';
import checkifUnitIsBlocked from '@salesforce/apex/PaymentRequestFormControllerCopy.checkifUnitIsBlocked';
import checkPropertyAvailableForPROrNot from '@salesforce/apex/PaymentRequestFormControllerCopy.checkPropertyAvailableForPROrNot';
import checkAllocatedSmRec from '@salesforce/apex/PaymentRequestFormControllerCopy.checkAllocatedSmRec';
import getAllowedAmountVal from '@salesforce/apex/PaymentRequestFormControllerCopy.getAllowedAmountVal';
import PR_Mortgage_Extra_Charges from '@salesforce/label/c.PR_Mortgage_Extra_Charges';
import Towards_Deed_Charges from '@salesforce/label/c.Towards_Deed_Charges';
import EscrowAccountMapError from '@salesforce/label/c.EscrowAccountMapError'
//SOB-265 20k to hold unit for 24 hrs in Multi Mode
import paymentamount from '@salesforce/label/c.Payment_Amount';

const BOOKINGFIELDS = ['PropStrength__Application_Booking__c.Name','PropStrength__Application_Booking__c.Allow_Payment_Request__c','PropStrength__Application_Booking__c.Termination_Process_Status__c'];

export default class PaymentRequestFormCopy extends NavigationMixin(LightningElement) {

    @track units = [];
    @track showFromBooking = true;
    @track isBookinPage = false;
    @track Account_Type ;
    showSpinner = false;
    uploadedFileLength = 0;
    @track selected;
    @api recordId;
    @track pdfContent;
    @track showPdfPassport = false;
    @track imageUrl;
    @track showImgPassport = false;
    @track showPdfPOP = false;
    @track showImgPOP = false;
    @track showReadOnly = false;
    @track fileType;
    @track bankName;
    @track otherChangeValue;
    @track TowardsPreRegistrationAmountVal;
    @track fileUrl;
    @api objectApiName;
    @track threeModesFlag = false;
    currentUserName;
    makeLeadSourceRequired = true;
    approvedPr;
    isApprovedPrFound = false;
    //SOB-265 20k to hold unit for 24 hrs in Multi Mode
    payamount = paymentamount;
    escrowAccountMapErrorMessage = EscrowAccountMapError;
    @track showUnitSelection = false;
    @wire(getRecord, { recordId: Id, fields: [UserNameFld,ProfileNameFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Username.value;
            var currentProfileName = data.fields.Profile.value.fields.Name.value;
            if(!currentProfileName.includes('Sales')){
                this.makeLeadSourceRequired = false;
            }
        } else if (error) {
            this.error = error;
        }
    }
    label = {
        PR_OTC_Booking_Level_Restriction_Msg,
        PR_OTC_14_Percent_Validation_Msg,
        Payment_Request_Creation_Note,
        PR_Mortgage_Validation,
        PR_OTC_Skip_Validation_Usernames,
        PR_Mortgage_Extra_Charges,
        Towards_Deed_Charges
    };

    isCash = false;
    isCheque = false;
    isCreditCard = false;
    isWebsite = false;
    isCDMCash = false;
    isCDMCheque = false;
    isIWT = false;
    isDWT = false;
    isNOTCash = false;

    bookingDetailsFetched = false;

    @track customerName = '';
    @track customerEmail = '';
    @track customerPhone = '';
    @track customerPassportOrEmiratesId = '';
    @track customerPassport = '';
    @track category = '';
    @track subcategory = '';
    @track enqSource = '';
    @track typeOfEnquiry = '';
    @api bookingIdRecord;
    @api offerIdRecord;
    @api propertyRecordId;
    @api enquiryRecordId;
    @api unitOutStanding;
    @api DLDOutStanding;
    @api OtherChargesOutStanding;

    @track defaultCurrency = 'AED';

    @track isMultiMode = false;
    bookingId = '';
    modeOption = '';
    secondaryMode = '';
    toastMessg = '';
    allowedAmount;
    @track Towards_Other_Charges_Amount_Val;

    @track multiAmountAllocationFeatureFlag = true;//SOB-278 Aayushi
    @track multiAccountTowerMappingFeatureFlag = true;


    @track modeSelected = false;
    @track towardsUnit = false;
    @track towardsPreReg = false;
    @track towardsOthers = false;
    @track hasOtherCharges = false;
    @track fromBooking = false;


    prId = '';
    rateMap;
    @track isCorporate = false;
    @track isESCROW = false;
    isSecondaryMode = false;
    @track escrowAccountName = '';

    authorizationFormUploaded = false;
    declarationFormUploaded = false;
    thirdPartyChequeUploaded = false;
    thirdPartyIWTUploaded = false;
    iwtpopFormUploaded = false;
    dwtpopFormUploaded = false;
    cdmChequepopFormUploaded = false;
    isThirdParty = false;
    thirdPartyCheque = false;
    thirdPartyIWT = false;
    thirdPartyCDMChequeUploaded = false;
    thirdPartyCDMCheque = false;
    thirdPartyDWT = false;
    thirdPartyDWTUploaded = false;
    @track showForm = true;
    showFromProperty = false;
    showFromProperty2 = false;
    showFromEnquiry = false;
    isEnquiryPage = false;
    isPropertyPage = false;
    showFromPR = false;
    newPRPage = false;
    isOfferRecord = false;
    prRecordId;
    secondryModeAccountTypeFlag = false;
    propertyPopAmountFlag = false;
    @wire(getRecord, { recordId: '$recordId', fields: BOOKINGFIELDS })
    wiredRecord({ error, data }) {
        console.log('inn offer--',this.objectApiName);
        console.log(this.recordId);
        
        if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a6E')) {
            console.log('inn1');
            this.offerIdRecord = this.recordId;
            this.isOfferRecord = true;
            this.getContFromOffer();
        }

        if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a4w')) {
            console.log('inn2 booking');
            this.bookingIdRecord = this.recordId;
            this.showFromBooking = false;
            this.isBookinPage = true;
            this.modeOption = 'Single Mode';
            this.getContFromBooking();
        }

        if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a28')) {
            console.log('inn3 pr');
            var units = this.units;
            this.prRecordId = this.recordId;
            this.showUnitSelection = false;
            this.showFromPR = true;
            this.modeOption = 'Multi Mode';
            this.isMultiMode = true;
            this.fromBooking = false;
            this.isSecondaryMode = true;
            console.log(this.units);
            getPaymentRequestDetails({ prId: this.recordId })
                .then(result => {
                    console.log('resut of PR28');
                    console.log(result);
                    this.bookingDetailsFetched = true;
                    units[0].id = result.Property__c;
                    units[0].value = result.Property__c;
                    if (result.hasOwnProperty('Property__r')) {
                        units[0].onDirectSale = result.Property__r.For_Direct_Sale__c;//sob-1040
                    }
                    this.propertyRecordId = result.Property__c;
                    this.customerName = result.Name__c;
                    this.customerEmail = result.Email__c;
                    this.offerIdRecord = result.Offer__c;
                    this.customerPhone = result.Enquiry__r.PropStrength__Primary_Contact__r.MobilePhone;
                    this.customerPassportOrEmiratesId = result.Enquiry__r.PropStrength__Primary_Contact__r.Emirates_ID__c;
                    this.customerPassport = result.Enquiry__r.PropStrength__Primary_Contact__r.Passport_No__c;
                    this.enqSource =  result.Enquiry_Source__c;
                    this.typeOfEnquiry = result.Type_of_Enquiry__c;
                    this.secondaryMode = result.Mode__c;
                    this.category = result.Lead_Source_Category__c;
                    this.subcategory = result.Lead_Source_Sub_Category__c;
                    if (result.Property__c != null && result.Property__r.PropStrength__Tower__c != null && result.Property__r.PropStrength__Tower__r.ESCROW_Account__c != null) {
                        this.escrowAccountName = result.Property__r.PropStrength__Tower__r.ESCROW_Account__r.Name;
                    }
                    this.units = units;
                    this.prId = result.Id;
                })
                .catch(error => {
                    console.log(error);
                });
        }

        if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a6d')) {
            console.log('inn5 Property');
            this.propertyRecordId = this.recordId;
            this.checkAllocatedSm();
            this.checkPropertyAvailableForPR();
            this.showFromProperty = true;
            this.showFromProperty2 = true;
            this.isPropertyPage = true;
            this.units = [];
            var units = [];
            console.log('esttttttt2222');
            var obj = { 'row': 1, 'id': this.propertyRecordId , 'details': '', 'currency': 'AED', 'amount': '', 'isRemoveVisible': false, 'accountType': '', 'accountId': '', 'isCorporate': false, 'isESCROW': false, 'escrowAccount': '', 'value': this.propertyRecordId };
            units.push(obj);
            this.units = units;

            if ((this.bookingIdRecord == undefined || this.bookingIdRecord == null || this.bookingIdRecord == '')) {
                console.log('inn7 pr can create');
                this.checkPrCanCreate();
            }

        }

        if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a6g')) {
            console.log(this.newPRPage,'--inn6 Enquiry--',this.recordId);
            this.enquiryRecordId = this.recordId;
            this.retreivePrimaryContact();
            this.showFromEnquiry = true;
            this.isEnquiryPage = true;
        }
        this.newPRPage = false;
        if(this.recordId == null || this.recordId == '' || this.recordId == undefined){
            this.newPRPage = true;
        }
        console.log(this.showFromEnquiry,'****',this.newPRPage);
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            console.log('data - > ',JSON.stringify(data));
            console.log('data - > ',data.fields.Termination_Process_Status__c.value);
            // if(data.fields.Termination_Process_Status__c.value == 'Termination Cancelled' || data.fields.Allow_Payment_Request__c.value){
            //     console.log('TRUES');
            //     this.showForm = true;
            // }else{
            //     this.showForm = false;
            //     console.log('FALSE');
            // }
        }
    }

    checkAllocatedSm() {
        checkAllocatedSmRec({
            recId: this.propertyRecordId
        }).then(result => {
            if (result == 'No') {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'This user is not allowed to create Payment Request.'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            } else if (result == 'Fill') {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'Please Fill Allocated SM field on Property.'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    checkPropertyAvailableForPR() {
        console.log('inn8 pr can create');
        console.log(this.propertyRecordId);
        checkPropertyAvailableForPROrNot({
            recId: this.propertyRecordId
        }).then(result => {
            if (result == 'No') {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'This property is not available for Payment Request.'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    checkPrCanCreate() {
        console.log(this.propertyRecordId);
        checkPrCanCreateOrNot({
            recId: this.propertyRecordId
        }).then(result => {
            if (result == 'No') {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'Payment Request can not be created on this Property.'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    handleThirdPartyChange(event) {
        this.isThirdParty = event.currentTarget.value;
    }

    handleOtherChangeValue(event) {
        this.otherChangeValue = event.currentTarget.value;
        this.allowedAmount = null;
        this.getAllowedAmountValue();
    }

    getAllowedAmountValue() {
        var cashOrNot = this.isCash  ? true : false;
        getAllowedAmountVal({ othercharge: this.otherChangeValue, bookId : this.bookingIdRecord, mode : cashOrNot})
            .then(result => {
                console.log('result other charge----', result);
                if (result != null) {
                    this.allowedAmount = result;
                    if (this.allowedAmount == 0) {
                        this.allowedAmount = null;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    retrieveContactFromOffer(event) {
        this.offerIdRecord = event.detail.value[0];
        if (this.offerIdRecord != null && this.offerIdRecord != '' && this.offerIdRecord != undefined) {
            this.getContFromOffer();
        } else {
            this.customerPassportOrEmiratesId = '';
            this.customerName = '';
            this.customerEmail = '';
            this.customerPhone = '';
            this.customerPassport = '';
            this.enqSource = '';
            this.typeOfEnquiry = '';
        }
    } 

    retrieveContactFromBooking(event) {
        this.bookingIdRecord = event.detail.value[0];
        if (this.bookingIdRecord != null && this.bookingIdRecord != '' && this.bookingIdRecord != undefined) {
            this.getContFromBooking();
        } else {
            this.customerPassportOrEmiratesId = '';
            this.customerName = '';
            this.customerEmail = '';
            this.customerPhone = '';
            this.customerPassport = '';
            this.enqSource = '';
            this.typeOfEnquiry = '';
        }
    }

    getContFromOffer() {
        this.customerPassportOrEmiratesId = '';
        this.customerName = '';
        this.customerEmail = '';
        this.customerPhone = '';
        this.customerPassport = '';
        this.enqSource = '';
        this.typeOfEnquiry = '';
        getContactRecFromOffer({ offerIdrec: this.offerIdRecord})
            .then(result => {
                console.log('offer');
                console.log(result);
                if (result.PropStrength__Status__c == 'Closed Won') {
                    const evt = new ShowToastEvent({
                        label: 'Error',
                        title: 'Error',
                        variant: 'error',
                        message: 'Offer is closed won'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
                this.customerName = result.PropStrength__Primary_Contact__r.Name;
                this.customerEmail = result.PropStrength__Primary_Contact__r.Email;
                this.customerPhone = result.PropStrength__Primary_Contact__r.MobilePhone;
                if (result.PropStrength__Primary_Contact__r.Passport_No__c != undefined && result.PropStrength__Primary_Contact__r.Passport_No__c != '' && result.PropStrength__Primary_Contact__r.Passport_No__c != null) {
                    this.customerPassport = result.PropStrength__Primary_Contact__r.Passport_No__c;
                }
                if (result.PropStrength__Primary_Contact__r.Emirates_ID__c != undefined && result.PropStrength__Primary_Contact__r.Emirates_ID__c != '' && result.PropStrength__Primary_Contact__r.Emirates_ID__c != null) {
                    this.customerPassportOrEmiratesId = result.PropStrength__Primary_Contact__r.Emirates_ID__c;
                }
                this.enqSource = result.PropStrength__Request__r.PropStrength__Request_Source__c;
                this.typeOfEnquiry = result.PropStrength__Request__r.Type_of_Enquiry__c;
                this.enquiryRecordId = result.PropStrength__Request__c;
                var obj = { 'row': 1, 'id': result.PropStrength__Property__c , 'details': '', 'currency': 'AED', 'amount': '', 'isRemoveVisible': false, 'accountType': '', 'accountId': '', 'isCorporate': false, 'isESCROW': false, 'escrowAccount': '', 'value': result.PropStrength__Property__c };
                var units = [];
                console.log('esttttttt33');
                units.push(obj);
                this.units = units;
                this.showFromProperty = true;
                this.showFromEnquiry = true;
                this.getPassportFromContact(result.PropStrength__Primary_Contact__c);
                // this.offerIdRecord = {Id: result.Id,Name: result.Name};
            })
            .catch(error => {
                    console.log(error);
            });
    }

    getPassportFromContact(contId) {
        getContactRecPassport({ contactId: contId})
            .then(result => {
                console.log('passport----');
                if (result != null) {
                    this.pdfContent = result;
                    this.showPdfPassport = true;
                } else {
                    this.getPassportFromContact2(contId);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    getPassportFromContact2(contId) {
        this.showSpinner = true;
        console.log('contId--',contId);
        getContactRecPassport2({ contactId: contId})
            .then(result => {
                console.log('passport File----');
                if (result != null) {
                    this.showPdfPassport = true;
                    const blobVal = new Blob([this.base64ToArrayBuffer(result)], { type: 'application/pdf' });
                    this.pdfContent = URL.createObjectURL(blobVal);
                } else {
                    this.getPassportFromContact3(contId);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    getPassportFromContact3(contId) {
        this.showSpinner = true;
        getContactRecPassport3({ contactId: contId})
            .then(result => {
                console.log('passport IMG File----',result);
                console.log(JSON.stringify(result));
                if (result != null) {
                    this.showImgPassport = true;
                    this.imageUrl = 'data:image/jpeg;base64,' + result;
                    this.showSpinner = false;
                }       
                this.showSpinner = false;         
            })
            .catch(error => {
                console.log(error);
            });
    }

    base64ToArrayBuffer(base64) {
        const binaryString = window.atob(base64);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; ++i) {
            bytes[i] = binaryString.charCodeAt(i);
        }
        this.showSpinner = false;
        return bytes.buffer;
    }

    getContFromBooking() {
        this.customerPassportOrEmiratesId = '';
        this.customerName = '';
        this.customerEmail = '';
        this.customerPhone = '';
        this.customerPassport = '';
        this.enqSource = '';
        this.typeOfEnquiry = '';
        getContactRecFromBooking({ bookingIdRec: this.bookingIdRecord})
            .then(result => {
                console.log('booking');
                console.log(result);
                if (result.Termination_Process_Status__c == 'Submitted to DLD' || result.Termination_Process_Status__c == 'Approved for Termination') {
                    const evt = new ShowToastEvent({
                        label: 'Error',
                        title: 'Error',
                        variant: 'error',
                        message: 'PR cannot be created as this Booking is under Termination'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
                this.customerName = result.PropStrength__Primary_Customer__r.Name;
                this.customerEmail = result.PropStrength__Primary_Customer__r.Email;
                this.customerPhone = result.PropStrength__Primary_Customer__r.MobilePhone;

                this.DLDOutStanding = result.DLD_Outstanding__c;
                this.OtherChargesOutStanding = result.Income_Charge_Outstanding_Without_DLD__c;
                this.unitOutStanding = result.PropStrength__Outstanding_Balance__c;

                if (result.PropStrength__Primary_Customer__r.Passport_No__c != undefined && result.PropStrength__Primary_Customer__r.Passport_No__c != '' && result.PropStrength__Primary_Customer__r.Passport_No__c != null) {
                    this.customerPassport = result.PropStrength__Primary_Customer__r.Passport_No__c;
                }
                if (result.PropStrength__Primary_Customer__r.Emirates_ID__c != undefined && result.PropStrength__Primary_Customer__r.Emirates_ID__c != '' && result.PropStrength__Primary_Customer__r.Emirates_ID__c != null) {
                    this.customerPassportOrEmiratesId = result.PropStrength__Primary_Customer__r.Emirates_ID__c;
                }
                if (result.PropStrength__Booking_Request__c != undefined && result.PropStrength__Booking_Request__r.PropStrength__Request_Source__c != undefined && result.PropStrength__Booking_Request__r.PropStrength__Request_Source__c != '' && result.PropStrength__Booking_Request__r.PropStrength__Request_Source__c != null) {
                    this.enqSource = result.PropStrength__Booking_Request__r.PropStrength__Request_Source__c;
                }
                if (result.PropStrength__Booking_Request__c != undefined && result.PropStrength__Booking_Request__r.Type_of_Enquiry__c != undefined && result.PropStrength__Booking_Request__r.Type_of_Enquiry__c != '' && result.PropStrength__Booking_Request__r.Type_of_Enquiry__c != null) {
                    this.typeOfEnquiry = result.PropStrength__Booking_Request__r.Type_of_Enquiry__c;
                }
                console.log('result -> ',JSON.stringify(result));
                if (result.PropStrength__Property__c != null && result.PropStrength__Property__r.PropStrength__Tower__c != null && result.PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c != null) {
                    this.escrowAccountName = result.PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__r.Name;
                }
                this.getPassportFromContact(result.PropStrength__Primary_Customer__c);
                // this.bookingIdRecord = {Id: result.Id,Name: result.Name};
            })
            .catch(error => {
                    console.log(error);
            });
    }

    onAmountTowardsChange(event) {
        this.towardsUnit = (event.detail.value == 'Unit Price') ? true : false;
        this.towardsPreReg = (event.detail.value == 'Registration Amount') ? true : false;
        this.towardsOthers = (event.detail.value == 'Other Amount') ? true : false;
    }

    validateOtherCharges(event) {
        this.Towards_Other_Charges_Amount_Val =event.detail.value ;
        this.hasOtherCharges = (event.detail.value > 0) ? true : false;
    }


    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            if(this.isIWT){  
                this.iwtpopFormUploaded = true;
            }else if(this.isDWT){
                this.dwtpopFormUploaded = true;
            }
            if(this.isCDMCheque){
                this.cdmChequepopFormUploaded = true;
            }
            
            console.log("Upload");
            console.log(uploadedFiles[0]);

            
            this.fileType = this.getFileType(uploadedFiles[0].mimeType);

            if (this.fileType === 'image') {
                this.getPOPImg(uploadedFiles[0].contentVersionId);
            } else if (this.fileType === 'application/pdf') {
                this.getPOPPdf(uploadedFiles[0].contentVersionId);
            }
            console.log(this.fileUrl);
            updateUploadedFileName({ fileName: 'POP', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    getPOPPdf(contVId) {
        this.showSpinner = true;
        getPOPPdfFile({ contVersionId: contVId})
            .then(result => {
                console.log('POP File----');
                if (result != null) {
                    const blobVal = new Blob([this.base64ToArrayBuffer(result)], { type: 'application/pdf' });
                    this.fileUrl = URL.createObjectURL(blobVal);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    getPOPImg(contVId) {
        this.showSpinner = true;
        getPOPImgFile({ contVersionId: contVId})
            .then(result => {
                console.log('POP IMG File----');
                if (result != null) {
                    console.log(result);
                    this.showSpinner = false;
                    this.fileUrl = 'data:image/jpeg;base64,' + result;
                }
            })
            .catch(error => {
                console.log(error);
            });
    }


    getFileType(type) {
        if (type.startsWith('image/')) {
            this.showImgPOP = true;
            this.showPdfPOP = false;
            return 'image';
        } else if (type === 'application/pdf') {
            this.showImgPOP = false;
            this.showPdfPOP = true;
            return 'application/pdf';
        }
        return null;
    }

    handleUploadFinishedAuthorizationForm(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.authorizationFormUploaded = true;
            updateUploadedFileName({ fileName: 'Credit Card Authorization Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedDeclarationForm(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.declarationFormUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Declaration Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdPartyCheque(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyChequeUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdParty(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyChequeUploaded = true;
            updateUploadedFileName({ fileName: 'Trade licence / Passport/EID copy', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdOther(event) {
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyChequeUploaded = true;
            updateUploadedFileName({ fileName: 'Other Docs', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdPartyIWT(event){
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyIWTUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdPartyDWT(event){
        console.log('upload finished');
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyDWTUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdPartyCDMCheque(event){
        const uploadedFiles = event.detail.files;
        console.log('this.uploadedFileLength*-1--',this.uploadedFileLength);
        this.uploadedFileLength += uploadedFiles.length;
        console.log('this.uploadedFileLength*-2--',this.uploadedFileLength);
        if (uploadedFiles.length > 0) {
            this.thirdPartyCDMChequeUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    showThirdPartyFileUpload(event) {
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyCheque = true;
        } else {
            this.thirdPartyCheque = false;
        }
    }

    showThirdPartyFileUploadIWT(event){
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyIWT = true;
        } else {
            this.thirdPartyIWT = false;
        }
    }

    showThirdPartyFileUploadDWT(event){
        console.log('DWT upload');
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyDWT = true;
           
        } else {
            this.thirdPartyDWT = false;
        }
    }

    showThirdPartyFileUploadCDMCheque(event){
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyCDMCheque = true;
        } else {
            this.thirdPartyCDMCheque = false;
        }
    }

    handleModeOptionChange(event) {
        this.isMultiMode = (event.detail.value == 'Multi Mode') ? true : false;
    }

    // renderedCallback() {
    //     console.log(this.prRecordId); 
    //     console.log('in renderCallback');
    //     console.log(this.recordId);
    //     if (this.recordId != undefined && this.recordId.includes('a28')) {
    //         this.showUnitSelection = false;
    //         this.showFromPR = true;
    //         this.modeOption = 'Multi Mode';
    //         this.isMultiMode = true;
    //         this.fromBooking = false;
    //         this.isSecondaryMode = true;
    //         getPaymentRequestDetails({ prId: this.recordId })
    //             .then(result => {
    //                 console.log(result);
    //                 this.bookingDetailsFetched = true;
    //                 units[0].id = result.Property__c;
    //                 units[0].onDirectSale = result.Property__r.For_Direct_Sale__c;//sob-1040
                
    //                 this.customerName = result.Name__c;
    //                 this.customerEmail = result.Email__c;
    //                 this.customerPhone = result.Mobile_Number__c;
    //                 this.customerPassportOrEmiratesId = result.Emirates_Id_Passport_Number__c;
    //                 this.secondaryMode = result.Mode__c;
    //                 this.category = result.Lead_Source_Category__c;
    //                 this.subcategory = result.Lead_Source_Sub_Category__c;
    //                 if (result.Property__c != null && result.Property__r.PropStrength__Tower__c != null && result.Property__r.PropStrength__Tower__r.ESCROW_Account__c != null) {
    //                     this.escrowAccountName = result.Property__r.PropStrength__Tower__c.ESCROW_Account__r.Name;
    //                 }
    //                 this.units = units;
    //                 this.prId = result.Id;
    //             })
    //             .catch(error => {
    //             });
    //     } else {
    //         this.showUnitSelection = true;
    //     }
    // }

    connectedCallback() {
        var units = [];
        console.log(this.propertyRecordId);
        console.log('esttttttt11');
        var obj = { 'row': 1, 'id': this.propertyRecordId, 'details': '', 'currency': 'AED', 'amount': '', 'isRemoveVisible': false, 'accountType': '', 'accountId': '', 'isCorporate': false, 'isESCROW': false, 'escrowAccount': '', 'value': this.propertyRecordId };
        units.push(obj);
        this.units = units;
        getCurrencyRate()
            .then(result => {
                this.rateMap = result;
            })
            .catch(error => {
            });
        console.log('connectedCallback');
        console.log(this.bookingIdRecord);
        console.log(this.offerIdRecord);
        console.log(this.units);
        console.log(this.recordId);
        this.showUnitSelection = true;

        // if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a3')) {
        //     this.offerIdRecord = this.recordId;
        // }

        // if (this.recordId != null && this.recordId != '' && this.recordId != undefined && this.recordId.includes('a2')) {
        //     this.bookingIdRecord = this.recordId;
        // }

        // if (this.offerIdRecord != '' && this.offerIdRecord != null && this.offerIdRecord != undefined) {
        //     this.getContFromOffer();
        // }

        // if (this.bookingIdRecord != '' && this.bookingIdRecord != null && this.bookingIdRecord != undefined) {
        //     this.getContFromBooking();
        // }
    }

    addUnits() {
        var units = this.units;
        var unit = units[units.length - 1];
        var row = unit.row;
         var obj = { 'row': row + 1, 'id': '', 'details': '', 'currency': 'AED', 'amount': '', 'isRemoveVisible': true, 'accountType': '', 'accountId': '', 'isCorporate': false, 'isESCROW': false, 'escrowAccount': '' };
        if (this.isIWT == true && this.isDWT == false) {
            obj.currency = undefined;
            if (this.popCurrency) {
                obj.currency = this.popCurrency;
            }
        }
        console.log('esttttttt555');
        units.push(obj);
        this.units = units;
    }

    handleModeChange(event) {
        console.log('Logging..');
                        console.log(event.detail.value);
        this.hasOtherCharges = false;
        if (event.detail.value) {
            this.modeSelected = true;
        } else {
            this.modeSelected = false;
        }
        this.isCash = (event.detail.value == 'OTC Deposits(Cash counter)') ? true : false;
        this.isCheque = (event.detail.value == 'Cheque') ? true : false;
        this.isCreditCard = (event.detail.value == 'Credit Card') ? true : false;        
        this.isWebsite = (event.detail.value == 'Website') ? true : false;
        console.log(this.isCash,'*---',this.isCheque,'///',this.isCreditCard,'--',this.isWebsite);
        if(this.isCash || this.isCheque || this.isCreditCard || this.isWebsite){
            this.threeModesFlag = true;
        }
        else
            this.threeModesFlag = false;
        this.isCDMCash = (event.detail.value == 'CDM Cash (Cash Deposit in Machine)') ? true : false;
        this.isCDMCheque = (event.detail.value == 'CDM Cheque (Cheque Deposit in Machine)') ? true : false;
        this.isIWT = (event.detail.value == 'IWT(International)') ? true : false;
        if (event.detail.value == 'DWT(Domestic)') {
            this.isIWT = false;
            this.isDWT = true;
            this.thirdPartyDWT = false;
            this.thirdPartyIWT = false;
        } else {
            this.isDWT = false;
        }
        if( this.isIWT || this.isDWT || this.isCDMCash || this.isCDMCheque){
            this.secondryModeAccountTypeFlag = true;
        }
        else
            this.secondryModeAccountTypeFlag = false;

        if( this.isCash || this.isCreditCard || this.isWebsite ){
            this.propertyPopAmountFlag = true;
        }
        else
            this.propertyPopAmountFlag = false;
        if(event.detail.value == 'IWT(International)'){
            this.thirdPartyDWT = false;
            this.thirdPartyIWT = false;
        }

        if (this.isIWT)
            this.defaultCurrency = '';
        else
            this.defaultCurrency = 'AED';

        if (event.detail.value != 'OTC Deposits(Cash counter)') {
            this.isNOTCash = true;
        }
        else {
            this.isNOTCash = false;
        }

        this.units.forEach(u => {
            if (this.isIWT == true && this.isDWT == false) {
                u.currency = this.popCurrency;
            }
        })
        console.log('CRUX');
         console.log(this.isIWT);
                        console.log(this.isDWT);
    }

    onRemove(event) {
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        var tempUnits = this.units;
        var indexNo;
        for (var i = 0; i < tempUnits.length; i++) {
            if (tempUnits[i].row == rowNo) {
                indexNo = i;
                break;
            }
        }
        tempUnits.splice(indexNo, 1);
        this.units = tempUnits;
    }

    onCurrencySelect(event) {
        var curr = event.detail.value;
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            if (units[i].row == rowNo) {
                units[i].currency = curr;
            }
        }
        this.units = units;
    }

    onCurrencySelectMulti(event) {
        var curr = event.detail.value;
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            units[i].currency = curr;
        }
        this.units = units;
    }

    onAmountSelectBooking(event) {
        var amt = event.detail.value;
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            units[i].amount = amt;
        }
        this.units = units;
    }

    onAmountSelect(event) {
        var amt = event.detail.value;
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            if (units[i].row == rowNo) {
                units[i].amount = amt;
            }
        }
        this.units = units;
    }

    onAccountTypeChangeMulti(event) {
        console.log(event.detail.value);   
        this.Account_Type = event.detail.value;     
        this.isCorporate = (event.detail.value == 'Corporate') ? true : false;
        this.isESCROW = (event.detail.value == 'ESCROW') ? true : false;   
        console.log(this.TowardsPreRegistrationAmountVal,'*****',this.Towards_Other_Charges_Amount_Val);     
        if( ( (this.TowardsPreRegistrationAmountVal != undefined && this.TowardsPreRegistrationAmountVal != null && this.TowardsPreRegistrationAmountVal != '') || 
        (this.Towards_Other_Charges_Amount_Val != undefined && this.Towards_Other_Charges_Amount_Val != null && this.Towards_Other_Charges_Amount_Val != '') )  && this.isBookinPage && event.detail.value == 'ESCROW'){
            this.Account_Type = '--None--';
            alert('ESCROW Account Type selected towards should be only to Unit price');
            console.log('test');
            this.Account_Type = '--None--';
        }
        
    }

    onBankNameChange(event) {        
        this.bankName = event.detail.value;      
    }

    handlePre_Registration_Amount(event){
        this.TowardsPreRegistrationAmountVal = event.detail.value;
    }

    onAccountTypeChange(event) {
        var accountType = event.detail.value;
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            if (units[i].row == rowNo) {
                units[i].accountType = accountType;
                if (accountType == 'Corporate')
                    units[i].isCorporate = true;
                else
                    units[i].isCorporate = false;
                if (accountType == 'ESCROW')
                    units[i].isESCROW = true;
                else
                    units[i].isESCROW = false;
            }
        }
        this.units = units;
    }

    onAccountIdChange(event) {
        var accountId = event.detail.value;
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            if (units[i].row == rowNo) {
                units[i].accountId = accountId;
            }
        }
        this.units = units;
    }
    
    onUnitSelect(event) {
        console.log(event);
        console.log(event.detail.value);
        var unitId = event.detail.value;
        this.propertyRecordId = event.detail.value[0];
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
        console.log(rowNo);
        if (String(unitId) == '') {
            var units = this.units;
            for (var i = 0; i < units.length; i++) {
                if (units[i].row == rowNo) {
                    units[i].id = '';
                    units[i].details = '';

                }

            }
            this.units = units;
        } else {
            console.log('in else');
            console.log(this.propertyRecordId);
            checkPropertyAvailableForPROrNot({
                recId: this.propertyRecordId
            }).then(result => {
                console.log(result);
                if (result == 'No') {
                    this.propertyRecordId = undefined;
                    var units = this.units;
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].row == rowNo) {
                            units[i].id = '';
                            units[i].details = '';
                            units[i].value = '';
                        }
                    }
                    this.units = units;

                    const evt = new ShowToastEvent({
                        label: 'Warning',
                        title: 'Warning',
                        variant: 'warning',
                        message: 'This property is not available for Payment Request.'
                    });
                    this.dispatchEvent(evt);
                } else {
                    this.showSpinner = true;
                    checkifUnitIsBlocked({ 'unitid': String(unitId) }).then(response => {
                        this.showSpinner = false;
                        if (response == true) {
                            const userInputs = this.template.querySelectorAll('[data-id="' + rowNo + '"]');
                            userInputs.forEach(element => {
                                element.value = null;

                            });
                            const evt = new ShowToastEvent({
                                label: 'Error',
                                title: 'Error',
                                variant: 'error',
                                message: ' Unit has been blocked due to non submission of New Sale Approval, please wait for 24 hours to select same unit.'
                            });
                            this.dispatchEvent(evt);
                        } else {
                            unitDetails({ unitId: String(unitId) })
                                .then(result => {
                                    var units = this.units;
                                    var unitKey = result.unitkey;//sob-1040
                                    console.log('this.units===',this.units);
                                    var existingUnitLength = 0;
                                    this.units.forEach(u =>{
                                        if(u.id && u.id != ""){
                                            existingUnitLength ++;
                                        }
                                    })
                                    if(existingUnitLength >= 1
                                        && this.existingProject != unitKey.split('-')[0]){
                                            const userInputs = this.template.querySelectorAll('[data-id="' + rowNo + '"]');
                                            userInputs.forEach(element => {
                                                element.value = null;
                                            });
                                            var msg = 'Units can be selected from a common project only '+this.existingProject;
                                        const evt = new ShowToastEvent({
                                            label: 'Error',
                                            title: 'Error',
                                                variant: 'error',
                                                message: msg
                                            });
                                            this.dispatchEvent(evt);
                                            return;
                                    }else if(existingUnitLength >= 1){
                                        console.log('This is here -> ',existingUnitLength);
                                        console.log('This is here -> ',this.units.lenght);
                                        
                                        let sameUnit = false;
                                        this.units.forEach(element => {
                                            console.log('This is here element -> ',JSON.parse(JSON.stringify(element)));
                                            console.log('This is here unitId -> ',JSON.parse(JSON.stringify(unitId)));
                                            if(element.id[0] == unitId[0]){
                                                sameUnit = true;
                                            }
                                        });
                                        console.log('This is here sameUnit -> ',sameUnit);
                                        if(sameUnit){
                                            const userInputs = this.template.querySelectorAll('[data-id="' + rowNo + '"]');
                                            userInputs.forEach(element => {
                                                element.value = null;

                                            });
                                            var msg = 'Trying to add duplicate Unit is not allowed please select some other Unit ';
                                            const evt = new ShowToastEvent({
                                                label: 'Error',
                                                title: 'Error',
                                                variant: 'error',
                                                message: msg
                                            });
                                            this.dispatchEvent(evt);
                                            return;
                                        }
                                    }    
                                    ////sob-1040 start
                                    for (var i = 0; i < units.length; i++) {
                                        if (units[i].row == rowNo) {
                                            units[i].id = unitId;
                                            units[i].details = unitKey.split('@@')[0];
                                            units[i].escrowAccount = unitKey.split('@@')[1];
                                            units[i].onDirectSale = result.onDirectSale;
                                        }

                                    }
                                    this.units = units;
                                    
                                    console.log('this units -> ',this.units);
                                    existingUnitLength = 0;
                                    this.units.forEach(u =>{
                                        if(u.id && u.id != ""){
                                            existingUnitLength ++;
                                        }
                                    })
                                    if(existingUnitLength == 1){
                                        this.existingProject =  unitKey.split('-')[0];//sob-1040
                                    }
                                    if(existingUnitLength == 0){
                                        this.existingProject = null;
                                    }
                                })
                                .catch(error => {
                                });
                        }
                    });
                }
            })
            .catch(error => {
                console.log('rooro -> ',JSON.stringify(error));
                const evt = new ShowToastEvent({
                    label: 'Warning',
                    title: 'Warning',
                    variant: 'warning',
                    message: JSON.stringify(error)
                });
                this.dispatchEvent(evt);
            });
        }

    }

    handleSubmit(event) {
        event.preventDefault();
        console.log('save');
        console.log(this.bookingIdRecord);
        console.log(this.offerIdRecord);
        console.log(this.propertyRecordId); 
        console.log(this.allowedAmount); 
        console.log(this.Towards_Other_Charges_Amount_ValTowards_Other_Charges_Amount_Val); 
        
        if(this.allowedAmount != undefined && this.allowedAmount != null){
            if (parseFloat(this.Towards_Other_Charges_Amount_Val) > parseFloat(this.allowedAmount)) {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'Towards Other Charges Amount can not be greater than Allowed Amount!!'
                });
                this.dispatchEvent(evt);
                return;
            }
        }
       
        console.log((this.bookingIdRecord == undefined || this.bookingIdRecord == null && this.bookingIdRecord == '') && (this.offerIdRecord == undefined || this.offerIdRecord == null && this.offerIdRecord == '') && (this.propertyRecordId == undefined || this.propertyRecordId == null && this.propertyRecordId == ''));
        const fields = event.detail.fields;
        if ((fields.Email__c != '' && fields.Email__c != undefined && fields.Email__c != null)) {
            this.customerEmail = fields.Email__c;
            console.log('in cond0');
        }
        if ( (fields.Name__c != '' && fields.Name__c != undefined && fields.Name__c != null)) {
            console.log('in cond1');
            this.customerName = fields.Name__c;
        }
        if ( (fields.Mobile_Number__c != '' && fields.Mobile_Number__c != undefined && fields.Mobile_Number__c != null)) {
            console.log('in cond2');
            this.customerPhone = fields.Mobile_Number__c;
        }
        if ((fields.Emirates_Id_Passport_Number__c != '' && fields.Emirates_Id_Passport_Number__c != undefined && fields.Emirates_Id_Passport_Number__c != null)) {
            console.log('in cond3');
            this.customerPassportOrEmiratesId = fields.Emirates_Id_Passport_Number__c;
        }
        if( (fields.Passport_No__c != '' && fields.Passport_No__c != undefined && fields.Passport_No__c != null)) {
            console.log('in cond4');
            this.customerPassport = fields.Passport_No__c;
        }

        console.log(this.customerPassport);
        console.log(this.customerPassportOrEmiratesId);
        console.log(this.customerPhone);
        console.log(this.customerName);
        console.log(this.customerEmail);

        if( this.customerEmail == '' || this.customerEmail == undefined || this.customerEmail == null ||
            this.customerName == '' || this.customerName == undefined || this.customerName == null ||
            this.customerPhone == '' || this.customerPhone == undefined || this.customerPhone == null ||
            this.customerPassportOrEmiratesId == '' || this.customerPassportOrEmiratesId == undefined || this.customerPassportOrEmiratesId == null ||
            this.customerPassport == '' || this.customerPassport == undefined || this.customerPassport == null
         ){
            const evt = new ShowToastEvent({
                label: 'Error',
                title: 'Error',
                variant: 'error',
                message: 'Name, Email, Mobile Number, Emirates Id / Passport Number and Passport No is mandatory for all modes'
            });
            this.dispatchEvent(evt);
            return;
        }  
        if ((this.bookingIdRecord == undefined || this.bookingIdRecord == null && this.bookingIdRecord == '') && (this.offerIdRecord == undefined || this.offerIdRecord == null && this.offerIdRecord == '') && (this.propertyRecordId == undefined || this.propertyRecordId == null && this.propertyRecordId == '')) {
            const evt = new ShowToastEvent({
                label: 'Error',
                title: 'Error',
                variant: 'error',
                message: 'Please select Either Property OR Booking OR Offer'
            });
            this.dispatchEvent(evt);
            return;
        } 

        if( ( (this.TowardsPreRegistrationAmountVal != undefined && this.TowardsPreRegistrationAmountVal != null && this.TowardsPreRegistrationAmountVal != '') || 
        (this.Towards_Other_Charges_Amount_Val != undefined && this.Towards_Other_Charges_Amount_Val != null && this.Towards_Other_Charges_Amount_Val != '') )  && this.isBookinPage && this.isESCROW){
            const evt = new ShowToastEvent({
                label: 'Error',
                title: 'Error', 
                variant: 'error',
                message: 'ESCROW Account Type selected towards should be only to Unit price'
            });
            this.dispatchEvent(evt);
            return;
        }

        var unitIds = [];
        var units = this.units;
        ////sob-1040 start
        var onDirectSaleCount = 0;
        var onInDirectSaleCount = 0;
        units.forEach(varUnit =>{
            console.log('varUnit.onDirectSale===',varUnit.onDirectSale);
            if(varUnit.onDirectSale == true){
                onDirectSaleCount++;
            }else{
                onInDirectSaleCount++;
            }
        });
        if(onDirectSaleCount > 0 && onInDirectSaleCount >0){
            const evt = new ShowToastEvent({
                label: 'Error',
                title: 'Error',
                variant: 'error',
                message: 'You have selected units flagged on direct sale with units flagged with broker, please create different Payment Request for Indirect Units'
            });
            this.dispatchEvent(evt);
            return;
        }
       
        
        var today = new Date();        
        var instrumentDate = new Date(fields.Instrument_Date__c);        
        if(instrumentDate.setHours(0,0,0,0) > today.setHours(0,0,0,0) && (this.isCDMCheque || this.isCDMCash) ) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'Warning',
                message: 'You can not select future date in instrument Date'
            });
            this.dispatchEvent(evt);
            return;
        }
        var initiationDate = new Date(fields.Date_of_Initiation__c);   
        if(initiationDate.setHours(0,0,0,0) > today.setHours(0,0,0,0) && (this.isDWT || this.isIWT) ) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'Warning',
                message: 'You can not select future date in initiation Date'
            });
            this.dispatchEvent(evt);
            return;
        }        
        console.log('fields.Lead_Source_Category__c===',fields.Lead_Source_Category__c);
        if(this.makeLeadSourceRequired == true && onDirectSaleCount > 0 && fields.Lead_Source_Category__c != 'Direct' && fields.Lead_Source_Category__c != 'Marketing'){
            const evt = new ShowToastEvent({
                label: 'Error',
                title: 'Error',
                variant: 'error',
                message: 'For Direct sales unit - Lead source should be Direct or marketing only'
            });
            this.dispatchEvent(evt);
            return;
        }
        //sob-1040 end
        if(((this.label.PR_OTC_Skip_Validation_Usernames 
            && !this.label.PR_OTC_Skip_Validation_Usernames.includes(this.currentUserName))
        || !this.label.PR_OTC_Skip_Validation_Usernames)
         &&
        fields.Others__c == 'Title Deed Charges'
        && this.label.Towards_Deed_Charges &&
        (!fields.Towards_Other_Charges_Amount__c 
            || fields.Towards_Other_Charges_Amount__c != parseFloat(this.label.Towards_Deed_Charges))){
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                    variant: 'warning',
                    message: 'Title Deed Charge should be equal to '+this.label.Towards_Deed_Charges+ ''
                });
                this.dispatchEvent(evt);
                return;
        }
        //SOB-278 Aayushi
        if (this.multiAmountAllocationFeatureFlag == false &&
            this.isCash == false) {
            this.units.forEach(u => {
                u.amount = fields.Amount__c;
            })
        }
        var category = this.showFromBooking ? String(fields.Lead_Source_Category__c) + '#' + String(fields.Lead_Source_Sub_Category__c) : '';
        if (this.modeOption == '') {
            this.modeOption = String(fields.Mode_Option__c);
        }
        if (((this.label.PR_OTC_Skip_Validation_Usernames && !this.label.PR_OTC_Skip_Validation_Usernames.includes(this.currentUserName))
            || !this.label.PR_OTC_Skip_Validation_Usernames)
            && this.fromBooking == true && fields.Mortgage_Value__c
            && fields.Mortgage_Value__c != 0
        ) {
            var mortgageExtraCharges = this.label.PR_Mortgage_Extra_Charges;
            if (!mortgageExtraCharges) {
                mortgageExtraCharges = 2000;
            }
            var mortageToCompare = (parseFloat(fields.Mortgage_Value__c) * this.label.PR_Mortgage_Validation) + parseFloat(mortgageExtraCharges);
            var Preregistration = fields.Towards_Pre_Registration_Amount__c ? parseFloat(fields.Towards_Pre_Registration_Amount__c) : fields.Towards_Pre_Registration_Amount__c;
            if (Preregistration > mortageToCompare) {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'Preregistration amount should be less then or equal to ' + this.label.PR_Mortgage_Validation * 100 + ' of Mortgage value + ' + mortgageExtraCharges
                });
                this.dispatchEvent(evt);
                return;
            }
        }
        if (this.uploadedFileLength == 0 && (this.isCDMCash || this.isCDMCheque || this.isCheque || this.isIWT || this.isDWT)) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload POP'
            });
            this.dispatchEvent(evt);
            return;
        }
        if (!this.isSecondaryMode && this.popAmount && (this.isCDMCash || this.isCDMCheque || this.isCheque
            || this.isIWT || this.isCreditCard)) {
            var totalAmount = 0;
            this.units.forEach(u => {
                totalAmount += parseFloat(u.amount);
            })
            if (totalAmount != this.popAmount) {
                const evt = new ShowToastEvent({
                    label: 'Error',
                    title: 'Error',
                    variant: 'error',
                    message: 'POP Amount should match total amount of units, please fix and try again!!'
                });
                this.dispatchEvent(evt);
                return;
            }
        }
        if(this.isSecondaryMode && this.popAmount && (this.isCDMCash || this.isCDMCheque || this.isCheque
            || this.isIWT || this.isCreditCard)){
                if (parseFloat(fields.Amount__c) != parseFloat(this.popAmount)) {
                    const evt = new ShowToastEvent({
                        label: 'Error',
                        title: 'Error',
                        variant: 'error',
                        message: 'POP Amount should match total amount of units, please fix and try again!!'
                    });
                    this.dispatchEvent(evt);
                    return;
                }
            }
        if (this.authorizationFormUploaded == false && this.isCreditCard) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Credit Card Authorization Form'
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.declarationFormUploaded == false && this.isCreditCard && this.isThirdParty) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Third Party Declaration Form'
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyChequeUploaded == false && this.isCheque && this.thirdPartyCheque) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Third Party Cheque'
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyIWTUploaded == false && this.isIWT && this.thirdPartyIWT) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Third Party IWT'
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyDWTUploaded == false && this.isDWT && this.thirdPartyDWT) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Third Party DWT'
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyCDMChequeUploaded == false && this.isCDMCheque && this.thirdPartyCDMCheque) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Please upload Third Party CDM Cheque (Cheque Deposit in Machine)'
            });
            this.dispatchEvent(evt);
            return;
        }

        var nounitsfound = false;
        if (this.units.length > 0) {
            this.units.forEach(u => {
                if (u.id == "" || u.id == '' || u.id == null || u.id == undefined) {
                    const evt = new ShowToastEvent({
                        label: 'Error',
                        title: 'Error',
                        variant: 'error',
                        message: 'Please select unit to save payment request'
                    });
                    //this.dispatchEvent(evt);
                    nounitsfound = true;
                }
            })
        }
        if (nounitsfound == true) {
            //return;
        }
        for (var i = 0; i < units.length; i++) {
            if (units[i].id != null && units[i].id != '' && units[i].id != undefined) {
                if (String(fields.Mode__c) == 'OTC Deposits(Cash counter)' || (this.multiAmountAllocationFeatureFlag
                    && this.modeOption == 'Multi Mode')) {
                    if (this.modeOption == 'Multi Mode') {
                        var amt = 0;
                        if (fields.Mode__c != 'IWT(International)'
                            && fields.Mode__c != 'OTC Deposits(Cash counter)') {
                            amt = units[i].amount;
                        } else {
                            amt = (units[i].currency == 'AED') ? units[i].amount : units[i].amount * this.rateMap[units[i].currency];
                        }
                      //SOB-265 20k to hold unit for 24 hrs in Multi Mode
                        console.log('amt===',amt);
                        console.log('this.payamount===',this.payamount);
                        console.log('amt < this.payamount',amt < this.payamount);
                        if (amt != '' &&  amt < Number(this.payamount) && this.secondaryMode == ''
                            && !this.fromBooking && !this.tertiaryPayment) {
                            //SOB-265 20k to hold unit for 24 hrs in Multi Mode
    
                            const evt = new ShowToastEvent({
                                label: 'Warning',
                                title: 'Warning',
                                variant: 'warning',
                                message: 'Amount cannot be less than '+this.payamount
                            });
                            this.dispatchEvent(evt);
                            return;
                        }
                    }
                }

                if (this.multiAccountTowerMappingFeatureFlag == false) {
                    unitIds.push(String(units[i].id) + '##' + units[i].currency + '##' + units[i].amount);
                }
                else {
                    //Aayushi : SOB-341 SOB-403 added CDM Cash (Cash Deposit in Machine) condition || this.isCDMCash
                    if ((this.isIWT || this.isDWT || this.isCDMCash) && units[i].accountType == 'ESCROW' && units[i].escrowAccount == 'ESCROW Account not mapped, Please select Corporate Account.') {
                        const evt = new ShowToastEvent({
                            label: 'Warning',
                            title: 'Warning',
                            variant: 'warning',
                            message: this.escrowAccountMapErrorMessage
                        });
                        this.dispatchEvent(evt);
                        return;
                    }
                    if (units[i].accountType == 'Corporate') {
                        unitIds.push(String(units[i].id) + '##' + units[i].currency + '##' + units[i].amount + '##Corporate##' + units[i].accountId);
                    }
                    else if (units[i].accountType == 'ESCROW')
                        unitIds.push(String(units[i].id) + '##' + units[i].currency + '##' + units[i].amount + '##ESCROW##' + units[i].escrowAccount);
                    else
                        unitIds.push(String(units[i].id) + '##' + units[i].currency + '##' + units[i].amount);
                }

            }
        }

        if (this.modeOption == 'Multi Mode' && fields.Mode__c != 'OTC Deposits(Cash counter)'
        && this.multiAmountAllocationFeatureFlag == false) {//SOB-278 Aayushi
            var amountToEnter = Number(this.payamount) * units.length;
            var amt;
            if (fields.Mode__c != 'IWT(International)')
                amt = fields.Amount__c;
            else {
                amt = (fields.Currency__c == 'AED') ? fields.Amount__c : fields.Amount__c * this.rateMap[fields.Currency__c];
            }
            if (amt < amountToEnter && this.secondaryMode == '') {
                const evt = new ShowToastEvent({
                    label: 'Warning',
                    title: 'Warning',
                    variant: 'warning',
                    message: 'Amount cannot be less than ' + amountToEnter
                });
                this.dispatchEvent(evt);
                return;
            }
        }
        
        var totalAmt = 0;
        if (String(fields.Towards_Unit_Price_Amount__c) != 'null' && String(fields.Towards_Unit_Price_Amount__c) != undefined && String(fields.Towards_Unit_Price_Amount__c) != '' && String(fields.Towards_Unit_Price_Amount__c) != null && fields.Towards_Unit_Price_Amount__c != undefined) {
            totalAmt = totalAmt + parseFloat(fields.Towards_Unit_Price_Amount__c);
        }
        if (String(fields.Towards_Pre_Registration_Amount__c) != 'null' && String(fields.Towards_Pre_Registration_Amount__c) != undefined && String(fields.Towards_Pre_Registration_Amount__c) != '' && String(fields.Towards_Pre_Registration_Amount__c) != null && fields.Towards_Pre_Registration_Amount__c != undefined) {
            totalAmt = totalAmt + parseFloat(fields.Towards_Pre_Registration_Amount__c);
        }
        if (String(fields.Towards_Other_Charges_Amount__c) != 'null' && String(fields.Towards_Other_Charges_Amount__c) != undefined && String(fields.Towards_Other_Charges_Amount__c) != '' && String(fields.Towards_Other_Charges_Amount__c) != null && fields.Towards_Other_Charges_Amount__c != undefined) {
            totalAmt = totalAmt + parseFloat(fields.Towards_Other_Charges_Amount__c);
        }
        totalAmt = totalAmt.toFixed(2);
        console.log(totalAmt);
        console.log(this.showFromBooking,'--this.showFromBooking--',this.isDWT,'*---*---',parseFloat(fields.Amount__c).toFixed(2));
        if ((this.isIWT == false ) && this.showFromBooking == false && totalAmt != parseFloat(fields.Amount__c).toFixed(2)) {
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: 'Sum of Amount Towards Field(s) should be equal to Amount.'
            });
            this.dispatchEvent(evt);
            return;
        }

        let fileUploaded = 0;
        if (this.isCreditCard) {
            if (this.authorizationFormUploaded)
                fileUploaded = fileUploaded + 1;
            if (this.declarationFormUploaded)
                fileUploaded = fileUploaded + 1;
        }

        if (this.isCheque) {
            fileUploaded = 1;
            if (this.thirdPartyChequeUploaded) {
                fileUploaded = fileUploaded + 1;
            }
        }

        if(this.isCDMCheque){
            if(this.thirdPartyCDMCheque){
                fileUploaded = fileUploaded +1;
            }
            if(this.cdmChequepopFormUploaded){
                fileUploaded = fileUploaded +1;
            }
        }

        if(this.isIWT){
            //fileUploaded = 1;
            if(this.thirdPartyIWTUploaded){
                fileUploaded = fileUploaded +1;
            }
            if(this.iwtpopFormUploaded){
                fileUploaded = fileUploaded + 1;
            }
        }

        if(this.isDWT){
            //fileUploaded = 1;
            if(this.thirdPartyDWTUploaded){
                fileUploaded = fileUploaded +1;
            }
            if(this.dwtpopFormUploaded){
                fileUploaded = fileUploaded + 1;
            }
        }
    console.log('fileuploaded : '+fileUploaded);
        this.showSpinner = true;
        var curr = String(fields.Currency__c);

        var is3rdParty = fields.X3rd_Party_Cheque__c +'###'+fields.X3rd_Party_CDM_Cheque__c+'###'+fields.X3rd_Party_IWT__c+'###'+fields.X3rd_Party_DWT__c;
        
        var popInfo = '';
        popInfo += fields.POP_Comments__c ? String(fields.POP_Comments__c): '';
        popInfo += fields.POP_Amount_1__c ? '######'+String(fields.POP_Amount_1__c): '';
        console.log('uploadedfilelength : ' + this.uploadedFileLength);
        var sendId = '';
        if (this.bookingIdRecord != '' && this.bookingIdRecord != null && this.bookingIdRecord != undefined) {
            if (this.offerIdRecord != '' && this.offerIdRecord != null && this.offerIdRecord != undefined) {
                sendId = String(this.bookingIdRecord) + '##' + String(this.offerIdRecord);
            } else {
                sendId = this.bookingIdRecord;
            }
        } else if (this.offerIdRecord != '' && this.offerIdRecord != null && this.offerIdRecord != undefined) {
            sendId = this.offerIdRecord;
        }

        if (fields.Enquiry_Source__c != null && fields.Enquiry_Source__c != undefined && fields.Enquiry_Source__c != '') {
            curr += '##'+String(fields.Enquiry_Source__c);
        }
        else if(this.enqSource != null && this.enqSource != undefined && this.enqSource != ''){
            curr += '##'+String(this.enqSource);
        }

        if (fields.Enquiry__c != null && fields.Enquiry__c != undefined && fields.Enquiry__c != '') {
            curr += '##'+String(fields.Enquiry__c);
        } else if (this.enquiryRecordId != null && this.enquiryRecordId != undefined && this.enquiryRecordId != '') {
            curr += '##'+String(this.enquiryRecordId);
        }

        var emiratesAndPassNo = '';
        if (this.customerPassportOrEmiratesId != null && this.customerPassportOrEmiratesId != undefined && this.customerPassportOrEmiratesId != '') {
            emiratesAndPassNo = String(this.customerPassportOrEmiratesId);
        } else {
            emiratesAndPassNo = fields.Emirates_Id_Passport_Number__c;
        }

        if (this.customerPassport != null && this.customerPassport != undefined && this.customerPassport != '') {
            emiratesAndPassNo += '##'+String(this.customerPassport);
        } else {
            emiratesAndPassNo += '##'+fields.Passport_No__c;
        }
         var enqtype = '';
        if (fields.Type_of_Enquiry__c != null && fields.Type_of_Enquiry__c != undefined && fields.Type_of_Enquiry__c != '') {
            enqtype += '##'+String(fields.Type_of_Enquiry__c);
        } 

        console.log(this.isCorporate);
        console.log(curr);
        console.log('this.uploadedFileLength**----',this.uploadedFileLength);
        createPaymentRequest({
            name: String(this.customerName != '' ? this.customerName : fields.Name__c),
            email: String(this.customerEmail != '' ? this.customerEmail : fields.Email__c),
            mobile: String(this.customerPhone != '' ? this.customerPhone : fields.Mobile_Number__c),
            passportNumber: emiratesAndPassNo,
            mode: String(fields.Mode__c),
            curr: curr,
            instrumentNumber: String(fields.Instrument_Number__c),
            chequeNo: String(fields.Cheque_No__c)+enqtype,
            chequeDate: String(fields.Cheque_Date__c),
            accountNo: String(fields.Account_Master__c),
            amount: String(fields.Amount__c),
            dateOfInitiation: String(fields.Date_of_Initiation__c),
            countryOfInitiation: String(fields.Country_of_Initiation__c),
            //       uploadedFileLength: (this.isCreditCard || this.isCheque || this.isIWT || this.isDWT || this.isCDMCheque) ? fileUploaded : this.uploadedFileLength,
            uploadedFileLength:  this.uploadedFileLength,
            units: unitIds,
            bookingId: String(sendId),
            modeOption: String(this.modeOption),
            secondaryMode: String(this.secondaryMode),
            instrumentDate: String(fields.Instrument_Date__c),
            referenceNo: String(fields.Reference_Number__c),
            is3rdParty : String(is3rdParty),
            amountTowards: String(fields.Amount_Towards__c),
            amountTowardsUnit: String(fields.Towards_Unit_Price_Amount__c),
            amountTowardsPreReg: String(fields.Towards_Pre_Registration_Amount__c),
            amountTowardsOther: ((fields.Towards_Other_Charges_Amount__c == undefined) ? null : String(fields.Towards_Other_Charges_Amount__c)),
            others: String(fields.Others__c),
            prId: String(this.prId),
            popComments: popInfo,
            isCorporate: Boolean(this.isCorporate),
            thirdPartyAndId: this.isThirdParty+'##'+this.objectApiName+'##'+this.recordId,
            category: category + '$' + this.bankName,
            mortageValue: String(fields.Mortgage_Value__c),
            recordId : this.recordId
           // bankName = this.bankName
        }).then(result => {
            console.log('result check-->');
            console.log(result);
                if (result == 'success') {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        label: 'Success',
                        title: 'Success',
                        variant: 'success',
                        message: 'Payment Request created successfully!'
                    });
                    this.dispatchEvent(evt);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Payment_Request__c',
                            actionName: 'list'
                        },
                        state: {
                            filterName: 'Recent'
                        }
                    });
                }
                else if(result.includes('success')){
                    console.log('result**--', result);
                    var prId = result.split('&&');
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        label: 'Success',
                        title: 'Success',
                        variant: 'success',
                        message: 'Payment Request created successfully!'
                    });
                    console.log('result**-11-', prId[1]);
                    this.dispatchEvent(evt);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: prId[1].trim(),
                            objectApiName:'	Payment_Request__c',
                            actionName: 'view'
                        }
                    });                    
                }
                else {
                    
                    if(result.includes('blacklisted') || result.includes('property')){
                        this.toastMessg = result.substring(result.indexOf(',')+1);
                    }
                    else{
                        this.toastMessg = result;
                    }
                    console.log('result -> ',this.toastMessg);
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        label: 'Warning',
                        title: 'Warning',
                        variant: 'warning',
                        message: this.toastMessg
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('rooro -> ',JSON.stringify(error));
                const evt = new ShowToastEvent({
                    label: 'Warning',
                    title: 'Warning',
                    variant: 'warning',
                    message: JSON.stringify(error)
                });
                this.dispatchEvent(evt);
            });
    }

    handleCancel() {
        if (this.showUnitSelection) {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Payment_Request__c',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                }
            });
        }
        else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    popCurrency;
    popAmount;
    onCurrencySelectMultiIWT(event) {
        var curr = event.detail.value;
        var units = this.units;
        for (var i = 0; i < units.length; i++) {
            units[i].currency = curr;
        }
        this.popCurrency = curr;
        this.units = units;
    }
    onPopAmountChange(event) {
        this.popAmount = event.detail.value;
    }
    
    paymentCheck = false;
    handleUnitPrice(event){
        let unitPrice = event.target.value;
        if(unitPrice !== null || unitPrice !== ''){
            this.paymentCheck = true;
           
        }else{
            this.paymentCheck = false;
            

        }
       

    }

    retreivePrimaryContact(event) {
        this.showPdfPassport = false;
        this.showImgPassport = false;
        var enqId;
        if (this.enquiryRecordId != undefined && this.enquiryRecordId != null && this.enquiryRecordId != '') { 
            enqId = this.enquiryRecordId;
        } else {
            enqId = event.detail.value[0]
        }

        if (enqId != undefined && enqId != null && enqId != '') {
            searchPrimaryContact({
                enquiryId: enqId
            }).then(result => {
                this.showSpinner = false;
                console.log('nishank');
                console.log(result);
                if (result.hasOwnProperty('PropStrength__Primary_Contact__r')) {
                    this.customerName = result['PropStrength__Primary_Contact__r'].Name;
                    this.customerEmail = result['PropStrength__Primary_Contact__r'].Email;
                    this.customerPhone = result['PropStrength__Primary_Contact__r'].MobilePhone;
                    this.customerPassportOrEmiratesId = result['PropStrength__Primary_Contact__r'].Emirates_ID__c;
                    this.customerPassport = result['PropStrength__Primary_Contact__r'].Passport_No__c;
                }
                if (result.hasOwnProperty('PropStrength__Request_Source__c')) {
                    this.enqSource = result['PropStrength__Request_Source__c'];
                }

                if (result.hasOwnProperty('Type_Of_Enquiry__c')) {
                    this.typeOfEnquiry = result['Type_Of_Enquiry__c'];
                }

                this.showReadOnly = true;

                this.getPassportFromContact(result['PropStrength__Primary_Contact__c']);
            })
                .catch(error => {
                    this.showSpinner = false;
                    console.log('rooro -> ', JSON.stringify(error));
                    const evt = new ShowToastEvent({
                        label: 'Warning',
                        title: 'Warning',
                        variant: 'warning',
                        message: JSON.stringify(error)
                    });
                    this.dispatchEvent(evt);
                });
        } else {
            this.showReadOnly = false;
        }
    }
}