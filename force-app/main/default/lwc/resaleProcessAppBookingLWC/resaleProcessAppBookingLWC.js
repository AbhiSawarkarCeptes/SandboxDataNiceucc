import { LightningElement, api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getResaleRecords from '@salesforce/apex/ResaleProcessAppBookingLWCController.getactiveresale';
import getApplicantRecords from '@salesforce/apex/ResaleProcessAppBookingLWCController.getallapplicants';
import createResale from '@salesforce/apex/ResaleProcessAppBookingLWCController.createResale';
import createAttachment from '@salesforce/apex/ResaleProcessAppBookingLWCController.createAttachment';
import getBookingDetails from '@salesforce/apex/ResaleProcessAppBookingLWCController.getBookingDetails';
import { NavigationMixin } from "lightning/navigation";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Resale__OBJECT from '@salesforce/schema/PropStrength__Transaction_Requests__c';
import Resale_Type_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.PropStrength__Customer_Transfer_Type__c';
import ResaleNoc_Type_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.NOC_Type__c';
import Type_of_Buyer_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.Type_of_Buyer__c';
import Buyer_Residence_Status from '@salesforce/schema/PropStrength__Transaction_Requests__c.Buyer_Residence_Status__c';
import Mortgage_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.Mortgage__c';
// import country_FIELD from '@salesforce/schema/Resale_Process__c.Country__c';
// import city_FIELD from '@salesforce/schema/Resale_Process__c.City__c';
// import Bank_Name_FIELD from '@salesforce/schema/Resale_Process__c.Bank_Name__c';

import CONTACT__OBJECT from '@salesforce/schema/Contact'; 
import Salutation_FIELD from '@salesforce/schema/Contact.Salutation';

import Buyer__OBJECT from '@salesforce/schema/PropStrength__Customer_Detail__c';
import Nationality_FIELD from '@salesforce/schema/PropStrength__Customer_Detail__c.Nationality__c';
import Buyer_Type_FIELD from '@salesforce/schema/PropStrength__Customer_Detail__c.PropStrength__Type__c';
import Residential_Status_FIELD from '@salesforce/schema/Contact.PropStrength__Resident_Status__c';
//import Residence_Status_FIELD from '@salesforce/schema/Buyer__c.Residence_Status__c';


    const MAX_FILE_SIZE = 5000000;
export default class ResaleProcessAppBookingLWC extends NavigationMixin(LightningElement) {
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
    typeOfBuyerOptions;
    propertyOptions;
    resaletypeOptions;
    resaleNoctypeOptions;
    @track ResidenceStatus;
    @track activeresale=true;
    @track residencetypeOptions;
    @track nationalityOptions;
    @track mortagageOptions;
    @track countryOptions;
    @track cityOptions;
    @track bankOptions;
    @track sellerInformation;
    @track sellerInformation_2;
    @track sellerInformation_3;
    @track sellerInformation_4;
    @track salutationOptions;
    @track displayBankName = false;
    
    @track transectionInformation = {
        PropStrength__Application_Booking__c : this.recordId,
        PropStrength__Customer_Transfer_Type__c : '',
        NOC_Type__c : '',
        Buyer_Residence_Status__c : '',
        PropStrength__Reason_For_Assignment__c : null
    }
    @track buyerInformation = [];
    @track showSpinner= false;
    @track showfirst= true;
    @track showSecond= false;
    @track showThird= false;
    @track showFourth= false;
    @track showFifth= false;
    @track buyerCount = 0;
    @track buyerNumnerInfo = 'First';
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
    @track recordTypeId;
    @track residencestatusOptions;

    @wire(getObjectInfo, { objectApiName: Resale__OBJECT })
    wiredObjectInfo({error, data}) {
        if (error) {
          // handle Error
        } else if (data) {
          const rtis = data.recordTypeInfos;
          this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Transfer Of Property');
        }
      };

    @wire(getPicklistValues,{
        recordTypeId: '$recordTypeId', 
        fieldApiName: Buyer_Residence_Status
    })wiredpropertyOptions({error,data}){
        if(data) {
            this.ResidenceStatus = data.values;
        } 
     };

    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: Resale_Type_FIELD
    })wiredresaletypeOptions({error,data}){
        console.log('data128*---',data);
        if(data) {
            this.resaletypeOptions = data.values;
        } 
     };
    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: ResaleNoc_Type_FIELD
    })wiredresaleNoctypeOptions({error,data}){
        console.log('data128*---',data);
        if(data) {
            this.resaleNoctypeOptions = data.values;
        } 
     };
    
     @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId",
        fieldApiName: Type_of_Buyer_FIELD
    })wiredresalebuyerOptions({error,data}){
        console.log('data136*---',data);
        if(data) {
            this.typeOfBuyerOptions = data.values;
        } 
     };

     @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: Mortgage_FIELD
        
    })wiredmortagageOptions({error,data}){  
        if(data) {
            this.mortagageOptions = data.values;
        } 
     };

    @wire(getPicklistValues,{
        recordTypeId: '$buyerMetadata.data.defaultRecordTypeId', 
        fieldApiName: Nationality_FIELD
    })wirednationalityOptions({error,data}){
        if(data) {
            this.nationalityOptions = data.values;
        } 
     };
    
    @wire(getObjectInfo, { objectApiName: CONTACT__OBJECT })
     ContactMetadata;

     @wire(getPicklistValues,{
        recordTypeId: '$ContactMetadata.data.defaultRecordTypeId', 
        fieldApiName: Salutation_FIELD
    })wiredsalutationOptions({error,data}){
        if(data) {
            this.salutationOptions = data.values;
        } 
     };

    @wire(getObjectInfo, { objectApiName: Buyer__OBJECT })
     buyerMetadata;

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
        fieldApiName: Residential_Status_FIELD
    })wiredresidencestatusOptions1({error,data}){
        if(data) {
            this.residencestatusOptions = data.values;   
        }
    };

    
    connectedCallback(){
        
        this.addBuyer();
    }

    navigateToRecordPage(recordPageId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordPageId,
                objectApiName: 'PropStrength__Transaction_Requests__c',
                actionName: 'view'
            }
        });
    }

    addBuyer(){
        if(this.buyerCount < 5){
            if(this.buyerCount == 0){
                var buyer = {
                    flag : true,
                    buyerNum : 'First',
                    Last_name:null,  
                    First_name:null,          
                    Salutation : null,            
                    Email : null,
                    Phone_Number : null,
                    Passport_Number : null,
                    Address : null,
                    Resale_Process : null,
                    Nationality : null,
                    New_Sale_Value : null,
                    Residence_Status : null,
                    Street : null,
                    State : null,
                    PostalCode : null,
                    Emirates_Id : null,
                    Country : null,
                    Buyer1_Unit_Share_Transfer:null,
                    Buyer_Type : null,
                    City : null
                }
            } 
            if(this.buyerCount == 1){
                var buyer = {
                    flag : false,
                    buyerNum : 'Second',
                    Last_name:null,  
                    First_name:null,          
                    Salutation : null,            
                    Email : null,
                    Phone_Number : null,
                    Passport_Number : null,
                    Address : null,
                    Resale_Process : null,
                    Nationality : null,
                    New_Sale_Value : null,
                    Residence_Status : null,
                    Street : null,
                    State : null,
                    PostalCode : null,
                    Emirates_Id : null,
                    Country : null,
                    Buyer1_Unit_Share_Transfer:null,
                    Buyer_Type : null,
                    City : null
                }
            }
            if(this.buyerCount == 2){
                var buyer = {
                    flag : false,
                    buyerNum : 'Third',
                    Last_name:null,  
                    First_name:null,          
                    Salutation : null,            
                    Email : null,
                    Phone_Number : null,
                    Passport_Number : null,
                    Address : null,
                    Resale_Process : null,
                    Nationality : null,
                    New_Sale_Value : null,
                    Residence_Status : null,
                    Street : null,
                    State : null,
                    PostalCode : null,
                    Emirates_Id : null,
                    Country : null,
                    Buyer1_Unit_Share_Transfer:null,
                    Buyer_Type : null,
                    City : null
                }
            }
            if(this.buyerCount == 3){
                var buyer = {
                    flag : false,
                    buyerNum : 'Fourth',
                    Last_name:null,  
                    First_name:null,          
                    Salutation : null,            
                    Email : null,
                    Phone_Number : null,
                    Passport_Number : null,
                    Address : null,
                    Resale_Process : null,
                    Nationality : null,
                    New_Sale_Value : null,
                    Residence_Status : null,
                    Street : null,
                    State : null,
                    PostalCode : null,
                    Emirates_Id : null,
                    Country : null,
                    Buyer1_Unit_Share_Transfer:null,
                    Buyer_Type : null,
                    City : null
                }
            }
            if(this.buyerCount == 4){
                var buyer = {
                    flag : false,
                    buyerNum : 'Fifth',
                    Last_name:null,  
                    First_name:null,          
                    Salutation : null,            
                    Email : null,
                    Phone_Number : null,
                    Passport_Number : null,
                    Address : null,
                    Resale_Process : null,
                    Nationality : null,
                    New_Sale_Value : null,
                    Residence_Status : null,
                    Street : null,
                    State : null,
                    PostalCode : null,
                    Emirates_Id : null,
                    Country : null,
                    Buyer1_Unit_Share_Transfer:null,
                    Buyer_Type : null,
                    City : null
                }
            }
            console.log(buyer);
            this.buyerInformation.push(buyer);
            this.buyerCount++;
            //this.buyerCountInformation();
        }
        else{
            this.showToast('Alert','We can not add more than 5 buyer','Info');
        }
    }

    removedBuyer(event){
        if(this.buyerInformation.length <= 1){
            this.showToast('Success','At least one Buyer should be their','Info');
        }else{
            this.buyerInformation.splice(event.target.dataset.bindex,1);
        }
        this.buyerCount--;
    }    

    handleFieldChange(event){
        this.buyerInformation[event.target.dataset.bindex][event.target.dataset.fieldname] = event.target.value;
        
    }
    handleFieldChange1(event){
        this.transectionInformation[event.target.dataset.fieldname] = event.target.value;

    }

    handlePicklistFieldChange(event) {
        
        this.buyerInformation[event.currentTarget.dataset.bindex][event.currentTarget.dataset.fieldname] = event.detail.value;
        if(event.currentTarget.dataset.fieldname=='PropStrength__Customer_Transfer_Type__c')
        {
            var resident1;
        resident1=event.detail.value;
        if(resident1=='Individual & Resident' ) 
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
        
        if(resident1=='Individual & Non-Resident') 
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
        //resaleInformation
        console.log(event.currentTarget.dataset.fieldname);
        if(event.currentTarget.dataset.fieldname=='Buyer_Residence_Status__c')
        {
            var resident1;
            resident1=event.detail.value;
            if(resident1=='Individual & Resident' ) 
            {
                this.resident=true;
                this.nonresident=false;                
                this.resindidual=true;
                this.nonresindidual=false;
                this.companytype=false; 
                
            }
            
            if(resident1=='Individual & Non-Resident') 
            {
                this.companytype=false; 
                this.companytyperesident=false;
                this.nonresident=true;
                this.resident=false;
                
                    this.nonresindidual=true;
                    this.resindidual=false;
                
            }       
            if(resident1=='Company & Resident') 
            {
                this.companytype=true;
                this.indivudualtype=false;
                this.resindidual=false;
                this.nonresindidual=false;                
                this.companytyperesident=true;
                
            }
            
            if(resident1=='Company & Non-Resident') 
            {
                this.companytyperesident=false;
                this.companytype=true;          
            }
    
            if(resident1=='Individual') 
            {
                this.companytyperesident=false;
                this.indivudualtype=true;
                this.companytype=false;
               
                    this.nonresindidual=true;
                    this.resindidual=false;
                
                
            }
    
        }
       
        console.log(this.transectionInformation[event.currentTarget.dataset.fieldname],'*-*-*-',event.detail.value);
        this.transectionInformation[event.currentTarget.dataset.fieldname] = event.detail.value;
        console.log(this.transectionInformation[event.currentTarget.dataset.fieldname],'*-*-*-',event.detail.value);
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
            this.dispatchEvent(new CloseActionScreenEvent());
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
                    if(data[index].PropStrength__Type__c == '1st Applicant'){
                        this.sellerInformation = data[index];
                    }
                    if(data[index].PropStrength__Type__c == '2nd Applicant'){
                        this.sellerInformation_2 = data[index];
                    }
                    if(data[index].PropStrength__Type__c == '3rd Applicant'){
                        this.sellerInformation_3 = data[index];
                    }
                    if(data[index].PropStrength__Type__c == '4th Applicant'){
                        this.sellerInformation_4 = data[index];
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
        console.log('this.resindidual*---',this.resindidual);
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
        console.log('this.nonresindidual*---',this.nonresindidual);
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
        console.log('this.companytype*---',this.companytype);
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
        console.log('this.companytyperesident*---',this.companytyperesident);
        if(this.companytyperesident){
            if(!this.emiratescopy){
                this.documents=false; 
            }
        }

        if(this.documents || true){
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
                    
                    this.transectionInformation.PropStrength__Application_Booking__c = this.recordId;                    
                    this.transectionInformation.PropStrength__Customer_Transfer_Type__c = this.transectionInformation.PropStrength__Customer_Transfer_Type__c;
                    this.transectionInformation.NOC_Type__c = this.transectionInformation.NOC_Type__c;
                    this.transectionInformation.PropStrength__Reason_For_Assignment__c = this.transectionInformation.PropStrength__Reason_For_Assignment__c;
                    // this.resaleInformation.Seller1_Passport_Number__c = this.sellerInformation.Passport_Copy_Details__c;
                    // this.resaleInformation.Seller1_Phone_Number__c = this.sellerInformation.Mobile_Number__c;
                    
                    
                    console.log('transectionInformation--',JSON.stringify(this.transectionInformation));
                    console.log('buyerInformation-',JSON.stringify(this.buyerInformation));
                    //console.log('resaleInformation',JSON.stringify(this.resaleInformation));
                    let resultOfResaleId = null;
                    let createResalePromise = createResale({resale : JSON.stringify(this.transectionInformation), buyers : JSON.stringify(this.buyerInformation) }).then((res) => {
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