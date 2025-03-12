import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STAND_LEAD_OBJECT from '@salesforce/schema/Stand_Lead__c';
import STAND_LEAD_ROASTER_OBJECT from '@salesforce/schema/Mall_Stand_Roaster__c';
import COUNTRY_CODES from '@salesforce/schema/Stand_Lead__c.Country_Code__c';
import COUNTRIES from '@salesforce/schema/Stand_Lead__c.Country__c';
import CITIES from '@salesforce/schema/Stand_Lead__c.City__c';
import NATIONALITIES from '@salesforce/schema/Stand_Lead__c.Nationality__c';
import LANGUAGE from '@salesforce/schema/Stand_Lead__c.Language__c';
import AGERANGE from '@salesforce/schema/Stand_Lead__c.Age_Range__c';
import PROPERTY_STATUS from '@salesforce/schema/Stand_Lead__c.Preferred_Property_Status__c';
import ALREADY_PURCHASED from '@salesforce/schema/Stand_Lead__c.Purchased_in_the_preferred_City__c';
import PROFESSION from '@salesforce/schema/Stand_Lead__c.Profession__c';
import PREFERRED_CITY from '@salesforce/schema/Stand_Lead__c.Preferred_City_of_Interest__c';
import PROPERTY_TYPE from '@salesforce/schema/Stand_Lead__c.Property_Type__c';
import WILLING_TO_MEET from '@salesforce/schema/Stand_Lead__c.Willing_to_meet_this_week__c';
import BUDGET from '@salesforce/schema/Stand_Lead__c.Budget__c';
import EXPECTED_LEVEL_OF_USAGE from '@salesforce/schema/Stand_Lead__c.Expected_Level_of_Usage__c';
import MORTAGE_REQUIRED from '@salesforce/schema/Stand_Lead__c.Mortage_Required__c';
import HOW_MANY_BEDROOMS from '@salesforce/schema/Stand_Lead__c.How_Many_Bedrooms__c';
import ACCOMPANIED_BY from '@salesforce/schema/Stand_Lead__c.Accompanied_By__c';
import MEETING_TYPE from '@salesforce/schema/Stand_Lead__c.Meeting_Type__c';
import RENT_CURRENT_VALUES from '@salesforce/schema/Stand_Lead__c.Rent_Current_Residence__c'
import SPECIFIC_LOCATION_CITY from '@salesforce/schema/Stand_Lead__c.Specific_Location_in_the_City__c';
import INTERESTED_PROJECT from '@salesforce/schema/Stand_Lead__c.Interested_Project__c';
import salesManager from '@salesforce/schema/Stand_Lead__c.SalesManager__c';
import mallName from '@salesforce/schema/Mall_Stand_Roaster__c.Mall_Name__c';
import NEED_PICKUP_VALUES from '@salesforce/schema/Stand_Lead__c.Needs_Pick_Up__c';
import RESIDENT_TYPE from '@salesforce/schema/Stand_Lead__c.Resident_Type__c';
import GENDER_VALUE from '@salesforce/schema/Stand_Lead__c.Gender__c';
import { NavigationMixin } from 'lightning/navigation';
import userId from '@salesforce/user/Id';
import updateLocation from '@salesforce/apex/MallStandController.updateLocation';
import validateIfLocationUpdated from '@salesforce/apex/MallStandController.validateIfLocationUpdated';
import fetchSalesManagerId from '@salesforce/apex/MallStandController.fetchSalesManagerId';
import validatePhoneNumber from '@salesforce/apex/Nice_PhoneValidationUtility.validatePhoneNumber';
import validateEmail from '@salesforce/apex/Nice_EmailValidationUtility.validateEmail';
import id from '@salesforce/user/Id';

import SobhaLeadImage from '@salesforce/resourceUrl/SobhaLeadImage';
import { loadStyle } from "lightning/platformResourceLoader";
import LeadCreationStyle from "@salesforce/resourceUrl/LeadCreationStyle";

const genderOptions = [
    {
        value: 'Male',
        label: 'Male'
    },
    {
        value: 'Female',
        label: 'Female'
    }
];




export default class LeadCreationComponent extends NavigationMixin(LightningElement) {
    backgroundImageUrl = SobhaLeadImage;
    backgroundImageStyle = `background-image: url(${SobhaLeadImage}); background-size: cover; background-position: right; background-repeat: no-repeat;`;


    @wire(getObjectInfo, { objectApiName: STAND_LEAD_OBJECT })
    standLeadInfo;

    @wire(getObjectInfo, { objectApiName: STAND_LEAD_ROASTER_OBJECT })
    standLeadRoasterInfo;

    @wire(getPicklistValues, { recordTypeId: '$standLeadRoasterInfo.data.defaultRecordTypeId', fieldApiName: mallName })
    mallNameValues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_CODES })
    countryCodes;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: COUNTRIES })
    countries;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: CITIES })
    cities;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: NATIONALITIES })
    nationalities;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: LANGUAGE })
    languages;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: AGERANGE })
    ageRanges;

    /* @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: ALREADY_PURCHASED })
     alreadypurchasedstatuses;
 
     @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: PROPERTY_STATUS })
     propertystatuses;*/

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: PROFESSION })
    professions;

    /*@wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: PREFERRED_CITY })
    preferredcities;*/

    /* @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: PROPERTY_TYPE })
     propertytypes;*/

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: WILLING_TO_MEET })
    willingtomeetvalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: BUDGET })
    budgetvalues;

    /*@wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: EXPECTED_LEVEL_OF_USAGE })
    expectedusagevalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: MORTAGE_REQUIRED })
    mortgagevalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: HOW_MANY_BEDROOMS })
    bedroomvalues;*/

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: ACCOMPANIED_BY })
    accompaniedbyvalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: MEETING_TYPE })
    meetingtypevalues;

    /* @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: RENT_CURRENT_VALUES })
     rentcurrentvalues;
 
     @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: SPECIFIC_LOCATION_CITY })
     specificLocationvalues;*/

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: INTERESTED_PROJECT })
    projectvalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: NEED_PICKUP_VALUES })
    needpickupvalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: RESIDENT_TYPE })
    residenttypevalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: GENDER_VALUE })
    gendervalues;

    @wire(getPicklistValues, { recordTypeId: '$standLeadInfo.data.defaultRecordTypeId', fieldApiName: salesManager })
    salesmanagerValues;

    ShowModal = false;

    @track currentUserId = userId;


    openModal() {
        console.log('enteredclick');
        this.ShowModal = true;
    }
    closeModal() {
        this.ShowModal = false;
    }
    // Age range options for the combobox
    get ageOptions() {
        return [
            { label: '20-30', value: '20-30' },
            { label: '30-40', value: '30-40' },
            { label: '40-50', value: '40-50' },
            { label: '50+', value: '50+' }
        ];
    }

    val = 50;
    firstName;
    lastName;
    gender;
    contactnumber;
    countrycode;
    country;
    residentselectvalue;
    age;
    city;
    nationality;
    language;
    ageRange;
    //alreadypurchased;
    //  propertystatus;
    profession;
    preferredcity;
    //specificlocationcity;
    // propertytype;
    budget;
    willingtomeetvalue;
    @track meetnow = false;
    email;
    // expectedusage;
    //  mortgagevalue;
    // bedroomvalue;
    accomaniedby;
    // rentcurrentvalue;
    meetlater = false;
    //assignRM = false;
    meetingdatetime;
    projectvalue;
    meetingtypevalue;
    needpickup;
    residenttype;
    promotorsRemark;
    salesManager;
    salesMgrlkp;
    mallNameVal = false;
    salesMgrValue;
    @track isLoading = false;
    @track saveDisabled = false;
    @track isOtherLanguageSelected = false;

    selectedOptionValue;
    selectedOptionLabel;


    phoneNoApiResponse = '';
    accessKey = '7448c6f770b4f9d822af0a5b3c6e00ce';
    valid = false;
    tempNumber;
    validEmail = false;
    tempEmail;
    isContactNumberDisabled = true;
    hasInteracted = false;
    hasInteractedPhone = false;

    connectedCallback() {
        loadStyle(this, LeadCreationStyle);
    }

    handleOptionChange(event) {
        this.selectedOptionLabel = event.detail.label;
    }
    navigateToRecord(recordId) {
        console.log('enterednavifate');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }
    handleStatusChange(event) {
        //let objDetails = event.detail;
        console.log(JSON.stringify(event.detail));

        console.log("flow status", event.detail);
        if (event.detail.status === "FINISHED") {
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name === 'currentRecord') {
                    this.navigateToRecord(outputVar.value);
                }
            }

        }
    }



    handleChange(event) {
        //this.firstname = event.target.value;
        console.log('event==', event);
        console.log('event.target.name : ' + event.target.name);
        console.log('event.target.value : ' + event.target.value);
        console.log('COming here 1');
        console.log('event.detail.label dd' + JSON.stringify(event.detail));
        console.log('event.detail.label' + event.detail.name);
        console.log('event.detail.value' + event.detail.value);
        const contactNumberField = this.template.querySelector('lightning-input[data-id="contactnumber"]');

        console.log('COming here 2');

        if (event.target.name == 'firstName') {
            this.firstName = event.target.value;
        } else if (event.target.name == 'lastName') {
            this.lastName = event.target.value;
        } else if (event.target.name == 'email') {
            this.email = event.target.value;
            /*this.tempEmail = this.email;
            console.log('this.email 2nd : ' + this.tempEmail);
            // Set hasInteracted to true after first interaction
            this.hasInteracted = true;*/
            console.log('this.emailId 1st : '+this.emailId);
            this.tempEmail = this.email;
            console.log('this.emailId 2nd : '+this.emailId);  
            this.hasInteracted = true;
            this.validEmail = false;
        } else if (event.target.name == 'gender') {
            this.gender = event.target.value;
        } else if (event.target.name == 'countrycode') {
            console.log('COming here 3');
            console.log(event.detail.value);
            this.countrycode = event.detail.value;
            this.isContactNumberDisabled = false;
            this.clearContactNumber();

        } else if (event.target.name == 'residenttype') {
            this.residenttype = event.target.value;
        } else if (event.target.name === 'ageRange') {
            this.age = event.target.value; // Update the age property with selected value
            console.log('Selected Age Range:', this.age); // Optional: Debugging purpose
        } else if (event.target.name == 'country') {
            this.country = event.target.value;
        } else if (event.target.name == 'city') {
            this.city = event.target.value;
        } else if (event.target.name == 'nationality') {
            this.nationality = event.target.value;
        } else if (event.target.name == 'language') {
            this.language = event.detail.value;
            this.isOtherLanguageSelected = this.language === 'Others';
        } else if (event.target.name == 'otherlanguage') {
            this.language = event.detail.value;
        } /*else if (event.target.name == 'alreadypurchased') {
            this.alreadypurchased = event.detail.value;
        } else if (event.target.name == 'propertytype') {
            this.propertytype = event.detail.value;
        } else if (event.target.name == 'propertystatus') {
            this.propertystatus = event.detail.value;
        }*/
        else if (event.target.name == 'profession') {
            this.profession = event.detail.value;
        } /*else if (event.target.name == 'Preferred City of Interest') {
            this.preferredcity = event.detail.value;
        } else if (event.target.name == 'specificlocationcity') {
            this.specificlocationcity = event.detail.value;
        } */
        else if (event.target.name == 'budget') {
            this.budget = event.target.value;
        } else if (event.target.value == 'Moscow Exhibition') {
            this.mallNameVal = true;
        } else if (event.target.name == 'salesManager') {
            // console.log('entereddsalesmgr')
            this.salesMgrValue = event.detail.value;
            this.getsalesManagerId()
        }


        else if (event.target.name == 'willingtomeet') {

            this.willingtomeetvalue = event.detail.value;
            console.log("Meet now", this.willingtomeetvalue);
            if (event.target.value == 'Yes') {
                console.log("Meet now");
                this.meetnow = true;
                this.meetlater = false;
                //this.assignRM = false;
                this.needpickup = undefined;
                this.meetingdatetime = undefined;
            } else if (event.target.value == 'Later') {
                this.meetnow = false;
                this.meetlater = true;
                //this.assignRM = false;
                this.accomaniedby = undefined;
                this.meetingtypevalue = undefined;
            } else if (event.target.value == 'Assign RM on Stand') {
                console.log('1234456789');
                this.meetnow = false;
                this.meetlater = false;
                //this.assignRM = true;
                this.meetingdatetime = undefined;
                this.accomaniedby = undefined;
                this.meetingtypevalue = undefined;
            } else {
                this.meetlater = false;
                this.meetnow = false;
                //  this.assignRM = false;
                this.needpickup = undefined;
                this.meetingdatetime = undefined;
                this.accomaniedby = undefined;
                this.meetingtypevalue = undefined;
            }
        } /*else if (event.target.name == 'expectedusage') {
            this.expectedusage = event.target.value;
        } 
       else if (event.target.name == 'mortgagevalue') {
            this.mortgagevalue = event.target.value;
        } else if (event.target.name == 'bedroomvalue') {
            this.bedroomvalue = event.target.value;
        } */
        else if (event.target.name == 'accomaniedby') {
            this.accomaniedby = event.detail.value;
        }
        /*else if (event.target.name == 'rentcurrentvalue') {
            this.rentcurrentvalue = event.target.value;
        } */
        else if (event.target.name == 'meetingdatetime') {
            this.meetingdatetime = event.target.value;
        } else if (event.target.name == 'projectvalue') {
            this.projectvalue = event.detail.value;
        } else if (event.target.name == 'meetingtypevalue') {
            this.meetingtypevalue = event.target.value;
        } else if (event.target.name == 'needpickup') {
            this.needpickup = event.target.value;
        } else if (event.target.name == 'promotorsRemark') {
            this.promotorsRemark = event.target.value;
        }
    }

    handleChangeContact(event) {
        console.log('this.contactnumber 1st : ' + this.contactnumber);
        this.contactnumber = event.target.value;
        this.tempNumber = this.contactnumber;
        console.log('this.contactnumber 2nd : ' + this.contactnumber);
        this.hasInteractedPhone = true;
    }


    clearContactNumber() {
        // Wait for DOM to update if necessary
        Promise.resolve().then(() => {
            const contactNumberField = this.template.querySelector('lightning-input[data-id="contactnumber"]');

            console.log('Inside clearContactNumber : ' + contactNumberField);
            if (contactNumberField) {
                console.log('Inside clearContactNumber');
                contactNumberField.value = ''; // Clear the value
                this.valid = false;
            } else {
                console.error('Contact number field not found in DOM.');
            }
        });
    }

    async handleBlur() {
        //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

        console.log('Inside handleBlur');
        console.log('Inside handleBlur : this.countrycode ' + this.countrycode);
        console.log('Inside handleBlur : this.tempNumber ' + this.tempNumber);
        // Validate input
        if (!this.countrycode && this.tempNumber) {
            this.apiResponse = 'Both Mobile Country Code and Contact Number are required.';
            this.hasInteractedPhone = false;
            this.valid = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid country code first',
                    variant: 'error',
                }),
            );
            return;
        }
        if (this.countrycode && !this.tempNumber) {
            this.apiResponse = 'Both Mobile Country Code and Contact Number are required.';
            this.hasInteractedPhone = false;
            this.valid = false;
            return;
        }

        try {
            const response = await validatePhoneNumber({
                accessKey: this.accessKey,
                phoneNumber: this.countrycode + this.tempNumber,
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

                this.valid = parsedResponse.valid; //commented to resolve phone validation API failure need to be uncommented this and remove below line before deploying 
                //this.valid = true;
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
        console.log('Inside handleBlur : valid : ' + this.valid);

        if (!this.valid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid mobile number',
                    variant: 'error',
                }),
            );
        }

    }

    /*async handleEmailBlur() {
        //const combinedPhoneNumber = this.mobileCountryCode + this.contactNumber;

        console.log('Inside handleBlur : this.tempEmail ' + this.tempEmail);
        // Validate input
        if (!this.tempEmail) {
            this.apiResponse = 'Email is required.';
            this.validEmail = false;
            return;
        }

        try {
            const response = await validateEmail({
                emailAddress: this.tempEmail
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

                this.validEmail = parsedResponse.is_deliverable;

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
            this.apiResponse = 'Error validating Email number.';
        }
        console.log('Inside handleBlur : validEmail : ' + this.validEmail);

        if (!this.validEmail) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid Email',
                    variant: 'error',
                }),
            );
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

    getsalesManagerId() {
        console.log('salesmgrvalue' + this.salesMgrValue);
        fetchSalesManagerId({
            salesMgrName: this.salesMgrValue
        })
            .then(result => {
                if (result && result.length > 0) {

                    this.salesManager = result;
                    console.log('resultsalesmgrvalue : ' + result + '////' + this.salesManager);
                } else {
                    this.message = "No Records Found for '" + this.searchTerm + "'";
                }
            }).catch(error => {
                this.message = error.message;
                console.log(error);
            })
    }

    createStandLead() {

        if (!this.nationality && !this.countrycode) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill Nationality & Country Code',
                    variant: 'error',
                }),
            );
        }
        else if (this.nationality && !this.countrycode) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill Country Code',
                    variant: 'error',
                }),
            );
        }
        else if (!this.nationality && this.countrycode) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill Nationality',
                    variant: 'error',
                }),
            );
        }
        else if (!this.willingtomeetvalue) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Willing to meet',
                    variant: 'error',
                }),
            );
        }
        else if (!this.valid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid mobile number',
                    variant: 'error',
                }),
            );
        } else if (!this.validEmail) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid Email',
                    variant: 'error',
                }),
            );
        }
        else {
            this.saveDisabled = true;
            console.log('mallname' + this.salesManager + '////' + this.salesMgrlkp);
            validateIfLocationUpdated()


                .then(result => {
                    if (result == true) {
                        this.isLoading = true;
                        console.log(this.firstName);
                        console.log(this.lastName);


                        if (this.lastName) {
                            var fields = {
                                'FirstName__c': this.firstName,
                                'Last_Name__c': this.lastName,
                                'Contact_Number__c': this.contactnumber,
                                'Gender__c': this.gender,
                                'Country_Code__c': this.countrycode,
                                'Age_Range__c': this.age,
                                'Resident_Type__c': this.residentselectvalue,
                                'Country__c': this.country,
                                'City__c': this.city,
                                'Nationality__c': this.nationality,
                                'Language__c': this.language,
                                'Profession__c': this.profession,
                                //'Purchased_in_the_preferred_City__c': this.alreadypurchased,
                                'Profession__c': this.profession,
                                // 'Preferred_City_of_Interest__c': this.preferredcity,
                                'Email__c': this.email,
                                // 'Property_Type__c': this.propertytype,
                                'Budget__c': this.budget,
                                // 'Preferred_Property_Status__c': this.propertystatus,
                                // 'Expected_Level_of_Usage__c': this.expectedusage,
                                // 'Mortage_Required__c': this.mortgagevalue,
                                // 'How_Many_Bedrooms__c': this.bedroomvalue,
                                'Tour_Date_Time__c': this.meetingdatetime,
                                'Willing_to_meet_this_week__c': this.willingtomeetvalue,
                                'Accompanied_By__c': this.accomaniedby,
                                'Meeting_Type__c': this.meetingtypevalue,
                                'Needs_Pick_Up__c': this.needpickup,
                                'Resident_Type__c': this.residenttype,
                                //'Specific_Location_in_the_City__c': this.specificlocationcity,
                                //'Rent_Current_Residence__c': this.rentcurrentvalue,
                                'Interested_Project__c': this.projectvalue,
                                'Promotors_Remarks__c': this.promotorsRemark,
                                'Sales_manager__c': this.salesMgrlkp !== undefined ? this.salesMgrlkp : this.salesManager,
                                'syntax_valid__c': this.valid,
                                'is_deliverable__c': this.validEmail

                            }
                            console.log('enteredhere1');
                            const recordInput = { apiName: STAND_LEAD_OBJECT.objectApiName, fields };
                            console.log('enteredhere22' + JSON.stringify(recordInput));
                            createRecord(recordInput)
                                .then(account => {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'Information Captured Successfully created',
                                            variant: 'success',
                                        }),
                                    );
                                    this.isLoading = false;
                                    setTimeout(() => {
                                        document.location.reload();
                                    }, 2000);
                                })
                                .catch(error => {
                                    this.saveDisabled = false;
                                    this.isLoading = false;
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error capturing information',
                                            message: error.body.message,
                                            variant: 'error',
                                        }),
                                    );
                                    console.log(error);
                                });


                            //setTimeout(window.location.reload(),5000);

                        } else {
                            this.saveDisabled = false;
                            this.isLoading = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Missing required information',
                                    message: 'Please provide Last name value',
                                    variant: 'error',
                                }),
                            );
                        }
                    }
                    else {
                        this.saveDisabled = false;
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: 'Please update the location before saving the information.',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    this.saveDisabled = false;
                    this.isLoading = false;
                    console.log(error);
                });

        }

    }


    handleUserSelection(event) {
        console.log("the selected record id is : " + event.detail);
        this.salesMgrlkp = event.detail;
    }

    /*refreshUI() {
        this.val = 50;
        this.firstName  = null;
        this.lastName = null;
        this.gender = null;
        this.contactnumber = null;
        this.countrycode= null;
        this.country = null;
        this.residentselectvalue= null;
        this.age= null;
        this.city= null;
        this.nationality= null;
        this.language= null;
        this.alreadypurchased= null;
        this.propertystatus= null;
        this.profession= null;
        this.preferredcity= null;
        this.specificlocationcity= null;
        this.propertytype= null;
        this.budget= null;
        this.willingtomeetvalue= null;
        
        this.email= null;
        this.expectedusage= null;
        this.mortgagevalue= null;
        this.bedroomvalue= null;
        this.accomaniedby= null;
        this.rentcurrentvalue= null;
        
        this.meetingdatetime= null;
        this.projectvalue= null;
        this.meetingtypevalue= null;
        this.needpickup= null;
        this.residenttype= null;
        this.languagesOptions= null;

        this.meetlater = false;
        this.meetnow = false;
        this.isLoading = false;
    }*/

    handleModalOpen() {
        // open up the Modal
        MyModal.open({
            size: 'medium',
            heading: 'Navigate to Record Page',
            description: 'Navigate to a record page by clicking the row button',
            options: [{ data }, { data }],
        }).then((result) => {
            // when the LightningModal closes, result is whatever
            // data that was passed out using this.close({ data })
            if (result === null) {
                // do something else
            } else {
                // shouldNavigate is boolean, arbitrary
                // rowId is what's needed for lightning-navigation
                const { shouldNavigate, rowId } = result;
                if (shouldNavigate) {
                    this.navigateToObjectHome(rowId);
                }
            }
        });
    }

    handleLocationSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        var fieldsJSON = JSON.stringify(fields);
        updateLocation({ invoiceFieldJSON: fieldsJSON })
            .then(result => {
                this.isLoading = false;
                if (result == 'success') {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Location updated successfully.',
                    });
                    this.dispatchEvent(evt);
                    this.ShowModal = false;
                }
                else {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log(error);
            });
    }
}