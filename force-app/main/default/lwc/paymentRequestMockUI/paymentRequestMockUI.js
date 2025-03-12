import { LightningElement, track, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Username';
import ProfileNameFld from '@salesforce/schema/User.Profile.Name';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPaymentRequest from '@salesforce/apex/PaymentRequestMockController.createPaymentRequest';
import unitDetails from '@salesforce/apex/PaymentRequestMockController.unitDetails';
import getUnitId from '@salesforce/apex/PaymentRequestMockController.getUnitId';
import getPaymentRequestDetails from '@salesforce/apex/PaymentRequestMockController.getPaymentRequestDetails';
import getCurrencyRate from '@salesforce/apex/PaymentRequestMockController.getCurrencyRate';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateUploadedFileName from '@salesforce/apex/PaymentRequestMockController.updateUploadedFileName';
import PR_OTC_Booking_Level_Restriction_Msg from '@salesforce/label/c.PR_OTC_Booking_Level_Restriction_Msg';
import PR_OTC_14_Percent_Validation_Msg from '@salesforce/label/c.PR_OTC_14_Percent_Validation_Msg';
import PR_Mortgage_Validation from '@salesforce/label/c.PR_Mortgage_Validation';
import Payment_Request_Creation_Note from '@salesforce/label/c.Payment_Request_Creation_Note';
import PR_OTC_Skip_Validation_Usernames from '@salesforce/label/c.PR_OTC_Skip_Validation_Usernames';
import checkifUnitIsBlocked from '@salesforce/apex/PaymentRequestFormController.checkifUnitIsBlocked';
import PR_Mortgage_Extra_Charges from '@salesforce/label/c.PR_Mortgage_Extra_Charges';
import Towards_Deed_Charges from '@salesforce/label/c.Towards_Deed_Charges';
import EscrowAccountMapError from '@salesforce/label/c.EscrowAccountMapError'
//SOB-265 20k to hold unit for 24 hrs in Multi Mode
import paymentamount from '@salesforce/label/c.Payment_Amount';

const BOOKINGFIELDS = ['Booking__c.Name','Booking__c.Allow_Payment_Request__c', 'Booking__c.Termination_Status__c','Booking__c.Termination_Process_Status__c'];

export default class PaymentRequestMockUI extends NavigationMixin(LightningElement) {
    thirdPartyPayment = false;
    @track units = [];
    @api newpaymentform;
    showSpinner = false;
    uploadedFileLength = 0;
    @track selected;
    @api recordId;
    currentUserName;
    makeLeadSourceRequired = true;
    approvedPr;
    isApprovedPrFound = false;
    //SOB-265 20k to hold unit for 24 hrs in Multi Mode
    payamount = paymentamount;
    profileName; //SOB-1659 - added by Hitesh
    towardsunitprice=0;//SOB-1659 - added by Hitesh
    escrowAccountMapErrorMessage = EscrowAccountMapError;
    @track showUnitSelection = false;
    @wire(getRecord, { recordId: Id, fields: [UserNameFld,ProfileNameFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Username.value;
            var currentProfileName = data.fields.Profile.value.fields.Name.value;
            this.profileName=data.fields.Profile.value.fields.Name.value; //SOB-1659 - added by Hitesh
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
    @track category = '';
    @track subcategory = '';

    @track defaultCurrency = 'AED';

    @track isMultiMode = false;
    bookingId = '';
    modeOption = '';
    secondaryMode = '';

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
    @track bookingTerminationError = false;
    @track tertiaryPrError = false;
    @track tertiaryPrErrorMessage = '';
    alreadyQueriedPRs = false;

    @wire(getRecord, { recordId: '$recordId', fields: BOOKINGFIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            console.log('data - > ',JSON.stringify(data));
            console.log('data - > ',data.fields.Termination_Status__c.value);
            console.log('data - > ',data.fields.Termination_Process_Status__c.value);
            if((data.fields.Termination_Status__c.value == 'Raised to DLD Team')){
                if(data.fields.Termination_Process_Status__c.value == 'Removed from Termination' || data.fields.Allow_Payment_Request__c.value){
                    console.log('TRUES');
                    this.showForm = true;
                    this.bookingTerminationError = false;
                }else{
                    this.showForm = false;
                    this.bookingTerminationError = true;
                    console.log('FALSE');
                }
                
            }else{
                console.log('FALSE');
                this.showForm = true;
                this.bookingTerminationError = false;
            }
        }
    }


    handleThirdPartyChange(event) {
        this.isThirdParty = event.currentTarget.value;
        if(event.detail.checked){
            this.thirdPartyPayment = true;
        }
        else{
            this.thirdPartyPayment = false;
        }
        
    }

    onAmountTowardsChange(event) {
        this.towardsUnit = (event.detail.value == 'Unit Price') ? true : false;
        this.towardsPreReg = (event.detail.value == 'Registration Amount') ? true : false;
        this.towardsOthers = (event.detail.value == 'Other Amount') ? true : false;
    }

    validateOtherCharges(event) {
        this.hasOtherCharges = (event.detail.value > 0) ? true : false;
    }


    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFileLength += uploadedFiles.length;
        if (uploadedFiles.length > 0) {
            if(this.isIWT){  
                this.iwtpopFormUploaded = true;
            }else if(this.isDWT){
                this.dwtpopFormUploaded = true;
            }
            if(this.isCDMCheque){
                this.cdmChequepopFormUploaded = true;
            }
            updateUploadedFileName({ fileName: 'POP', docId: uploadedFiles[0].documentId })
                .then(result => {
                    console.log(result);
                })
                .catch(error => {
                    alert('Error');
                    console.log(error);
                });
        }
    }

    handleUploadFinishedAuthorizationForm(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFileLength += uploadedFiles.length;
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
        this.uploadedFileLength += uploadedFiles.length;
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
        this.uploadedFileLength += uploadedFiles.length;
        if (uploadedFiles.length > 0) {
            this.thirdPartyChequeUploaded = true;
            updateUploadedFileName({ fileName: 'Third Party Form', docId: uploadedFiles[0].documentId })
                .then(result => {
                })
                .catch(error => {
                });
        }
    }

    handleUploadFinishedThirdPartyIWT(event){
        const uploadedFiles = event.detail.files;
        this.uploadedFileLength += uploadedFiles.length;
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
        this.uploadedFileLength += uploadedFiles.length;
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
        this.uploadedFileLength += uploadedFiles.length;
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
            this.thirdPartyPayment = true;
        } else {
            this.thirdPartyCheque = false;
            this.thirdPartyPayment = false;
        }
    }

    showThirdPartyFileUploadIWT(event){
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyIWT = true;
            this.thirdPartyPayment = true;
        } else {
            this.thirdPartyIWT = false;
            this.thirdPartyPayment = false;
        }
    }
   
    showThirdPartyFileUploadDWT(event){
        console.log('DWT upload');
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyDWT = true;
            this.thirdPartyPayment = true;
           
        } else {
            this.thirdPartyDWT = false;
            this.thirdPartyPayment = false;
        }
    }

    showThirdPartyFileUploadCDMCheque(event){
        var checkboxValue = event.detail.checked;
        if (checkboxValue === true) {
            this.thirdPartyCDMCheque = true;
            this.thirdPartyPayment = true;
        } else {
            this.thirdPartyCDMCheque = false;
            this.thirdPartyPayment = false;
        }
    }

    handleModeOptionChange(event) {
        this.isMultiMode = (event.detail.value == 'Multi Mode') ? true : false;
    }

    renderedCallback() {
        if (this.recordId != undefined) {
            if(this.newpaymentform == 'yes' || (this.recordId && this.recordId.startsWith("a06"))){
                this.NewPaymentFormRequest = false;
            }
            else{
                this.NewPaymentFormRequest = true;
            }
            this.showUnitSelection = false;
            var units = this.units;
            if (!this.showUnitSelection) {
                if (!this.bookingDetailsFetched) {
                    var recId = this.recordId;
                    if (recId.startsWith("a06")) {
                        this.fromBooking = true;
                        this.bookingId = recId;
                        getUnitId({ bookingId: this.recordId })
                            .then(result => {
                                this.bookingDetailsFetched = true;
                                units[0].id = result.Unit__c;
                                //sob-1140
                                units[0].onDirectSale = result.Unit__r.For_Direct_Sale__c;
                                if(units[0].onDirectSale){
                                    console.log('units[0].onDirectSale===',units[0].onDirectSale)
                                    unitDetails({ unitId: String(result.Unit__c) })
                                        .then(result => {
                                            console.log('result===',result)
                                            if(result.approvedPR){
                                            this.approvedPr = result.approvedPR;
                                            this.isApprovedPrFound = true;
                                            this.category = result.approvedPR.Lead_Source_Category__c;
                                            this.subcategory = result.approvedPR.Lead_Source_Sub_Category__c;
                                            }
                                        }).catch(error =>{
                                        });
                                }
                                this.customerName = result.Primary_Applicant_Name__c;
                                this.customerEmail = result.Primary_Applicant_Email__c;
                                this.customerPhone = result.PrimaryMobileNumber__c;
                                this.customerPassportOrEmiratesId = result.Applicant_2_Name__c;
                                if (result.Unit__c != null && result.Unit__r.Tower__c != null && result.Unit__r.Tower__r.ESCROW_Account__c != null) {
                                    this.escrowAccountName = result.Unit__r.Tower__r.ESCROW_Account__r.Name;
                                }
                                this.units = units;
                               
                            })
                            .catch(error => {
                            });
                    }
                    else if(!this.alreadyQueriedPRs) {
                        this.modeOption = 'Multi Mode';
                        this.isMultiMode = true;
                        this.fromBooking = false;
                        this.isSecondaryMode = true;
                        this.showForm = false;
                        this.tertiaryPrError = false;
                        getPaymentRequestDetails({ prId: this.recordId })
                            .then(result => {
                                this.alreadyQueriedPRs = true;
                                this.bookingDetailsFetched = true;
                                units[0].id = result.Unit__c;
                                units[0].onDirectSale = result.Unit__r.For_Direct_Sale__c;//sob-1040
                               
                                this.customerName = result.Name__c;
                                this.customerEmail = result.Email__c;
                                this.customerPhone = result.Mobile_Number__c;
                                this.customerPassportOrEmiratesId = result.Emirates_Id_Passport_Number__c;
                                this.secondaryMode = result.Mode__c;
                                this.category = result.Lead_Source_Category__c;
                                this.subcategory = result.Lead_Source_Sub_Category__c;
                                if (result.Unit__c != null && result.Unit__r.Tower__c != null && result.Unit__r.Tower__r.ESCROW_Account__c != null) {
                                    this.escrowAccountName = result.Unit__r.Tower__r.ESCROW_Account__r.Name;
                                }
                                this.units = units;
                                this.prId = result.Id;
                                this.showForm = true;
                            })
                            .catch(error => {
                                this.alreadyQueriedPRs = true;
                                error = JSON.parse(JSON.stringify(error));
                                this.showForm = false;
                                this.tertiaryPrError = true;
                                this.tertiaryPrErrorMessage = ''+error.body.message;
                            });
                    }
                }
            }
        }
        else {
            this.showUnitSelection = true;
        }
    }
    NewPaymentFormRequest = false;
    connectedCallback() {
        var units = [];
        var obj = { 'row': 1, 'id': '', 'details': '', 'currency': 'AED', 'amount': '', 'isRemoveVisible': false, 'accountType': '', 'accountId': '', 'isCorporate': false, 'isESCROW': false, 'escrowAccount': '' };
        units.push(obj);
        this.units = units;
        getCurrencyRate()
            .then(result => {
                this.rateMap = result;
            })
            .catch(error => {
            });


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

        units.push(obj);
        this.units = units;
        console.log(this.units);
    }

    handleModeChange(event) {
        this.hasOtherCharges = false;
        this.thirdPartyPayment = false;
        if (event.detail.value) {
            this.modeSelected = true;
        } else {
            this.modeSelected = false;
        }
        this.isCash = (event.detail.value == 'OTC Deposits') ? true : false;
        this.isCheque = (event.detail.value == 'Cheque') ? true : false;
        this.isCreditCard = (event.detail.value == 'Credit Card') ? true : false;
        this.isWebsite = (event.detail.value == 'Website') ? true : false;
        this.isCDMCash = (event.detail.value == 'CDM Cash') ? true : false;
        this.isCDMCheque = (event.detail.value == 'CDM Cheque') ? true : false;
        this.isIWT = (event.detail.value == 'International Wire Transfer') ? true : false;
        if (event.detail.value == 'Domestic Wire Transfer') {
            this.isIWT = false;
            this.isDWT = true;
            this.thirdPartyDWT = false;
            this.thirdPartyIWT = false;
        } else {
            this.isDWT = false;
        }

        if(event.detail.value == 'International Wire Transfer'){
            this.thirdPartyDWT = false;
            this.thirdPartyIWT = false;
        }

        if (this.isIWT)
            this.defaultCurrency = '';
        else
            this.defaultCurrency = 'AED';

        if (event.detail.value != 'OTC Deposits') {
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
        this.isCorporate = (event.detail.value == 'Corporate') ? true : false;
        this.isESCROW = (event.detail.value == 'ESCROW') ? true : false;
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
     existingProject ;
    onUnitSelect(event) {
        var unitId = event.detail.value;
        var rowNo = event.currentTarget.id;
        rowNo = rowNo.split('-')[0];
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
            this.showSpinner = true;
            checkifUnitIsBlocked({ 'unitid': String(unitId) }).then(response => {
                this.showSpinner = false;
                if (response == true) {
                    const userInputs = this.template.querySelectorAll('[data-id="' + rowNo + '"]');
                    userInputs.forEach(element => {
                        element.value = null;

                    });
                    const evt = new ShowToastEvent({
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
                            ////sob-1040 end
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

    }

    handleSubmit(event) {
        console.log('SUbmission');
        event.preventDefault();
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

        //SOB-1659 - added by Hitesh
        if(this.towardsunitprice > 0  && this.profileName.includes('CRM')){
            const evt = new ShowToastEvent({
                variant: 'error',
                message: 'CRM users cannot raise PR towards Unit price',
            });
            this.dispatchEvent(evt);
            return;
        }

        if(onDirectSaleCount > 0 && onInDirectSaleCount >0){
            const evt = new ShowToastEvent({
                variant: 'error',
                message: 'You have selected units flagged on direct sale with units flagged with broker, please create different Payment Request for Indirect Units',
            });
            this.dispatchEvent(evt);
            return;
        }
       
        const fields = event.detail.fields;
        console.log('onDirectSaleCount===',onDirectSaleCount);
        console.log('fields.Lead_Source_Category__c===',fields.Lead_Source_Category__c);
        if(this.makeLeadSourceRequired == true && onDirectSaleCount > 0 && fields.Lead_Source_Category__c != 'Direct' && fields.Lead_Source_Category__c != 'Marketing'){
            const evt = new ShowToastEvent({
                variant: 'error',
                message: 'For Direct sales unit - Lead source should be Direct or marketing only',
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
        var category = String(fields.Lead_Source_Category__c) + '#' + String(fields.Lead_Source_Sub_Category__c);
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
                    variant: 'error',
                    message: 'Preregistration amount should be less then or equal to ' + this.label.PR_Mortgage_Validation * 100 + ' of Mortgage value + ' + mortgageExtraCharges,
                });
                this.dispatchEvent(evt);
                return;
            }
        }
        if (this.uploadedFileLength == 0 && (this.isCDMCash || this.isCDMCheque || this.isCheque || this.isIWT || this.isDWT)) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload POP',
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
                    variant: 'error',
                    message: 'POP Amount should match total amount of units, please fix and try again!!',
                });
                this.dispatchEvent(evt);
                return;
            }
        }
        if(this.isSecondaryMode && this.popAmount && (this.isCDMCash || this.isCDMCheque || this.isCheque
            || this.isIWT || this.isCreditCard)){
                if (parseFloat(fields.Amount__c) != parseFloat(this.popAmount)) {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: 'POP Amount should match total amount of units, please fix and try again!!',
                    });
                    this.dispatchEvent(evt);
                    return;
                }
            }
        if (this.authorizationFormUploaded == false && this.isCreditCard) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Credit Card Authorization Form',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.declarationFormUploaded == false && this.isCreditCard && this.isThirdParty) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Third Party Declaration Form',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyChequeUploaded == false && this.isCheque && this.thirdPartyCheque) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Third Party Cheque',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyIWTUploaded == false && this.isIWT && this.thirdPartyIWT) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Third Party IWT',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyDWTUploaded == false && this.isDWT && this.thirdPartyDWT) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Third Party DWT',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.thirdPartyCDMChequeUploaded == false && this.isCDMCheque && this.thirdPartyCDMCheque) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please upload Third Party CDM Cheque',
            });
            this.dispatchEvent(evt);
            return;
        }

        var nounitsfound = false;
        if (this.units.length > 0) {
            this.units.forEach(u => {
                if (u.id == "" || u.id == '' || u.id == null || u.id == undefined) {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: 'Please select unit to save payment request',
                    });
                    this.dispatchEvent(evt);
                    nounitsfound = true;
                }
            })
        }
        if (nounitsfound == true) {
            return;
        }
        for (var i = 0; i < units.length; i++) {
            if (units[i].id != null && units[i].id != '' && units[i].id != undefined) {
                if (String(fields.Mode__c) == 'OTC Deposits' || (this.multiAmountAllocationFeatureFlag
                    && this.modeOption == 'Multi Mode')) {
                    if (this.modeOption == 'Multi Mode') {
                        var amt = 0;
                        if (fields.Mode__c != 'International Wire Transfer'
                            && fields.Mode__c != 'OTC Deposits') {
                            amt = units[i].amount;
                        } else {
                            amt = (units[i].currency == 'AED') ? units[i].amount : units[i].amount * this.rateMap[units[i].currency];
                        }
                      //SOB-265 20k to hold unit for 24 hrs in Multi Mode
                        console.log('amt===',amt);
                        console.log('this.payamount===',this.payamount);
                        console.log('amt < this.payamount',amt < this.payamount);
                        if ( amt < Number(this.payamount) && this.secondaryMode == ''
                            && !this.fromBooking && !this.tertiaryPayment) {
                            //SOB-265 20k to hold unit for 24 hrs in Multi Mode
    
                            const evt = new ShowToastEvent({
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
                    //Aayushi : SOB-341 SOB-403 added CDM cash condition || this.isCDMCash
                    if ((this.isIWT || this.isDWT || this.isCDMCash) && units[i].accountType == 'ESCROW' && units[i].escrowAccount == 'ESCROW Account not mapped, Please select Corporate Account.') {
                        const evt = new ShowToastEvent({
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

        if (this.modeOption == 'Multi Mode' && fields.Mode__c != 'OTC Deposits'
        && this.multiAmountAllocationFeatureFlag == false) {//SOB-278 Aayushi
            var amountToEnter = Number(this.payamount) * units.length;
            var amt;
            if (fields.Mode__c != 'International Wire Transfer')
                amt = fields.Amount__c;
            else {
                amt = (fields.Currency__c == 'AED') ? fields.Amount__c : fields.Amount__c * this.rateMap[fields.Currency__c];
            }
            if (amt < amountToEnter && this.secondaryMode == '') {
                const evt = new ShowToastEvent({
                    variant: 'warning',
                    message: 'Amount cannot be less than ' + amountToEnter,
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
        console.log('totalAmt--->',totalAmt);
        console.log('parseFloat(fields.Amount__c).toFixed(2)-->',parseFloat(fields.Amount__c).toFixed(2));
        console.log('this.isIWT-->',this.isIWT);
        console.log('this.fromBooking -->',this.fromBooking );
        if ((this.isIWT == false) && this.fromBooking == true && totalAmt != parseFloat(fields.Amount__c).toFixed(2)) {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Sum of Amount Towards Field(s) should be equal to Amount.',
            });
            this.dispatchEvent(evt);
            return;
        }
        console.log('Towards_Other_Charges_Amount__c--->',fields.Towards_Pre_Registration_Amount__c);
        console.log('Towards_Other_Charges_Amount__c--->',fields.Towards_Other_Charges_Amount__c);
        if( (fields.Mode__c == 'CDM Cash' || fields.Mode__c == 'CDM Cheque' || fields.Mode__c == 'Domestic Wire Transfer') && (fields.Towards_Pre_Registration_Amount__c != '' || fields.Towards_Other_Charges_Amount__c != '' )
        && (fields.Towards_Pre_Registration_Amount__c != null || fields.Towards_Other_Charges_Amount__c != null )
        && (fields.Towards_Pre_Registration_Amount__c >= 0 || fields.Towards_Other_Charges_Amount__c >= 0) && (fields.Account_Type__c == 'ESCROW')){
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please correct the allocation - Other Charges and Registration cannot be allocated in ESCROW Account. please ensure to make these field empty not even \'0\' is accepted',
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
        popInfo += fields.Pop_Amount__c ? '######'+String(fields.Pop_Amount__c): '';
        popInfo += fields.X3rd_Party_payment__c ? '######'+String(fields.X3rd_Party_payment__c): '';
        console.log('uploadedfilelength : '+this.uploadedFileLength);
        console.log('popInfo : '+popInfo);
        createPaymentRequest({
            name: String(fields.Name__c),
            email: String(fields.Email__c),
            mobile: String(fields.Mobile_Number__c),
            passportNumber: String(fields.Emirates_Id_Passport_Number__c),
            mode: String(fields.Mode__c),
            curr: curr,
            instrumentNumber: String(fields.Instrument_Number__c),
            chequeNo: String(fields.Cheque_No__c),
            chequeDate: String(fields.Cheque_Date__c),
            accountNo: String(fields.Account_Master__c),
            amount: String(fields.Amount__c),
            dateOfInitiation: String(fields.Date_of_Initiation__c),
            countryOfInitiation: String(fields.Country_of_Initiation__c),
            uploadedFileLength: (this.isCreditCard || this.isCheque || this.isIWT || this.isDWT || this.isCDMCheque) ? this.uploadedFileLength : this.uploadedFileLength,
            units: unitIds,
            bookingId: String(this.bookingId),
            modeOption: String(this.modeOption),
            secondaryMode: String(this.secondaryMode),
            referenceNo: String(fields.Reference_Number__c),
            instrumentDate: String(fields.Instrument_Date__c),
            referenceNo: String(fields.Reference_Number__c),
          //  is3rdPartyCheque: fields.X3rd_Party_Cheque__c,
            is3rdParty : String(is3rdParty),
            amountTowards: String(fields.Amount_Towards__c),
            amountTowardsUnit: String(fields.Towards_Unit_Price_Amount__c),
            amountTowardsPreReg: String(fields.Towards_Pre_Registration_Amount__c),
            amountTowardsOther: ((fields.Towards_Other_Charges_Amount__c == undefined) ? null : String(fields.Towards_Other_Charges_Amount__c)),
            others: String(fields.Others__c),
            prId: String(this.prId),
            popComments: popInfo,
            isCorporate: Boolean(this.isCorporate),
            isThirdParty: Boolean(this.isThirdParty),
            category: category,
            mortageValue: String(fields.Mortgage_Value__c)

        }).then(result => {
                if (result == 'success') {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Payment Request created successfully!',
                    });
                    this.dispatchEvent(evt);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Payment_Request_Mock__c',
                            actionName: 'list'
                        },
                        state: {
                            filterName: 'Recent'
                        }
                    });
                }
                else {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'warning',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('rooro -> ',JSON.stringify(error));
                const evt = new ShowToastEvent({
                    variant: 'warning',
                    message: JSON.stringify(error),
                });
                this.dispatchEvent(evt);
            });
    }

    handleCancel() {
        if (this.showUnitSelection) {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Payment_Request_Mock__c',
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
        this.towardsunitprice=unitPrice; //SOB-1659 - added by Hitesh
        if(unitPrice !== null || unitPrice !== ''){
            this.paymentCheck = true;
           
        }else{
            this.paymentCheck = false;
            

        }
       

    }
}