import { LightningElement, api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getResaleRecords from '@salesforce/apex/resaleprocesscontroller.getactiveresale';
import getApplicantRecords from '@salesforce/apex/resaleprocesscontroller.getallapplicants';
import createResale from '@salesforce/apex/resaleprocesscontroller.createResale';
import createAttachment from '@salesforce/apex/resaleprocesscontroller.createAttachment';
import getBookingDetails from '@salesforce/apex/resaleprocesscontroller.getBookingDetails';
import { NavigationMixin } from "lightning/navigation";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Resale__OBJECT from '@salesforce/schema/Resale_Process__c';
import Resale_Type_FIELD from '@salesforce/schema/Resale_Process__c.Resale_Type__c';
import Type_of_Buyer_FIELD from '@salesforce/schema/Resale_Process__c.Type_of_Buyer__c';
import Property_Status_FIELD from '@salesforce/schema/Resale_Process__c.Property_Status__c';
import Seller_Mortgage_FIELD from '@salesforce/schema/Resale_Process__c.Seller_Mortgage__c';
import Mortgage_FIELD from '@salesforce/schema/Resale_Process__c.Mortgage__c';
import country_FIELD from '@salesforce/schema/Resale_Process__c.Country__c';
import city_FIELD from '@salesforce/schema/Resale_Process__c.City__c';
import Seller_Bank_Name_FIELD from '@salesforce/schema/Resale_Process__c.Bank_Name__c';
import Bank_Name_FIELD from '@salesforce/schema/Resale_Process__c.Bank_Name__c';
import Buyer__OBJECT from '@salesforce/schema/Buyer__c';
import Salutation_FIELD from '@salesforce/schema/Buyer__c.Salutation__c';
import Nationality_FIELD from '@salesforce/schema/Buyer__c.Nationality__c';
import Buyer_Type_FIELD from '@salesforce/schema/Buyer__c.Buyer_Type__c';
import Residence_Status_FIELD from '@salesforce/schema/Buyer__c.Residence_Status__c';


const MAX_FILE_SIZE = 5000000;

export default class Resaleprocess extends NavigationMixin(LightningElement) {
    @track filesData = []; 
    @api recordId;
    @api resaleId;
    passportcopy=false;
    visacopy=false;
    Contractfcopy=false;
    nationalidcopy=false;
    emiratescopy=false;
    tradecopy=false;
    mortgagecopy=false;
    chequecopy=false;
    documents=false;
    applicantlist;
    resaletype=false;
    companytype=false;
    companytyperesident=false;
    indivudualtype=false;
    residencestatus;
    resident=false;
    nonresident=false;
    resindidual=false;
    nonresindidual=false;
    countofpdc
    amountofpdc
    latecharges
    typeOptions;
    propertyOptions;
    resaletypeOptions;
    @track activeresale=true;
    @track residencetypeOptions;
    @track nationalityOptions;
    @track mortagageOptions;
    @track countryOptions;
    @track cityOptions;
    @track bankOptions;
    @track sellerInformation;
    @track salutationOptions;
    @track displayBankName = false;
    @track resaleInformation = {
        Booking__c : this.recordId,
        Title_Deed_No__c : null,
        Count_of_PDC_s_available__c : null,
        Amount_of_PDC__c : null,
        Late_payment_charges__c : null,
        Unit__c : null,
        Tower__c : null,
        Mortgage__c : null,
        Bank_Name__c : null,
        Seller1_Emirates_Id__c : null,
        Initial_Contract_of_Sale_No__c: null,
        Seller1_Unit_Share_Transfer__c: null,
        Initial_Contract_Dated__c : null,
        Transferrer_Date__c : null,
        Resale_Type__c : null,
        Type_of_Buyer__c : null,
        Property_Status__c : null,
        Buyer1_Name__c : null,
        Last_Name__c : null,
        Buyer1_Email__c : null,
        Buyer1_Phone_Number__c : null,
        Buyer1_Passport_Number__c : null,
        Buyer1_Address__c : null,
        Buyer1_Emirates_Id__c : null,
        Buyer1_City__c : null,
        Buyer1_Country__c : null,
        Buyer1_Unit_Share_Transfer__c : null,
        Seller1_Address__c : null,
        Seller1_Name__c : null,
        Seller1_Email__c : null,
        Seller1_Passport_Number__c : null,
        Seller1_Phone_Number__c : null,
        Nationality__c : null,
        Plot_No__c : null,
        Plot_Name__c : null,
        DM_No__c : null,
    }
    @track buyerInformation = [];
    @track showSpinner= false;

    @track passportscopy;
    @track visacopyfile;
    @track emiratesIdcopy;
    @track contractFMOU;
    @track titledeed_oqood;
    @track poadetails;
    @track passportcopy1;
    @track nationalcopy;
    @track contractFMOU1;
    @track titledeed_oqood1;
    @track poadetails1;
    @track emiratescopy1;
    @track tradelicencecopy1;
    @track memorandumcopy;
    @track goodstandingcopy;
    @track incumbencycopy;
    @track authorizedsignatorycopy;
    @track contractFMOU2;
    @track titledeed_oqood2;
    @track poadetals2;
    @track otherdocumentscopy;
    @track mortagagecopy;
    @track managerschequecopy;

    @wire(getObjectInfo, { objectApiName: Resale__OBJECT })
    resaleMetadata;

    @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Type_of_Buyer_FIELD
    })wiredresalebuyerOptions({error,data}){
        if(data) {
            this.typeOptions = data.values;
        } 
     };

    @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Property_Status_FIELD
    })wiredpropertyOptions({error,data}){
        if(data) {
            this.propertyOptions = data.values;
        } 
     };

    @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Resale_Type_FIELD
    })wiredresaletypeOptions({error,data}){
        if(data) {
            
            this.resaletypeOptions = data.values;
        } 
     };
    
    @wire(getObjectInfo, { objectApiName: Buyer__OBJECT })

    buyerMetadata;

    @wire(getPicklistValues,{
        recordTypeId: '$buyerMetadata.data.defaultRecordTypeId', 
        fieldApiName: Nationality_FIELD
    })wirednationalityOptions({error,data}){
        if(data) {
            this.nationalityOptions = data.values;
        } 
     };

     @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Mortgage_FIELD
        
    })wiredmortagageOptions({error,data}){  
        if(data) {
            this.mortagageOptions = data.values;
        } 
     };

     @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: country_FIELD
        
    })wiredcountryOptions({error,data}){  
        if(data) {
            this.countryOptions = data.values;
        } 
     };

     @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: city_FIELD
        
    })wiredcityOptions({error,data}){  
        if(data) {
            this.cityOptions = data.values;
        } 
     };

     @wire(getPicklistValues,{
        recordTypeId: '$resaleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Bank_Name_FIELD
        
    })wiredbankOptions({error,data}){  
        if(data) {
            this.bankOptions = data.values;
        } 
     };


     @wire(getPicklistValues,{
        recordTypeId: '$buyerMetadata.data.defaultRecordTypeId', 
        fieldApiName: Salutation_FIELD
    })wiredsalutationOptions({error,data}){
        if(data) {
            this.salutationOptions = data.values;
        } 
     };

    @wire(getPicklistValues,{
        recordTypeId: '$buyerMetadata.data.defaultRecordTypeId', 
        fieldApiName: Buyer_Type_FIELD
    })wiredbuyerTypeOptions1({error,data}){
        if(data) {
            this.buyerTypeOptions = data.values;   
        }
    };

    @wire(getPicklistValues,{
        recordTypeId: '$buyerMetadata.data.defaultRecordTypeId', 
        fieldApiName: Residence_Status_FIELD
    })wiredresidenceOptions({error,data}){
        if(data) {
            this.residencestatusOptions = data.values;   
        }
    };

    renderedCallback(){}

    connectedCallback(){
        this.addBuyer();
    }

    navigateToRecordPage(recordPageId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordPageId,
                objectApiName: 'Resale_Process__c',
                actionName: 'view'
            }
        });
    }

    addBuyer(){
        var buyer = {
            Name:null,
            Buyer_Emirate_Id__c : null,
            Buyer1_City__c : null,
            Buyer1_Country__c : null,
            Buyer_Unit_Share_Transfer__c : null,
            Salutation__c : null,
            First_Name__c : null,
            Last_Name__c : null,
            Email__c : null,
            Phone_Number__c : null,
            Passport_Number__c : null,
            Address__c : null,
            Resale_Process__c : null,
            Nationality__c : null,
            New_Sale_Value__c : null,
        }
        this.buyerInformation.push(buyer);
    }

    removedBuyer(event){
        if(this.buyerInformation.length <= 1){
            this.showToast('Success','At least one Buyer should be their','Info');
        }else{
            this.buyerInformation.splice(event.target.dataset.bindex,1);
        }

    }

    handleFieldChange(event){
        this.buyerInformation[event.target.dataset.bindex][event.target.dataset.fieldname] = event.target.value;
        
    }
    handleFieldChange1(event){
        this.resaleInformation[event.target.dataset.fieldname] = event.target.value;

        if(event.currentTarget.dataset.fieldname=='Mortgage__c')
        {
            var mortgageValue;
            mortgageValue = event.detail.value;
            if(mortgageValue == 'Yes')
            {
                this.displayBankName = true;
            }else
            {
                this.displayBankName = false;
            }
        }
        
    }

    handlePicklistFieldChange(event) {
        
        //console.log('value is ===> ',JSON.parse(JSON.stringify(event.detail.value)));
        //console.log('bindex===> ',JSON.parse(JSON.stringify(event.currentTarget.dataset.bindex)));
       // console.log('===> ',JSON.parse(JSON.stringify(event.currentTarget.dataset.fieldname)));

        this.buyerInformation[event.currentTarget.dataset.bindex][event.currentTarget.dataset.fieldname] = event.detail.value;
        if(event.currentTarget.dataset.fieldname=='Residence_Status__c')
        {
            var resident1;
        resident1=event.detail.value;
        if(resident1=='Resident' ) 
        {
            if(this.companytype)
            {
                this.companytyperesident=true;
            }
            this.resident=true;
            this.nonresident=false;
            if(this.indivudualtype)
            {
                this.resindidual=true;
                this.nonresindidual=false;
            }
        }
        
        if(resident1=='Non-Resident') 
        {
            this.companytyperesident=false;
            this.nonresident=true;
            this.resident=false;
            if(this.indivudualtype)
            {
                this.nonresindidual=true;
                this.resindidual=false;
            }
        }

        }
        
    }
    handlePicklistFieldChange1(event) {
        if(event.currentTarget.dataset.fieldname=='Type_of_Buyer__c')
        {
            var typeofbuyer1;
            typeofbuyer1=event.detail.value;
            if(typeofbuyer1=='Company') 
            {
                this.companytype=true;
                this.indivudualtype=false;
                this.resindidual=false;
                this.nonresindidual=false;
                if(this.resident)
                {
                    this.companytyperesident=true;
                }
            }
            
            if(typeofbuyer1=='Individual') 
            {
                this.indivudualtype=true;
                this.companytype=false;
                if(this.resident) 
                {
                    this.resindidual=true;
                    this.nonresindidual=false;
                }
                
            }
    
            if(typeofbuyer1=='Individual') 
            {
                this.companytyperesident=false;
                this.indivudualtype=true;
                this.companytype=false;
                if(this.nonresident) 
                {
                    this.nonresindidual=true;
                    this.resindidual=false;
                }
                
            }
    
        }
       
        if(event.currentTarget.dataset.fieldname=='Resale_Type__c')
        {
            var resaletype1;
            resaletype1=event.detail.value;
            if(resaletype1=='Resale with Mortgage') 
            {
                this.resaletype=true;
            }
            else
            {
                this.resaletype=false;
            }
        }
        
        this.resaleInformation[event.currentTarget.dataset.fieldname] = event.detail.value;
        //console.log('===> ',JSON.parse(JSON.stringify(this.resaleInformation)));
        
    }
   /* removeFile(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    } */
    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                console.log('event.target.files[i].size ',event.target.files[i].size );
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                };
                if(inputType == 'titledeed_oqood'){
                    this.titledeed_oqood = file.name;
                }else if(inputType == 'poadetails'){
                    this.poadetails = file.name;
                }else if(inputType == 'poadetails1'){
                    this.poadetails1 = file.name;
                }else if(inputType == 'memorandumcopy'){
                    this.memorandumcopy = file.name;
                }else if(inputType == 'goodstandingcopy'){
                    this.goodstandingcopy = file.name;
                }else if(inputType == 'incumbencycopy'){
                    this.incumbencycopy = file.name;
                }else if(inputType == 'titledeed_oqood2'){
                    this.titledeed_oqood2 = file.name;
                }else if(inputType == 'poadetals2'){
                    this.poadetals2 = file.name;
                }else if(inputType == 'otherdocumentscopy'){
                    this.otherdocumentscopy = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    } 

    passportcopyupload(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'PassportCopy_'+file.name, 'fileContent':fileContents});
                    this.passportcopy=true;
                    if(inputType == 'passportcopy'){
                        this.passportscopy = file.name;
                    }else if(inputType == 'passportcopy1'){
                        this.passportcopy1 = file.name;
                    }else if(inputType == 'authorizedsignatorycopy'){
                        this.authorizedsignatorycopy = file.name;
                    }
                    
                    
                };
                reader.readAsDataURL(file);
            }
        }
    }

    visacopyUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                    
                if (event.target.files[i].size > MAX_FILE_SIZE) {            
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'VisaCopy_'+file.name, 'fileContent':fileContents});
                    this.visacopy=true;
                    if(inputType == 'visacopyfile'){
                        this.visacopyfile = file.name;
                    }
                    
                    
                };
                reader.readAsDataURL(file);
            }
        }
    }

    emiratescopyUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'EmiratesIdCopy_'+file.name, 'fileContent':fileContents});
                    this.emiratescopy=true;
                };
                if(inputType == 'emiratesIdcopy'){
                    this.emiratesIdcopy = file.name;
                }else if(inputType == 'emiratescopy1'){
                    this.emiratescopy1 = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }

    contractfloaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'ContractMOU_'+file.name, 'fileContent':fileContents});
                    this.Contractfcopy=true;
                };
                if(inputType == 'contractFMOU'){
                    this.contractFMOU = file.name;
                }else if(inputType == 'contractFMOU1'){
                    this.contractFMOU1 = file.name;
                }else if(inputType == 'contractFMOU2'){
                    this.contractFMOU2 = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }

    nationalcopyUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'NationalIdCopy_'+file.name, 'fileContent':fileContents});
                    this.nationalidcopy=true;
                };
                if(inputType == 'nationalcopy'){
                    this.nationalcopy = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }

    tradelicenceUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'TradeLicenseCopy_'+file.name, 'fileContent':fileContents});
                    this.tradecopy=true;
                };
                if(inputType == 'tradelicencecopy1'){
                    this.tradelicencecopy1 = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }

    mortgageUploaded(event){
       
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'MortgageContract_'+file.name, 'fileContent':fileContents});
                    this.mortgagecopy=true;
                };
                if(inputType == 'mortagagecopy'){
                    this.mortagagecopy = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }
    
    chequeUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'ManagersChequeCopy_'+file.name, 'fileContent':fileContents});
                    this.chequecopy=true;
                };
                if(inputType == 'managerschequecopy'){
                    this.managerschequecopy = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }


    showToast(title,msg,type){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvent); 
    }

    @wire(getResaleRecords, {bookid:'$recordId'})
    wiredResaleList({error,data}) {
        if (data) {
            console.log('wiredResaleList -> ',JSON.parse(JSON.stringify(data)));
            this.activeresale=false;
        }
        if(this.activeresale)
        {
            console.log('Can initiate Resale process'); 
        }
        else{
            this.showToast('warning','you cannot initiate Resale, There is active Resale Process under this booking','Info');
        }

    }

    @wire(getBookingDetails, {resaleid:'$recordId', record:'book'})
    wiredBookingDetailsList({error,data}) {
        if (data) {
            this.bookingrecord = data;
            for(var key in this.bookingrecord)
            {
                if(key=='countofpdc')
                {
                    this.countofpdc=this.bookingrecord[key];
                }
                if(key=='amountofpdc')
                {
                    this.amountofpdc=this.bookingrecord[key];
                }
                if(key=='latecharges')
                {
                    this.latecharges=this.bookingrecord[key];
                }

            }
        }
        if(error){
            console.log('wiredBookingList -> ',JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getApplicantRecords, {bookid:'$recordId'})
    wiredApplicantList({error,data}) {
        if (data) {
            console.log('wiredApplicantList -> ',JSON.parse(JSON.stringify(data)));
            if(data.length > 0){
                for (let index = 0; index < data.length; index++) {
                    if(data[index].Applicant_Number__c == 'Primary Applicant'){
                        this.sellerInformation = data[index];
                        break;
                    }
                }
                if(this.sellerInformation == null){
                    console.log('wiredApplicantList -> ',JSON.parse(JSON.stringify(data)));
                    this.showToast('Success','No Primary Applicants found under this booking please correct the data from backend or report to IT','Info');
                }
            }else{
                this.showToast('Success','No existing applicants found under this booking please correct the data from backend or report to IT','Info');
            }
        }
        if(error){
            console.log('wiredApplicantList -> ',JSON.parse(JSON.stringify(error)));
            this.showToast('Success',error,'Error');
        }
    }
    
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm',event.detail.id);
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Resale Process Initiated Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvent); 

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              actionName: "view",
              recordId: this.recordId
            }
          });
    }

    async submitForm(event){
        if(this.resindidual){
           if(this.passportcopy && this.visacopy && this.Contractfcopy && this.emiratescopy)
           {
            if(this.resaletype)
            {
                if(this.mortgagecopy && this.chequecopy)
                {
                    this.documents=true;
                }
            }
            else
            {
                this.documents=true;
            }
           } 
        }

        if(this.nonresindidual){
            if(this.passportcopy && this.Contractfcopy && this.nationalidcopy){
                if(this.resaletype){
                    if(this.mortgagecopy && this.chequecopy){
                        this.documents=true;
                    }
                }else{
                    this.documents=true;
                }
            } 
        }

        if(this.companytype){
            if(this.tradecopy && this.passportcopy && this.Contractfcopy){  
                if(this.resaletype){
                    if(this.mortgagecopy && this.chequecopy){
                        this.documents=true;
                    }
                }else{
                    this.documents=true;  
                }
            }
        }
        if(this.companytyperesident){
            if(!this.emiratescopy){
                this.documents=false; 
            }
        }

        if(this.documents){
            if(this.buyerInformation.length > 0){
                this.showSpinner = true;
                let isValid = true;
                let inputFields = this.template.querySelectorAll('.validate');
                inputFields.forEach(inputField => {
                    if(!inputField.checkValidity()) {
                        inputField.reportValidity();
                        isValid = false;
                    }
                });
                if(isValid == true){
                    console.log('TRUE',isValid);
                    
                    this.resaleInformation.Booking__c = this.recordId;
                    this.resaleInformation.Buyer1_Name__c = this.buyerInformation[0].Name;
                    this.resaleInformation.Buyer1_Email__c = this.buyerInformation[0].Email__c;
                    this.resaleInformation.Buyer1_Phone_Number__c = this.buyerInformation[0].Phone_Number__c;
                    this.resaleInformation.Buyer1_Passport_Number__c = this.buyerInformation[0].Passport_Number__c;
                    this.resaleInformation.Buyer1_Address__c = this.buyerInformation[0].Address__c;
                    this.resaleInformation.New_Sale_Value__c = this.buyerInformation[0].New_Sale_Value__c;
                    this.resaleInformation.Seller1_Name__c = this.sellerInformation.Name;
                    this.resaleInformation.Seller1_Email__c = this.sellerInformation.Email_Address__c;
                    this.resaleInformation.Seller1_Passport_Number__c = this.sellerInformation.Passport_Copy_Details__c;
                    this.resaleInformation.Seller1_Phone_Number__c = this.sellerInformation.Mobile_Number__c;
                    this.resaleInformation.Buyer1_Emirates_Id__c = this.buyerInformation[0].Buyer1_Emirates_Id__c;
                    this.resaleInformation.City__c = this.buyerInformation[0].City__c;
                    this.resaleInformation.Country__c = this.buyerInformation[0].Country__c;
                    this.resaleInformation.Buyer1_Unit_Share_Transfer__c = this.buyerInformation[0].Buyer1_Unit_Share_Transfer__c;
                    this.resaleInformation.Tower__c = this.sellerInformation.Booking__r.Unit__r.Tower__c;
                    this.resaleInformation.Unit__c = this.sellerInformation.Booking__r.Unit__c;
                    this.resaleInformation.Seller1_Address__c=this.sellerInformation.Mailing_Address__c;
                    this.resaleInformation.Nationality__c=this.sellerInformation.Nationality__c;
                    this.resaleInformation.Count_of_PDC_s_available__c=this.countofpdc;
                    this.resaleInformation.Amount_of_PDC__c=this.amountofpdc;
                    this.resaleInformation.Late_payment_charges__c=this.latecharges; 
                    
                    console.log('resaleInformation',JSON.stringify(this.resaleInformation));
                    console.log('resaleInformation',JSON.stringify(this.buyerInformation));
                    let resultOfResaleId = null;
                    let createResalePromise = createResale({resale : JSON.stringify(this.resaleInformation), buyers : JSON.stringify(this.buyerInformation) }).then((res) => {
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

                    createResalePromise.then((resu) => { 
                        console.log('rsu',resu); 
                        if(resu!= null && resu.includes('Success')){
                            this.showSpinner = true;
                            var temp = resu.split(',');
                            const asynccreateAttachment = this.filesData.map(item => this.createAttachment(item,temp[1]));
                            Promise.all(asynccreateAttachment).then(results => {
                                console.log('All attachments created successfully:', results);
                                this.showToast('Success','Record has been created','Success');
                                this.showSpinner = false;
                                setTimeout(() => {
                                    this.navigateToRecordPage(temp[1]);
                                }, 300);
                            }).catch(error => {
                                this.showSpinner = false;
                                this.showToast('Success','Resale Data has been save please upload document if it not uploaded','success');
                                this.navigateToRecordPage(temp[1]);
                                console.error('An error occurred:', error);
                            });
                        }else{
                            this.showSpinner = false;
                        }
                    })
                }else{
                    this.showSpinner = false;
                    return isValid;
                }
            }else{
                this.showSpinner = false;
                this.showToast('Note','You need to add atleast one buyer','Info');
            }
        }else{
            this.showSpinner = false;
            this.showToast('Note','Please upload all mandatory documents','Info');  
        }
    }

    async createAttachment(item,parentId){
        return new Promise(resolve => {
            createAttachment({filedata : JSON.stringify(item),parentId}).then((res) => {
                if(res == 'Success'){
                    this.showToast('info ',item.fileName+ ' File Uploaded Successfully please wait dont leave the screen ','info');
                    resolve('Success');
                }else{
                    this.showToast('Info ',item.fileName+ ' File Uploading Error But Record is Save You can Upload File Later in Record  wait dont leave the screen','Error');
                    resolve('Success');
                }
            }).catch((err) => {
                this.showToast('Info ',item.fileName+ ' File Uploading Error But Record is Save You can Upload File Later in Record wait dont leave the screen '+err,'Error');
                resolve('Success');
            });
        });        
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Booking__c=this.recordId;
        fields.Seller1_Name__c=this.primaryappl.Name;
        fields.Seller1_Email__c=this.primaryappl.Email_Address__c;
        fields.Seller1_Phone_Number__c=this.primaryappl.Mobile_Number__c; 
        fields.Seller1_Address__c=this.primaryappl.Mailing_Address__c;
        fields.Seller1_Passport_Number__c=this.primaryappl.PassportNoDetails__c;

        fields.Seller2_Name__c=this.secondappl.Name;
        fields.Seller2_Email__c=this.secondappl.Email_Address__c;
        fields.Seller2_Phone_Number__c=this.secondappl.Mobile_Number__c; 
        fields.Seller2_Address__c=this.secondappl.Mailing_Address__c;
        fields.Seller2_Passport_Number__c=this.secondappl.PassportNoDetails__c;

        fields.Seller3_Name__c=this.thirdappl.Name;
        fields.Seller3_Email__c=this.thirdappl.Email_Address__c;
        fields.Seller3_Phone_Number__c=this.thirdappl.Mobile_Number__c; 
        fields.Seller3_Address__c=this.thirdappl.Mailing_Address__c;
        fields.Seller3_Passport_Number__c=this.thirdappl.PassportNoDetails__c;

        fields.Seller4_Name__c=this.fourthappl.Name;
        fields.Seller4_Email__c=this.fourthappl.Email_Address__c;
        fields.Seller4_Phone_Number__c=this.fourthappl.Mobile_Number__c; 
        fields.Seller4_Address__c=this.fourthappl.Mailing_Address__c;
        fields.Seller4_Passport_Number__c=this.fourthappl.PassportNoDetails__c;

        fields.Seller5_Name__c=this.fifthappl.Name;
        fields.Seller5_Email__c=this.fifthappl.Email_Address__c;
        fields.Seller5_Phone_Number__c=this.fifthappl.Mobile_Number__c; 
        fields.Seller5_Address__c=this.fifthappl.Mailing_Address__c;
        fields.Seller5_Passport_Number__c=this.fifthappl.PassportNoDetails__c;
        
        console.log('onsubmit event recordEditForm'+ JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
       
    }
}