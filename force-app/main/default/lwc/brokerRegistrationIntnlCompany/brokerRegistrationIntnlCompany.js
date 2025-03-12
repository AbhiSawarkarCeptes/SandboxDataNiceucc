import { LightningElement, api, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import brokerRegistrationCSS from "@salesforce/resourceUrl/brokerRegistrationCSS";
import { DOCS_MAP } from "c/brokerRegistrationConstants";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import validateRegistrationNo from "@salesforce/apex/BrokerRegistrationFormExternalController.validateRegistrationNo";
import deleteDocuments from "@salesforce/apex/BrokerRegistrationFormExternalController.deleteDocuments";

//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import PICKLIST_FIELD_FIELD from '@salesforce/schema/Broker_Registration__c.Nationality__c';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import BrokerRegSource from "@salesforce/schema/Broker_Registration__c.Nationality__c";
import BrokerRegSources from "@salesforce/schema/Broker_Registration__c.Company_Registered_In__c";
import BrokerRegCountry from "@salesforce/schema/Broker_Registration__c.Country__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import BROKERREG_OBJECT from "@salesforce/schema/Broker_Registration__c";

import getDocID from "@salesforce/apex/BrokerRegistrationFormExternalController.getDocID";
import createBRDocumentHistory from "@salesforce/apex/BrokerRegistrationFormExternalController.createBRDocumentHistory";
import validateEmail from '@salesforce/apex/Nice_EmailValidationUtility.validateEmail';
import STAND_LEAD_OBJECT from '@salesforce/schema/Stand_Lead__c';
import COUNTRY_CODES from '@salesforce/schema/Stand_Lead__c.Mobile_Country_Code__c';
import { NavigationMixin } from 'lightning/navigation';
import validatePhoneNumber from '@salesforce/apex/Nice_PhoneValidationUtility.validatePhoneNumber';
import picklistValues from "@salesforce/apex/BrokerRegistrationFormExternalController.picklistValues";
import CommonIcons from '@salesforce/resourceUrl/commonIcons';

const defaultFieldApi = [
  "Id",
  "Broker_Category__c",
  "Witness_Email_1__c",
  "Witness_Name__c",
  "Mobile__c",
  "Status__c ",
  "Name",
  "Broker_Created_Date__c",
  "Registration_Number__c",
  "Registration_Link_Expiry_Date_Time__c",
  "Renewal_Status__c",
  "Mobile_Country_Code__c",
  "Telephone_Country_Code__c",
  "Alternate_Email__c",
  "CHRM_Manager_Email__c",
  "City_Province__c",
  "Country__c",
  "District_Area__c",
  "Email__c",
  "First_Name__c",
  "Name_as_per_passport__c",
  "Name_as_per_trade_license__c",
  "OwnerId",
  "RERA_Number__c",
  "RecordTypeId",
  "Street_name__c",
  "Villa_Building_name__c"
];

export default class BrokerRegistrationIntnlCompany extends NavigationMixin(LightningElement) {
  @track filerecordId = "068ba000000i3bhAAA";
  @track showConfirmModal = false;
  @track isConfirmed = false;
  @track isDisabled = true;
  @track _record = {};
  @track files;
  @api today;
  @api options = {};
  @api showalternateemail = false;
  docToDelete = [];
  @track isRegistrationValid = false;
  registrationError = "";
  showSpinner = false;
  nationalityPicklistVal = [];
  companyRegPicklistVal = [];
  picklistCompanyList = [];
  makeReraNumberReadonly = false;
  formType = "Broker Registration Form";
  sobhaRealityImageUrl = CommonIcons + '/commonIcons/sobhaRealtyTextIcon.svg';

  makeReadonly = true;
  @api getFiles;

  uploadedDocuments = [];

  /*validEmail = false;
  validEmailAccount = false; // For Account_Email__c
  validEmailAlternate = false; // For Alternate_Email__c
  //tempEmail;
  hasInteracted = false;
  hasInteractedAccount = false;
  hasInteractedAlternate = false;*/
  isContactNumberDisabled = true;
  accessKey = 'e6a86f2bf1706ccf429f5d34db15b9cb';
  validTelephone = false;
  tempNumber;
  contactnumber;
  hasInteractedPhone = false;

  validMobile = false;
  tempNumberMobile;
  contactnumberMobile;
  hasInteractedMobile = false;

  /*validEmail = false;
  tempEmail;
  emailId;
  hasInteracted = false;

  validAccountEmail = false;
  tempAccountEmail;
  accountEmailID;
  hasInteractedAccount = false;

  validAlternateEmail = false;
  tempAlternateEmail;
  alternateEmailID;
  hasInteractedAlternate = false;*/

  mobileCountryPicklistVal = [];
  telephoneCountryPicklistVal = [];
  telephoneCountryCodeRequired = false;
  mobileCountryCode;
  telephoneCountryCode;

  @api
  get record() {
    return this._record;
  }

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }

  @wire(getObjectInfo, { objectApiName: STAND_LEAD_OBJECT })
  standLeadInfo;

  @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_CODES })
  countryCodes;

  @wire(getObjectInfo, { objectApiName: BROKERREG_OBJECT })
  brokerRegInfo;
  @wire(getPicklistValues, {
    recordTypeId: "$brokerRegInfo.data.defaultRecordTypeId",
    fieldApiName: BrokerRegSource
  })
  getPicklistValuesForField({ data, error }) {
    if (error) {
      console.error(error);
      this.toast("Error", "Some error occured" + error, "error");
    } else if (data) {
      this.nationalityPicklistVal = [...data.values];
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$brokerRegInfo.data.defaultRecordTypeId",
    fieldApiName: BrokerRegSources
  })
  getPickValuesForFields({ data, error }) {
    if (error) {
      console.error(error);
      this.toast("Error", "Some error occured" + error, "error");
    } else if (data) {
      this.companyRegPicklistVal = [...data.values];
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$brokerRegInfo.data.defaultRecordTypeId",
    fieldApiName: BrokerRegCountry
  })
  getPickValuesForFields1({ data, error }) {
    if (error) {
      console.error(error);
      this.toast("Error", "Some error occured" + error, "error");
    } else if (data) {
      this.picklistCompanyList = [...data.values];
    }
  }

  /*@wire(getPicklistValues, { recordTypeId: '012000000000000AAA',fieldApiName: PICKLIST_FIELD_FIELD })
    getPicklistValuesForField({ data, error }) {
        if (error) {
            console.error(error);
            this.toast('Error', 'Some error occured'+error, 'error');
        } else if (data) {
            this.nationalityPicklistVal = [...data.values]
        }
    }*/

  set record(data) {
    this._record = JSON.parse(JSON.stringify(data));
  }

  connectedCallback() {
    console.log("connectedCallback 1");
    loadStyle(this, brokerRegistrationCSS);
    console.log("connectedCallback 12");
    if (this.record.Broker_Category__c != "Broker - Intnl") {
      this.files = JSON.parse(
        JSON.stringify(DOCS_MAP[this.record.Broker_Category__c]?.files)
      );
    } else if (
      this.record.Broker_Category__c == "Broker - Intnl" &&
      this._record.Sub_Category__c == "Company"
    ) {
      this.files = JSON.parse(
        JSON.stringify(DOCS_MAP["Broker - Intnl-Company"]?.files)
      );
    }
    
    console.log("connectedCallback 3",this.getFiles);
    console.log(JSON.stringify(this.files, null, 2));
    console.log("connectedCallback 4");
    console.log("~~~~~~~~Res: " + JSON.stringify(this.record));
    console.log("!!! " + this.record.RecordType.Name);

   /* if(this.getFiles.length){
      this.uploadedFiles = [...this.getFiles];
      
    }*/
    //showalternateemail
    if (
      this.record.Broker_Category__c == "Broker - RERA" ||
      this.record.Broker_Category__c == "Broker - Intnl" ||
      this.record.Broker_Category__c == "Sobha Connect - Intnl - Company" ||
      this.record.Broker_Category__c == "Sobha Connect - UAE - Company" ||
      this.record.Broker_Category__c == "Broker - UAE"
    ) {
      this.showalternateemail = true;
    }
    if (this.record.RecordType.Name != "Renewal") {
      let tempObj = this.record;
      Object.keys(tempObj).forEach(function (key) {
        if (!defaultFieldApi.includes(key)) {
          delete tempObj[key];
        }
      });
      //console.log('~~~~~~~~Aft: '+JSON.stringify(tempObj));
      this.record = tempObj;
    } else {
      this.formType = "Broker Renewal Form";
    }

    if (this.record.Mobile__c != undefined && this.record.Mobile__c) {
      this.tempNumberMobile = this.record.Mobile__c;
      this.mobileCountryCode = this.record.Mobile_Country_Code__c;
      this.handleBlurMobile();
    }

    if (this.record.Email__c != undefined && this.record.Email__c) {
      this.tempEmail = this.record.Email__c;
      this.handleEmailBlur();
    }

    picklistValues({
      objectName: "Broker_Registration__c",
      fieldName: "Mobile_Country_Code__c"
    })
      .then((result) => {
        this.mobileCountryPicklistVal = result;
      })
      .catch((error) => {
        console.log("error:", error);
      });

    picklistValues({
      objectName: "Broker_Registration__c",
      fieldName: "Telephone_Country_Code__c"
    })
      .then((result) => {
        this.telephoneCountryPicklistVal = result;
      })
      .catch((error) => {
        console.log("error:", error);
      });
      console.log('this.files:::;',this.files);
  }

  renderedCallback(){
    console.log('OUTPUT : rendeeredcalalbac', this.files);
  }

  clearContactNumber() {
    // Wait for DOM to update if necessary
    Promise.resolve().then(() => {
      const contactNumberField = this.template.querySelector('lightning-input[data-id="Telephone__c"]');

      console.log('Inside clearContactNumber : ' + contactNumberField);
      if (contactNumberField) {
        console.log('Inside clearContactNumber');
        contactNumberField.value = ''; // Clear the value
        this.validTelephone = false;
      } else {
        console.error('Contact number field not found in DOM.');
      }
    });
  }

  handleSubmit(event) {
    if (this.isConfirmed) {
      this.showConfirmModal = false;
      if (this.isRegistrationValid == false) {
        this.toast("Error", "Please validate Registration Number", "error");
        this.isConfirmed = false;
        this.isDisabled = true;
        return;
      } else if (!this.validate()) {
        this.isDisabled = true;
        this.isConfirmed = false;
        return;
      }else if (!this.validEmail) {
        this.showToast("Error", "Please enter a valid Email Address", "error");
        console.log("Invalid main email: ", this.validEmail);
        return;
      }/*else if (!this.validEmailAccount){
        this.showToast("Error", "Please enter a valid Account Email", "error");
        console.log("Invalid account email: ", this.validEmailAccount);
        return;
      }else if (!this.validEmailAlternate && this.showalternateemail){
        this.showToast("Error", "Please enter a valid Owner Email", "error");
        console.log("Invalid alternate email: ", this.validEmailAlternate);
        return;
      }*/else if (!this.validMobile) {
        this.isDisabled = true;
        this.isConfirmed = false;
        this.showToast("Error", "Please enter a valid Mobile Number", "error");
        console.log("Invalid Mobile Number: ", this.validMobile);
        return;
      } else if (this.tempNumber && !this.validTelephone) {
        this.isDisabled = true;
        this.isConfirmed = false;
        this.showToast("Error", "Please enter a valid Telephone Number", "error");
        console.log("Invalid Telephone Number: ", this.validTelephone);
        return;
      }else if (this.tempEmail != undefined && !this.validEmail) {
        this.showToast("Error", "Please enter a valid Email Address", "error");
        console.log("Invalid main email: ", this.validEmail);
        return;
      }else if (this.tempAccountEmail != undefined && !this.validAccountEmail){
        this.showToast("Error", "Please enter a valid Account Email", "error");
        console.log("Invalid account email: ", this.validAccountEmail);
        return;
      }else if (this.tempAlternateEmail !=undefined && !this.validAlternateEmail && this.showalternateemail){
        this.showToast("Error", "Please enter a valid Owner Email", "error");
        console.log("Invalid alternate email: ", this.validEmailAlternate);
        return;
      }

      console.log("All validations passed. Proceeding with form submission.");

      this.showSpinner = true;
      this.isConfirmed = false;
      this.isDisabled = true;
      if (this.uploadedDocuments.length > 0) {
        var recId = this.record.Id;
        createBRDocumentHistory({
          brId: recId,
          docList: JSON.stringify(this.uploadedDocuments)
        })
          .then((result) => { })
          .catch((error) => {
            console.log("---- createBRDocumentHistory errors ----");
            console.log(error);
          });
      }
      if (this.docToDelete.length > 0) {
        deleteDocuments({ DocIds: this.docToDelete })
          .then((res) => {
            const submitEvent = new CustomEvent("submit", {
              detail: { record: this.record }
            });
            this.dispatchEvent(submitEvent);
            this.showSpinner = false;
          })
          .catch((error) => {
            this.toast("Error", "Some error occured" + error, "error");
          });
        const submitEvent = new CustomEvent("submit", {
          detail: { record: this.record }
        });
        this.dispatchEvent(submitEvent);
        this.showSpinner = false;
      } else {
        const submitEvent = new CustomEvent("submit", {
          detail: { record: this.record }
        });
        this.dispatchEvent(submitEvent);
        this.showSpinner = false;
      }
    }
  }

  handleChange(event) {
    this.record[event.target.name] = event.target.value;
    if (event.target.name === "Registration_Number__c" && event.target.value) {
      this.isRegistrationValid = false;
      console.debug("isResValid:", this.isRegistrationValid);
    }else if (event.target.name === "Email__c") {
      this.emailId = event.target.value;
      console.log('this.emailId 1st : '+this.emailId);
      this.tempEmail = this.emailId;
      console.log('this.emailId 2nd : '+this.emailId);  
      this.hasInteracted = true;
      this.validEmail = false;
    }else if (event.target.name === "Account_Email__c") {
      this.accountEmailID = event.target.value;
      console.log('this.accountEmailID 1st : '+this.accountEmailID);
      this.tempAccountEmail = this.accountEmailID;
      console.log('this.accountEmailID 2nd : '+this.accountEmailID);  
      this.hasInteractedAccount = true;
      this.validAccountEmail = false;
    }else if (event.target.name === "Alternate_Email__c") {
      this.alternateEmailID = event.target.value;
      console.log('this.alternateEmailID 1st : '+this.alternateEmailID);
      this.tempAlternateEmail = this.alternateEmailID;
      console.log('this.alternateEmailID 2nd : '+this.alternateEmailID);  
      this.hasInteractedAlternate = true;
      this.validAlternateEmail = false;
    }else if (event.target.name == 'countrycode') {
      console.log('COming here 3');
      console.log(event.target.value);
      this.countrycode = event.target.value;
      this.isContactNumberDisabled = false;
      this.clearContactNumber();
    } else if (event.target.name === "Telephone__c") {
      this.contactnumber = event.target.value;
      console.log('this.contactnumber 1st : ' + this.contactnumber);
      this.tempNumber = this.contactnumber;
      console.log('this.contactnumber 2nd : ' + this.contactnumber);
      this.hasInteractedPhone = true;
      this.validTelephone = false;
    } else if (event.target.name === "Mobile__c") {
      this.contactnumberMobile = event.target.value;
      console.log('this.contactnumberMobile 1st : ' + this.contactnumberMobile);
      this.tempNumberMobile = this.contactnumberMobile;
      console.log('this.contactnumberMobile 2nd : ' + this.contactnumberMobile);
      this.hasInteractedMobile = true;
      this.validMobile = false;
    }
    else if (event.target.name === "Telephone__c" && this.record.Telephone__c && !this.record.Telephone_Country_Code__c) {
      this.telephoneCountryCodeRequired = true;
    }
    else if (event.target.name === "Telephone_Country_Code__c" && event.target.value) {
      this.telephoneCountryCodeRequired = false;
      this.telephoneCountryCode = event.target.value;
      console.log('this.tempNumber : ' + this.tempNumber);
      console.log('this.validTelephone 2nd : ' + this.validTelephone);
      if (this.tempNumber != undefined && !this.validTelephone) {
        this.handleBlurPhone();
      }
      //console.log('this.telephoneCountryCode=',this.telephoneCountryCode);
    }
    else if (event.target.name === "Mobile_Country_Code__c" && event.target.value) {
      this.mobileCountryCode = event.target.value;
      //console.log('this.mobileCountryCode=',this.mobileCountryCode);
    }
  }



  handleBlur(event) {
    this.record[event.target.name] = event.target.value;

    if (event.target.name === "Registration_Number__c" && event.target.value) {
      let catgType = "NotBroker";
      if (this.record.Broker_Category__c.startsWith("Broker")) {
        catgType = "Broker";
      }
      console.log("~~~~ResisNo: " + this.record.Registration_Number__c);
      validateRegistrationNo({
        registrationNo: this.record.Registration_Number__c,
        obj: catgType,
        category: this.record.Broker_Category__c,
        brRecordTypeId: this.record.RecordTypeId
      })
        .then((result) => {
          console.log("~~~~Res: " + JSON.stringify(result));
          console.log("~~~~ResisNo1: " + this.record.Registration_Number__c);
          if (result > 0) {
            this.registrationError =
              "Broker already exists for given: " +
              this.record.Registration_Number__c;
            this.record.Registration_Number__c = "";
            this.isRegistrationValid = false;
          } else if (result === -1) {
            this.registrationError =
              "Broker has been blacklisted for the given: " +
              this.record.Registration_Number__c;
            this.record.Registration_Number__c = "";
            this.isRegistrationValid = false;
          } else {
            this.registrationError = "";
            this.isRegistrationValid = true;
          }
        })
        .catch((error) => {
          console.log("error:", error);
          this.registrationError = error.body
            ? error.body.message
            : error.message;
          this.isRegistrationValid = false;
        });
    }

  }

  async handleBlurPhone() {
    //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

    console.log('Inside handleBlur');
    console.log('Inside handleBlur : this.telephoneCountryCode ' + this.telephoneCountryCode);
    console.log('Inside handleBlur : this.tempNumber ' + this.tempNumber);

    if (this.tempNumber && this.telephoneCountryCode == undefined) {
      this.showToast('Error', 'Please enter valid country code first', 'error');
      this.hasInteractedPhone = true;
      this.validTelephone = false;
    }

    // Validate input
    if (!this.telephoneCountryCode || !this.tempNumber) {
      this.hasInteractedPhone = false;
      this.validTelephone = true;
      this.record.Is_ValidTelephone__c = false;
      /* this.apiResponse = 'Both Mobile Country Code and Contact Number are required.';
       this.dispatchEvent(
           new ShowToastEvent({
               title: 'Error',
               message: 'Please enter valid country code first',
               variant: 'error',
           }),
       );*/
      return;
    }

    console.log('Inside handleBlur : this.tempNumberMobile ' + this.tempNumberMobile);
    console.log('Inside handleBlur : this.validMobile ' + this.validMobile);
    if (this.validMobile && this.tempNumberMobile == this.tempNumber && this.telephoneCountryCode != undefined) {
      this.hasInteractedPhone = true;
      this.validTelephone = true;
      this.record.Is_ValidTelephone__c = this.validTelephone;
      console.log('Inside handleBlurPhone if: this.record.Is_ValidTelephone__c : ' + this.record.Is_ValidTelephone__c);
    } else {
      try {
        const response = await validatePhoneNumber({
          accessKey: this.accessKey,
          phoneNumber: this.telephoneCountryCode + this.tempNumber,
          countryCode: ''
        });
        // Null check for the response
        if (!response) {
          this.errorMessage = 'No response received from the API.';
          this.apiResponse = null;
          console.log('Inside handleBlur : errorMessage : ' + this.errorMessage);
          return;
        }

        console.log('Raw Response from Apex:', response);
        console.log('typeof Response from Apex:', typeof response);

        // Parse and map the response to the PhoneValidationResponse format
        const parsedResponse = JSON.parse(response);
        console.log('parsedResponse', parsedResponse);
        //console.log('Inside handleBlur : parsedResponse : '+JSON.stringify(this.parsedResponse));

        // Check if the parsed response is valid
        if (parsedResponse) {
          // Map response to the UI

          this.validTelephone = parsedResponse.valid;
          /* mobNumber: parsedResponse.number,
           local_format: parsedResponse.local_format,
           international_format: parsedResponse.international_format,
           country_prefix: parsedResponse.country_prefix,
           country_code: parsedResponse.country_code,
           country_name: parsedResponse.country_name,
           location: parsedResponse.location,
           carrier: parsedResponse.carrier,
           line_type: parsedResponse.line_type,*/


          // Clear error message
          this.errorMessage = '';
        } else {
          this.errorMessage = 'Invalid response format from the API.';
          this.apiResponse = null;
          console.log('Inside handleBlur : errorMessage : ' + this.errorMessage);
        }
      } catch (error) {
        console.error('Error:', error);
        console.log('Inside handleBlur : catch : ' + this.error);
        this.apiResponse = 'Error validating phone number.';
      }

      console.log('Inside handleBlurPhone : valid : ' + this.validTelephone);
      this.record.Is_ValidTelephone__c = this.validTelephone;
      console.log('Inside handleBlurPhone : this.record.Is_ValidTelephone__c : ' + this.record.Is_ValidTelephone__c);
      if (!this.validTelephone) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Please enter valid mobile number',
            variant: 'error',
          }),
        );
      }
    }

    if (this.telephoneCountryCode && this.tempNumber == undefined) {
      this.validTelephone = true;
    }
    console.log('Inside handleBlur end: this.tempNumber ' + this.tempNumber);
    console.log('Inside handleBlur end: this.telephoneCountryCode ' + this.telephoneCountryCode);
  }

  async handleBlurMobile() {
    //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

    console.log('Inside handleBlur');
    console.log('Inside handleBlur : this.countrycode ' + this.mobileCountryCode);
    console.log('Inside handleBlur : this.tempNumber ' + this.tempNumberMobile);
    // Validate input
    if (!this.mobileCountryCode || !this.tempNumberMobile) {
      this.hasInteractedMobile = false;
      this.validMobile = true;
      /* this.apiResponse = 'Both Mobile Country Code and Contact Number are required.';
       this.dispatchEvent(
           new ShowToastEvent({
               title: 'Error',
               message: 'Please enter valid country code first',
               variant: 'error',
           }),
       );*/
      return;
    }

    if (this.validTelephone && this.tempNumberMobile == this.tempNumber) {
      this.hasInteractedPhone = true;
      this.validMobile = true;
      this.record.Is_ValidMobileNumber__c = this.validMobile;
      console.log('Inside handleBlurMobile if: this.record.Is_ValidTelephone__c : ' + this.record.Is_ValidTelephone__c);

    } else {
      try {
        const response = await validatePhoneNumber({
          accessKey: this.accessKey,
          phoneNumber: this.mobileCountryCode + this.tempNumberMobile,
          countryCode: ''
        });
        // Null check for the response
        if (!response) {
          this.errorMessage = 'No response received from the API.';
          this.apiResponse = null;
          console.log('Inside handleBlur : errorMessage : ' + this.errorMessage);
          return;
        }

        console.log('Raw Response from Apex:', response);
        console.log('typeof Response from Apex:', typeof response);

        // Parse and map the response to the PhoneValidationResponse format
        const parsedResponse = JSON.parse(response);
        console.log('parsedResponse', parsedResponse);
        //console.log('Inside handleBlur : parsedResponse : '+JSON.stringify(this.parsedResponse));

        // Check if the parsed response is valid
        if (parsedResponse) {
          // Map response to the UI
          this.hasInteractedMobile = true;
          this.validMobile = parsedResponse.valid;
          /* mobNumber: parsedResponse.number,
           local_format: parsedResponse.local_format,
           international_format: parsedResponse.international_format,
           country_prefix: parsedResponse.country_prefix,
           country_code: parsedResponse.country_code,
           country_name: parsedResponse.country_name,
           location: parsedResponse.location,
           carrier: parsedResponse.carrier,
           line_type: parsedResponse.line_type,*/


          // Clear error message
          this.errorMessage = '';
        } else {
          this.errorMessage = 'Invalid response format from the API.';
          this.apiResponse = null;
          console.log('Inside handleBlur : errorMessage : ' + this.errorMessage);
        }
      } catch (error) {
        console.error('Error:', error);
        console.log('Inside handleBlur : catch : ' + this.error);
        this.apiResponse = 'Error validating phone number.';
      }

      console.log('Inside handleBlurMobile : valid : ' + this.validMobile);
      this.record.Is_ValidMobileNumber__c = this.validMobile;
      console.log('Inside handleBlurMobile : this.record.Is_ValidMobileNumber__c : ' + this.record.Is_ValidMobileNumber__c);
      if (!this.validMobile) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Please enter valid mobile number',
            variant: 'error',
          }),
        );
      }
    }


  }

  async handleEmailBlur(){  
    console.log('Inside handleEmailBlur');
    console.log('Inside handleEmailBlur : this.tempEmail '+this.tempEmail);
    // Validate input
    if (!this.tempEmail) {
        this.hasInteracted = false;
        this.validEmail = true;
        return;
    }

    if((this.validAccountEmail &&(this.tempAccountEmail == this.tempEmail)) || (this.validAlternateEmail &&(this.tempAlternateEmail == this.tempEmail))){
      console.log('Inside if to check duplication condition for Email : this.validAccountEmail '+this.validAccountEmail);
      console.log('Inside if to check duplication condition for Email : this.tempAccountEmail '+this.tempAccountEmail);
      console.log('Inside if to check duplication condition for Email : this.tempEmail '+this.tempEmail);
      console.log('Inside if to check duplication condition for Email : this.validAlternateEmail '+this.validAlternateEmail);
      console.log('Inside if to check duplication condition for Email : this.tempAlternateEmail '+this.tempAlternateEmail);
      console.log('Inside if to check duplication condition for Email : this.tempEmail '+this.tempEmail);
      this.hasInteracted = true;
      this.validEmail = true;
      console.log('Inside handleEmailBlur : valid : '+this.validEmail);
      this.record.Is_ValidEmail__c = this.validEmail;
      console.log('Inside handleEmailBlur : this.record.Is_ValidEmail__c : '+this.record.Is_ValidEmail__c);
    }else{
        try{
            const response = await validateEmail({
              emailAddress : this.tempEmail
          });
          // Null check for the response
          if (!response) {
              this.errorMessage = 'No response received from the API.';
              this.apiResponse = null;
              console.log('Inside handleEmailBlur : errorMessage : '+this.errorMessage);
              return;
          }
  
          console.log('Raw Response from Apex:', response);
          console.log('typeof Response from Apex:', typeof response);
  
          // Parse and map the response to the PhoneValidationResponse format
          const parsedResponse = JSON.parse(response);
          console.log('parsedResponse', parsedResponse);
          //console.log('Inside handleBlur : parsedResponse : '+JSON.stringify(this.parsedResponse));
  
          // Check if the parsed response is valid
          if (parsedResponse) {
              // Map response to the UI
                this.hasInteracted = true;
                this.validEmail = parsedResponse.is_deliverable;
                
              
  
              // Clear error message
              this.errorMessage = '';
          } else {
              this.errorMessage = 'Invalid response format from the API.';
              this.apiResponse = null;
              console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
          }
      } catch (error) {
          console.error('Error:', error);
          console.log('Inside handleEmailBlur : catch : '+this.error);
          this.apiResponse = 'Error validating Email Address.';
      }
      console.log('Inside handleEmailBlur : valid : '+this.validEmail);
      this.record.Is_ValidEmail__c = this.validEmail;
      console.log('Inside handleEmailBlur : this.record.Is_ValidEmail__c : '+this.record.Is_ValidEmail__c);
  
      if(!this.validEmail){
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please enter valid Email Address',
                  variant: 'error',
              }),
          );
      }
    }
  }
  async handleAccountEmailBlur(){  
    console.log('Inside handleAccountEmailBlur');
    console.log('Inside handleAccountEmailBlur : this.tempAccountEmail '+this.tempAccountEmail);
    // Validate input
    if(!this.tempAccountEmail){
      this.hasInteractedAccount = false;
      this.validAccountEmail = true;
      console.log('Inside handleAccountEmailBlur If !this.tempAccountEmail' +this.tempAccountEmail);
      this.record.Is_ValidAccountEmail__c = false;
      console.log('Inside handleAccountEmailBlur If !this.tempAccountEmail then this.record.Is_ValidAccountEmail__c : '+this.record.Is_ValidAccountEmail__c);
      return;
    }

    if((this.validEmail &&(this.tempEmail == this.tempAccountEmail)) || (this.validAlternateEmail &&(this.tempAlternateEmail == this.tempAccountEmail))){
      console.log('Inside if to check duplication condition for Account Email : this.validEmail '+this.validEmail);
      console.log('Inside if to check duplication condition for Account Email : this.tempEmail '+this.tempEmail);
      console.log('Inside if to check duplication condition for Account Email : this.tempAccountEmail '+this.tempAccountEmail);
      console.log('Inside if to check duplication condition for Account Email : this.validAlternateEmail '+this.validAlternateEmail);
      console.log('Inside if to check duplication condition for Account Email : this.tempAlternateEmail '+this.tempAlternateEmail);
      console.log('Inside if to check duplication condition for Account Email : this.tempAccountEmail '+this.tempAccountEmail);
      this.hasInteractedAccount = true;
      this.validAccountEmail = true;
      console.log('Inside handleAccountEmailBlur : valid : '+this.validAccountEmail);
      this.record.Is_ValidAccountEmail__c = this.validAccountEmail;
      console.log('Inside handleAccountEmailBlur : this.record.Is_ValidAccountEmail__c : '+this.record.Is_ValidAccountEmail__c);
    }else{
        try{
            const response = await validateEmail({
              emailAddress : this.tempAccountEmail
          });
          // Null check for the response
          if (!response) {
              this.errorMessage = 'No response received from the API.';
              this.apiResponse = null;
              console.log('Inside handleAccountEmailBlur : errorMessage : '+this.errorMessage);
              return;
          }
  
          console.log('Raw Response from Apex:', response);
          console.log('typeof Response from Apex:', typeof response);
  
          // Parse and map the response to the PhoneValidationResponse format
          const parsedResponse = JSON.parse(response);
          console.log('parsedResponse', parsedResponse);
          //console.log('Inside handleAccountEmailBlur : parsedResponse : '+JSON.stringify(this.parsedResponse));
  
          // Check if the parsed response is valid
          if (parsedResponse) {
              // Map response to the UI
                this.hasInteractedAccount = true;
                this.validAccountEmail = parsedResponse.is_deliverable;                
  
              // Clear error message
              this.errorMessage = '';
          } else {
              this.errorMessage = 'Invalid response format from the API.';
              this.apiResponse = null;
              console.log('Inside handleAccountEmailBlur : errorMessage : '+this.errorMessage);
          }
      } catch (error) {
          console.error('Error:', error);
          console.log('Inside handleAccountEmailBlur : catch : '+this.error);
          this.apiResponse = 'Error validating Account Email Address.';
      }
      console.log('Inside handleAccountEmailBlur : valid : '+this.validAccountEmail);
      this.record.Is_ValidAccountEmail__c = this.validAccountEmail;
      console.log('Inside handleAccountEmailBlur : this.record.Is_ValidAccountEmail__c : '+this.record.Is_ValidAccountEmail__c);
  
      if(!this.validAccountEmail){
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please enter valid Account Email Address',
                  variant: 'error',
              }),
          );
      }
    }
    if(!this.tempAccountEmail){
      console.log('Inside handleAccountEmailBlur end If ');
      this.record.Is_ValidAccountEmail__c = false;
      console.log('Inside handleAccountEmailBlur end If this.record.Is_ValidAccountEmail__c : '+this.record.Is_ValidAccountEmail__c);
    }
  }
  async handleAlternateEmailBlur(){  
    console.log('Inside handleAlternateEmailBlur');
    console.log('Inside handleAlternateEmailBlur : this.tempAlternateEmail '+this.tempAlternateEmail);
    // Validate input
    if (!this.tempAlternateEmail) {
        this.hasInteractedAlternate = false;
        this.validAlternateEmail = true;
        return;
    }

    if((this.validEmail &&(this.tempEmail == this.tempAlternateEmail)) || (this.validAccountEmail &&(this.tempAccountEmail == this.tempAlternateEmail))){
      console.log('Inside if to check duplication condition for Alternate Email : this.validEmail '+this.validEmail);
      console.log('Inside if to check duplication condition for Alternate Email : this.tempEmail '+this.tempEmail);
      console.log('Inside if to check duplication condition for Alternate Email : this.tempAlternateEmail '+this.tempAlternateEmail);
      console.log('Inside if to check duplication condition for Alternate Email : this.validAccountEmail '+this.validAccountEmail);
      console.log('Inside if to check duplication condition for Alternate Email : this.tempAccountEmail '+this.tempAccountEmail);
      console.log('Inside if to check duplication condition for Alternate Email : this.tempAlternateEmail '+this.tempAlternateEmail);
      this.hasInteractedAlternate = true;
      this.validAlternateEmail = true;
      console.log('Inside handleAlternateEmailBlur : valid : '+this.validAlternateEmail);
      this.record.Is_ValidOwnerEmail__c = this.validAlternateEmail;
      console.log('Inside handleAlternateEmailBlur : this.record.Is_ValidOwnerEmail__c : '+this.record.Is_ValidOwnerEmail__c);
    }else{
        try{
            const response = await validateEmail({
              emailAddress : this.tempAlternateEmail
          });
          // Null check for the response
          if (!response) {
              this.errorMessage = 'No response received from the API.';
              this.apiResponse = null;
              console.log('Inside handleAlternateEmailBlur : errorMessage : '+this.errorMessage);
              return;
          }
  
          console.log('Raw Response from Apex:', response);
          console.log('typeof Response from Apex:', typeof response);
  
          // Parse and map the response to the PhoneValidationResponse format
          const parsedResponse = JSON.parse(response);
          console.log('parsedResponse', parsedResponse);
          //console.log('Inside handleAlternateEmailBlur : parsedResponse : '+JSON.stringify(this.parsedResponse));
  
          // Check if the parsed response is valid
          if (parsedResponse) {
              // Map response to the UI
                this.hasInteractedAlternate = true;
                this.validAlternateEmail = parsedResponse.is_deliverable;                
  
              // Clear error message
              this.errorMessage = '';
          } else {
              this.errorMessage = 'Invalid response format from the API.';
              this.apiResponse = null;
              console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
          }
      } catch (error) {
          console.error('Error:', error);
          console.log('Inside handleAccountEmailBlur : catch : '+this.error);
          this.apiResponse = 'Error validating Alternate Email Address.';
      }
      console.log('Inside handleAlternateEmailBlur : valid : '+this.validAlternateEmail);
      this.record.Is_ValidOwnerEmail__c = this.validAlternateEmail;
      console.log('Inside handleAlternateEmailBlur : this.record.Is_ValidOwnerEmail__c : '+this.record.Is_ValidOwnerEmail__c);
  
      if(!this.validAlternateEmail){
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please enter valid Owner Email Address',
                  variant: 'error',
              }),
          );
      }
    }
  }

  // Helper method to show toast messages
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: variant,
        mode: 'dismissable',
      })
    );
  }



  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    const index = event.target.dataset.index;
    const label = this.files[index].label;

    let uploadedDocuments = this.uploadedDocuments;
    uploadedDocuments.push({
      versionId: uploadedFiles[0].contentVersionId,
      filelabel: label,
      fileName: uploadedFiles[0].name
    });
    this.uploadedDocuments = uploadedDocuments;

    let fileNameParts = event.detail.files[0].name.split(".");
    let extension = "." + fileNameParts[fileNameParts.length - 1].toLowerCase();
    console.log("~~~~" + extension);

    console.log("index : ", this.files[index].label);

    var recId = this.record.Id;
    this.files[index].uploaded = true;
    let newFile = { name: uploadedFiles[0].name };
    console.log("newFile : ", newFile);
    /*getDocID({recordID:recId, filelabel : label,fileName : uploadedFiles[0].name}).then(res =>{
            newFile.documentId  = res;
        });*/

    if (!this.files[index].uploadedFiles) this.files[index].uploadedFiles = [];
    this.files[index].uploadedFiles.push(newFile);
    console.log("", JSON.stringify(this.files[0].label));
  }

  validate() {
    let allValid = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    console.log("allValid1:", allValid);

    allValid &= this.validateFileUploads();

    return allValid;
  }

  validateFileUploads() {
    for (let file of this.files)
      if (file.required && !file.uploaded) {
        this.toast(
          "Error",
          "Please upload all the required documents.",
          "error"
        );
        return false;
      }
    return true;
  }

  toast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: "dismissable"
      })
    );
  }
  removeReceiptImage(event) {
    console.log(" event.currentTarget.dataset", event.currentTarget.dataset);
    var index = event.currentTarget.dataset.id;
    let fileIndex = event.currentTarget.dataset.fileIndex;
    console.log("this.files11", this.files[index].documentId);

    this.docToDelete.push(
      this.files[index].uploadedFiles[fileIndex].documentId
    );

    let tempUploadFiles = [...this.files[index].uploadedFiles];
    tempUploadFiles.splice(fileIndex, 1);

    if (!tempUploadFiles.length) this.files[index].uploaded = false;

    this.files[index].uploadedFiles = tempUploadFiles;
    // console.log('this.files', this.files);

    // var tempFiles = this.files;
    // this.files = [];
    // this.files = [...tempFiles];
  }

  reraInprogressChange(event) {
    console.log(
      "~~~~" +
      event.currentTarget.dataset.id +
      "___" +
      event.target.checked +
      "__" +
      event.target.value
    );
    this.makeReraNumberReadonly = event.target.checked;
    this.record[event.currentTarget.dataset.id] = "";
    if (event.target.checked) {
      this.record[event.currentTarget.dataset.id] = "Under Process";
    }
  }

  get isBrokerRera() {
    return this.record.Broker_Category__c === "Broker - RERA";
  }

  get isBuildingRequired() {
    return (
      this.record.Broker_Category__c === "Broker - RERA" ||
      this.record.Broker_Category__c === "Broker - UAE" ||
      this.record.Broker_Category__c === "Broker - Intnl" ||
      this.record.Broker_Category__c === "Sobha Connect - Intnl - Company" ||
      this.record.Broker_Category__c === "Sobha Connect - UAE - Company"
    );
  }

  get isNoBrokerReraUAE() {
    return (
      this.record.Broker_Category__c != "Broker - RERA" &&
      this.record.Broker_Category__c != "Broker - UAE"
    );
  }

  get isCompanyRegVisible() {
    return (
      this.record.Broker_Category__c === "Broker - UAE" ||
      this.record.Broker_Category__c === "Sobha Connect - UAE - Company"
    );
  }

  onKeyUpInputField(event) {
    this.record[event.target.name] = event.target.value.toUpperCase();
  }

  enableEdit() {
    this.makeReadonly = false;
  }

  handleModalPopup(event) {
    const getAction = event.currentTarget.dataset.action;
    if (getAction == "submit") {
      this.showConfirmModal = true;
    }
    if (getAction == "close") {
      this.showConfirmModal = false;
      this.isDisabled = true;
      this.isConfirmed = false;
    }
    if (getAction == "checked") {
      this.isConfirmed = event.target.checked;
      this.isDisabled = !(event.target.checked);
    }
  }
}