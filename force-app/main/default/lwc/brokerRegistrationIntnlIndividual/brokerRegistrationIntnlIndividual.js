import { LightningElement, api, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import brokerRegistrationCSS from "@salesforce/resourceUrl/brokerRegistrationCSS";
import { DOCS_MAP } from "c/brokerRegistrationConstants";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteDocuments from "@salesforce/apex/BrokerRegistrationFormExternalController.deleteDocuments";
import validateRegistrationNo from "@salesforce/apex/BrokerRegistrationFormExternalController.validateRegistrationNo";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import BrokerRegSource from "@salesforce/schema/Broker_Registration__c.Nationality__c";
import BrokerRegCountry from "@salesforce/schema/Broker_Registration__c.Country__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import BROKERREG_OBJECT from "@salesforce/schema/Broker_Registration__c";
import picklistValues from "@salesforce/apex/BrokerRegistrationFormExternalController.picklistValues";

import getDocID from "@salesforce/apex/BrokerRegistrationFormExternalController.getDocID";
import createBRDocumentHistory from "@salesforce/apex/BrokerRegistrationFormExternalController.createBRDocumentHistory";
import validateEmail from "@salesforce/apex/Nice_EmailValidationUtility.validateEmail";
import validatePhoneNumber from '@salesforce/apex/Nice_PhoneValidationUtility.validatePhoneNumber';
import MobileCountryCode from "@salesforce/schema/Broker_Registration__c.Mobile_Country_Code__c";
import TelephoneCountryCode from "@salesforce/schema/Broker_Registration__c.Telephone_Country_Code__c";


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
  "Telephone_Country_Code__c"
];

export default class BrokerRegistrationIntnlIndividual extends LightningElement {
  @track _record = {};
  @track files;
  @api today;
  @api showalternateemail = false;
  docToDelete = [];
  formType = "Registration";

  uploadedDocuments = [];
  @track isRegistrationValid = false;
  registrationError = "";

  @api options = {};
  nationalityPicklistVal = [];
  picklistCompanyList = [];
  /*validEmail = false;//for Email__c
  validEmailAlternate = false; // For Alternate_Email__c
  hasInteracted = false;
  hasInteractedAlternate = false;*/

  mobileCountryPicklistVal = [];
  telephoneCountryPicklistVal = [];
  telephoneCountryCodeRequired = false;
  mobileCountryCode;
  telephoneCountryCode;

  accessKey = '8be667c1c59b3f0ecf6b09e498b52c9d';
  validTelephone = false;
  tempNumber;
  contactnumber;
  hasInteractedPhone = false;

  validMobile = false;
  tempNumberMobile;
  contactnumberMobile;
  hasInteractedMobile = false;

  validEmail = false;
  tempEmail;
  emailId;
  hasInteracted = false;

  validAlternateEmail = false;
  tempAlternateEmail;
  alternateEmailID;
  hasInteractedAlternate = false;

  @api
  get record() {
    return this._record;
  }

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }

  @wire(getObjectInfo, { objectApiName: BROKERREG_OBJECT })
  brokerRegInfo;
  @wire(getPicklistValues, {
    recordTypeId: "$brokerRegInfo.data.defaultRecordTypeId",
    fieldApiName: BrokerRegSource
  })
  getPicklistValuesForField({ data, error }) {
    if (error) {
      console.error(error);
      this.toast("Error", "Some error occured" + JSON.stringify(error), "error");
      
    } else if (data) {
      this.nationalityPicklistVal = [...data.values];
    }
  }
  

  @wire(getPicklistValues, {
    recordTypeId: "$brokerRegInfo.data.defaultRecordTypeId",
    fieldApiName: BrokerRegCountry
  })
  getPickValuesForFields({ data, error }) {
    if (error) {
      console.error(error);
      this.toast("Error", "Some error occured" + JSON.stringify(error), "error");
    } else if (data) {
      this.picklistCompanyList = [...data.values];
    }
  }

  set record(data) {
    this._record = JSON.parse(JSON.stringify(data));
  }

  connectedCallback() {
    loadStyle(this, brokerRegistrationCSS);

    if (this.record?.Broker_Category__c !== "Broker - Intnl") {
      // Default case where Broker Category is not "Broker - Intnl"
      this.files = JSON.parse(
        JSON.stringify(DOCS_MAP[this.record.Broker_Category__c]?.files || [])
      );
    } else if (
      this.record.Broker_Category__c === "Broker - Intnl" &&
      this.record.Sub_Category__c === "Individual"
    ) {
      // Specific case for "Broker - Intnl" with "Individual" sub-category
      this.files = JSON.parse(
        JSON.stringify(DOCS_MAP["Broker - Intnl-Individual"]?.files || [])
      );
    } else {
      // Optional: Add a fallback case if neither condition is met
      console.warn(
        "No matching document set found for provided category/subcategory."
      );
      this.files = [];
    }
    console.log("connectedCallback 3");
    console.log(JSON.stringify(this.files, null, 2));
    //console.log(JSON.stringify(this.files, null, 2));
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
      let tempName = this.record.First_Name__c;
      let tempObj = this.record;
      Object.keys(tempObj).forEach(function (key) {
        if (!defaultFieldApi.includes(key)) {
          delete tempObj[key];
        }
      });
      tempObj.Name_as_per_trade_license__c = tempName;
      console.log("~~~~" + JSON.stringify(tempObj));

      this.record = tempObj;
    } else {
      this.formType = "Renewal";
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

        if(this.record.Mobile__c!=undefined && this.record.Mobile__c && this.record.Mobile_Country_Code__c!=undefined && this.record.Mobile_Country_Code__c){
          this.tempNumberMobile = this.record.Mobile__c;
          this.mobileCountryCode = this.record.Mobile_Country_Code__c;
          this.handleBlurMobile();
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

  /*async handleEmailBlur(event) {
    const fieldName = event.target.name; // Get the field name
    const emailValue = event.target.value; // Get the email value from the field

    console.log(`handleEmailBlur invoked for field: ${fieldName}, value: ${emailValue}`);

    // Set interaction flag for the specific field
    if (fieldName === "Email__c" && this.emailValue ==undefined) {
      this.hasInteracted = false;
      console.log("Interaction flag set for Account_Email__c.");
    }else if (fieldName === "Email__c" && this.emailValue !=undefined) {
      this.hasInteracted = true;
      console.log("Interaction flag set for Account_Email__c.");
    }else if (fieldName === "Alternate_Email__c" && this.emailValue ==undefined) {
      this.hasInteractedAlternate = false;
      console.log("Interaction flag set for Alternate_Email__c.");
    }else if (fieldName === "Alternate_Email__c" && this.emailValue !=undefined) {
      this.hasInteractedAlternate = true;
      console.log("Interaction flag set for Alternate_Email__c.");
    }

    // Validate input
    if (!emailValue) {
      console.log(`${fieldName} is empty. Skipping validation.`);
      return;
    }

    try {
      console.log(`Validating email for field: ${fieldName}, email: ${emailValue}`);
      const response = await validateEmail({ emailAddress: emailValue });

      if (!response) {
        console.error(`No response received for field: ${fieldName}`);
        return;
      }

      console.log(`Raw response for field ${fieldName}:`, response);

      const parsedResponse = JSON.parse(response);
      console.log(`Parsed response for field ${fieldName}:`, parsedResponse);

      const isValid = parsedResponse.is_deliverable;
      console.log(`Validation result for field ${fieldName}:`, isValid);

      // Update validation status for the respective field and show toast if invalid
      if (fieldName === "Email__c") {
        this.hasInteracted = true;
        this.validEmail = isValid;
        this.record.Is_ValidEmail__c = this.validEmail;
        console.log(`Updated validEmail for Email__c: ${this.validEmail}`);
        if (!isValid) {
          this.showToast('Error', 'Please enter a valid Email Address', 'error');
          console.log('Invalid Email__c. Toast message displayed.');
        }
      }else if (fieldName === "Alternate_Email__c") {
        this.hasInteractedAlternate = true;
        this.validEmailAlternate = isValid;
        this.record.Is_ValidAlternateEmail__c = this.validEmailAlternate;
        console.log(`Updated validEmailAlternate for Alternate_Email__c: ${this.validEmailAlternate}`);
        if (!isValid) {
          this.showToast('Error', 'Please enter a valid Owner Email', 'error');
          console.log('Invalid Alternate_Email__c. Toast message displayed.');
        }
      }
    } catch (error) {
      console.error(`Error validating email for field ${fieldName}:`, error);
    }
  }*/
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
              
                this.validEmail = parsedResponse.is_deliverable;
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

  clearContactNumber() {
    // Wait for DOM to update if necessary
    Promise.resolve().then(() => {
        const contactNumberField = this.template.querySelector('lightning-input[name="Telephone__c"]');
        
        console.log('Inside clearContactNumber : '+contactNumberField);
        if (contactNumberField) {
            console.log('Inside clearContactNumber');
            contactNumberField.value = ''; // Clear the value
            this.validTelephone = false;
        } else {
            console.error('Contact number field not found in DOM.');
        }
    });
}

  async handleAlternateEmailBlur(){  
    console.log('Inside handleAlternateEmailBlur');
    console.log('Inside handleAlternateEmailBlur : this.tempAlternateEmail '+this.tempAlternateEmail);
    // Validate input
    if (!this.tempAlternateEmail) {
        this.hasInteractedAlternate = false;
        this.validAlternateEmail = true;
        this.record.Is_ValidOwnerEmail__c = false;
      console.log('Inside handleAccountEmailBlur If !this.tempAlternateEmail then this.record.Is_ValidOwnerEmail__c : '+this.record.Is_ValidOwnerEmail__c);
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

  handleSubmit(event) {
    if (this.isRegistrationValid == false) {
      this.toast("Error", "Please validate Registration Number", "error");
      return;
    } else if (!this.validate()) {
      return;
    }/*else if (!this.validEmail) {
      this.showToast("Error", "Please enter a valid Email Address", "error");
      console.log("Invalid main email: ", this.validEmail);
      return;
    }else if (!this.validEmailAlternate && this.showalternateemail){
      this.showToast("Error", "Please enter a valid Owner Email", "error");
      console.log("Invalid alternate email: ", this.validEmailAlternate);
      return;
    }*/else if(!this.validMobile){
      this.showToast("Error", "Please enter a valid Mobile Number", "error");
      console.log("Invalid Mobile Number: ", this.validMobile);
      return;
    }else if(/*this.tempNumber != undefined && */!this.validTelephone){
      this.showToast("Error", "Please enter a valid Country code", "error");
      console.log("Invalid Telephone Number: ", this.validTelephone);
      return;
    }else if(this.tempNumber && !this.telephoneCountryCode){
      this.showToast("Error", "Please enter valid country code first", "error");
      console.log("Invalid Country Number: ", this.telephoneCountryCode);
      return;
    }/*else if(!this.tempNumber && this.telephoneCountryCode){
      this.showToast("Error", "Please enter valid telephone number", "error");
      console.log("Invalid telephone number: ", this.tempNumber);
      return;
    }*/else if (this.tempEmail != undefined && !this.validEmail) {
      this.showToast("Error", "Please enter a valid Email Address", "error");
      console.log("Invalid main email: ", this.validEmail);
      return;
    }else if (this.tempAlternateEmail !=undefined && !this.validAlternateEmail && this.showalternateemail){
      this.showToast("Error", "Please enter a valid Owner Email", "error");
      console.log("Invalid alternate email: ", this.validEmailAlternate);
      return;
    }
    console.log("All validations passed. Proceeding with form submission.");
    if (this.uploadedDocuments.length > 0) {
      var recId = this.record.Id;
      createBRDocumentHistory({
        brId: recId,
        docList: JSON.stringify(this.uploadedDocuments)
      })
        .then((result) => {})
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
          this.toast("Error", "Some error occured" + JSON.stringify(error), "error");
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

  handleChange(event) {
    console.log("event.target.name:", event.target.name);
    console.log("event.target.value:", event.target.value);
    this.record[event.target.name] = event.target.value;
    if (event.target.name === "Registration_Number__c" && event.target.value) {
      this.isRegistrationValid = false;
      console.log("isResValid:", this.isRegistrationValid);
    }// Check if Telephone Number is entered and Country Code is missing    
    else if(event.target.name ==="Telephone_Country_Code__c" && event.target.value){
      this.record.Telephone__c = '';
      this.telephoneCountryCodeRequired = false;
      this.telephoneCountryCode = event.target.value;
      this.hasInteractedPhone = false;
      //this.validTelephone = false;
      //console.log('this.telephoneCountryCode=',this.telephoneCountryCode);
    }
    else if(event.target.name ==="Mobile_Country_Code__c" && event.target.value){
      this.mobileCountryCode = event.target.value;
      //console.log('this.mobileCountryCode=',this.mobileCountryCode);
    }else if (event.target.name === "Telephone__c") {
      if(!this.record.Telephone_Country_Code__c)
      this.telephoneCountryCodeRequired = true;
      this.contactnumber = event.target.value;
      console.log('this.contactnumber 1st : '+this.contactnumber);
      this.tempNumber = this.contactnumber;
      console.log('this.contactnumber 2nd : '+this.contactnumber);   
      this.hasInteractedPhone = true;
      this.validTelephone = false;
    } else if (event.target.name === "Mobile__c") {
      this.contactnumberMobile = event.target.value;
      console.log('this.contactnumberMobile 1st : '+this.contactnumberMobile);
      this.tempNumberMobile = this.contactnumberMobile;
      console.log('this.contactnumberMobile 2nd : '+this.contactnumberMobile);   
      this.hasInteractedMobile = true;
      this.validMobile = false;
    }else if (event.target.name === "Email__c") {
      this.emailId = event.target.value;
      console.log('this.emailId 1st : '+this.emailId);
      this.tempEmail = this.emailId;
      console.log('this.emailId 2nd : '+this.emailId);  
      this.hasInteracted = true;
      this.validEmail = false;
    }else if (event.target.name === "Alternate_Email__c") {
      this.alternateEmailID = event.target.value;
      console.log('this.alternateEmailID 1st : '+this.alternateEmailID);
      this.tempAlternateEmail = this.alternateEmailID;
      console.log('this.alternateEmailID 2nd : '+this.alternateEmailID);  
      this.hasInteractedAlternate = true;
      this.validAlternateEmail = false;
    }
  }

  async handleBlurPhone() {
    //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

    console.log('Inside handleBlur');
    console.log('Inside handleBlur : this.telephoneCountryCode '+this.telephoneCountryCode);
    console.log('Inside handleBlur : this.tempNumber '+this.tempNumber);

    if(this.tempNumber && this.telephoneCountryCode==undefined){
      this.showToast('Error','Please enter valid country code first','error'); 
      this.hasInteractedPhone = true;
      this.validTelephone = false;
    }

    // Validate input
    if (!this.telephoneCountryCode || !this.tempNumber) {
        this.hasInteractedPhone = false;
        this.validTelephone = false;
        this.record.Is_ValidTelephone__c = false;
        this.telephoneCountryCodeRequired = false;
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

     // Validate input
     if (this.telephoneCountryCode && !this.tempNumber) {
      this.hasInteractedPhone = false;
      this.validTelephone = true;
      this.record.Is_ValidTelephone__c = true;
      this.telephoneCountryCodeRequired = false;
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


    if(this.validMobile && this.tempNumberMobile == this.tempNumber && this.telephoneCountryCode!=undefined){
      this.hasInteractedPhone = true;
      this.validTelephone = true;
      this.record.Is_ValidTelephone__c = this.validTelephone;
      console.log('Inside handleBlurPhone if: this.record.Is_ValidTelephone__c : '+this.record.Is_ValidTelephone__c);
    }else{
      try {
        const response = await validatePhoneNumber({
            accessKey: this.accessKey,
            phoneNumber: this.telephoneCountryCode+this.tempNumber,
            countryCode:''
        });
        // Null check for the response
        if (!response) {
            this.errorMessage = 'No response received from the API.';
            this.apiResponse = null;
            console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
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
               this.hasInteractedPhone = true;
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
            console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
        }
    } catch (error) {
        console.error('Error:', error);
        console.log('Inside handleBlur : catch : '+this.error);
        this.apiResponse = 'Error validating phone number.';
    }
    console.log('Inside handleBlur : valid : '+this.validTelephone);
    this.record.Is_ValidTelephone__c = this.validTelephone;
    console.log('Inside handleBlurPhone : this.record.Is_ValidTelephone__c : '+this.record.Is_ValidTelephone__c);

    if(!this.validTelephone){
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

async handleBlurMobile() {
  //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

  console.log('Inside handleBlur');
  console.log('Inside handleBlur : this.countrycode '+this.mobileCountryCode);
  console.log('Inside handleBlur : this.tempNumber '+this.tempNumberMobile);
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

  if(this.validTelephone && this.tempNumberMobile == this.tempNumber){
    this.hasInteractedPhone = true;
    this.validMobile = true;
    this.record.Is_ValidMobileNumber__c = this.validMobile;
    console.log('Inside handleBlurMobile if: this.record.Is_ValidTelephone__c : '+this.record.Is_ValidTelephone__c);

  }else{
    try {
      const response = await validatePhoneNumber({
          accessKey: this.accessKey,
          phoneNumber: this.mobileCountryCode+this.tempNumberMobile,
          countryCode:''
      });
      // Null check for the response
      if (!response) {
          this.errorMessage = 'No response received from the API.';
          this.apiResponse = null;
          console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
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
          console.log('Inside handleBlur : errorMessage : '+this.errorMessage);
      }
    } catch (error) {
      console.error('Error:', error);
      console.log('Inside handleBlur : catch : '+this.error);
      this.apiResponse = 'Error validating phone number.';
    }
    console.log('Inside handleBlur : valid : '+this.validMobile);
    this.record.Is_ValidMobileNumber__c = this.validMobile;
    console.log('Inside handleBlurMobile : this.record.Is_ValidMobileNumber__c : '+this.record.Is_ValidMobileNumber__c);
    

    if(!this.validMobile){
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


  handleUploadFinished(event) {
    const index = event.target.dataset.index;
    // const label = event.target.dataset.label;
    console.log("index : ", index);
    const uploadedFiles = event.detail.files;
    var recId = this.record.Id;
    this.files[index].uploaded = true;
    let newFile = { name: uploadedFiles[0].name };

    const label = this.files[index].label;

    let uploadedDocuments = this.uploadedDocuments;
    uploadedDocuments.push({
      versionId: uploadedFiles[0].contentVersionId,
      filelabel: label,
      fileName: uploadedFiles[0].name
    });
    this.uploadedDocuments = uploadedDocuments;

    /*getDocID({recordID:recId}).then(res =>{
            newFile.documentId  = res;
        });*/

    if (!this.files[index].uploadedFiles) this.files[index].uploadedFiles = [];
    this.files[index].uploadedFiles.push(newFile);
  }

  validate() {
    let allValid = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

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

  get isNationalityRequired() {
    return (
      this.record.Broker_Category__c === "Sobha Connect - UAE - Individual" ||
      this.record.Broker_Category__c === "Sobha Connect - Intnl - Individual"
    );
  }

  onKeyUpInputField(event) {
    this.record[event.target.name] = event.target.value.toUpperCase();
  }
}