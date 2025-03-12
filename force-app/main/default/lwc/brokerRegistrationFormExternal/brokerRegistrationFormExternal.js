import { LightningElement, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import brokerRegistrationCSS from "@salesforce/resourceUrl/brokerRegistrationCSS";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateRecord from "@salesforce/apex/BrokerRegistrationFormExternalController.updateRecord";
import getRecord from "@salesforce/apex/BrokerRegistrationFormExternalController.getRecord";

export default class BrokerRegistrationFormExternal extends LightningElement {
  objectApiName = "Broker_Registration__c";
  brokerCategory = "";
  brokerSubCategory = "";
  recordId;
  showSpinner;
  @track showCmp;
  showSuccess = false;
  today;
  @track record = {};
  options = {};
  @track BrokerCreatedDate;
  @track RegistrationNumber;
  @track recordForUI = {
    Name: undefined,
    BrokerCreatedDate: undefined,
    RegistrationNumber: undefined
  };
  connectedCallback() {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    this.recordId = urlParams.get("id");

    this.showSpinner = true;

    getRecord({ recordId: this.recordId })
      .then((data) => {
        console.log("inside get records" + JSON.stringify(data));
        this.record = data.record;
        this.today = data.today;
        this.brokerCategory = this.record.Broker_Category__c;
        this.brokerSubCategory = this.record.Sub_Category__c
          ? this.record.Sub_Category__c
          : "";
        this.options.country = data.countryOptions;
        this.options.city = data.cityOptions;
        this.showCmp = true;
        this.recordForUI.Name = this.record.Name;
        this.recordForUI.BrokerCreatedDate = this.record.Broker_Created_Date__c;
        this.recordForUI.RegistrationNumber =
          this.record.Registration_Number__c;
        console.log("last line get records");
      })
      .catch((error) => {
        this.toast("Error", error.body.message, "error");
        console.log("get records catch: " + error.body.message);
      })
      .finally(() => {
        console.log("get records finally: ");
        this.showSpinner = false;
      });

    loadStyle(this, brokerRegistrationCSS);
  }

  handleSubmit(event) {
    this.record = event.detail.record;
    this.showSpinner = true;
    //console.log('record -'+JSON.stringify(this.record));
    updateRecord({ record: this.record })
      .then((data) => {
        console.log("record inside -");
        // this.record = data;
        this.recordForUI.Name = data.Name;
        this.recordForUI.BrokerCreatedDate = data.Broker_Created_Date__c;
        this.recordForUI.RegistrationNumber = data.Registration_Number__c;
        this.toast("Success", "Registration successful", "success");
        this.dispatchEvent(event);
        this.showCmp = false;
        this.showSuccess = true;
        //window.open('/s/registration-successful', '_self');
      })
      .catch((error) => {
        console.log("~~~Error");
        console.log(error);
        this.toast("Error", error.body.message, "error");
      })
      .finally(() => (this.showSpinner = false));
  }

  handleChange(event) {
    this.record[event.target.name] = event.target.value;
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

  // get showBrokerRera() {
  //     return this.brokerCategory === 'Broker – RERA';
  // }

  get showIntnlCompany() {
    return (
      this.brokerCategory === "Sobha Connect - Intnl - Company" ||
      this.brokerCategory === "Broker - RERA" ||
      this.brokerCategory === "Broker - UAE" ||
      (this.brokerCategory === "Broker - Intnl" &&
        this.brokerSubCategory === "Company") ||
      this.brokerCategory === "Sobha Connect - UAE - Company"
    );
  }

  get showIntnlIndividual() {
    return (
      this.brokerCategory === "Sobha Connect - Intnl - Individual" ||
      this.brokerCategory === "Sobha Connect - UAE - Individual" ||
      (this.brokerCategory === "Broker - Intnl" &&
        this.brokerSubCategory === "Individual")
    );
  }
}