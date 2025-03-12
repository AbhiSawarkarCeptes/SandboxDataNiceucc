import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getBookingData from '@salesforce/apex/CRMSiteVisitController.getBookingData';
import getRecordType from '@salesforce/apex/CRMSiteVisitController.getRecordTypeId';
export default class createCRMSiteVisitForm extends NavigationMixin(LightningElement) {

    @track showSpinner = false;
    @track Customer_Registration__c = {
        Booking__c: null,
        Unit__c: null,
        First_Name__c: null,
        Last_Name__c: null,
        Mobile_Number__c: null,
        Email_Address__c: null,
        Nationality__c: null,
        Residential_Status__c: null,
        City__c: null,
        Visitor_name__c: null,
        Address__c: null,
        RecordTypeId: null,
        Visitor_Email_address__c: null,
        Category__c: null,
        Visitor_Mobile_number__c: null,
        Vertical__c: null,
        Status__c: 'Open',
        CRM_Executive__c: null,
        Executive_attended__c: null,
        Purpose_of_visit__c: null,
        Remarks__c: null,
    }

    connectedCallback() {
        this.fetchRecordType();
    }

    handleBookingChange(event) {
        if (event.target.value != null && event.target.value != '') {
            this.Customer_Registration__c.Booking__c = event.target.value;
            this.fetchBookingData(event.target.value, null);
        } else {
            this.Customer_Registration__c.Booking__c = null;
            this.handleReset();
        }
    }

    handleUnitChange(event) {
        if (event.target.value != null && event.target.value != '') {
            this.Customer_Registration__c.Unit__c = event.target.value;
            this.fetchBookingData(null, event.target.value);
        } else {
            this.Customer_Registration__c.Unit__c = null;
            this.handleReset();
        }
    }

    handleChange(event) {
        //this.firstname = event.target.value;
        console.log('event==', event);
        console.log('event.target.name : ' + event.target.name);
        console.log('event.target.value : ' + event.detail.value);
        if (event.target.name == 'Nationality') {
            this.nationality = event.target.value;
        }  else if (event.target.name == 'Country') {
            this.country = event.detail.value;
        }  else if (event.target.name == 'Remarks') {
            this.Remarks = event.target.value;
        }  else if (event.target.name == 'mobileNumber') {
            this.mobileNumber = event.target.value;
        } 
    }

    fetchBookingData(bookingParam, unitParam) {
        this.showSpinner = true;
        console.log(' booking : ', bookingParam, ' unit : ', unitParam);
        getBookingData({
            bookingId: bookingParam,
            unitId: unitParam
        }).then(result => {
            console.log('result booking : ',JSON.parse(JSON.stringify(result)));
                this.showSpinner = false;
                let firstName = null;
                let lastName = null;
                let Name = result.Primary_Applicant_Name__c !== undefined ? result.Primary_Applicant_Name__c : '';
                console.log('result booking : ', result.CRM_Executive__c);
                firstName = Name.split(' ')[0].includes('Mr.') ? Name.split(' ')[1] : Name.split(' ')[0];//Name;               
                let lastname = ' ';
                for (var j = 0; j < Name.split(' ').length; j++) {
                    if (Name.split(' ')[0].includes('Mr.') && (Name.split(' ')[j + 2] != undefined)) {
                        lastname += Name.split(' ')[j + 2] + ' ';
                    } else if (!Name.split(' ')[0].includes('Mr.') && Name.split(' ')[j + 1] != undefined) {
                        lastname += Name.split(' ')[j + 1] + ' ';
                    }
                }
                lastName = lastname;
                this.Customer_Registration__c.Booking__c = (this.Customer_Registration__c.Booking__c == null || this.Customer_Registration__c.Booking__c == '') ? result.Id !== undefined ? result.Id : '' : this.Customer_Registration__c.Booking__c != result.Id ? result.Id : this.Customer_Registration__c.Booking__c;
                this.Customer_Registration__c.Unit__c = (this.Customer_Registration__c.Unit__c == null || this.Customer_Registration__c.Unit__c == '') ? result.Unit__c !== undefined ? result.Unit__c : '' : this.Customer_Registration__c.Unit__c != result.Unit__c ? result.Unit__c : this.Customer_Registration__c.Unit__c;
                this.Customer_Registration__c.First_Name__c = firstName;
                this.Customer_Registration__c.Last_Name__c = lastname;
                this.Customer_Registration__c.Mobile_Number__c = result.PrimaryMobileNumber__c !== undefined ? result.PrimaryMobileNumber__c : '';
                this.Customer_Registration__c.Email_Address__c = result.Primary_Applicant_Email__c !== undefined ? result.Primary_Applicant_Email__c : '';
                this.Customer_Registration__c.Address__c = result.Primary_Applicant_Address__c;
                this.Customer_Registration__c.CRM_Executive__c = result.CRM_Executive__c != undefined ? result.CRM_Executive__c : null ;
                this.Customer_Registration__c.Nationality__c = null;
                this.Customer_Registration__c.Residential_Status__c = null;
                this.Customer_Registration__c.City__c = result.City__c != undefined ? result.City__c : null;
                this.Customer_Registration__c.Category__c = null;
                this.Customer_Registration__c.Vertical__c = null;
                this.Customer_Registration__c.Status__c = 'Open';
                this.Customer_Registration__c.Executive_attended__c = null;
                this.Customer_Registration__c.Purpose_of_visit__c = null;
                this.Customer_Registration__c.Remarks__c = null; 
                console.log('CRM SITE VISIT -> ',JSON.parse(JSON.stringify(this.Customer_Registration__c)));
                this.fetchRecordType();
        }).catch(error => {
            this.showSpinner = false;
            this.showToast('No Record Found', ' No related information found! ', 'info');
            console.log('result booking : ',JSON.stringify(error));
            // this.showToast('Exception Error', error, 'error');
        })
    }

    fetchRecordType() {
        getRecordType({
            recordTypeName: 'CRM_Site_Visit'
        }).then(result => {
            if (result) {
                this.Customer_Registration__c.RecordTypeId = result;
            }
        }).catch(error => {
            this.showSpinner = false;
            this.showToast('Exception Error', error, 'error');
        });
    }

    saveForm(event) {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
        }, 3000);
    }

    handleReset(event) {
        this.showSpinner = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (element.type === 'checkbox' || element.type === 'checkbox-button') {
                element.checked = false;
            } else if(element.disabled == false) {
                element.value = null;
            }
        });
        this.Customer_Registration__c.Booking__c = null,
        this.Customer_Registration__c.Unit__c = null;
        this.Customer_Registration__c.First_Name__c = null;
        this.Customer_Registration__c.Last_Name__c = null;
        this.Customer_Registration__c.Mobile_Number__c = null;
        this.Customer_Registration__c.Email_Address__c = null;
        this.Customer_Registration__c.Interested_In__c = null;
        this.Customer_Registration__c.Source__c = null;
        this.Customer_Registration__c.Nationality__c = null;
        this.Customer_Registration__c.Residential_Status__c = null;
        this.Customer_Registration__c.City__c = null;
        this.Customer_Registration__c.Country_Code__c = null;
        this.Customer_Registration__c.Address__c = null;
        this.Customer_Registration__c.Dialing_Country__c = null;
        this.Customer_Registration__c.Category__c = null;
        this.Customer_Registration__c.Property_Type__c = null;
        this.Customer_Registration__c.Vertical__c = null;
        this.Customer_Registration__c.Status__c = null;
        this.Customer_Registration__c.Purpose_Of_Purchase__c = null;
        this.Customer_Registration__c.CRM_Executive__c = null;
        this.Customer_Registration__c.Executive_attended__c = null;
        this.Customer_Registration__c.Purpose_of_visit__c = null;
        this.Customer_Registration__c.Remarks__c = null;
        
        setTimeout(() => {
            this.fetchRecordType();
            this.showSpinner = false;
        }, 1000);
    }

    handleSuccess(event) {
        this.showToast('Success', 'Form has been save succesfully', 'success');
        this.handleReset(event);
    }

    handleError(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        this.showSpinner = false;
    }


    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}