import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    loadStyle,
    loadScript
} from 'lightning/platformResourceLoader';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import performanceIcons from '@salesforce/resourceUrl/performanceIcons';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getBookingData from '@salesforce/apex/SitevisitChartController.getBookingData';
import getBookingDataDetails from '@salesforce/apex/SitevisitChartController.getBookingDataDetails';
import getBookingMonthlyData from '@salesforce/apex/SitevisitChartController.getBookingMonthlyData';
import getSitevisitsMonthlyData from '@salesforce/apex/SitevisitChartController.getSitevisitsMonthlyData';
import getBookingFormUrl from '@salesforce/apex/SitevisitChartController.getBookingFormUrl';
import getBookingFormSPAUrl from '@salesforce/apex/SitevisitChartController.getBookingFormSPAUrl';
import getBookingAppartmentsCount from '@salesforce/apex/SitevisitChartController.getBookingAppartmentsCount';
import getBookingVillasCount from '@salesforce/apex/SitevisitChartController.getBookingVillasCount';
import getLoggedInUserContactId from '@salesforce/apex/SitevisitChartController.getLoggedInUserContactId';

import getSitevisits from '@salesforce/apex/SitevisitChartController.getSitevisits';
import getSitevisits1 from '@salesforce/apex/SitevisitChartController.getSitevisits1';
import getSalesBookings from '@salesforce/apex/SitevisitChartController.getSalesBookings';
import getBookingDataYearly from '@salesforce/apex/SitevisitChartController.getBookingDataYearly';
import getSitevisitsYearly from '@salesforce/apex/SitevisitChartController.getSitevisitsYearly';
import getBookingDataQuaterly from '@salesforce/apex/SitevisitChartController.getBookingDataQuaterly';
import getBookingDataHalfYearly from '@salesforce/apex/SitevisitChartController.getBookingDataHalfYearly';
import getSitevisitsQuaterly from '@salesforce/apex/SitevisitChartController.getSitevisitsQuaterly';
import getSitevisitsHalfYearly from '@salesforce/apex/SitevisitChartController.getSitevisitsHalfYearly';
import getUpcomingEvents from '@salesforce/apex/SitevisitChartController.getUpcomingEvents';

import getBookingCount from '@salesforce/apex/SitevisitChartController.getBookingCount';
import getSitevisitsCountInCurrentYear from '@salesforce/apex/SitevisitChartController.getSitevisitsCountInCurrentYear';
import SITEVISITE_IMAGE_URL from '@salesforce/resourceUrl/SitevisitIcon';

import SITEVISITE_IMAGE_LEFT_URL from '@salesforce/resourceUrl/sitevisiticonleft';
import SALES_IMAGE_LEFT_URL from '@salesforce/resourceUrl/Salesiconleft';
import Event_Icon_Image_URL from '@salesforce/resourceUrl/EventlocationIcon';

import PerformanceStyleSheet from '@salesforce/resourceUrl/performanceStyleSheet';
import isEligibleForAction from '@salesforce/apex/PortalBrokerEventsController.isEligibleForAction';
import getBookingsTotalInCurrentYear from '@salesforce/apex/SitevisitChartController.getBookingsTotalInCurrentYear';
import getBookingsInSelectedMonth from '@salesforce/apex/SitevisitChartController.getBookingsInSelectedMonth';


export default class PerformanceDashboardLwc extends LightningElement {
    events = [];
    siteVisitsCount;
    @track isEligible = "main-panel";
    @track booleanEligible = true;
    salesIconleft = SALES_IMAGE_LEFT_URL;
    sitevisitUrl = SITEVISITE_IMAGE_URL;
    siteVisitIconLeft = SITEVISITE_IMAGE_LEFT_URL;
    eventIconImageLeft = Event_Icon_Image_URL;
    monthly = false;
    @track buttonClass1 = '';
    @track buttonClass = '';
    @track buttonClass3 = '';
    @track buttonClass4 = '';
    @api loaderVariant = 'base';
    @api chartConfig;
    @track chartOne = false;
    @track saleschartOne = false;
    @track chartTwo = false;
    @track chartThree = false;
    @track chartFour = false;
    @track error;
    @track selectedYear = '';
    @track totalCount = 0;
    @track totalSalesCount = 0;
    @track totalSalesCountQuarter = 0;
    @track totalSalesCountHalfyear = 0;
    @track totalSalesCountyear = 0;
    @track selectedValue = '';
    @track isModalOpen = false;
    villasBookingCount = 0;
    appartmentsBookingCount = 0;
    chart;
    chartData = [];
    chartDataTwo = [];
    chartjsInitialized = false;
    lineChart;
    barChart;
    labels = [];
    lineChartData = [];
    barChartData = [];
    chartDataLine = [];
    chartDataBar = [];
    chartMonthDataLine = [];
    chartMonthDataBar = [];
    bookingData = []; // Added By Vipul
    newCloneChartLabel = [];
    newCloneDataLine = [];
    sale_icon = portalAssests + '/assets/images/performance-sale-icon-black.svg';
    sale_icon_blue = performanceIcons + '/performanceIcons/saleIconBlue.svg';
    filter_icon_white = performanceIcons + '/performanceIcons/filterIconWhite.svg';
    filter_icon_blue = performanceIcons + '/performanceIcons/filterIconBlue.svg';
    villaIcon = performanceIcons + '/performanceIcons/villa.svg';
    appartmentIcon = performanceIcons + '/performanceIcons/appartment.svg';
    cloneTotalCount = 0;
    yearOptions = [
        { label: '2024', value: '2024' }
    ];
    areaAllValues = [];
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
    wiredContactId({
        error,
        data
    }) {
        if (data) {
            console.log('Logged-in user Contact Id:', data);
        } else if (error) {
            console.error('Error fetching user Contact Id:', error);
        }
    }
    @wire(getSitevisitsCountInCurrentYear)
    wiredSiteVisitsCount({
        error,
        data
    }) {
        if (data) {
            this.siteVisitsCount = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
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
    @wire(isEligibleForAction)
    eligibilityCheck({ error, data }) {
        if (data !== undefined) {
            console.log('Eligibility data is  : ' + data);
            if (data == false) {
                this.booleanEligible = false;
                this.isEligible += ' disableAction';
            }
            if (data == true) {
                console.log('this is true block');
                //  this.isEligible += ' disableAction';
                //this.booleanEligible=true;
            }
        } else if (error) {
            // perform your logic related to error 
        }
    };
    connectedCallback() {
        this.showSiteVisitsTemplate = true;
        this.selectedYear = '2024';
        this.buttonClass1 = 'graph-tab-link active';
        this.chartOne = true;
        this.saleschartOne = true;
        this.loadChartJS();
        this.getData();
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, PerformanceStyleSheet)
        ]).then(() => {
            console.log('Files loaded');
        }).catch(error => {
            console.log(error.body.message);
        });
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


    fetchData() {
        // Fetch data for booking chart
        if (this.chartFive) {
            if (this.dOEvent && this.dOEventTo) {
                var getmonth = this.dOEvent;
                const d = new Date(getmonth);
                var getmonthTo = this.dOEventTo;
                const dTo = new Date(getmonthTo);
                getBookingMonthlyData({
                    fromMonthSelect: d.getMonth() + 1,
                    ToMonthSelect: dTo.getMonth() + 1
                })
                    .then(result => {
                        this.chartDataBar = this.processData(result);
                        if (this.chartFive) {
                            this.renderCombinedChartMonthlyWise();
                        }

                    })
                    .catch(
                        error => {
                            console.log('Error : ', error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error fetching data for bookings chart',
                                    message: error,
                                    variant: 'error',
                                })
                            );
                        }
                    );



                getSitevisitsMonthlyData({
                    fromMonthSelect: d.getMonth() + 1,
                    ToMonthSelect: dTo.getMonth() + 1
                })
                    .then(result => {
                        this.chartDataLine = this.processData(result);
                        if (this.chartFive) {
                            this.renderCombinedChartMonthlyWise();
                        }

                    })
                    .catch(
                        error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error Month fetching data for site visits chart',
                                    message: error.body.message,
                                    variant: 'error',
                                })
                            );
                        }
                    );
            }




        } else if (this.chartOne) {

            //   getBookingData()
            // .then(result => {
            //     console.log("YOU BOOKINGDATA OneMonth" + JSON.stringify(result));
            //     this.chartDataBar = this.processData(result);

            //     if (this.chartOne) {
            //         console.log("this.chartOne" + this.chartOne);
            //         this.renderCombinedChart();
            //     }
            //     if (this.chartTwo) {
            //         console.log("this.chartTwo" + this.chartTwo);
            //         this.renderCombinedQuarterlyChart();
            //     }
            //     if (this.chartThree) {
            //         console.log("this.chartThree" + this.chartThree);
            //         this.renderCombinedHalfyearlyChart();
            //     }
            //     if (this.chartFour) {
            //         console.log("this.chartfour" + this.chartFour);
            //     }



            // })
            // .catch(
            //     error => {
            //         this.dispatchEvent(
            //             new ShowToastEvent({
            //                 title: 'Error fetching data for bookings chart',
            //                 message: error.body.message,
            //                 variant: 'error',
            //             })
            //         );
            //     }
            // );

            // Fetch data for site visits 
            let monthList = [];
            let yearList = [];
            var list = [];
            if (this.dOEvent && !this.dOEventTo) {
                monthList.push(parseInt(this.dOEvent.split('-')[1]));
                yearList.push(parseInt(this.dOEvent.split('-')[0]));
            }
            if (!this.dOEvent && this.dOEventTo) {
                monthList.push(parseInt(this.dOEventTo.split('-')[1]));
                yearList.push(parseInt(this.dOEventTo.split('-')[0]));
            }
            if (this.dOEvent && this.dOEventTo) {
                monthList = [];
                yearList = [];
                let lowEnd = parseInt(this.dOEvent.split('-')[0]);
                let highEnd = parseInt(this.dOEventTo.split('-')[0]);
                for (var i = lowEnd; i <= highEnd; i++) {
                    yearList.push(i);
                }
                let lowEndM = parseInt(this.dOEvent.split('-')[1]);
                let highEndM = parseInt(this.dOEventTo.split('-')[1]);
                for (var i = lowEndM; i <= highEndM; i++) {
                    monthList.push(i);
                }
            }

            if (yearList.length == 0 && monthList.length == 0) {
                let today = new Date();
                yearList.push(today.getFullYear());
                for (var i = 1; i < 13; i++) {
                    monthList.push(i);
                }

            }

            getSitevisits1({
                years: yearList,
                months: monthList
            })
                .then(result => {
                    try {
                        let index = 0;
                        let chartOneLabels = [];
                        let processedData = [];
                        let total = 0;
                        for (let key in result) {
                            chartOneLabels.push(key);
                            // Store the value in processedData array
                            // console.log('Roshan : key '+key);
                            console.log('Roshan : booleanEligible ' + this.booleanEligible);
                            let value;
                            if (this.booleanEligible == true) {
                                value = result[key];
                            }
                            else {
                                value = 0
                            }
                            processedData.push(index);
                            if (this.booleanEligible == true) {
                                processedData[index] = result[key];
                            }
                            else {
                                processedData[index] = 0;
                            }

                            index = index + 1;
                            // Accumulate the total count
                            total += value;
                        }
                        this.totalCount = total;
                        console.log("totalCount" + this.totalCount);
                        this.chartTwo = false;
                        this.chartThree = false;
                        this.chartFour = false;
                        this.chartOneLabels = chartOneLabels;
                        this.chartDataLine = processedData;
                        this.renderCombinedChart();
                        if (this.cloneTotalCount == 0) {
                            this.cloneTotalCount = total;
                        }
                    } catch (error) {
                        console.log('error ' + error);
                    }

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error in Chart One fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );

            getSalesBookings({
                years: yearList,
                months: monthList
            }).then(result => {
                try {
                    let index = 0;
                    let chartOneLabels = [];
                    let processedData = [];
                    let total = 0;
                    for (let key in result) {
                        chartOneLabels.push(key);
                        // Store the value in processedData array
                        const value = result[key];
                        processedData.push(index);
                        processedData[index] = result[key];
                        index = index + 1;
                        // Accumulate the total count
                        total += value;
                    }
                    this.totalSalesCount = total;
                    this.chartOneLabels = chartOneLabels;
                    this.chartDataLine = processedData;
                    //this.renderCombinedChart();
                    if (this.newCloneChartLabel.length == 0 && this.newCloneDataLine.length == 0) {
                        //   this.newCloneChartLabel = chartOneLabels;
                        //   this.newCloneDataLine = processedData;
                    }
                    this.renderSalesChart();
                } catch (error) {
                    console.log('Sales error ' + error);
                }

            })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for Sales chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );

        } else if (this.chartTwo) {
            getBookingDataQuaterly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    let recordCounts = [0, 0, 0, 0];
                    // Loop through the result and update the recordCounts array
                    result.forEach(item => {
                        const exprValue = item.expr0; // Assuming expr0 represents the month (1-4)
                        const recordCount = item.recordCount;
                        if (exprValue >= 1 && exprValue <= 4) {
                            recordCounts[exprValue - 1] = recordCount; // Update recordCount for the corresponding month
                        }
                    });
                    // Set the chartDataBar array based on recordCounts
                    this.chartDataBar = recordCounts;

                    this.renderSalesQuarterlyChart();
                    let totalSumSales = 0;
                    for (let i = 0; i < this.chartDataBar.length; i++) {
                        totalSumSales += this.chartDataBar[i];
                    }
                    this.totalSalesCountQuarter = totalSumSales;
                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for bookings chart',
                                message: error.body.message,
                                variant: 'error',
                            }));
                    });
            // Fetch data for site visits chart
            getSitevisitsQuaterly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    const recordCounts = [0, 0, 0, 0];
                    // Loop through the result and populate processedData based on month
                    result.forEach(item => {
                        const exprValue = item.expr0; // Assuming expr0 represents the month (1-4)
                        const recordCount = item.recordCount;
                        if (exprValue >= 1 && exprValue <= 4) {
                            recordCounts[exprValue - 1] = recordCount; // Update recordCount for the corresponding month
                        }
                    });
                    this.chartDataLine = recordCounts;
                    this.renderCombinedQuarterlyChart();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Quartely fetching data for site visits chart',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
                }
                );
        } else if (this.chartThree) {
            getBookingDataHalfYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    let sumLessThanSix = 0;
                    let sumGreaterThanSix = 0;
                    // Loop through the result to calculate sums based on month value
                    result.forEach(item => {
                        const recordCount = item.recordCount;
                        const month = item.month;

                        if (month <= 6) {
                            // Sum recordCount values for months less than 6
                            sumLessThanSix += recordCount;
                        } else if (month > 6) {
                            // Sum recordCount values for months greater than 6
                            sumGreaterThanSix += recordCount;
                        }
                    });
                    // Create the processeddata array with the computed sums
                    let processeddata = [sumLessThanSix, sumGreaterThanSix];
                    this.chartDataLine = processeddata;
                    let totalSumHalfyear = 0;
                    this.renderSalesHalfYearlyChart();
                    for (let i = 0; i < this.chartDataLine.length; i++) {
                        totalSumHalfyear += this.chartDataLine[i];
                    }
                    this.totalSalesCountHalfyear = totalSumHalfyear;
                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error fetching data for bookings chart',
                                message: error.body.message,
                                variant: 'error',
                            }));
                    });

            // Fetch data for site visits chart
            getSitevisitsHalfYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    this.chartDataLine = [0, 0];
                    // Loop through the result and accumulate recordCount for months < 6
                    result.forEach(item => {
                        const month = item.month;
                        const recordCount = item.recordCount;

                        // Check if the month is less than 6 (i.e., months 1 to 5)
                        /* if (month >= 1 && month <= 5) {
                             // Add recordCount to the first element of chartDataLine
                             this.chartDataLine[0] += recordCount;
                         } */

                        if (month <= 6) {
                            this.chartDataLine[0] += recordCount;
                        } else if (month > 6) {
                            // Sum recordCount values for months greater than 6
                            this.chartDataLine[1] += recordCount;
                        }
                    });
                    this.renderCombinedHalfyearlyChart();

                })
                .catch(
                    error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Half Yearly fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        } else if (this.chartFour) {
            getBookingDataYearly({ selectedYear: parseInt(this.selectedYear) })
                .then(result => {
                    let chartDataLine = [];
                    let resMap = new Map();
                    resMap.set(this.selectedYear, 0);
                    let processedLabel = resMap;
                    let labels = [];
                    result.forEach(item => {
                        const recordCount = item.recordCount;
                        const month = item.month;
                        labels.push(month.toString());
                        // Assign month as label (assuming month is a string representation of the year)
                        // labels.push(month.toString());
                        // processedLabel.set(item.month, item.recordCount);
                        // Assign recordCount to chartDataLine
                        chartDataLine.push(recordCount);
                    });
                    if (result.length == 0) {
                        labels.push(this.selectedYear);
                        chartDataLine.push(0);
                    }
                    // for (let [key, value] of processedLabel) {
                    //     labels.push(key);
                    // }
                    this.labels = labels; // Assuming this is where you want to store labels
                    this.chartDataBar = chartDataLine;
                    this.totalSalesCountyear = this.chartDataBar;
                    this.renderSalesYearlyChart();

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
                    let processedData = [];
                    // const processedLabel = [];
                    let resMap = new Map();
                    resMap.set(this.selectedYear, 0);
                    let processedLabel = new Map();
                    result.forEach(item => {
                        let i = 0;
                        processedLabel.set(item.month, item.recordCount);
                        processedData.push(item.recordCount);
                    });
                    if (result.length == 0) {
                        processedLabel.set(this.selectedYear, 0);
                        processedData.push(0);
                    }
                    this.processedLabel = processedLabel;

                    this.chartDataLine = processedData;
                    this.renderCombinedyearlyChart();

                })
                .catch(
                    error => {
                        console.log(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error In YEARLY fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        } else if (this.saleschartOne) {
            // Fetch data for site visits 
            let monthList = [];
            let yearList = [];
            var list = [];
            if (this.dOEvent && !this.dOEventTo) {
                monthList.push(parseInt(this.dOEvent.split('-')[1]));
                yearList.push(parseInt(this.dOEvent.split('-')[0]));
            }
            if (!this.dOEvent && this.dOEventTo) {
                monthList.push(parseInt(this.dOEventTo.split('-')[1]));
                yearList.push(parseInt(this.dOEventTo.split('-')[0]));
            }
            if (this.dOEvent && this.dOEventTo) {
                monthList = [];
                yearList = [];
                let lowEnd = parseInt(this.dOEvent.split('-')[0]);
                let highEnd = parseInt(this.dOEventTo.split('-')[0]);
                for (var i = lowEnd; i <= highEnd; i++) {
                    yearList.push(i);
                }
                let lowEndM = parseInt(this.dOEvent.split('-')[1]);
                let highEndM = parseInt(this.dOEventTo.split('-')[1]);
                for (var i = lowEndM; i <= highEndM; i++) {
                    monthList.push(i);
                }
            }

            if (yearList.length == 0 && monthList.length == 0) {
                let today = new Date();
                yearList.push(today.getFullYear());
                for (var i = 1; i < 13; i++) {
                    monthList.push(i);
                }

            }
        }

    }
    handleYearChange(event) {
        // Get the selected value from the event
        this.selectedYear = event.detail.value;
        if (this.types.length > 0) {
            this.getBookingsBasedOnSelection();
        } else {
            this.fetchData();
        }


    }
    projOptions = [];
    natOptions = [];
    bedOptions = [];
    saleOptions = [];
    bookOptions = [];
    typeOptions = [];
    agenOptions = [];

    projValue = [];
    natValue = [];
    bedValue = [];
    saleValue = [];
    bookValue = [];
    typeValue = [];
    agenValue = [];
    bookIds = [];
    filterMap = new Map();

    handleChange(e) {
        let eleName = e.target.name;
        let eVal = e.detail.value;
        console.log(eleName, eVal, this.bookValue, this.bookOptions, "changehandle");
        console.log("changehandle eleName" + eleName);
        console.log("changehandle eVal" + eVal);
        let thisVar = this;

        if (eleName == 'proj') {
            console.log("SS-PROJECT");
            if (eVal.length > 0) {
                thisVar.filterMap.set('projectName', eVal);
            } else {
                thisVar.filterMap.delete('projectName');
            }
            this.projValue = eVal;

        } else if (eleName == 'nat') {
            console.log("SS-nat");
            if (eVal.length > 0) {
                thisVar.filterMap.set('natName', eVal);
            } else {
                thisVar.filterMap.delete('natName');
            }
            this.natValue = eVal;

        } else if (eleName == 'bed') {
            console.log("SS-bed");
            if (eVal.length > 0) {
                thisVar.filterMap.set('bedName', eVal);
            } else {
                thisVar.filterMap.delete('bedName');
            }
            this.bedValue = eVal;

        }
        else if (eleName == 'sale') {
            console.log("SS-sale");
            if (eVal.length > 0) {
                // Store range values as strings (e.g., "1000-2000") in the filterMap
                thisVar.filterMap.set('saleRange', eVal); // Just store as text now
            } else {
                thisVar.filterMap.delete('saleRange');
            }
            this.saleValue = eVal;

        } else if (eleName == 'book') {
            console.log("SS-BOOKIF");
            if (eVal.length > 0) {
                thisVar.filterMap.set('bookName', eVal);
            } else {
                thisVar.filterMap.delete('bookName');
            }
            this.bookValue = eVal;

        }
        else if (eleName == 'propType') {
            console.log("SS-BOOKIF");
            if (eVal.length > 0) {
                thisVar.filterMap.set('propType', eVal);
            } else {
                thisVar.filterMap.delete('propType');
            }
            this.typeValue = eVal;

        }

        else if (eleName == 'agen') {
            console.log("SS-AAGENT");
            if (eVal.length > 0) {
                thisVar.filterMap.set('agentName', eVal);
            } else {
                thisVar.filterMap.delete('agentName');
            }
            this.agenValue = eVal;
        }

        if (this.agenValue.length == 0 && this.bookValue.length == 0 && this.saleValue.length == 0 &&
            this.bedValue.length == 0 && this.natValue.length == 0 && this.projValue.length == 0 && this.typeValue == 0) {
            this.bookIds = [];
            this.bookingData = this.bookingDataCopy;

        } else {
            try {
                let filters = this.filterMap;
                var filterObj = {};
                filters.forEach((v, f) => {
                    filterObj[f] = v;
                });

                let results = this.bookingDataCopy.filter(x => {
                    return Object.keys(filterObj).every(function (f) {
                        return filterObj[f].some(function (z) {

                            if (f === 'saleRange' && x.Unit__r && x.Unit__r.Chargeable_Area__c) {
                                const [start, end] = z.split('-').map(Number); // Extract start and end from text
                                // Check if the Chargeable_Area__c falls within the range
                                return start <= x.Unit__r.Chargeable_Area__c && x.Unit__r.Chargeable_Area__c <= end;
                            }
                            if (f === 'propType' && x.Unit__r && x.Unit__r.Tower__r && x.Unit__r.Tower__r.Tower_Type__c) {
                                // Filter by Tower_Type__c (Property Type)
                                return x.Unit__r.Tower__r.Tower_Type__c.toLowerCase() == z.toLowerCase();
                            }

                            if (typeof x[f] === 'string' || x[f] instanceof String) {
                                return x[f] && z && x[f].toLowerCase() == z.toLowerCase();
                            } else {
                                return z == x[f];
                            }
                        });
                    });
                });

                this.bookingData = results;

            } catch (error) {
                console.log(error);
            }
        }
    }


    get mapEntries() {
        console.log(Array.from(this.filterMap.entries()), this.filterMap.entries(), "from");
        return Array.from(this.filterMap.entries()).map(([key, value]) => {
            return { key, value };
        });
    }

    handleDelete(event) {
        const key = event.currentTarget.dataset.key;
        const value = event.currentTarget.dataset.value;
        const entries = Array.from(this.filterMap.entries());
        const index = entries.findIndex(entry => entry[0] === key && entry[1].includes(value));
        if (index !== -1) {
            entries[index][1] = entries[index][1].filter(item => item !== value);
            if (entries[index][1].length === 0) {
                entries.splice(index, 1);
            }
            this.filterMap = new Map(entries);
        }
        this.bookValue = this.bookValue.filter(item => item !== value);
        this.projValue = this.projValue.filter(item => item !== value);
        this.natValue = this.natValue.filter(item => item !== value);
        this.bedValue = this.bedValue.filter(item => item !== value);
        this.saleValue = this.saleValue.filter(item => item !== value);
        this.typeValue = this.typeValue.filter(item => item !== value);

        this.handleChange(event);
    }

    openModal() {
        this.isModalOpen = !this.isModalOpen;

    }
    closeModal() {
        this.isModalOpen = false;
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

    renderCombinedChartMonthlyWise() {
        var labelValue = [];
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const d = new Date(this.dOEvent);
        const dTo = new Date(this.dOEventTo);
        for (var i = d.getMonth() + 1; i <= dTo.getMonth() + 1; i++) {
            labelValue.push(months[i - 1]);
        }
        const ctx = this.template.querySelector('canvas.combined-monthly').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labelValue,
                datasets: [{
                    label: 'Bookings',
                    data: this.chartDataBar,
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 1
                }, {
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgba(255, 0, 0, 0.6)',
                    borderColor: 'rgba(255, 99, 132, 1)',
                    fill: false,
                    borderWidth: 2,
                    type: 'line'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    chartOneLabels = [];
    //render monthly chart for site visit
    renderCombinedChart() {
        if (this.tabSelection == 1) {
            // this.chartDataLine = this.newCloneDataLine;
            // this.chartOneLabels = this.newCloneChartLabel;
        }
        const ctx = this.template.querySelector('canvas.combined-chart').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: this.chartOneLabels,
                datasets: [{
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(148,220,245)',
                    //fill: false,
                    borderWidth: 2,
                    borderRadius: 30,
                    borderSkipped: false,

                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        //display: true,
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    //render sales chart for 1 month
    renderSalesChart() {

        const ctx = this.template.querySelector('canvas.combined-chartSales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: this.chartOneLabels,
                datasets: [{
                    label: 'Sales Bookings (Units)',
                    data: this.chartDataLine,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(148,220,245)',
                    borderWidth: 2,
                    borderRadius: 30,
                    borderSkipped: false,
                    type: 'bar'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        //display: true,
                        position: 'top'
                    }
                },

            }
        });
    }
    //render sales chart for Quartely
    renderSalesQuarterlyChart() {
        const ctx = this.template.querySelector('canvas.combined-quarterchartSales').getContext('2d');

        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                    label: 'Sales Bookings (Units)',
                    data: this.chartDataBar,

                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }
    //render sales booking data for Haly year
    renderSalesHalfYearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-halfyearlychartSales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['B1', 'B2'],
                datasets: [{
                    label: 'Sales Bookings (Units)',
                    data: this.chartDataLine,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }
    //render Yearly chart data of sales Bookings
    renderSalesYearlyChart() {


        const ctx = this.template.querySelector('canvas.combined-yearlychartSales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        labels = this.labels;
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Sales Bookings (Units)',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }
    // Method to render the quarterly combined chart
    renderCombinedQuarterlyChart() {
        const ctx = this.template.querySelector('canvas.combined-quarterchart').getContext('2d');

        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                    label: 'Site Visits',
                    data: this.chartDataLine,

                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }

    renderCombinedHalfyearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-halfyearlychart').getContext('2d');

        if (this.chart) {
            this.chart.destroy();
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['B1', 'B2'],
                datasets: [
                    //     {
                    //     label: 'Bookings',
                    //     data: this.chartDataBar,
                    //     backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    //     borderColor: 'rgba(54, 162, 235, 1)',
                    //     borderWidth: 1
                    // }, 
                    {
                        label: 'Site Visits',
                        data: this.chartDataLine,
                        backgroundColor: 'rgb(144,218,244)',
                        borderColor: 'rgb(144,218,244)',
                        borderWidth: 0.5,
                        fill: false,
                        type: 'bar',
                        barThickness: 'flex'
                    }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }

    renderCombinedyearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-yearlychart').getContext('2d');

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
                    //     {
                    //     label: 'Bookings',
                    //     data: this.chartDataBar,
                    //     backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    //     borderColor: 'rgba(54, 162, 235, 1)',
                    //     borderWidth: 1
                    // },
                    {
                        label: 'Site Visits',
                        data: this.chartDataLine,
                        backgroundColor: 'rgb(144,218,244)',
                        borderColor: 'rgb(144,218,244)',
                        borderWidth: 0.5,
                        fill: false,
                        type: 'bar'
                    }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

    }
    tabSelection;
    handleTabClick(event) {
        const selectedTabId = parseInt(event.currentTarget.dataset.tab, 10);
        this.tabSelection = selectedTabId;
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        this.selectedYear = '2024';
        if (selectedTabId == 1) {

            this.buttonClass1 = 'graph-tab-link active';
            this.buttonClass2 = '';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = true;
            this.saleschartOne = true;
            this.chartTwo = false;
            this.chartThree = false;
            this.chartFour = false;
            this.chartFive = false;
            this.loadChartJS();
            if (this.chartjsInitialized) {
                return;
            }
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;

        } else if (selectedTabId == 2) {
            this.buttonClass2 = 'graph-tab-link active';
            this.buttonClass1 = '';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = false;
            this.chartTwo = true;
            this.chartThree = false;
            this.chartFour = false;
            this.chartFive = false;
            this.loadChartJS();
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;

        } else if (selectedTabId == 3) {
            this.buttonClass3 = 'graph-tab-link active';
            this.buttonClass1 = '';
            this.buttonClass2 = '';
            this.buttonClass4 = '';
            this.chartThree = true;
            this.chartOne = false;
            this.chartTwo = false;
            this.chartFour = false;
            this.chartFive = false;
            this.loadChartJS();
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        } else if (selectedTabId == 4) {
            this.buttonClass4 = 'graph-tab-link active';
            this.buttonClass2 = '';
            this.buttonClass3 = '';
            this.buttonClass1 = '';
            this.chartFour = true;
            this.chartOne = false;
            this.chartTwo = false;
            this.chartThree = false;
            this.chartFive = false;
            this.loadChartJS();
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
            // if (this.chartjsInitialized) {
            //     this.renderCombinedQuarterlyChart();
            // }

        }
    }





    showSiteVisitsTemplate = false;
    showSalesTemplate = false;
    showBookingsTemplate = false;


    handleSiteVisitsClick(event) {
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        this.selectedYear = '2024';
        this.buttonClass1 = 'graph-tab-link active';
        this.buttonClass2 = '';
        this.buttonClass3 = '';
        this.buttonClass4 = '';
        this.chartOne = true;
        this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = true;
        this.showSalesTemplate = false;
        this.showBookingsTemplate = false;
        this.fetchData();
    }

    // Event handler for Sales button click
    handleSalesClick(event) {
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        this.selectedYear = '2024';
        this.buttonClass1 = 'graph-tab-link active';
        this.buttonClass2 = '';
        this.buttonClass3 = '';
        this.buttonClass4 = '';
        this.chartOne = true;
        this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = false;
        this.showSalesTemplate = true;
        this.showBookingsTemplate = false;
        this.fetchData();
    }

    // Event handler for Bookings button click
    handleBookingsClick(event) {
        this.clearFilterMethod();
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;

        this.types = [];
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        this.selectedYear = '2024';

        this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = false;
        this.showSalesTemplate = false;
        this.showBookingsTemplate = true;
    }

    toggleTabe(clickedElement) {
        const listItems = this.template.querySelectorAll('.events-list li');
        listItems.forEach(item => {
            item.classList.remove('active');
        });
        clickedElement.classList.add('active');
    }
    getData() {
        getBookingDataDetails()
            .then(result => {
                console.log("BOOKING RESULT" + JSON.stringify(result));
                const getData = result.map(item => {
                    let isProcessed = false,
                        isCancelled = false,
                        isBooked = false,
                        isUnProcessed = false,
                        isSpaExecuted = false,
                        isDLDPaid = false,
                        BFormSigned = false,
                        salesValueAED;
                    console.log("Paid_Percentage__c" + item.Paid_Percentage__c);
                    // if(item.Paid_Percentage__c = "0"){
                    //           isStatusCancelled = true;
                    // } else if(item.Paid_Percentage__c > "0" && item.Paid_Percentage__c < "50" ){
                    //           isStatusUnbooked = true;
                    // } else if(item.Paid_Percentage__c > "50" && item.Paid_Percentage__c < "90" ){
                    //           isStatusProcessed = true;
                    // } else if(item.Paid_Percentage__c > "90" ){
                    //           isStatusBooked = true;
                    // } 
                    if (item.Status__c !== null && item.Paid_Percentage__c >= 9.5) {
                        isUnProcessed = true;
                    } else if (item.Status__c !== null && item.Paid_Percentage__c < 9.5 && item.Paid_Percentage__c >= 0) {
                        isBooked = true;
                    }
                    if (item.SPA_Executed_Date__c != null) {
                        isSpaExecuted = true;
                    }
                    //if (item.Pre_registration__c == "Completed") {
                    if (item.DLD_Percentage__c == 'Yes') {
                        isDLDPaid = true;
                    } else {
                        isDLDPaid = false;
                    }
                    if (item.Signed_Date__c != null) {
                        BFormSigned = true;
                    }
                    if (item.Agreement_Value__c) {
                        const number = item.Agreement_Value__c;
                        salesValueAED = new Intl.NumberFormat('en-US').format(number);
                    }

                    return {
                        ...item,
                        isProcessed,
                        isCancelled,
                        isUnProcessed,
                        isBooked,
                        isSpaExecuted,
                        isDLDPaid,
                        BFormSigned,
                        salesValueAED,
                        "salesManager": item.Sales_Managers__r
                            ? (item.Sales_Managers__r.FirstName != null ? item.Sales_Managers__r.FirstName : '') +
                            ' ' +
                            (item.Sales_Managers__r.LastName != null ? item.Sales_Managers__r.LastName : '')
                            : "",
                        "salesDirector": item.Sales_Head__r
                            ? (item.Sales_Head__r.FirstName != null ? item.Sales_Head__r.FirstName : '') +
                            ' ' +
                            (item.Sales_Head__r.LastName != null ? item.Sales_Head__r.LastName : '')
                            : ""


                    }
                })
                this.bookingData = getData;
                console.log('******getData variable value*****', getData);
                console.log('******this.bookingData variable value*****', this.bookingData);


                let thisVar = this;
                let p = [];
                let n = [];
                let b = [];
                let s = [];
                let bo = [];
                let ag = [];
                let t = [];
                this.bookingData.forEach(item => {

                    item.showMoreInfo = false;
                    if (item.Unit__r && item.Unit__r.Tower__r.Tower_Type__c) {
                        console.log('line 1520');
                        item.projectType = item.Unit__r.Tower__r.Tower_Type__c;
                        if (!t.includes(item.Unit__r.Tower__r.Tower_Type__c)) {
                            console.log('line 1523');
                            t.push(item.Unit__r.Tower__r.Tower_Type__c);
                            thisVar.typeOptions.push({ label: item.Unit__r.Tower__r.Tower_Type__c, value: item.Unit__r.Tower__r.Tower_Type__c });
                            console.log('line 1526');
                        }
                    } else {
                        item.projectType = '';
                    }

                    if (item.Project__r && item.Project__r.Name) {
                        item.projectName = item.Project__r.Name;
                        if (!p.includes(item.Project__r.Name)) {
                            p.push(item.Project__r.Name);
                            thisVar.projOptions.push({ label: item.Project__r.Name, value: item.Project__r.Name });
                        }
                    } else {
                        item.projectName = '';
                    }
                    if (item.Nationality_V2__c) {
                        item.natName = item.Nationality_V2__c;
                        if (!n.includes(item.Nationality_V2__c)) {
                            n.push(item.Nationality_V2__c);
                            thisVar.natOptions.push({ label: item.Nationality_V2__c, value: item.Nationality_V2__c });
                        }
                    } else {
                        item.natName = '';
                    }
                    if (item.Unit__r && item.Unit__r.No_of_Bedroom__c) {
                        item.bedName = item.Unit__r.No_of_Bedroom__c;
                        if (!b.includes(item.Unit__r.No_of_Bedroom__c)) {
                            b.push(item.Unit__r.No_of_Bedroom__c);
                            thisVar.bedOptions.push({ label: item.Unit__r.No_of_Bedroom__c, value: item.Unit__r.No_of_Bedroom__c });
                        }
                    } else {
                        item.bedName = '';
                    }
                    // if (item.Unit__r && item.Unit__r.Super_Builtup_Area_Sq_Mtr__c) {
                    //     item.saleName = item.Unit__r.Super_Builtup_Area_Sq_Mtr__c;
                    //     if (!s.includes(item.Unit__r.Super_Builtup_Area_Sq_Mtr__c)) {
                    //         s.push(item.Unit__r.Super_Builtup_Area_Sq_Mtr__c);
                    //         thisVar.saleOptions.push({ label: item.Unit__r.Super_Builtup_Area_Sq_Mtr__c, value: item.Unit__r.Super_Builtup_Area_Sq_Mtr__c });
                    //     }
                    // } else {
                    //     item.saleName = '';
                    // }
                    if (item.Unit__r && item.Unit__r.Chargeable_Area__c) {
                        item.saleName = item.Unit__r.Chargeable_Area__c;
                        if (!s.includes(item.Unit__r.Chargeable_Area__c)) {
                            s.push(item.Unit__r.Chargeable_Area__c);
                            thisVar.saleOptions.push({ label: `${item.Unit__r.Chargeable_Area__c} Sq. ft.`, value: String(item.Unit__r.Chargeable_Area__c) });
                            this.areaAllValues.push(item.Unit__r.Chargeable_Area__c);
                        }
                    } else {
                        item.saleName = '';
                    }



                    let v = '';
                    if (item.isProcessed) {
                        v = 'Sold';
                    } else if (item.isCancelled) {
                        v = 'Blocked';
                    } else if (item.isUnProcessed) {
                        v = 'Qualified';
                    }
                    else if (item.isBooked) {
                        v = 'Blocked';
                    }
                    item.bookName = v;
                    if (!bo.includes(v)) {
                        bo.push(v);
                        console.log(item, "item.v");
                        thisVar.bookOptions.push({ label: v, value: v });
                    }
                    if (item.Channel_Partner__r && item.Channel_Partner__r.Name) {
                        item.agentName = item.Channel_Partner__r.Name;
                        if (!ag.includes(item.Channel_Partner__r.Name)) {
                            ag.push(item.Channel_Partner__r.Name);
                            thisVar.agenOptions.push({ label: item.Channel_Partner__r.Name, value: item.Channel_Partner__r.Name });
                        }
                    } else {
                        item.agentName = '';
                    }
                })
                this.bookingDataCopy = this.bookingData;
                console.log('### Booking data copy', this.bookingDataCopy);
            })
            .catch(
                error => {

                }
            );
        console.log('*****nat option is ******', this.natOptions);
        console.log('*****Type option is ******', this.typeOptions);
    }

    get saleOptionsInRange() {
        let lowestValue = Math.min(...this.areaAllValues);
        let highestValue = Math.max(...this.areaAllValues);
        //const saleOptionsRange;
        console.log("Lowest Value: ", lowestValue);
        console.log("Highest Value: ", highestValue);
        lowestValue = Math.floor(lowestValue / 1000) * 1000;
        // Round highestValue up to the nearest 1000
        highestValue = Math.ceil(highestValue / 1000) * 1000;
        // Create ranges of 500 increments
        let range = [];
        let currentStart = lowestValue;
        while (currentStart <= highestValue) {
            let currentEnd = currentStart + 500; // Create a range of 500
            range.push(`${currentStart}-${currentEnd}`);
            currentStart = currentEnd; // Move to the next range
        }

        console.log("Range Array: ", range);
        let saleOptionsRange = []
        // Now create options for the lightning-checkbox-group using these ranges
        saleOptionsRange = range.map(r => ({
            label: r,
            value: r
        }));
        return saleOptionsRange;
    }
    dOEvent;
    dOEventTo;
    chartFive;
    bookingDataCopy;
    handleSelectMonth(event) {
        this.dOEvent = event.target.value; // Start Date

        // Ensure the Start Date is not greater than the End Date
        if (this.dOEventTo && new Date(this.dOEvent) > new Date(this.dOEventTo)) {
            // alert('Start Date cannot be after the End Date');
            this.showToast('Error', 'Start Date cannot be after the End Date', 'error');
            // Reset the Start Date input in the UI
            this.template.querySelector('.start-date-input').value = '';
            this.dOEvent = null; // Reset Start Date in JS
            return;
        }

        this.tabSelection = 8;
        this.chartFive = false;
        this.chartOne = true;
        this.chartTwo = false;
        this.chartThree = false;
        this.chartFour = false;
        this.loadChartJS();

        if (this.showSalesTemplate) {
            this.salesData();
        }
    }

    handleSelectMonthTo(event) {
        this.dOEventTo = event.target.value; // End Date

        // If Start Date is not selected, prevent user from proceeding
        if (!this.dOEvent) {
            //alert('Please select the Start Date first');
            this.showToast('Error', 'Please select the Start Date first', 'error');

            // Reset the End Date input in the UI
            this.template.querySelector('.end-date-input').value = '';
            this.dOEventTo = null; // Reset End Date in JS
            return;
        }

        // Ensure the End Date is not less than the Start Date
        if (new Date(this.dOEventTo) < new Date(this.dOEvent)) {
            // alert('End Date cannot be before the Start Date');
            this.showToast('Error', 'End Date cannot be before the Start Date', 'error');

            // Reset the End Date input in the UI
            this.template.querySelector('.end-date-input').value = '';
            this.dOEventTo = null; // Reset End Date in JS
            return;
        }

        this.tabSelection = 9;
        this.chartFive = false;
        this.chartOne = true;
        this.chartTwo = false;
        this.chartThree = false;
        this.chartFour = false;
        this.loadChartJS();

        if (this.showSalesTemplate) {
            this.salesData();
        }
    }




    downloadFormHandler(event) {
        let targetId = event.target.dataset.targetId;
        let targetName = event.target.dataset.targetName;
        getBookingFormUrl({
            recordId: targetId,
            fileTitle: targetName

        })
            .then(result => {
                if (result != null) {
                    window.open(result);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'File is not available',
                            message: 'File is not available',
                            variant: 'error',
                        })
                    );
                }

            })
            .catch(
                error => {
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Please contact sysytem admin.',
                                message: error.message,
                                variant: 'error',
                            })
                        );
                    }
                }
            );
    }
    getSelectedYear() {
        return this.selectedYear;
    }
    downloadFormSPAHandler(event) {
        let targetId = event.target.dataset.targetId;
        getBookingFormSPAUrl({
            recordId: targetId,
        })
            .then(result => {
                if (result != null) {
                    window.open(result);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'File is not available',
                            message: 'File is not available',
                            variant: 'error',
                        })
                    );
                }

            })
            .catch(
                error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Please contact sysytem admin.',
                            message: error.message,
                            variant: 'error',
                        })
                    );
                }
            );
    }

    types = [];
    handleCheckboxClick(event) {

        let selectedId = event.currentTarget.name;
        let checked = event.currentTarget.checked;
        if (!checked) {
            if (selectedId == 'villas') {
                let index = this.types.indexOf('Villas');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }

            } else if (selectedId == 'apartments') {
                let index = this.types.indexOf('Apartments');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }
            } else if (selectedId == 'others') {
                let index1 = this.types.indexOf('Townhouses');
                if (index1 > -1) { // only splice array when item is found
                    this.types.splice(index1, 1); // 2nd parameter means remove one item only
                }
                let index = this.types.indexOf('');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }
            }
        }
        if (selectedId == 'villas' && checked) {
            this.types.push('Villas');
        } else if (selectedId == 'apartments' && checked) {
            this.types.push('Apartments');
        } else if (selectedId == 'others' && checked) {
            this.types.push('Townhouses');
            this.types.push('');
        }
        if (this.types.length > 0) {
            this.getBookingsBasedOnSelection();

        } else {
            this.fetchData();
        }
        this.salesData();
    }

    getBookingsBasedOnSelection() {
        if (this.chartOne) {
            let monthList = [];
            let yearList = [];

            if (this.dOEvent && !this.dOEventTo) {
                monthList.push(parseInt(this.dOEvent.split('-')[1]));
                yearList.push(parseInt(this.dOEvent.split('-')[0]));
            }
            if (!this.dOEvent && this.dOEventTo) {
                monthList.push(parseInt(this.dOEventTo.split('-')[1]));
                yearList.push(parseInt(this.dOEventTo.split('-')[0]));
            }
            if (this.dOEvent && this.dOEventTo) {
                monthList = [];
                yearList = [];
                let lowEnd = parseInt(this.dOEvent.split('-')[0]);
                let highEnd = parseInt(this.dOEventTo.split('-')[0]);
                for (var i = lowEnd; i <= highEnd; i++) {
                    yearList.push(i);
                }
                let lowEndM = parseInt(this.dOEvent.split('-')[1]);
                let highEndM = parseInt(this.dOEventTo.split('-')[1]);
                for (var i = lowEndM; i <= highEndM; i++) {
                    monthList.push(i);
                }
            }

            if (yearList.length == 0 && monthList.length == 0) {
                let today = new Date();
                yearList.push(today.getFullYear());
                for (var i = 1; i < 13; i++) {
                    monthList.push(i);
                }
            }

            getBookingCount({
                types: this.types,
                frequency: 'month',
                years: yearList,
                months: monthList
            })
                .then(result => {
                    try {
                        let index = 0;
                        let chartOneLabels = [];
                        let processedData = [];
                        //  let total = 0;
                        for (let key in result) {
                            chartOneLabels.push(key);
                            // Store the value in processedData array
                            const value = result[key];
                            processedData.push(index);
                            processedData[index] = result[key];
                            index = index + 1;
                            // Accumulate the total count
                            //  total += value;
                        }
                        //this.totalSalesCount = total;
                        this.chartOneLabels = chartOneLabels;
                        this.chartDataLine = processedData;
                        //this.renderCombinedChart();
                        this.renderSalesChart();

                    } catch (error) {
                        console.log('error ' + error);
                    }

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error COUNT fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );

        } else {
            let freq = '';
            if (this.chartTwo) {
                freq = 'quarter';
            } else if (this.chartThree) {
                freq = 'biyear';
            } else if (this.chartFour) {
                freq = 'year';
            }
            getBookingCount({
                types: this.types,
                frequency: freq,
                years: [],
                months: [],
                selectedYear: parseInt(this.selectedYear)
            })
                .then(result => {
                    try {
                        try {
                            let index = 0;
                            //let chartOneLabels = [];
                            let processedData = [];
                            //  let total = 0;
                            for (let key in result) {
                                // chartOneLabels.push(key);
                                // Store the value in processedData array
                                //const value = result[key];
                                processedData.push(index);
                                processedData[index] = result[key];
                                index = index + 1;
                                // Accumulate the total count
                                //  total += value;
                            }
                            //this.totalSalesCount = total;
                            // this.chartOneLabels = chartOneLabels;
                            // console.log("Sales Chartone labels" + this.chartOneLabels);

                            // console.log('Sales ChartLIne' + this.chartDataBar);
                            //this.renderCombinedChart();
                            if (this.chartTwo) {
                                this.chartDataBar = processedData;
                                this.renderSalesQuarterlyChart();
                            } else if (this.chartThree) {
                                this.chartDataLine = processedData;
                                this.renderSalesHalfYearlyChart();
                            } else if (this.chartFour) {
                                this.chartDataBar = processedData;
                                this.renderSalesYearlyChart();
                            }
                        }
                        catch (error) {
                            console.log('error ' + error);
                        }

                    } catch (error) {
                        console.log('error ' + error);
                    }

                })
                .catch(
                    error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Booking fetching data for site visits chart',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    }
                );
        }
    }


    refreshPage() {
        // Reload the current page
        location.reload();
    }


    handleMoreInfo(event) {
        console.log("handleMoreInfo1844");
        try {
            const getIndex = event.currentTarget.dataset.index || event.detail.index;
            console.log(getIndex, event, this.bookingData[getIndex], this.bookingData[getIndex],
                "handleMoreInfo"
            );
            this.bookingData = this.bookingData.map((item, index) => {
                if (index == getIndex) {
                    item.showMoreInfo = !item.showMoreInfo;
                } else {
                    item.showMoreInfo = false;
                }
                return item;
            });

        } catch (error) {
            console.log("error--handleMoreInfo", error.message);
        }
    }
    totalBookingsinYear = 0;
    duplicatetotalBookingsinYear = 0;

    @wire(getBookingsTotalInCurrentYear)
    wiredBookingsVisitsCount({
        error,
        data
    }) {
        if (data) {
            console.log("this.totalBookingsinYear" + JSON.stringify(data));
            this.totalBookingsinYear = (data / 1000000).toFixed(2);
            this.duplicatetotalBookingsinYear = (data / 1000000).toFixed(2);
            console.log("this.totalBookingsinYear" + this.totalBookingsinYear);

        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }


    salesData() {
        //this.totalBookingsinYear = 0;
        var getmonth = this.dOEvent;
        const d = new Date(getmonth);
        var getmonthTo = this.dOEventTo;
        const dTo = new Date(getmonthTo);

        let monthList = [];
        if (this.dOEvent && !this.dOEventTo) {
            monthList.push(parseInt(this.dOEvent.split('-')[1]));
        }
        if (!this.dOEvent && this.dOEventTo) {
            monthList.push(parseInt(this.dOEventTo.split('-')[1]));
        }
        if (this.dOEvent && this.dOEventTo) {
            monthList = [];
            let lowEndM = parseInt(this.dOEvent.split('-')[1]);
            let highEndM = parseInt(this.dOEventTo.split('-')[1]);
            for (var i = lowEndM; i <= highEndM; i++) {
                monthList.push(i);
            }
        }

        getBookingsInSelectedMonth({
            months: monthList,
            TypeValue: this.types

        })
            .then(result => {
                //this.totalBookingsinYear ;
                console.log('result--Vi1', result);
                this.totalBookingsinYear = (result / 1000000).toFixed(2);

            })
            .catch(
                error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Month fetching data for site visits chart',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
                }
            );
    }

    clearFilterMethod() {
        this.agenValue.length = 0
        this.bookValue.length = 0
        this.saleValue.length = 0
        this.bedValue.length = 0
        this.natValue.length = 0
        this.projValue.length = 0
        this.filterMap.clear();
        this.handleChange({ target: { name: 'abc' }, detail: { value: [] } });
        this.isModalOpen = false;
    }


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}