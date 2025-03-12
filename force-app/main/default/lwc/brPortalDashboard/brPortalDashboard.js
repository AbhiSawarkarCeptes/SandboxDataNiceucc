import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import getBookingData from '@salesforce/apex/BRSiteVisitChartController.getBookingData';
import getLoggedInUserContactId from '@salesforce/apex/BRSiteVisitChartController.getLoggedInUserContactId';
import getBookingAppartmentsCount from '@salesforce/apex/BRSiteVisitChartController.getBookingAppartmentsCount';
import getBookingVillasCount from '@salesforce/apex/BRSiteVisitChartController.getBookingVillasCount';
import getSitevisits from '@salesforce/apex/BRSiteVisitChartController.getSitevisits';
import getBookingDataYearly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataYearly';
import getSitevisitsYearly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsYearly';
import getBookingDataQuaterly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataQuaterly';
import getSitevisitsQuaterly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsQuaterly';
import getSitevisitsHalfYearly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsHalfYearly';
import getBookingDataHalfYearly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataHalfYearly';

import getUpcomingEvents from '@salesforce/apex/BRSiteVisitChartController.getUpcomingEvents';
import getUpcomingAllEvents from '@salesforce/apex/BRSiteVisitChartController.getUpcomingAllEvents';
import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';

import getSitevisitsCountInCurrentYear from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsCountInCurrentYear';
import getSitevisitsCountInlastSixmonth from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsCountLastSixMonths';
import getSitevisitsCountLastThreeMonths from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsCountLastThreeMonths';
import getSitevisitsCountInCurrentMonth from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsCountInCurrentMonth';
import getBookingsTotalInCurrentYear from '@salesforce/apex/BRSiteVisitChartController.getBookingsTotalInCurrentYear';
import getBookingsTotalInLastSixMonths from '@salesforce/apex/BRSiteVisitChartController.getBookingsTotalInLastSixMonths';
import getBookingsTotalInLastThreeMonths from '@salesforce/apex/BRSiteVisitChartController.getBookingsTotalInLastThreeMonths';
import getBookingsTotalInCurrentMonth from '@salesforce/apex/BRSiteVisitChartController.getBookingsTotalInCurrentMonth';
import SITEVISITE_IMAGE_URL from '@salesforce/resourceUrl/SitevisitIcon';
import SITEVISITE_IMAGE_LEFT_URL from '@salesforce/resourceUrl/sitevisiticonleft';
import SALES_IMAGE_LEFT_URL from '@salesforce/resourceUrl/Salesiconleft';
import Event_Icon_Image_URL from '@salesforce/resourceUrl/EventlocationIcon';
import Appartment_Image_URL from '@salesforce/resourceUrl/Appartments';
import Villa_Image_URL from '@salesforce/resourceUrl/VillaIcon';

export default class BrPortalDashboard extends LightningElement {
    @track events = [];
    @track Allevents = [];
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

    @track mainDivStyle = '';
    @track displayElement = false;
    @track siteVisitsText = "This Month"; 
    @track salesValueText = "This Month";

    @track upcomingEventsClass = "upcoming-events";

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
            this.siteVisitsCount = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountInlastSixmonth)
    wiredSiteVisitsCountsixmonth({ error, data }) {
        if (data) {
            this.siteVisitsCountsixmonth = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountLastThreeMonths)
    wiredSiteVisitsCountthreemonth({ error, data }) {
        if (data) {
            this.siteVisitsCountthreemonth = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getSitevisitsCountInCurrentMonth)
    wiredSiteVisitsCountCurrentmonth({ error, data }) {
        if (data) {
            this.siteVisitsCountCurrentmonth = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInCurrentYear)
    wiredBookingsVisitsCount({ error, data }) {
        if (data) {
            this.totalBookingsinYear = (data / 1000000).toFixed(2);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInLastSixMonths)
    wiredBookingsSixmonthsCount({ error, data }) {
        if (data) {
            this.totalBookingsinHalfYear = (data / 1000000).toFixed(2);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInLastThreeMonths)
    wiredBookingsThreemonthsCount({ error, data }) {
        if (data) {
            this.totalBookingsinQuartYear = data;
            this.totalBookingsinQuartYearMillion = (this.totalBookingsinQuartYear / 1000000).toFixed(2);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(getBookingsTotalInCurrentMonth)
    wiredBookingsCurrentmonthsCount({ error, data }) {
        if (data) {
            this.totalBookingsinCurrentMonth = data;
            this.totalBookingsinCurrentMonthtomillion = (this.totalBookingsinCurrentMonth / 1000000).toFixed(2);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }
    @wire(getUpcomingAllEvents)
    wiredEvents({ error, data }) {
        if (data) {
            this.Allevents = data.map(event => ({
                Id: event.Id,
                Name: event.Name,
                City_Country__c: event.City_Country__c,
                FormattedDay: new Date(event.Date_Of_Event__c).getDate(),
                FormattedMonth: new Date(event.Date_Of_Event__c).toLocaleString('default', { month: 'short' }),
                FormattedYear: new Date(event.Date_Of_Event__c).getFullYear()
            }));
            this.allEventCount = this.Allevents.length;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.Allevents = undefined;
        }
    }
    
    connectedCallback() {
        this.isOpenhouseClicked = false;
        this.upcomingEventsClass = "upcoming-events-active";
        this.buttonClass1 = 'graph-tab-link active';
        this.chartOne = true;
        this.ShowAllEvents = true;
        isEligibleForAction()
        .then(result => {
            if(result==false) {
                this.mainDivStyle = 'main-panel no-click';
                this.displayElement = false;
            } else {
                this.mainDivStyle = 'main-panel';
                this.displayElement = true;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
    renderedCallback() {
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
                            message: 'Error loading ChartJS',
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
        if (this.recordType) {
            this.callApexMethod();
        }
    }
    callApexMethod() {
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
        let cDate = new Date();
        let cYear = cDate.getFullYear();

        if (this.chartOne) {
            getBookingData()
            .then(result => {
                this.chartDataBar = this.processData(result);
                if(this.chartOne) {
                    this.renderCombinedChart();
                }
                if(this.chartTwo) {
                    this.renderCombinedQuarterlyChart();
                }
                if(this.chartThree) {
                    this.renderCombinedHalfyearlyChart();
                }
                if(this.chartFour) {
                    this.renderCombinedyearlyChart();
                }
            })
            .catch(
                error => {
                    console.log('Error fetching data for bookings chart');
                }
            );
            let currentDate = new Date();
            let currentYear = currentDate.getFullYear();
            let currentmonth = currentDate.getMonth() + 1;
            // Fetch data for site visits chart
            getSitevisits({ years: parseInt(currentYear), months: parseInt(currentmonth) })
            .then(result => {
                this.chartDataLine = this.processData(result);
                this.renderCombinedChart();
            })
            .catch(
                error => {
                    console.log('Error fetching data for site visits chart');
                }
            );
        } else if (this.chartTwo) {
            getBookingDataQuaterly({ selectedYear: parseInt(cYear) })
            .then(result => {
                const processedData = Array(4).fill(0); // Initialize processedData array with 0s
                result.forEach(item => {
                    const exprValue = item.expr0;
                    if (exprValue >= 1 && exprValue <= 4) {
                        processedData[exprValue - 1] = item.recordCount;
                    }
                });
                this.chartDataBarBookingQat = processedData;
                this.renderCombinedQuarterlyChart();
            })
            .catch(
                error => {
                    console.log('Error fetching data for bookings chart');
                }
            );
            // Fetch data for site visits chart
            getSitevisitsQuaterly({ selectedYear: parseInt(cYear) })
            .then(result => {
                const processedData = Array(4).fill(0); // Initialize processedData array with 0s
                result.forEach(item => {
                    const exprValue = item.expr0;
                    if (exprValue >= 1 && exprValue <= 4) {
                        processedData[exprValue - 1] = item.recordCount;
                    }
                });
                this.chartDataLinesiteVisitQat = processedData;
                this.renderCombinedQuarterlyChart();
            })
            .catch(
                error => {
                    console.log('Error fetching data for site visits chart');
                }
            );
        } else if (this.chartThree) {
            getBookingDataHalfYearly({ selectedYear: parseInt(cYear) })
            .then(result => {
                const processedData = [0, 0];
                let sum = 0;
                let sum2 = 0;
                result.forEach(item => {
                    const MonthValue = item.month;
                    if (MonthValue >= 1 && MonthValue <= 6) {
                        // processedData[MonthValue - 1] += item.recordCount; // Accumulate recordCount by month
                        // sum += recordCount; // Accumulate total sum of recordCount values
                        sum += item.recordCount;
                    } else {
                        sum2 += item.recordCount;
                    }
                });
                processedData[0] = sum;
                processedData[1] = sum2;
                this.chartDataBarBookingHlf = processedData;
                this.renderCombinedHalfyearlyChart();
            })
            .catch(
                error => {
                    console.log('Error fetching data for site visits chart');
                }
            );
            // Fetch data for site visits chart
            getSitevisitsHalfYearly({ selectedYear: parseInt(cYear) })
            .then(result => {
                const processedData = [0, 0];
                let sum = 0; // Initialize sum variable to accumulate recordCount values
                let sum2 = 0;
                result.forEach(item => {
                    const MonthValue = item.month;
                    if (MonthValue >= 1 && MonthValue <= 6) {
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
                    this.chartDataBarsiteVisitHlf = processedData;
                    this.renderCombinedHalfyearlyChart();
                });
                this.chartDataLine[0] = sum;
                this.renderCombinedHalfyearlyChart();
            })
            .catch(
                error => {
                    console.log(error);
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching data for site visits chart',
                            message: 'Error fetching data for site visits chart',
                            variant: 'error',
                        })
                    );*/
                }
            );
        } else if (this.chartFour) {
            getBookingDataYearly({ selectedYear: parseInt(cYear) })
            .then(result => {
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
                this.renderCombinedyearlyChart();
            })
            .catch(
                error => {
                    console.log(error);
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching data for bookings chart',
                            message: 'Error fetching data for bookings chart',
                            variant: 'error',
                        })
                    );*/
                }
            );
            // Fetch data for site visits chart
            getSitevisitsYearly({ selectedYear: parseInt(cYear) })
            .then(result => {
                let processedData = [];
                let resMap = new Map();
                let processedLabel = this.processedLabel;
                result.forEach(item => {
                    let i = 0;
                    processedData.push(item.recordCount);
                    processedLabel.set(item.month, 0);
                });
                this.processedLabel = processedLabel;
                this.chartDataLineSiteVisitYly = processedData;
                let labels = [];
                for (let [key, value] of processedLabel) {
                    labels.push(value);
                }
                this.renderCombinedyearlyChart();
            })
            .catch(
                error => {
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching data for site visits chart',
                            message: 'Error fetching data for site visits chart',
                            variant: 'error',
                        })
                    );*/
                    console.log(error);
                }
            );
        }
    }
    processedLabel = new Map();
    // Method to group data
    groupMonthData() {
        const groupSize = 3;
        for (let i = 0; i < this.chartDataBar.length; i += groupSize) {
            const group = this.chartDataBar.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataBar.push(sum);
        }
    }
    groupMonthDataline() {
        const groupSize = 3;
        for (let i = 0; i < this.chartDataLine.length; i += groupSize) {
            const group = this.chartDataLine.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataLine.push(sum);
        }
    }
    processData(data) {
        const processedData = Array(12).fill(0);
        data.forEach(item => {
            const monthIndex = parseInt(item.month, 10) - 1;
            processedData[monthIndex] = parseInt(item.recordCount, 10);
        });
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
                datasets: [
                {
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    fill: false,
                    borderWidth: 2,
                    type: 'line'
                },
                {
                    label: 'Bookings (Units)',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 2
                }
                ]
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
                datasets: [
                {
                    label: 'Site Visits',
                    data: chartDataLineNoNegatives,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                },
                {
                    label: 'Bookings (Units)',
                    data: chartDataBarNoNegatives,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
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
                datasets: [
                {
                    label: 'Site Visits',
                    data: this.chartDataBarsiteVisitHlf,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                },
                {
                    label: 'Bookings (Units)',
                    data: this.chartDataBarBookingHlf,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
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
                datasets: [
                {
                    label: 'Site Visits',
                    data: this.chartDataLineSiteVisitYly,
                    backgroundColor: 'rgba(22, 193, 34, 0.81)',
                    borderColor: 'rgba(22, 193, 34, 0.81)',
                    borderWidth: 2,
                    fill: false,
                    type: 'line'
                },
                {
                    label: 'Bookings (Units)',
                    data: this.chartDataBarBookYly,
                    backgroundColor: 'rgb(217,217,217)',
                    borderColor: 'rgb(217,217,217)',
                    borderWidth: 1
                }]
            },
            options: {
                scales: scales
            }
        });
    }

    getCurrentByYear() {
        let currentDate = new Date();
        let firstBiYearStart = new Date(currentDate.getFullYear(), 0, 1); 
        let secondBiYearStart = new Date(currentDate.getFullYear(), 6, 1); 
        let biYear;
        if (currentDate >= firstBiYearStart && currentDate < secondBiYearStart) {
            biYear = "H1, " + currentDate.getFullYear();
        } else if (currentDate >= secondBiYearStart) {
            biYear = "H2, " + + currentDate.getFullYear();
        }
        return biYear;
    }

    handleTabClick(event) {
        const selectedTabId = parseInt(event.currentTarget.dataset.tab, 10);
        if(selectedTabId == 1) {
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