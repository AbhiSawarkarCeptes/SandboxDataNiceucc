import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import getBookingData from '@salesforce/apex/SitevisitChartController.getBookingData';
import getLoggedInUserContactId from '@salesforce/apex/SitevisitChartController.getLoggedInUserContactId';
import getBookingAppartmentsCount from '@salesforce/apex/SitevisitChartController.getBookingAppartmentsCount';
import getBookingVillasCount from '@salesforce/apex/SitevisitChartController.getBookingVillasCount';
import getSitevisits from '@salesforce/apex/SitevisitChartController.getSitevisits';
import getBookingDataYearly from '@salesforce/apex/SitevisitChartController.getBookingDataYearly';
import getSitevisitsYearly from '@salesforce/apex/SitevisitChartController.getSitevisitsYearly';
import getBookingDataQuaterly from '@salesforce/apex/SitevisitChartController.getBookingDataQuaterly';
import getSitevisitsQuaterly from '@salesforce/apex/SitevisitChartController.getSitevisitsQuaterly';
import getSitevisitsHalfYearly from '@salesforce/apex/SitevisitChartController.getSitevisitsHalfYearly';
import getBookingDataHalfYearly from '@salesforce/apex/SitevisitChartController.getBookingDataHalfYearly';

import getUpcomingEvents from '@salesforce/apex/SitevisitChartController.getUpcomingEvents';
import getUpcomingAllEvents from '@salesforce/apex/SitevisitChartController.getUpcomingAllEvents';
import isEligibleForAction from '@salesforce/apex/PortalBrokerEventsController.isEligibleForAction';


import getSitevisitsCountInCurrentYear from '@salesforce/apex/SitevisitChartController.getSitevisitsCountInCurrentYear';
import getSitevisitsCountInlastSixmonth from '@salesforce/apex/SitevisitChartController.getSitevisitsCountLastSixMonths';
import getSitevisitsCountLastThreeMonths from '@salesforce/apex/SitevisitChartController.getSitevisitsCountLastThreeMonths';
import getSitevisitsCountInCurrentMonth from '@salesforce/apex/SitevisitChartController.getSitevisitsCountInCurrentMonth';
import getBookingsTotalInCurrentYear from '@salesforce/apex/SitevisitChartController.getBookingsTotalInCurrentYear';
import getBookingsTotalInLastSixMonths from '@salesforce/apex/SitevisitChartController.getBookingsTotalInLastSixMonths';
import getBookingsTotalInLastThreeMonths from '@salesforce/apex/SitevisitChartController.getBookingsTotalInLastThreeMonths';
import getBookingsTotalInCurrentMonth from '@salesforce/apex/SitevisitChartController.getBookingsTotalInCurrentMonth';

import getBaseURL from '@salesforce/apex/PortalBrokerEventsController.getBaseURL';

import SITEVISITE_IMAGE_URL from '@salesforce/resourceUrl/SitevisitIcon';

import SITEVISITE_IMAGE_LEFT_URL from '@salesforce/resourceUrl/sitevisiticonleft';
import SALES_IMAGE_LEFT_URL from '@salesforce/resourceUrl/Salesiconleft';
import Event_Icon_Image_URL from '@salesforce/resourceUrl/EventlocationIcon';
import Appartment_Image_URL from '@salesforce/resourceUrl/Appartments';
import Villa_Image_URL from '@salesforce/resourceUrl/VillaIcon';
export default class PortalDashboard extends LightningElement {
    @track events = [];
    @track Allevents = [];
    // @track ShowAllEvents = false;
    allEventCount = 0;
    siteVisitsCount = 0;
    siteVisitsCountsixmonth = 0;
    siteVisitsCountthreemonth = 0;
    siteVisitsCountCurrentmonth = 0;
    totalBookingsinYear = 0;
    totalBookingsinHalfYear = 0;
    totalBookingsinQuartYear = 0;
    totalBookingsinQuartYearMillion = 0;
    totalBookingsinCurrentMonth = 0;
    totalBookingsinCurrentMonthtomillion = 0;
    appartmentsBookingCount = 0;
    villasBookingCount = 0;
    villaimageurl = Villa_Image_URL;
    appartmenticon = Appartment_Image_URL;
    salesIconleft = SALES_IMAGE_LEFT_URL;
    sitevisitUrl = SITEVISITE_IMAGE_URL;
    siteVisitIconLeft = SITEVISITE_IMAGE_LEFT_URL;
    eventIconImageLeft = Event_Icon_Image_URL;
    monthly = false;
    @track eventsRecordCount = 0;
    isOpenhouseClicked = true;
    @track isRoadshowsClicked = false;
    @track isBusinessTripsClicked = false;
    @track isVideoShootsClicked = false;

    @track buttonClass1 = '';
    @track buttonClass = '';
    @track buttonClass3 = '';
    @track buttonClass4 = '';
    @api loaderVariant = 'base';
    @api chartConfig;
    @track chartOne = false;
    @track chartTwo = false;
    @track chartThree = false;
    @track chartFour = false;
    @track error;
    @track recordType = '';
    chart;
    chartData = [];
    chartDataTwo = [];
    chartjsInitialized = false;
    lineChart;
    barChart;
    lineChartData = [];
    barChartData = [];
    chartDataLine = [];
    chartDataBar = [];
    chartDataBarBookingQat = [];
    chartDataLinesiteVisitQat = [];
    chartMonthDataLine = [];
    chartMonthDataBar = [];
    chartDataBarsiteVisitHlf = [];
    chartDataBarBookingHlf = [];
    chartDataBarBookYly = [];
    chartDataLineSiteVisitYly = [];
    arrow_icon = portalAssests + '/assets/images/arrow.svg';
    selectedYear = '2024';
    baseAddress='https://www.sobhapartnerportal.com/partnerportal';

    @track upcomingEventsClass = "upcoming-events";
    @track mainDivStyle='';
    @track displayElement=false;
    @track siteVisitsText = "This Month"; 
    @track salesValueText = "This Month";

    @wire(getBaseURL)
    getBaseURLMethod({ error, data }) {
        if (data) {
            //this.baseAddress = data;
        } else if (error) {
            console.error('Error fetching base URL address', error);
        }
    }

    get peformanceURL()
    {
        return this.baseAddress+'/s/performance';
    }
    get eventsURL()
    {
        return this.baseAddress+'/s/events';
    }
    @wire(getBookingAppartmentsCount)
    wiredBookingAppartmentCount({ error, data }) {
        if (data) {
            this.appartmentsBookingCount = data;
        } else if (error) {
            console.error('Error fetching booking count for appartments:', error);
        }
    }
    @wire(getBookingVillasCount)
    wiredBookingVillasCount({ error, data }) {
        if (data) {
            this.villasBookingCount = data;
        } else if (error) {
            console.error('Error fetching booking count for villas:', error);
        }
    }
    @wire(getLoggedInUserContactId)
    wiredContactId({ error, data }) {
        if (data) {
            console.log('Logged-in user Contact Id:', data);
        } else if (error) {
            console.error('Error fetching user Contact Id:', error);
        }
    }
    @wire(getSitevisitsCountInCurrentYear)
    wiredSiteVisitsCount({ error, data }) {
        if (data) {
            console.log("this.siteVisitsCount" + JSON.stringify(data));
            this.siteVisitsCount = data;
            console.log("this.siteVisitsCount" + this.siteVisitsCount);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountInlastSixmonth)
    wiredSiteVisitsCountsixmonth({ error, data }) {
        if (data) {
            console.log("siteVisitsCountsixmonth" + JSON.stringify(data));
            this.siteVisitsCountsixmonth = data;
            console.log("this.siteVisitsCountsixmonth" + this.siteVisitsCountsixmonth);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountLastThreeMonths)
    wiredSiteVisitsCountthreemonth({ error, data }) {
        if (data) {
            console.log("siteVisitsCountthreemonth" + JSON.stringify(data));
            this.siteVisitsCountthreemonth = data;
            console.log("this.siteVisitsCountthreemonth" + this.siteVisitsCountthreemonth);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountInCurrentMonth)
    wiredSiteVisitsCountCurrentmonth({ error, data }) {
        if (data) {
            console.log("MONTH" + JSON.stringify(data));
            this.siteVisitsCountCurrentmonth = data;
            console.log("MONTH2" + this.siteVisitsCountCurrentmonth);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInCurrentYear)
    wiredBookingsVisitsCount({ error, data }) {
        if (data) {
            console.log("this.totalBookingsinYear" + JSON.stringify(data));
            this.totalBookingsinYear = (data / 1000000).toFixed(2);
            console.log("this.totalBookingsinYear" + this.totalBookingsinYear);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInLastSixMonths)
    wiredBookingsSixmonthsCount({ error, data }) {
        if (data) {
            console.log("this.totalBookingsinHalfYear" + JSON.stringify(data));
            this.totalBookingsinHalfYear = (data / 1000000).toFixed(2);
            console.log("this.totalBookingsinHalfYear" + this.totalBookingsinHalfYear);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInLastThreeMonths)
    wiredBookingsThreemonthsCount({ error, data }) {
        if (data) {
            console.log("this.totalBookingsinQuartYear" + JSON.stringify(data));

            this.totalBookingsinQuartYear = data;
            this.totalBookingsinQuartYearMillion = (this.totalBookingsinQuartYear / 1000000).toFixed(2);
            console.log("this.totalBookingsinQuartYear" + this.totalBookingsinQuartYear);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInCurrentMonth)
    wiredBookingsCurrentmonthsCount({ error, data }) {
        if (data) {
            console.log("this.totalBookingsinCurrentMonth" + JSON.stringify(data));
            this.totalBookingsinCurrentMonth = data;
            console.log("this.totalBookingsinCurrentMonth" + this.totalBookingsinCurrentMonth);
            this.totalBookingsinCurrentMonthtomillion = (this.totalBookingsinCurrentMonth / 1000000).toFixed(2);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getUpcomingAllEvents)
    wiredEvents({ error, data }) {
        //Console.log("DATA"+ data);
        if (data) {
            console.log("THIS IS DATA" + data);
            this.Allevents = data.map(event => ({
                Id: event.Id,
                Name: event.Name,
                City_Country__c: event.City_Country__c,
                FormattedDay: new Date(event.Date_Of_Event__c).getDate(),
                FormattedMonth: new Date(event.Date_Of_Event__c).toLocaleString('default', { month: 'short' }),
                FormattedYear: new Date(event.Date_Of_Event__c).getFullYear()
            }));
            console.log("ALL EVENTS" + this.Allevents);
            this.allEventCount = this.Allevents.length;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.Allevents = undefined;
        }
    }


    /* @wire(getBookingData)
     wiredBookingData({ error, data }) {
         if (data) {
             console.log("data ", data)
 
             this.chartDataBar = this.processData(data);
             console.log("this.chartDataBar ", this.chartDataBar);
             if (this.isChartJsInitialized) {
 
             }
         } else if (error) {
 
         }
     }
     @wire(getSitevisits)
     wiredSitevisits({ error, data }) {
         if (data) {
             console.log("data1" + data)
             this.chartDataLine = this.processData(data);
             console.log("this.chartDataLine " + this.chartDataLine);
             if (this.isChartJsInitialized) {
 
             }
         } else if (error) {
 
         }
     }*/

    connectedCallback() {
        this.isOpenhouseClicked = false;
        this.upcomingEventsClass = "upcoming-events-active";
        this.buttonClass1 = 'graph-tab-link active';
        this.chartOne = true;
        this.ShowAllEvents = true;
        // this.loadChartJS();
        isEligibleForAction()
        .then(result => {
            if(result==false){
                this.mainDivStyle='main-panel no-click';
                this.displayElement = false;
            }
            else{
                this.mainDivStyle='main-panel';
                this.displayElement = true;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
    renderedCallback()
    {
        this.loadChartJS();
    }
    isChartJsInitialized = false;
    loadChartJS() {
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.chartjsInitialized = true;
                this.fetchData();
            })
            .catch(
                error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error loading ChartJS',
                            message: error.message,
                            variant: 'error',
                        })
                    );
                }
            );
    }

    handleClickEventtype(event) {
        const eventName = event.target.dataset.event;
        if (eventName == "All") {
            this.upcomingEventsClass = "upcoming-events-active";
        } else {
            this.upcomingEventsClass = "upcoming-events";
        }
        switch (eventName) {
            case 'Openhouse':

                this.isOpenhouseClicked = true;
                this.isRoadshowsClicked = false;
                this.isBusinessTripsClicked = false;
                this.isVideoShootsClicked = false;
                this.ShowAllEvents = false;
                this.showSelectedEvents = true;
                this.recordType = 'Open Houses';


                break;
            case 'Roadshows':
                this.isRoadshowsClicked = true;
                this.isBusinessTripsClicked = false;
                this.isVideoShootsClicked = false;
                this.isOpenhouseClicked = false;
                this.ShowAllEvents = false;
                this.showSelectedEvents = true;
                this.recordType = 'Road Shows';


                break;
            case 'Business Trips':
                this.isBusinessTripsClicked = true;
                this.isVideoShootsClicked = false;
                this.isOpenhouseClicked = false;
                this.isRoadshowsClicked = false;
                this.ShowAllEvents = false;
                this.showSelectedEvents = true;
                this.recordType = 'Business Trip';

                break;
            case 'Video Shoots':
                this.isVideoShootsClicked = true;
                this.isOpenhouseClicked = false;
                this.isRoadshowsClicked = false;
                this.isBusinessTripsClicked = false;
                this.ShowAllEvents = false;
                this.showSelectedEvents = true;
                this.recordType = 'Videoshoot';
                break;

            case 'All':
                this.recordType = 'All';
                this.ShowAllEvents = false;
                this.showSelectedEvents = true;
                this.isVideoShootsClicked = false;
                this.isOpenhouseClicked = false;
                this.isRoadshowsClicked = false;
                this.isBusinessTripsClicked = false;
            default:
                break;
        }
        // Calling the Apex method whenever a specific event type is clicked
        if (this.recordType) {
            this.callApexMethod();
        }
    }
    callApexMethod() {
        console.log("MYRECORDTYPE" + this.recordType);
        getUpcomingEvents({ recordType: this.recordType })
            .then(result => {
                this.events = result.events.map(event => ({
                    Id: event.Id,
                    Name: event.Name,
                    City_Country__c: event.City_Country__c,
                    Date_Of_Event__c: new Date(event.Date_Of_Event__c),
                    FormattedDay: this.getFormattedDay(new Date(event.Date_Of_Event__c)),
                    FormattedMonth: this.getFormattedMonth(new Date(event.Date_Of_Event__c)),
                    FormattedYear: this.getFormattedYear(new Date(event.Date_Of_Event__c))
                }));
                console.log("MYEVENT" + JSON.stringify(this.events));
                console.log('recordCount : ', result.recordCount);
                this.eventsRecordCount = result.recordCount;
            })
            .catch(error => {
                console.error('Error retrieving events:', error);
            });
    }
    getFormattedDay(date) {
        return date.getDate();
    }

    getFormattedMonth(date) {
        return date.toLocaleString('default', { month: 'short' });
    }

    getFormattedYear(date) {
        return date.getFullYear();
    }
    fetchData() {
        // Fetch data for booking chart
        console.log('this.chartOne : ', this.chartOne);
        console.log('this.chartTwo : ', this.chartTwo);
        console.log('this.chartThree : ', this.chartThree);
        console.log('this.chartFour : ', this.chartFour);
        if (this.chartOne) {
            getBookingData()
                .then(result => {

                    this.chartDataBar = this.processData(result);
                    console.log('this.chartDataBar : ', JSON.stringify(this.chartDataBar));
                    if (this.chartOne) {
                        // console.log("this.chartOne" + this.chartOne);
                        this.renderCombinedChart();
                    }
                    if (this.chartTwo) {
                        // console.log("this.chartTwo" + this.chartTwo);
                        this.renderCombinedQuarterlyChart();
                    }
                    if (this.chartThree) {
                        // console.log("this.chartThree" + this.chartThree);
                        this.renderCombinedHalfyearlyChart();
                    }
                    if (this.chartFour) {
                        // console.log("this.chartfour" + this.chartFour);
                        this.renderCombinedyearlyChart();
                    }



                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for bookings chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
            let currentDate = new Date();
            console.log('current Date : ', currentDate);
            let currentYear = currentDate.getFullYear();
            let currentmonth = currentDate.getMonth() + 1;
            console.log(currentmonth);
            // Fetch data for site visits chart
            getSitevisits({ years: parseInt(currentYear), months: parseInt(currentmonth) })
                .then(result => {
                    console.log('result : ', JSON.stringify(result));
                    this.chartDataLine = this.processData(result);
                    console.log('result 2 ', this.chartDataLine);
                    this.renderCombinedChart();

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        } else if (this.chartTwo) {
            getBookingDataQuaterly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('BOOKING result ' + JSON.stringify(result));
                    const processedData = Array(4).fill(0); // Initialize processedData array with 0s
                    result.forEach(item => {
                        const exprValue = item.expr0;
                        if (exprValue >= 1 && exprValue <= 4) {
                            processedData[exprValue - 1] = item.recordCount;
                        }
                    });

                    this.chartDataBarBookingQat = processedData;

                    console.log('Booking Data  this.chartDataBar' + this.chartDataBar);
                    this.renderCombinedQuarterlyChart();

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for bookings chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );

            // Fetch data for site visits chart
            getSitevisitsQuaterly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('SITE VISIT QUARTELY result ' + JSON.stringify(result));
                    const processedData = Array(4).fill(0); // Initialize processedData array with 0s
                    result.forEach(item => {
                        const exprValue = item.expr0;
                        if (exprValue >= 1 && exprValue <= 4) {
                            processedData[exprValue - 1] = item.recordCount;
                        }
                    });

                    console.log('processedDataQUART' + processedData);
                    this.chartDataLinesiteVisitQat = processedData;
                    console.log('SITE VISIT QUARTELY this.chartDataLine' + this.chartDataLine);
                    this.renderCombinedQuarterlyChart();

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        } else if (this.chartThree) {
            getBookingDataHalfYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('getBookingDataHalfYearly result ' + JSON.stringify(result));
                    const processedData = [0, 0];
                    let sum = 0;
                    let sum2 = 0;
                    result.forEach(item => {
                        const MonthValue = item.month;
                        if (MonthValue >= 1 && MonthValue <= 6) {
                            console.log('MonthValue : ', MonthValue);
                            // processedData[MonthValue - 1] += item.recordCount; // Accumulate recordCount by month
                            // sum += recordCount; // Accumulate total sum of recordCount values
                            sum += item.recordCount;
                        } else {
                            sum2 += item.recordCount;
                        }
                        console.log('sum : ', sum);

                    });
                    processedData[0] = sum;
                    processedData[1] = sum2;
                    console.log("HALF YEARLY " + processedData);
                    // this.chartDataLine[0] = processedData;
                    this.chartDataBarBookingHlf = processedData;
                    console.log('HALF YEARLY this.chartDataBar: ' + this.chartDataBarBookingHlf);
                    this.renderCombinedHalfyearlyChart();
                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching data for bookings chart',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
                });



            // Fetch data for site visits chart
            getSitevisitsHalfYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('site vist half yearly data ', JSON.stringify(result));
                    const processedData = [0, 0];
                    let sum = 0; // Initialize sum variable to accumulate recordCount values
                    let sum2 = 0;
                    result.forEach(item => {
                        const MonthValue = item.month;
                        //const recordCount = parseInt(item.recordCount);
                        if (MonthValue >= 1 && MonthValue <= 6) {
                            console.log('MonthValue : ', MonthValue);
                            // processedData[MonthValue - 1] += item.recordCount; // Accumulate recordCount by month
                            // sum += recordCount; // Accumulate total sum of recordCount values
                            sum += item.recordCount;
                        } else {
                            sum2 += item.recordCount;
                        }
                        console.log('sum site visit: ', sum);
                        console.log('sum2 site visit : ', sum);
                        processedData[0] = sum;
                        processedData[1] = sum2;
                        // this.chartDataLine[0] = processedData1;
                        this.chartDataBarsiteVisitHlf = processedData;
                        // Check if MonthValue is within the range of the first six months (1 to 6)
                        /* if (MonthValue >= 1 && MonthValue <= 6) {
                                processedData[MonthValue - 1] += recordCount; // Accumulate recordCount by month
                                sum += recordCount; // Accumulate total sum of recordCount values
                            } */
                        this.renderCombinedHalfyearlyChart();
                    });

                    console.log("HALF YEARLY processedData: site visit : " + processedData);


                    // Assign processedData (with summed values) to this.chartDataBar
                    this.chartDataLine[0] = sum;

                    // Also assign the total sum to the first index of chartDataBar (assuming this is how you want to use it)

                    this.renderCombinedHalfyearlyChart();

                })
                .catch(
                    error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        } else if (this.chartFour) {
            getBookingDataYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('result1 ', result);
                    const processedData = [];
                    const processedLabel = new Map();
                    let resMap = new Map();
                    result.forEach(item => {
                        resMap.set(item.month, item.recordCount);
                        processedData.push(item.recordCount);
                        processedLabel.set(item.month, 0);
                    });
                    this.processedLabel = processedLabel;
                    this.chartDataBarBookYly = processedData;
                    console.log('result ', this.chartDataBar);
                    this.renderCombinedyearlyChart();

                })
                .catch(
                    error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for bookings chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
            // Fetch data for site visits chart
            getSitevisitsYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    console.log('result2 site visit yearly :', JSON.stringify(result));
                    let processedData = [];
                    // const processedLabel = [];
                    let resMap = new Map();
                    let processedLabel = this.processedLabel;
                    result.forEach(item => {
                        let i = 0;
                        // processedLabel.set(item.month, item.recordCount);
                        processedData.push(item.recordCount);
                        processedLabel.set(item.month, 0);
                    });
                    //this.processedLabel = processedLabel;
                    this.processedLabel = processedLabel;
                    this.chartDataLineSiteVisitYly = processedData;
                    console.log('result2 ', processedLabel.values());
                    let labels = [];
                    for (let [key, value] of processedLabel) {
                        labels.push(value);
                    }
                    // this.chartDataLine = labels;
                    console.log('result2 ', this.chartDataLine);
                    this.renderCombinedyearlyChart();

                })
                .catch(
                    error => {
                        console.log('bbb ');
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        }

    }

    processedLabel = new Map();
    // Method to group data
    groupMonthData() {
        const groupSize = 3;
        console.log("chartDataBar" + this.chartDataBar);
        for (let i = 0; i < this.chartDataBar.length; i += groupSize) {
            const group = this.chartDataBar.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataBar.push(sum);
        }
        console.log("this.chartMonthDataBar" + this.chartMonthDataBar);
    }
    groupMonthDataline() {
        const groupSize = 3;

        console.log("this.chartDataLine" + this.chartDataLine);
        for (let i = 0; i < this.chartDataLine.length; i += groupSize) {
            const group = this.chartDataLine.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataLine.push(sum);
        }
        console.log("this.chartMonthDataLine" + this.chartMonthDataLine);
    }

    processData(data) {

        const processedData = Array(12).fill(0);
        console.log('data : ', data);
        data.forEach(item => {
            console.log('item : ', JSON.stringify(item));
            const monthIndex = parseInt(item.month, 10) - 1;
            console.log('monthIndex : ', monthIndex);
            processedData[monthIndex] = parseInt(item.recordCount, 10);
        });
        console.log('processedData : ', JSON.stringify(processedData));
        return processedData;
    }
    processLineChartData(data) {
        // Process data for bar chart
        return data.map(item => {
            return parseInt(item.recordCount, 10);
        });
    }

    processBarChartData(data) {
        // Process data for line chart
        return data.map(item => {
            return parseInt(item.siteVisitCount, 10);
        });
    }
    //render monthly chart
    renderCombinedChart() {
        const ctx = this.template.querySelector('canvas.combined-chart').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let scales = {
            xAxes: [{
                gridLines: { display: false },
                ticks: {
                    beginAtZero: true
                },
            }],
            yAxes: [{
                ticks: {
                    beginAtZero: true
                },
            }]
        };
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Bookings (Units)',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 2
                }, {
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    fill: false,
                    borderWidth: 2,
                    type: 'line'
                }]
            },
            options: {
                scales: scales,
                /* scales: {
                     yAxes: {
                          min: 0,
                          max: 10000,
                          grid:{
                              color:'red',
                              display: false,
                           }
                     },
                     xAxes: {
                         grid:{
                               color:'pink',
                               display: false,
                            }
                      }
                 } */
            }
        });
    }
    // Method to render the quarterly combined chart
    renderCombinedQuarterlyChart() {
        const ctx = this.template.querySelector('canvas.combined-quarterchart').getContext('2d');
        // to remove negative values in data
        const chartDataBarNoNegatives = this.chartDataBarBookingQat.map(value => Math.max(value, 0));
        const chartDataLineNoNegatives = this.chartDataLinesiteVisitQat.map(value => Math.max(value, 0));
        console.log("Booking chartDataBarNoNegatives" + chartDataBarNoNegatives);
        console.log("Site chartDataBarNoNegatives" + chartDataLineNoNegatives);
        let scales = {
            xAxes: [{
                gridLines: { display: false },
                ticks: {
                    beginAtZero: true
                },
            }],
            yAxes: [{
                ticks: {
                    beginAtZero: true
                },
            }]
        };

        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                    label: 'Bookings (Units)',
                    data: chartDataBarNoNegatives,

                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
                }, {
                    label: 'Site Visits',
                    data: chartDataLineNoNegatives,

                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                }]
            },
            options: {
                scales: scales
            }
        });

    }

    renderCombinedHalfyearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-halfyearlychart').getContext('2d');

        if (this.chart) {
            this.chart.destroy();
        }
        let scales = {
            xAxes: [{
                gridLines: { display: false },
                ticks: {
                    beginAtZero: true
                },
            }],
            yAxes: [{
                ticks: {
                    beginAtZero: true
                },
            }]
        };
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['H1', 'H2'],
                datasets: [{
                    label: 'Bookings (Units)',
                    data: this.chartDataBarBookingHlf,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
                }, {
                    label: 'Site Visits',
                    data: this.chartDataBarsiteVisitHlf,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                }]
            },
            options: {
                scales: scales
            }
        });

    }

    renderCombinedyearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-yearlychart').getContext('2d');
        let scales = {
            xAxes: [{
                gridLines: { display: false },
                ticks: {
                    beginAtZero: true
                },
            }],
            yAxes: [{
                ticks: {
                    beginAtZero: true
                },
            }]
        };
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        for (let [key, value] of this.processedLabel) {
            labels.push(key);
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Bookings (Units)',
                    data: this.chartDataBarBookYly,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
                }, {
                    label: 'Site Visits',
                    data: this.chartDataLineSiteVisitYly,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                }]
            },
            options: {
                scales: scales
            }
        });

    }

    getCurrentByYear(){
         let currentDate = new Date();
        let firstBiYearStart = new Date(currentDate.getFullYear(), 0, 1); 
        let secondBiYearStart = new Date(currentDate.getFullYear(), 6, 1); 
        let biYear;

        if (currentDate >= firstBiYearStart && currentDate < secondBiYearStart) {
            biYear = "H1, " + currentDate.getFullYear();
        } else if (currentDate >= secondBiYearStart) {
            biYear = "H2, " + currentDate.getFullYear();
        }
        return biYear;
    }

    handleTabClick(event) {
        const selectedTabId = parseInt(event.currentTarget.dataset.tab, 10);
        console.log("selectedTabId" + selectedTabId);
        if (selectedTabId == 1) {
            this.buttonClass1 = 'graph-tab-link active';
            this.buttonClass2 = '';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = true;
            this.chartTwo = false;
            this.chartThree = false;
            this.chartFour = false;
            this.siteVisitsText = "This Month";
            this.salesValueText = "This Month";
            this.loadChartJS();
            if (this.chartjsInitialized) {
                return;
            }

        } else if (selectedTabId == 2) {
            this.buttonClass2 = 'graph-tab-link active';
            this.buttonClass1 = '';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = false;
            this.chartTwo = true;
            this.chartThree = false;
            this.chartFour = false;
             this.siteVisitsText = "This Quarter";
            this.salesValueText = "This Quarter";
            this.loadChartJS();
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }

        }
        else if (selectedTabId == 3) {
            this.buttonClass3 = 'graph-tab-link active';
            this.buttonClass1 = '';
            this.buttonClass2 = '';
            this.buttonClass4 = '';
            this.chartThree = true;
            this.chartOne = false;
            this.chartTwo = false;
            this.chartFour = false;
             this.siteVisitsText = this.getCurrentByYear();
            this.salesValueText = this.getCurrentByYear();
            this.loadChartJS();
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }
        }
        else if (selectedTabId == 4) {
            this.buttonClass4 = 'graph-tab-link active';
            this.buttonClass2 = '';
            this.buttonClass3 = '';
            this.buttonClass1 = '';
            this.chartFour = true;
            this.chartOne = false;
            this.chartTwo = false;
            this.chartThree = false;
             this.siteVisitsText = "This Year";
            this.salesValueText = "This Year";
            this.loadChartJS();
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }

        }
    }

    get isOpenhouseClickedClass() {
        return this.isOpenhouseClicked ? 'clicked' : '';
    }

    get isRoadshowsClickedClass() {
        return this.isRoadshowsClicked ? 'clicked' : '';
    }

    get isBusinessTripsClickedClass() {
        return this.isBusinessTripsClicked ? 'clicked' : '';
    }

    get isVideoShootsClickedClass() {
        return this.isVideoShootsClicked ? 'clicked' : '';
    }




}