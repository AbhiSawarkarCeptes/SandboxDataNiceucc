import { LightningElement, wire, api, track } from 'lwc';
import getEventsDetails from '@salesforce/apex/BRPortalBrokerEventsController.getEventsDetails';
import createEventRecord from '@salesforce/apex/BRPortalBrokerEventsController.createEventRecord';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import Events__c_OBJECT from "@salesforce/schema/Events__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadMultipleFiles from '@salesforce/apex/BRPortalBrokerEventsController.uploadMultipleFiles';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';
import uploadFilesSingle from '@salesforce/apex/BRPortalBrokerEventsController.uploadFiles';
import updateEventsRecord from '@salesforce/apex/BRPortalBrokerEventsController.updateEventsRecord';
import { refreshApex } from '@salesforce/apex';
import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';
import getSalesTeam from '@salesforce/apex/BRPortalBrokerEventsController.getSalesTeam';

export default class BrPortalBrokerEvents extends LightningElement {
    @track showSpinner = false;
    currentYear;
    raiseRequestSuccessMessage
    idSet = [];
    @track filesData = [];
    @track filesDataSingle = [];
    @track recdId;
    @track isEligible = "main-panel";
    @track eligibility;
    optionIndexToSelect
    msgToChild
    showUploadColateral = false;
    showUploadVideo = false;
    // showMoreInfo=false;
    recType = 'Road Shows';
    eventName = 'Road Shows';
    fromDOEvent = '';
    toDOEvent = '';
    category = '';
    firstCall = true;
    @track filteredEvents
    year = ''
    showModal = false;
    selection;
    @track fieldsToDisplay = [];
    fieldsToUpdate = {};
    pageSizeOptions = [5, 10, 15, 20, 25, 50, 75, 100];
    totalRecords = 0; pageSize; totalPages; pageNumber = 1;
    @track recordsToDisplay = [];
    hasEvents = false;
    totalSaleValue;
    totalSaleValueMillion = 0;
    @track isTotalSaleValueMillionEqualsZero = false;
    citiesCovered;
    presentUserRecordsCount = 0;
    apartmentCount = 0;
    villasCount = 0;
    selectedRecordTypeId = '';
    allRecordTypesObject = {};
    defRecordTypeId;
    isVideoPage = false;
    sale_icon = portalAssests + '/assets/images/sale-icon.svg';
    roadshow_icon = portalAssests + '/assets/images/roadshow-icon.svg';
    loc_icon = portalAssests + '/assets/images/loc-icon.svg';
    apartment_icon = portalAssests + '/assets/images/apartment-icon.svg';
    villa_icon = portalAssests + '/assets/images/villa-icon.svg';
    raiseRequest_icon = portalAssests + '/assets/images/upload-doc-btn-iconsvg.svg';
    upload_icon = portalAssests + '/assets/images/upload-doc-icon.svg';
    videoEyeIcon = CommonIcons + "/commonIcons/videoEyeIcon.svg";
    videoPlayImg = CommonIcons + "/commonIcons/videoPlayImg.svg";
    endDate
    SelectOptions = ["Road Shows", "Open Houses", "Business Trips", "Video Shoot"];
    baseURL

    @track displayVideoShoot = false;
    @track currentVideoURL = '';
    @track latestVideoUrl = '';
    @track showLatestVideo = false;

    @wire(isEligibleForAction)
    eligibilityCheck({ error, data }) {
        if (data !== undefined) {
            this.eligibility = data;
            console.log('Eligibility data is : ' + data);
            if (data === true) {
                console.log('this is true block');
                // this.isEligible += ' disableAction'; // Uncomment if needed
            } else if(data === false) {
                //this.isEligible += ' disableAction';
            }
        } else if (error) {
            // Perform your logic related to error
            console.log('error on eligibility check', error);
        } else {
            console.log('isEligibleForAction Something went wrong');
        }
    }

    closeVideoModal() {
        this.displayVideoShoot = false;
        this.currentVideoURL = '';
    }

    videoEyeIconClickHandler(event) {
        const recId = event.target.dataset.id;
        this.currentVideoURL = recId;
        if(this.currentVideoURL !='') {
            this.displayVideoShoot = true;
        } else {
            this.showToast('Error', 'No video available.', 'error');
        }
        console.log("The record id recieved is" + recId)
    }

    Roadshow = [
        { id: '', label: 'Select Date', type: 'date', required: true, hidden: false, value: '', leftColumn: true, isDateTime: true },
        { id: '', label: 'Select Time', type: 'time', required: true, hidden: false, value: '', rightColumn: true, isDateTime: true },
        { id: 'Brief_on_city_country__c', label: '', placeholder: 'Brief on why the city/country', type: 'textarea', required: true, hidden: true, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: 'Target_audience__c', label: 'Target Audience', placeholder: 'Enter the Target Audience', type: 'text', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Venue_Hotel_Name_Name_of_Event_Hall__c', label: '', placeholder: 'Hotel Option 1', type: 'text', required: true, hidden: false, value: '', isText: true, leftColumn: true, isColumn: true },
        { id: 'Platforms_for_campaigns__c', label: 'Platforms you are planning to run the campaigns', placeholder: 'Sample Text', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, rightColumn: true, isColumn: true },
        { id: 'HOTEL2__c', label: '', placeholder: 'Hotel Option 2', type: 'text', required: true, hidden: false, value: '', isText: true, leftColumn: true, isColumn: true },
        { id: 'PS_Sobha_Sales_Team__c', label: 'Sobha Sales team', placeholder: 'First Name Last Name', type: 'text', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true, isSales: true },
        { id: 'HOTEL3__c', label: '', placeholder: 'Hotel Option 3', type: 'text', required: true, hidden: false, value: '', isText: true, leftColumn: true, isColumn: true },
        { id: 'Projects_focused_on__c', label: 'Projects will be focused on', placeholder: 'Enter Project Names', type: 'text', required: true, hidden: false, value: '', isText: true, isProjects: true },
        { id: 'Expected_Closure__c', label: 'Expected Closure', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true },
        { id: 'Expected_Meetings__c', label: 'Expected Meetings', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true }
    ];

    RoadshowOptions = ["Road Shows", "Open Houses", "Business Trips", "Video Shoot"];
    OpenHousesOptions = ["Open Houses", "Road Shows", "Business Trips", "Video Shoot"];
    BusinessTripOptions = ["Business Trips", "Road Shows", "Open Houses", "Video Shoot"];
    VideoShootOptions = ["Video Shoot", "Road Shows", "Open Houses", "Business Trips"];

    OpenHouses = [
        { id: '', label: 'Select Date', type: 'date', required: true, hidden: false, value: '', leftColumn: true, isDateTime: true },
        { id: '', label: 'Select Time', type: 'time', required: true, hidden: false, value: '', rightColumn: true, isDateTime: true },
        { id: 'Focus_Project__c', label: '', placeholder: 'Which projects will this Openhouse focus on...', type: 'textarea', required: true, hidden: true, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: 'Number_of_People_Attending__c', label: 'Number of People Attending', placeholder: '0', type: 'number', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Brief_on_city_country__c', label: '', placeholder: 'Brief on why the city/country', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: 'Target_audience__c', label: 'Target Audience', placeholder: 'Enter the Target Audience', type: 'text', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Platforms_for_campaigns__c', label: 'Platforms you are planning to run the campaigns', placeholder: 'Sample Text', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, rightColumn: true, isColumn: true },
        { id: 'Projects_focused_on__c', label: 'Projects will be focused on', placeholder: 'Enter Project Names', type: 'text', required: true, hidden: false, value: '', isText: true, isProjects: true },
        { id: 'Expected_Closure__c', label: 'Expected Closure', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true },
        { id: 'Expected_Meetings__c', label: 'Expected Meetings', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true },
        { id: 'PS_Sobha_Sales_Team__c', label: 'Sobha Sales Team', placeholder: 'First Name Last Name', type: 'text', required: true, hidden: false, value: '', isText: true, isCommon: true, isSales: true}
    ];

    BusinessTrip = [
        { id: '', label: 'Select Date', type: 'date', required: true, hidden: false, value: '', leftColumn: true, isDateTime: true },
        { id: '', label: 'Select Time', type: 'time', required: true, hidden: false, value: '', rightColumn: true, isDateTime: true },
        { id: 'Number_of_People_Attending__c', label: 'Number of People Attending', placeholder: '0', type: 'number', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Brief_on_city_country__c', label: '', placeholder: 'Brief on why the city/country', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: 'Target_audience__c', label: 'Target Audience', placeholder: 'Enter the Target Audience', type: 'text', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Platforms_for_campaigns__c', label: 'Platforms you are planning to run the campaigns', placeholder: 'Sample Text', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, rightColumn: true, isColumn: true },
        { id: 'Projects_focused_on__c', label: 'Projects will be focused on', placeholder: 'Enter Project Names', type: 'text', required: true, hidden: false, value: '', isText: true, isProjects: true },
        { id: 'Expected_Closure__c', label: 'Expected Closure', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true },
        { id: 'Expected_Meetings__c', label: 'Expected Meetings', placeholder: 'XX', type: 'number', required: true, hidden: false, value: '', isText: true, isCommon: true },
        { id: 'PS_Sobha_Sales_Team__c', label: 'Sobha Sales Team', placeholder: 'First Name Last Name', type: 'text', required: true, hidden: false, value: '', isText: true, isCommon: true, isSales: true }
    ];

    VideoShoot = [
        { id: '', label: 'Select Date', type: 'date', required: true, hidden: false, value: '', leftColumn: true, isDateTime: true },
        { id: '', label: 'Select Time', type: 'time', required: true, hidden: false, value: '', rightColumn: true, isDateTime: true },
        { id: 'Brief_about_the_video_shoot__c', label: '', placeholder: 'Brief about the video shoot...', type: 'textarea', required: true, hidden: true, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: 'Number_of_People_Attending__c', label: 'Number of People Attending', placeholder: '0', type: 'number', required: true, hidden: false, value: '', isText: true, rightColumn: true, isColumn: true },
        { id: 'Platforms_for_campaigns__c', label: 'Platforms you are planning promote the video', placeholder: 'Sample Text', type: 'textarea', required: true, hidden: false, value: '', isTextArea: true, leftColumn: true, isColumn: true },
        { id: '', label: 'Emirates ID of Shoot Attendees', type: 'file', required: true, hidden: false, value: '', isFile: true, rightColumn: true, isColumn: true }
    ];

    @track roadShowHeaderItems = [{ keyName: "Start Date", isVisible: true }, { keyName: "Number of Days", isVisible: true }, { keyName: "Country", isVisible: true },
    { keyName: "City", isVisible: true }, { keyName: "Number of Units Sold", isVisible: true }, { keyName: "Value of Units Sold (AED)", isVisible: true }, { keyName: "Collaterals", isVisible: true }, { keyName: "Actions", isVisible: true }];

    @track openHousesHeaderItems = [{ keyName: "Start Date of Event", isVisible: true }, { keyName: "Number of Days", isVisible: true }, { keyName: "Country", isVisible: true },
    { keyName: "City", isVisible: true }, { keyName: "Number of Units Sold", isVisible: true }, { keyName: "Value of Units Sold (AED)", isVisible: true }, { keyName: "Collaterals", isVisible: true }, { keyName: "Actions", isVisible: true }];

    @track businessTripsHeaderItems = [{ keyName: "Start Date of Event", isVisible: true }, { keyName: "Number of Days", isVisible: true }, { keyName: "Country", isVisible: true },
    { keyName: "City", isVisible: true }, { keyName: "Number of Units Sold", isVisible: true }, { keyName: "Value of Units Sold (AED)", isVisible: true }, { keyName: "Collaterals", isVisible: true }, { keyName: "Actions", isVisible: true }];

    @track videoShootsHeaderItems = [{ keyName: "Date of Request", isVisible: true }, { keyName: "Date of Shoot", isVisible: true }, { keyName: "Venue", isVisible: true },
    { keyName: "View Video", isVisible: true }, { keyName: "", isVisible: true }];

    @track getTableHeaderItems = [];

    connectedCallback() {
        this.getTableHeaderItems = this.roadShowHeaderItems;
        this.fieldsToDisplay = this.Roadshow;
        this.recType = "Road Shows";
        this.endDate = new Date(new Date().setDate(new Date().getDate() + 30)).toISOString().split('T')[0];
        let today = new Date();
        this.currentYear = (today.getFullYear());
    }
    
    renderedCallback() {
        if(this.recType == "Video Shoot") {
            this.isVideoPage = true;
        } else {
            this.isVideoPage = false;
        }
        console.log('===> this.recType ' + this.recType + '===' + this.isVideoPage);
        //this.fieldsToUpdate = {};
    }

    resetDates() {
        this.fromDOEvent = '';
        this.toDOEvent = '';
    }

    wiredActivities = {}
    @wire(getEventsDetails, { recType: '$recType', fromDOEvent: '$fromDOEvent', toDOEvent: '$toDOEvent', category: '$category', year: '$year' })
    eventsResponse(value) {
        {
            this.wiredActivities = value;
            const { error, data  } = value;
            console.log('===> value ' + JSON.stringify(value));
            if (data && this.eligibility) {
                this.baseURL = data.baseURL;
                if(this.isVideoPage && data.latestVideoUrl != 'NoURL') {
                    this.showLatestVideo = false;
                    this.latestVideoUrl = data.latestVideoUrl;
                    this.showLatestVideo = true;
                }
                if(this.isVideoPage && data.latestVideoUrl == 'NoURL') {
                    this.showLatestVideo = false;
                    //this.latestVideoUrl = 'https://srmapp01.blob.core.windows.net/brokerportal/Sobha_Hartland_Community_Video.mp4';
                    this.latestVideoUrl = 'https://srmapp01.blob.core.windows.net/brokerportal/HomeScreenVideo.mp4';
                    this.showLatestVideo = true;
                }
                if (data.eventsList.length > 0) {
                    this.filteredEvents = data.eventsList.map(event => {
                        return {
                            ...event,
                            videoURL: event.Remarks__c,
                            formattedDate: this.formatDate(event.Date_Of_Event__c),
                            noOfDays: (new Date(event.End_Date_Of_Event__c) - new Date(event.Date_Of_Event__c)) / (1000 * 60 * 60 * 24) ? (new Date(event.End_Date_Of_Event__c) - new Date(event.Date_Of_Event__c)) / (1000 * 60 * 60 * 24) : '0',
                            bookingCount: event.Applications_Bookings__r ? event.Applications_Bookings__r.length : 0,
                            //formattedPurchasePrice: this.formatTotalPurchasePrice(event.Total_Purchase_Price__c),
                            formattedPurchasePrice: this.formatPriceInUSFormat(event.Total_Purchase_Price__c),
                            moreInfoData: JSON.stringify({
                                "walkins": event.Expected_number_of_Visitors__c,
                                "confirmedMeetingNo": event.Confirmed_No_of_Meeting__c,
                                "recId": event.Id,
                                "salesManager": event.Sales_Manager__r 
                                ? (event.Sales_Manager__r.FirstName != null ? event.Sales_Manager__r.FirstName : '') + 
                                ' ' + 
                                (event.Sales_Manager__r.LastName != null ? event.Sales_Manager__r.LastName : '') 
                                : "",
                                "salesDirector": event.Sales_Director__r 
                                ? (event.Sales_Director__r.FirstName != null ? event.Sales_Director__r.FirstName : '') + 
                                ' ' + 
                                (event.Sales_Director__r.LastName != null ? event.Sales_Director__r.LastName : '') 
                                : "",
                                "campaignLead15Days": event.Campaign_Leads__c ? event.Campaign_Leads__c : "0",
                                "campaignLead7Days": event.Campaign_Lead_7_days_before_event__c ? event.Campaign_Lead_7_days_before_event__c : "0",
                                "eventName": event.Name,
                                "dateOfEvent": event.Date_Of_Event__c,
                                "pageName": this.recType,
                                "baseUrl": this.baseURL
                            }),
                            showMoreInfo: false
                        };
                    });
                }
                this.presentUserRecordsCount = data.userRecordCount;
                this.apartmentCount = data.apartmentCount;
                this.villasCount = data.villasCount;
                this.totalSaleValue = 0;
                if (this.filteredEvents.length > 0) {
                    this.hasEvents = true;
                    this.sideColumnValues();
                }
                else {
                    this.resetSideColumnValues();

                }
                //Pagination
                this.totalRecords = this.filteredEvents.length;
                this.pageSize = this.pageSizeOptions[0];
                this.paginationHelper();
                this.firstPage();
            }
            else if (error) {
                console.log('The error is ', error);
            }
            else {
                console.log('===> call here isVideoPage ' + this.isVideoPage);
                this.resetSideColumnValues();
                if(this.isVideoPage) {
                    this.showLatestVideo = false;
                    this.latestVideoUrl = 'https://srmapp01.blob.core.windows.net/brokerportal/HomeScreenVideo.mp4';
                    this.showLatestVideo = true;
                }
            }
        }
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const options = { day: 'numeric', month: 'short', year: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    }

    formatTotalPurchasePrice(price) {
        let newSalesValue = 0;
        const salesValue = parseFloat(price);
        if (!isNaN(salesValue)) {
            newSalesValue = (salesValue / 1000000).toFixed(2);
        } else {
            console.warn('Invalid Event_Sales_Value__c:', record.Total_Purchase_Price__c);
        }
        return newSalesValue + " Mn AED";
    }

    formatPriceInUSFormat(price) {
        let newSalesValue = 0;
        const salesValue = parseFloat(price);
        if (!isNaN(salesValue)) {
            newSalesValue = (salesValue / 1);
        } else {
            console.warn('Invalid Event_Sales_Value__c:', record.Total_Purchase_Price__c);
        }
        if (newSalesValue != 0) {
            newSalesValue = new Intl.NumberFormat('en-US').format(newSalesValue.toFixed(2));
            return newSalesValue;
        } else {
            return 0;
        }
    }

    sideColumnValues() {
        this.totalSaleValue = 0;
        const uniqueCityCountries = new Set();// Create a Set to store unique city_country values
        this.filteredEvents.forEach(record => {
            const salesValue = parseFloat(record.Total_Purchase_Price__c);
            if (!isNaN(salesValue)) {
                this.totalSaleValue += salesValue;
            } else {
                console.warn('Invalid Event_Sales_Value__c:', record.Total_Purchase_Price__c);
            }
            // Add the City_Country__c value to the Set
            if (record.City_Country__c)
                uniqueCityCountries.add(record.City_Country__c.toLowerCase());
        });
        this.totalSaleValueMillion = (this.totalSaleValue / 1000000).toFixed(2);
        if(this.totalSaleValueMillion != 0) {
            this.isTotalSaleValueMillionEqualsZero = false;
        } else {
            this.isTotalSaleValueMillionEqualsZero = true;
        }
        this.citiesCovered = uniqueCityCountries.size;
        console.log('total in millions', this.totalSaleValue);
        console.log('Unique City Countries:', uniqueCityCountries.size);
    }

    resetSideColumnValues() {
        this.totalSaleValue = 0;
        this.presentUserRecordsCount = 0;
        this.apartmentCount = 0;
        this.villasCount = 0;
        this.hasEvents = false;
        this.citiesCovered = 0;
        this.totalSaleValueMillion = 0;
    }

    //Pagination
    //BOD Pagination
    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.filteredEvents[i]);
        }
    }
    //END OF Pagination

    @wire(getObjectInfo, { objectApiName: Events__c_OBJECT })
    obInfo({ error, data }) {
        if (data) {
            this.defRecordTypeId = data.defaultRecordTypeId;
            this.allRecordTypesObject = data.recordTypeInfos;
            console.log('data.recordTypeInfos : ' + JSON.stringify(data.recordTypeInfos));
        } else if (error) {
            // perform your logic related to error 
        }
    };

    getRecordTypeIdByName(recordTypeObject, name) {
        for (const typeId in recordTypeObject) {
            if (Object.prototype.hasOwnProperty.call(recordTypeObject, typeId)) {
                if (recordTypeObject[typeId].name === name) {
                    return typeId;
                }
            }
        }
        return null;// Return null if the record type name is not found
    }

    handleItemClick(event) {
        const clickedElement = event.target;
        const getDataName = event.currentTarget.dataset.name;
        const listItems = this.template.querySelectorAll('.events-list li');
        // Remove "active" class from all list items
        listItems.forEach(item => {
            item.classList.remove('active');
        });
        // Add "active" class to the clicked list item
        clickedElement.classList.add('active');
        this.recType = clickedElement.dataset.name;
        if (this.recType == "Road Shows") {
            this.fieldsToDisplay = this.Roadshow;
            this.SelectOptions = this.RoadshowOptions;
            this.getTableHeaderItems = this.roadShowHeaderItems;
            this.resetDates();
            this.isVideoPage = false;
        } else if (this.recType == "Open Houses") {
            this.fieldsToDisplay = this.OpenHouses;
            this.getTableHeaderItems = this.openHousesHeaderItems;
            this.SelectOptions = this.OpenHousesOptions;
            this.resetDates();
            this.isVideoPage = false;
        } else if (this.recType == "Business Trip") {
            this.fieldsToDisplay = this.BusinessTrip;
            this.getTableHeaderItems = this.businessTripsHeaderItems;
            this.SelectOptions = this.BusinessTripOptions;
            this.resetDates();
            this.isVideoPage = false;
        } else if (this.recType == "Video Shoot") {
            this.fieldsToDisplay = this.VideoShoot;
            this.getTableHeaderItems = this.videoShootsHeaderItems;
            this.SelectOptions = this.VideoShootOptions;
            this.resetDates();
            this.isVideoPage = true;
        } else {
            this.getTableHeaderItems = [];
        }
    }

    handleItemClick2(event) {
        const clickedElement = event.target;
        const listItems = this.template.querySelectorAll('.filter-tab-area li');
        // Remove "active" class from all list items
        listItems.forEach(item => {
            item.classList.remove('active');
        });
        // Add "active" class to the clicked list item
        clickedElement.classList.add('active');
        this.year = '';
        this.fromDOEvent = '';
        this.category = clickedElement.innerText;
        this.toDOEvent = '';
    }

    handleFromDateChange(event) {
        this.category = ''
        this.year = '';
        this.fromDOEvent = event.target.value;
    }

    handleToDateChange(event) {
        this.category = ''
        this.year = '';
        this.toDOEvent = event.target.value;
    }

    handleYearClick(event) {
        this.category = ''
        this.fromDOEvent = '';
        if (event.target.value != "Select Year")
            this.year = event.target.value;
        else
            this.year = '';
    }

    showModalHandler(event) {
        console.log('rec type   ',  this.recType);
        //console.log('event type   ', this.eventName);
        //this.recType = this.eventName;
        this.showResetObjectData();
        this.showModal = !this.showModal;
        console.log("rec type id is " + this.selectedRecordTypeId);
    }

    showResetObjectData() {
        if (this.recType == "Road Shows") {
            this.fieldsToDisplay = this.Roadshow;
            this.endDate = new Date(new Date().setDate(new Date().getDate() + 30 )).toISOString().split('T')[0];
        } else if (this.recType == "Open Houses") {
            this.fieldsToDisplay = this.OpenHouses;
            this.endDate=new Date(new Date().setDate(new Date().getDate() + 15 )).toISOString().split('T')[0];
        } else if (this.recType == "Business Trip") {
            this.fieldsToDisplay = this.BusinessTrip;
            this.endDate=new Date(new Date().setDate(new Date().getDate() + 17 )).toISOString().split('T')[0];
        } else if (this.recType == "Video Shoot") {
            this.fieldsToDisplay = this.VideoShoot;
            this.endDate=new Date(new Date().setDate(new Date().getDate() + 4 )).toISOString().split('T')[0];
        }
        this.selectedRecordTypeId = this.getRecordTypeIdByName(this.allRecordTypesObject, this.recType);
    }

    handleFormSelect(event) {
        this.showSpinner = true;
        this.fieldsToUpdate = {};
        this.fieldsToDisplay = [];
        this.selectedValue = "";
        this.selection = event.target.value;
        setTimeout(() => {
            this.fieldsToUpdate = {};
            this.fieldsToDisplay = [];
            this.selectedValue = "";
            if(this.selection === "Road Shows") {
                this.selectedRecordTypeId = this.getRecordTypeIdByName(this.allRecordTypesObject, "Road Shows");
                this.fieldsToDisplay = this.Roadshow;
                this.recType = 'Road Shows';
                this.endDate = new Date(new Date().setDate(new Date().getDate() + 30 )).toISOString().split('T')[0];
            } else if(this.selection === "Open Houses") {
                this.selectedRecordTypeId = this.getRecordTypeIdByName(this.allRecordTypesObject, "Open Houses");
                this.fieldsToDisplay = this.OpenHouses;
                this.recType = 'Open Houses';
                this.endDate = new Date(new Date().setDate(new Date().getDate() + 15 )).toISOString().split('T')[0];
            } else if(this.selection === "Business Trips") {
                this.selectedRecordTypeId = this.getRecordTypeIdByName(this.allRecordTypesObject, "Business Trip");
                this.fieldsToDisplay = this.BusinessTrip;
                this.recType = 'Business Trip';
                this.endDate = new Date(new Date().setDate(new Date().getDate() + 17 )).toISOString().split('T')[0];
            } else if(this.selection === "Video Shoot") {
                this.selectedRecordTypeId = this.getRecordTypeIdByName(this.allRecordTypesObject, "Video Shoot");
                this.fieldsToDisplay = this.VideoShoot;
                this.recType = 'Video Shoot';
                this.endDate=new Date(new Date().setDate(new Date().getDate() + 4 )).toISOString().split('T')[0];
            } else {
                console.log('No iformation to show');
            }
            this.showSpinner = false;
        }, 1000);
    }

    handleFieldChange(event) {
        let field = event.target;
        let fieldId = field.id
        console.log('record id is ', this.recType);
        if (fieldId.includes("-")) {
            fieldId = fieldId.split('-')[0];
        }
        if(this.selectedValue) {
            this.fieldsToUpdate = {...this.fieldsToUpdate,"PS_Sobha_Sales_Team__c":this.selectedValue}
        }
        const fieldValue = field.value;
        const Fieldtype = field.type;
        this.fieldsToUpdate[fieldId] = fieldValue;
        console.log('field is ' + fieldId + 'The value is ' + fieldValue, ' the field type is' + Fieldtype);
        console.log('fieldset for update is ', JSON.stringify(this.fieldsToUpdate));
    }

    handleSubmit(event) {
        event.preventDefault();
        this.getFormElementIds();
        let isValid = this.validateForm();
        console.log("is valid value" + isValid);
        //console.log("rec rec rec " + this.recType + this.selectedRecordTypeId);
        if (isValid) {
            console.log('the validation is returning' + this.validateForm());
            this.submitForm();
        } else {
            // If form is not valid, display error messages or take appropriate action
            console.log("Fill all required fields");
        }
    }

    validateForm() {
        // Implement your validation logic here
        // Return true if form is valid, false otherwise
        let isValid = true;
        // Example: Check if required fields are filled
        //let keys = Object.keys(this.fieldsToUpdate);
        const errorMessages = this.template.querySelectorAll('.error-message');
        errorMessages.forEach(errorMessage => errorMessage.remove());
        console.log(' We are on 566');
        this.idSet.forEach(key => {
            if(key != 'PS_Sobha_Sales_Team__c') {
                if (this.fieldsToUpdate[key]) {
                    console.log(`Key "${key}" has a value: ${this.fieldsToUpdate[key]}`);
                } else {
                    isValid = false;
                    try {
                        //if(key == 'Sobha_sales_team__c') {
                            //this.showToast('Error', 'Please fill required details.', 'error');
                        //} else {
                            this.errorParagraph(key)
                        //}
                        //this.errorParagraph(key)
                    } catch (error) {
                        console.log('Error: ' + error.message);
                    }
                    console.log(`Key "${key}" does not have a value`);
                }
            }
        });
        if(isValid && !this.fieldsToUpdate["PS_Sobha_Sales_Team__c"] && this.recType != "Video Shoot") {
            isValid = false;
            this.showToast('Error', 'Please fill required details or correct data.', 'error');
        }
        if (this.fieldsToUpdate["Date_Of_Event__c"] && this.fieldsToUpdate["End_Date_Of_Event__c"]) {
            const startDate = new Date(this.fieldsToUpdate["Date_Of_Event__c"]);
            const endDate = new Date(this.fieldsToUpdate["End_Date_Of_Event__c"]);
            console.log("on 589 start date", startDate);
            console.log("on 590 end date", endDate);
            if (startDate > endDate) {
                isValid = false;
                console.log('Start date is greater than end date');
                this.errorParagraph("Date_Of_Event__c", "Start date can not be greater than end date");
            }
        }
        if (this.fieldsToUpdate["Start_Time_of_the_Event__c"] && this.fieldsToUpdate["End_Time_of_the_Event__c"]) {
            const startTime = parseInt(this.fieldsToUpdate["Start_Time_of_the_Event__c"].replace(":", ""));
            const endTime = parseInt(this.fieldsToUpdate["End_Time_of_the_Event__c"].replace(":", ""));
            console.log("on 601 start date", startTime);
            console.log("on 602 end date", endTime);
            if (startTime > endTime) {
                isValid = false;
                console.log('Start Time is greater than end Time');
                this.errorParagraph("Start_Time_of_the_Event__c", "Start Time can not be greater than end Time");
            }
        }
        if (this.fieldsToUpdate["Date_Of_Event__c"]) {
            const startDate = new Date(this.fieldsToUpdate["Date_Of_Event__c"]);
            const today = new Date();
            console.log('===> today ' + today);
            //const timeDifference = startDate.getTime() - today.getTime();

            const timeDifference = Math.abs(startDate - today);
            console.log('===> timeDifference ' + timeDifference);
            // Convert the difference from milliseconds to days
            const daysDifference = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
            console.log('===> daysDifference ' + daysDifference);
            // Check if the start date is more than 21 days in the past
            if (this.recType == "Road Shows" && daysDifference < 30) {
                isValid = false;
                console.log('Start date should be more than 30 days for Road Shows');
                this.errorParagraph("Date_Of_Event__c", "Start date cannot be less than 30 days from today");
            }
            else if (this.recType == "Video Shoot" && daysDifference < 4) {
                isValid = false;
                console.log('Start date should be more than 7 days for Video Shoot');
                this.errorParagraph("Date_Of_Event__c", "Start date cannot be less than 4 days from today");
            }
            else if (this.recType == "Business trip" && daysDifference < 17) {
                isValid = false;
                console.log('Start date should be more than 21 days for Business trip');
                this.errorParagraph("Date_Of_Event__c", "Start date cannot be less than 17 days from today");
            }
            else if (this.recType == "Open Houses" && daysDifference < 15) {
                isValid = false;
                console.log('Start date should be more than 21 days for Open Houses');
                this.errorParagraph("Date_Of_Event__c", "Start date cannot be less than 15 days from today");
            }
        }
        if (this.fieldsToUpdate["Date_Of_Event__c"]) {
            const startDate = new Date(this.fieldsToUpdate["Date_Of_Event__c"]);
            const today = new Date();

            const timeDifference = Math.abs(startDate - today);
            console.log('===> timeDifference ' + timeDifference);
            // Convert the difference from milliseconds to days
            const daysDifference = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
            console.log('===> daysDifference ' + daysDifference);

            //const timeDifference = startDate.getTime() - today.getTime();
            // Convert the difference from milliseconds to days
            //const daysDifference = Math.floor(timeDifference / (1000 * 60 * 60 * 24));
            // Check if the start date is more than 21 days in the past
            if (daysDifference < 0) {
                isValid = false;
                console.log('Start date can not be in past ');
                this.errorParagraph("Date_Of_Event__c", "Start date can not be in past");
            }
        }
        if (this.fieldsToUpdate["Date_Of_Event__c"] && this.fieldsToUpdate["End_Date_Of_Event__c"]) {
            //const startDate = new Date(this.fieldsToUpdate["Date_Of_Event__c"]);
            //const endDate = new Date(this.fieldsToUpdate["End_Date_Of_Event__c"]);
            console.log("===> 625 ");
            console.log("===> 626 ");
            if (this.fieldsToUpdate["Date_Of_Event__c"] === this.fieldsToUpdate["End_Date_Of_Event__c"]) {
                isValid = false;
                this.errorParagraph("End_Date_Of_Event__c", "End date should be greater than start date");
            }
        }
        if(isValid && this.recType == "Video Shoot" && (this.filesDataSingle == undefined || this.filesDataSingle == null || this.filesDataSingle.length == 0)) {
            isValid = false;
            this.showToast('Error', 'Please upload the document.', 'error');
        }
        console.log('the valid value is ' + isValid);
        return isValid;
    }

    errorParagraph(key, message) {
        console.log('Key recieved ', key);
        const inputElement = this.template.querySelector(`.${key}`);
        console.log("inputElement " + JSON.stringify(inputElement));
        if ((inputElement && inputElement.validity.valueMissing) || (inputElement && message)) {
            // Create a new paragraph element for the error message
            const errorMessage = document.createElement('p');
            if (!message)
                errorMessage.textContent = `*This is a required field!`;
            else
                errorMessage.textContent = message;
            errorMessage.classList.add('error-message');
            errorMessage.style.color = "red";
            // Insert the error message below the input element
            inputElement.parentNode.insertBefore(errorMessage, inputElement.nextSibling);
            // Optionally, add styling to the input field to indicate error
            // inputElement.classList.add('placeHolder-redcolor');
        }
    }

    submitForm() {
        this.fieldsToUpdate["recordTypeId"] = (this.selectedRecordTypeId != null) ? this.selectedRecordTypeId : this.defRecordTypeId;
        if(this.recType == "Road Shows") {
            this.fieldsToUpdate["Type_Of_Road_Show__c"] = "Channel Partner Roadshow";
        }
        //console.log("The fields to update are", this.fieldsToUpdate);
        this.showSpinner = true;
        createEventRecord({ eventData: this.fieldsToUpdate })
        .then(result => {
            //console.log('===> call here' + JSON.stringify(result));
            if (result) {
                console.log('===> call here');
                // Record created successfully
                if (this.recType == "Video Shoot") {
                    //this.handleAttachUpload(result);
                    this.handleUpload(result).then(() => {
                        this.finalizeFormSubmission();
                    }).catch(uploadError => {
                        console.error('Error during file upload: ' + uploadError);
                        this.showToast('Error', 'Error during file upload.', 'error');
                        this.showSpinner = false;
                    });
                } else {
                    this.finalizeFormSubmission();
                }
                refreshApex(this.wiredActivities);
                //this.showSpinner = false;
                /*else if (result.includes('maintained')) {
                    this.showModal = false;
                    this.showToast('Error', result, 'error');
                    this.showSpinner = false;
                    refreshApex(this.wiredActivities);
                } else {   
                    refreshApex(this.wiredActivities);
                    this.showModal = false;
                    this.showToast('Success', 'Record created successfully', 'success');
                    this.showSpinner = false;
                }*/
            } else {
                // Handle error
                this.showToast('Error', 'Failed to create event record.', 'error');
                this.showSpinner = false;
            }
        })
        .catch(error => {
            // Handle error
            //.showToast('Error', 'Error creating an event record', 'error');
            this.showSpinner = false;
        });
    }

    finalizeFormSubmission() {
        /*this.raiseRequestSuccessMessage = "Record created successfully!";
        setTimeout(() => {
            this.raiseRequestSuccessMessage = "";
            this.showModal = !this.showModal;
        }, 3000);*/
        this.showModal = !this.showModal;
        this.showToast('Success', 'Record created successfully', 'success');
        this.showSpinner = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    uploadCollateralHandler(event) {

        this.showUploadColateral = !this.showUploadColateral;
        this.recdId = event.currentTarget.dataset.recid;
    }

    uploadVideoHandler(event) {

        this.showUploadVideo = !this.showUploadVideo;
        this.recdId = event.currentTarget.dataset.recid;
    }
    
    handleSingleFilesChange(event) {
        console.log('Within handle file change');
        if (event.target.files.length > 0) {
            const promises = [];
            for (var i = 0; i < event.target.files.length; i++) {
                console.log('Within for loop file change');
                let file = event.target.files[i];
                //const recId = event.currentTarget.dataset.recid;
                promises.push(this.readFile(file));
            }
            Promise.all(promises)
            .then(() => {
                console.log("All files read successfully. Files data:", this.filesDataSingle);
                // Now you can proceed with further processing
            })
            .catch(error => {
                console.error("Error reading files:", error);
            });
        }
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            var reader = new FileReader();
            reader.onload = () => {
                console.log('Within onload file change');
                var base64 = reader.result.split(',')[1];
                this.filesDataSingle.push({
                    'filename': file.name,
                    'base64': base64
                });
                resolve();
            };
            reader.onerror = error => {
                console.error('File reading error:', error);
                reject(error);
            };
            reader.readAsDataURL(file);
        });
    }

    handleAttachUpload(recId) {
        const { base64, filename } = this.filesDataSingle[0];
        console.log("undher handle upload base64 is" + base64);
        const recordId = recId
        const filetype = '';
        uploadFilesSingle({ base64, filename, recordId, filetype })
        .then(result => {
            let title = `${filename} uploaded successfully!!`
            console.log('File uploaded successfully', title)
            //this.showToast('Success', 'Successfully uploaded file.', 'success');
            refreshApex(this.wiredActivities);
            this.showModal = false;
            this.showToast('Success', 'Record created successfully', 'success');
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('File uploaded failed', error)
            this.showSpinner = false;
        });
    }

    handleUpload(recId) {
        const { base64, filename } = this.filesDataSingle[0];
        console.log("undher handle upload base64 is" + base64);
        const recordId = recId
        const filetype = '';
        uploadFilesSingle({ base64, filename, recordId, filetype })
        .then(result => {
            let title = `${filename} uploaded successfully!!`
            refreshApex(this.wiredActivities);
            this.showModal = false;
            console.log('File uploaded successfully', title)
            this.showToast('Success', 'Successfully uploaded file.', 'success');
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('File uploaded failed', error)
            this.showToast('Error', 'Upload file failed', 'error');
            this.showSpinner = false;
        });
    }

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents });
                };
                reader.readAsDataURL(file);
            }
        }
    }

    uploadFiles() {
        if (this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'Please select files first', 'error'); return;
        }
        this.showSpinner = true;
        uploadMultipleFiles({
            recordId: this.recdId,
            filedata: JSON.stringify(this.filesData)
        })
        .then(result => {
            console.log('===> 990 ' + result);
            if (result && result == 'success') {
                this.filesData = [];
                if (this.recType == "Road Shows") {
                    let updateData = {}
                    updateData["Id"] = this.recdId;
                    updateData["Collateral_Uploaded__c"] = true;
                    updateEventsRecord({ updateData })
                        .then(result => {
                            if (result) {
                                // Record created successfully
                                console.log('Event record updated: ' + result);
                                // this.showToast('Success', 'Event record created successfully.', 'success');
                            } else {
                                // Handle error
                                console.error('Failed to update event record.');
                                // this.showToast('Error', 'Failed to create event record.', 'error');
                            }
                        })
                        .catch(error => {
                            // Handle error
                            console.error('Error creating event record: ' + error);
                            this.showToast('Error', 'Error creating event record.', 'error');
                        });

                } else if(this.recType == "Video Shoot") {
                    this.showUploadVideo = !this.showUploadVideo;
                }
                refreshApex(this.wiredActivities);
                this.showToast('Success', 'Successfully uploaded file.', 'success');
            } else {
                this.showToast('Error', result, 'error');
            }
            this.showSpinner = false;
        }).catch(error => {
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message, 'error');
                this.showSpinner = false;
            }
        }).finally(() => this.showSpinner = false);
    }

    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }
    
    showMoreInfoHandler(event) {
        this.msgToChild = event.currentTarget.dataset.info || event.detail.info;
        console.log('ms to child is ', this.msgToChild);
        const eventId = event.currentTarget.dataset.id || event.detail.id;
        console.log('Clicked id is ', eventId);
        this.filteredEvents.forEach(event => {
            if (event.Id === eventId) {
                event.showMoreInfo = !event.showMoreInfo;
            } else {
                event.showMoreInfo = false;
            }
        });
        console.log('Filterd events ', this.filteredEvents);
        this.paginationHelper();
    }

    moreInfoHandlerFromChild(event) {
        this.showMoreInfo = event.detail.makeFalse;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        event.preventDefault();
        const files = event.dataTransfer.files;
        // Handle dropped files
        if (files.length > 0) {
            // Handle file upload logic here
            for (var i = 0; i < files.length; i++) {
                console.log("Within for loop in files change");
                let file = files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents });
                };
                reader.readAsDataURL(file);
            }
            console.log("File data is ", this.filesData);
            console.log(files, "files");
        }
    }

    handleBrowse() {
        const fileInput = this.template.querySelector('.file-upload-design input[type="file"]');
        fileInput.click();
    }
    
    // Function to collect IDs of form elements into an array
    getFormElementIds() {
        console.log('The fieldset is  ' + this.fieldsToDisplay);
        this.idSet = [];
        // Iterate over the elements and extract their IDs
        this.fieldsToDisplay.forEach(element => {
            if (element.id) {
                this.idSet.push(element.id);
            }
        });
        this.idSet.push('Date_Of_Event__c');
        this.idSet.push('End_Date_Of_Event__c');
        this.idSet.push('Start_Time_of_the_Event__c');
        this.idSet.push('End_Time_of_the_Event__c');
        if(this.recType == "Road Shows") {

        }
    }

    handleRefreshRequestFromChild() {
        refreshApex(this.wiredActivities);
    }

    @track searchKey = "";
    /*objectApiName = 'User';
    recordsList = []
    message = ""
    error = ""
    selectedRecordId = ""
    selectedValue = "";

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        console.log(this.searchKey);
        this.getLookupResult();
    }

    getLookupResult() { 
        getSalesTeam({ searchKey: this.searchKey, objectName : this.objectApiName })  
        .then((result) => {  
            if (result.length === 0) {  
                this.recordsList = [];
                this.message = "No Records Found";  
            } else {
                this.recordsList = result.map(record => {
                    return {
                        ...record,
                        FirstName : record.FirstName ? record.FirstName : '',
                        LastName : record.LastName ? record.LastName : '',
                        completeName : record.FirstName + ' ' + record.LastName
                    };
                });
                this.message = "";  
            }  
            this.error = undefined;  
        })  
        .catch((error) => {  
            this.error = error;  
            this.recordsList = undefined;  
        });  
    }
    
    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        //this.onSelecetedRecordUpdate();
    }

    removeRecordOnLookup() {
        this.selectedRecordId = "";
        this.selectedValue = "";
        this.searchKey = "";
        this.recordsList = []
    }

    get recordPresent() {
        if(this.recordsList.length === 0) {
            return false;
        } else {
            return true;
        }
    }*/

    handleLookupSelect(event) {
        console.log('here in handle lookup',event.detail);
        const {fieldName,value}=event.detail;
        this.fieldsToUpdate = {...this.fieldsToUpdate,[fieldName]:value}
        console.log('Fieldname is ',fieldName);
        console.log('value  is ',value);
    }

    get dateTodayPlusThirty() {
        var today = new Date();
        today.setDate(today.getDate() + 30);
        return today.toISOString().split('T')[0];
    }

    callSalesUserMethod(event) {
        let child = this.template.querySelector('c-br-portal-sales-user');
        child.callFromParent();
        let childTeam = this.template.querySelector('c-br-portal-sales-user-team');
        childTeam.callFromParentTeam();
        let childHead = this.template.querySelector('c-br-portal-sales-user-head');
        childHead.callFromParentHead();
    }
}