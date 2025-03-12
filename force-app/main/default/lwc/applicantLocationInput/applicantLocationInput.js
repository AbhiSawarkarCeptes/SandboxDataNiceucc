import { LightningElement, api, wire, track } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCountries from "@salesforce/apex/ApplicantLocationInputController.getCountryList";
import getStates from "@salesforce/apex/ApplicantLocationInputController.getStates";
import getCities from "@salesforce/apex/ApplicantLocationInputController.getCities";
import { CloseActionScreenEvent } from 'lightning/actions';

// Define the fields to retrieve from the record
const FIELDS = ["Object__c.Country__c", "Object__c.State__c", "Object__c.City__c"];

export default class ApplicantLocationInput extends LightningElement {

  @track countryOptions = [];
  @track stateOptions = [];
  @track cityOptions = [];
  error;
  @track country = "";
  @track state = "";
  @track city = "";
  @track isUpdating = false;

  // Watch for changes in recordId
  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    if (this._recordId) {
      this.loadRecord();
    }
  }

  // Dynamically fetch current record
  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wiredRecord({ error, data }) {
    if (data) {
      this.country = data.fields.Country__c.value;
      this.state = data.fields.State__c.value;
      this.city = data.fields.City__c.value;
      this.loadStates(this.country);
      this.loadCities(this.state);
      console.log('currentRecord:', data);
      console.log('this.country:', this.country);
    } else if (error) {
      this.error = error;
    }
  }

  connectedCallback() {
    this.loadCountries();
  }

  loadCountries() {
    getCountries()
      .then((result) => {
        this.countryOptions = result;
        console.log('getCountries result', result);

        if (this.recordId) {
          this.callOnParamLoad();
        }
      })
      .catch((error) => {
        this.error = error;
      });
  }

  loadRecord() {
    // Ensure that states and cities are loaded when recordId is set
    if (this.country) {
      this.loadStates(this.country);
    }
    if (this.state) {
      this.loadCities(this.state);
    }
  }

  callOnParamLoad() {
    // Ensure states and cities are loaded based on the current record values
    if (this.country) {
      this.loadStates(this.country);
    }
    if (this.state) {
      this.loadCities(this.state);
    }
  }

  handleCountryChange(event) {
    this.country = event.target.value;
    this.loadStates(this.country);
    this.cityOptions = [];
  }

  loadStates(country) {
    getStates({ country })
      .then((result) => {
        this.stateOptions = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleStateChange(event) {
    this.state = event.target.value;
    this.loadCities(this.state);
  }

  loadCities(state) {
    getCities({ state })
      .then((result) => {
        this.cityOptions = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleCityChange(event) {
    this.city = event.target.value;
  }

  handleUpdate() {
    if(this.country && this.state && this.city){
      this.isUpdating = true; // Show updating indicator
      console.log('Country, State, City:', this.country, this.state, this.city);
      const fields = {};
      fields.Id = this.recordId;
      fields.Country__c = this.country;
      fields.State__c = this.state;
      fields.City__c = this.city;
      fields.Mailing_Country__c = this.country;
      fields.Mailing_State__c = this.state;
      fields.Mailing_City__c = this.city;

      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Address updated successfully',
              variant: 'success'
            })
          );
          this.closeModal();
        })
        .catch(error => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error updating record',
              message: error.body.message,
              variant: 'error'
            })
          );
          this.closeModal();
        });
    }
    else{
      this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please fill all the fields',
              variant: 'error'
            })
          );
    }
  }

  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}