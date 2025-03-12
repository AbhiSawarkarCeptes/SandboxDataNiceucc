import { LightningElement, track, wire } from "lwc";
import Id from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getUserManagerDetail from "@salesforce/apex/BrokerRegistrationController.getUserManagerDetails";
import createRecord from "@salesforce/apex/BrokerRegistrationController.createRecord";
import picklistValues from "@salesforce/apex/BrokerRegistrationFormExternalController.picklistValues";
//import validateRegistrationNo from '@salesforce/apex/BrokerRegistrationController.validateRegistrationNo';
import getReportingManger from "@salesforce/apex/BrokerRegistrationController.getReportingManger";
import { DOCS_MAP } from "c/brokerRegistrationConstants";

export default class BrokerRegistrationForm extends NavigationMixin(
  LightningElement
) {
  objectApiName = "Broker_Registration__c";
  showSpinner = false;
  recordId;
  @track error;
  @track userId = Id;
  @track currentUserName;
  @track currentUserEmail;
  @track currentIsActive;
  @track currentUserAlias;
  CHRMmanagerEmail;
  brokerCategoryOptions = [];
  brokerSubCategoryOptions = [];
  mobileCountryCodeOptions = [];
  @track record = {};
  isSubCategoryVisibile = false;
  showLicenseRegSection = false;
  tempId;
  regPassportLabel;
  tradeLicenseList = [
    "Broker - RERA",
    "Broker - UAE",
    "Sobha Connect - UAE - Company"
  ];
  regNumberList = ["Broker - Intnl", "Sobha Connect - Intnl - Company"];
  passportList = [
    "Sobha Connect - UAE - Individual",
    "Sobha Connect - Intnl - Individual"
  ];

  connectedCallback() {
    console.log("~~~~~" + this.userId);
    getUserManagerDetail({
      Managerid: this.userId
    })
      .then((result) => {
        var userarry = [];
        userarry = result;
        for (let i = 0; i < userarry.length; i++) {
          //console.log('mohit' + userarry[i].Manager.Email);
          // this.record.CHRM_Manager_Email__c = userarry[i].Manager.Email;
          if (userarry[i].Email) {
            this.record.CHRM_Manager_Email__c = userarry[i].Email;
            this.record.Email__c = userarry[i].Email;
          }
          if (userarry[i].Manager.Manager.Email) {
            this.CHRMmanagerHead = userarry[i].Manager.Manager.Email;
          }
        }
        console.log(result);
      })
      .catch((error) => {
        console.log("error:", error);
      });

    this.showSpinner = true;
    picklistValues({
      objectName: "Broker_Registration__c",
      fieldName: "Broker_Category__c"
    })
      .then((result) => {
        this.brokerCategoryOptions = result;
      })
      .catch((error) => {
        console.log("error:", error);
      });
    //.finally(() => this.showSpinner = false);
    picklistValues({
      objectName: "Broker_Registration__c",
      fieldName: "Sub_Category__c"
    })
      .then((result) => {
        this.brokerSubCategoryOptions = result;
      })
      .catch((error) => {
        console.log("error:", error);
      });

    picklistValues({
      objectName: "Broker_Registration__c",
      fieldName: "Mobile_Country_Code__c"
    })
      .then((result) => {
        this.mobileCountryCodeOptions = result;
      })
      .catch((error) => {
        console.log("error:", error);
      });
  }

  formOnLoaded() {
    this.showSpinner = false;
  }

  handleSubmit(event) {
    if (!this.validate()) {
      return;
    }
    if (!this.validateInputField()) {
      return;
    }
    this.showSpinner = true;
    this.validateRegPassportDetails();
  }

  validateRegPassportDetails() {
    let catgType = "NotBroker";
    if (this.record.Broker_Category__c.startsWith("Broker")) {
      catgType = "Broker";
    }

    // this.record.Registration_Number__c='';
    this.createBrokerRecord();
  }

  createBrokerRecord() {
    this.showSpinner = true;
    createRecord({
      record: this.record
    })
      .then((result) => {
        this.record = result;
        this.handleSuccess();
      })
      .catch((error) => {
        console.log("error:", error);
        const event = new ShowToastEvent({
          title: "Error",
          message: error.body ? error.body.message : error.message,
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
      })
      .finally(() => (this.showSpinner = false));
  }

  handleChange(event) {
    this.record[event.target.name] = event.target.value;
    /*if(event.target.name=='Broker_Category__c' && event.target.value!=null){
            this.showLicenseRegSection = true;
            this.populateRegistrationLabel(event.target.value);

            
            
        }*/
    if (event.target.name == "Sales_Manager__c") {
      this.populateReportingManager(event.target.value);
    }
    if (event.target.name == "Broker_Category__c") {
      if (this.record[event.target.name] == "Broker - Intnl") {
        this.isSubCategoryVisibile = true;
      } else {
        this.isSubCategoryVisibile = false;
      }
    }
    
  }

  populateRegistrationLabel(bCategory) {
    // console.log('~~~~'+bCategory);
    // bCategory= bCategory.replaceAll( '\\s+', '');6
    console.log(
      "~~Label: " + DOCS_MAP[this.record.Broker_Category__c]?.registrationLabel
    );
    this.regPassportLabel = DOCS_MAP[bCategory]?.registrationLabel;

    // if(this.tradeLicenseList.includes(bCategory)){
    //     this.regPassportLabel ='Trade license';
    // } else if(this.regNumberList.includes(bCategory)){
    //     this.regPassportLabel ='Registration Number';
    // } else if(this.passportList.includes(bCategory)){
    //     this.regPassportLabel ='Passport';
    // } else {
    //     this.regPassportLabel ='Registration/Passport Number';
    // }
  }

  populateReportingManager(saleManagerId) {
    if (saleManagerId != null && saleManagerId != "") {
      this.showSpinner = true;
      getReportingManger({ salesManagerId: saleManagerId })
        .then((result) => {
          console.log("~~~Res: " + result);
          this.record.Reporting_manager__c = result;
          this.showSpinner = false;
        })
        .catch((error) => {
          console.log("error:", error);
          const event = new ShowToastEvent({
            title: "Error",
            message: error.body ? error.body.message : error.message,
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(event);
          this.showSpinner = false;
        });
    }
  }

  // processLicenseRegSection(categoryValue){
  //     if(categoryValue.startsWith('Broker')){

  //     } else if(categoryValue.startsWith('Sobha')) {

  //     }
  //     this.showLicenseRegSection = true;
  // }

  validate() {
    let allValid = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    return allValid;
  }

  validateInputField() {
    let iserror = false;
    this.template
      .querySelectorAll("lightning-input-field")
      .forEach((element) => {
        if (element.value == null || element.value == "") {
          element.reportValidity();
          iserror = false;
          return false;
        } else {
          iserror = true;
        }
      });
    return iserror;
  }

  handleSuccess(event1) {
    this.showSpinner = false;
    const event = new ShowToastEvent({
      title: "Success",
      message: "Registration successful",
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(event);
    this.showSpinner = false;
    this.recordId = this.record.Id;

    this.clearValues();
    this.navigateToWebPage();
  }
  navigateToWebPage() {
    // Navigate to a URL
    this[NavigationMixin.Navigate](
      {
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          actionName: "view"
        }
      },
      true // Replaces the current page in your browser history with the URL
    );
  }

  clearValues() {
    this.record.Id = null;
    this.record.First_Name__c = null;
    this.record.Last_Name__c = null;
    this.record.Email__c = null;
    this.record.Mobile__c = null;
    this.record.Broker_Category__c = null;
    this.record.Registration_Number__c = null;
    this.record.Sales_Manager__c = null;
    this.record.Reporting_manager__c = null;
  }

  handleError(event) {
    let message = event.detail.detail;
    //do some stuff with message to make it more readable
    console.log("message", message);
  }

  onKeyUpInputField(event) {
    this.record[event.target.name] = event.target.value.toUpperCase();
  }
}