import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllTabData from '@salesforce/apex/CollectionDashboardManagementController.getAllTabData';
import getAgeingData from '@salesforce/apex/CollectionDashboardManagementController.getAgeingData';
import getYearList from '@salesforce/apex/CollectionDashboardManagementController.getYearList';
import calculateAdvancePayment from '@salesforce/apex/createAdvancePaymentRecordsBatch.calculateAdvancePayment';
import getYearWisePaymentMilestones from '@salesforce/apex/CollectionDashboardController.getYearWisePaymentMilestones';
import getMilestoneCollectiveData from '@salesforce/apex/CollectionDashboardManagementController.getMilestoneCollectiveData';
import getMilestoneAllData from '@salesforce/apex/CollectionDashboardManagementController.getMilestoneAllData';

export default class CollectionDashboard extends NavigationMixin(LightningElement) {

    @track isAll = false;
    @track isModalOpen = false;

    @track allTabData = [];
    @track totalyearOne = 0;
    @track totalyearTwo = 0;
    @track allTabSubProjectWiseData = [];
    @track allTabSubProjectWiseDataSectionOne = [];
    @track allTabSubProjectWiseDataSectionTwo = [];
    @track allTabSubProjectWiseDataSectionThree = [];
    @track allTabTowerWiseData = [];
    @track allTabUnitWiseData = [];
    @track allTabUnitWiseDataMain = [];
    @track allTabAgeingWiseData = [];
    @track showSubProjectData = false;
    @track showTowerData = false;
    @track showUnitData = false;
    @track selectedTower = '';
    @track allFutureMilestoneYear = [];
    @track advacePaymentProject = null;
    @track total_Payment_Milestone_Project = null;
    @track advacePaymentTower = null;
    @track total_Payment_Milestone_Tower = null;
    @track advacePaymentSubProject = null;
    @track total_Payment_Milestone_SubProject = null;

    @track secOneUnitCount;
    @track secOnePurchasePrice;
    @track secOneMilestoneDue;
    @track secOneCollected;
    @track secOneInvestor;
    @track secOneAdvance;
    @track secOneDue;
    @track secOneFuture;
    @track secOneFutureOneYear;
    @track secOneFutureTowYear;
    @track secOneFutureMilestoneDues = [];

    @track secOnetotalAdvanceAmount = [];
    @track secTwototalAdvanceAmount = [];
    @track secThreetotalAdvanceAmount = [];
    @track milestoneAgeingRecordsList = null;
    @track milestoneALLAgeingRecordsList = null;

    @track secTwoUnitCount;
    @track secTwoPurchasePrice;
    @track secTwoMilestoneDue;
    @track secTwoCollected;
    @track secTwoInvestor;
    @track secTwoAdvance;
    @track secTwoDue;
    @track secTwoFuture;
    @track secTwoFutureOneYear;
    @track secTwoFutureTwoYear;
    @track secTwoFutureMilestoneDues = [];

    @track secThreeUnitCount;
    @track secThreePurchasePrice;
    @track secThreeMilestoneDue;
    @track secThreeCollected;
    @track secThreeInvestor;
    @track secThreeDue;
    @track secThreeDue;
    @track secThreeFuture;
    @track secThreeFutureOneYear;
    @track secThreeFutureTwoYear;
    @track secThreeFutureMilestoneDues = [];

    
    @track secOneDue_B1 = 0;
    @track secOneDue_B2 = 0;
    @track secOneDue_B3 = 0;
    @track secOneDue_B4 = 0;
    @track secOneDue_B5 = 0;
    @track secOneDue_B6 = 0;
    @track secOneDue_B7 = 0;

    @track secTwoDue_B1 = 0;
    @track secTwoDue_B2 = 0;
    @track secTwoDue_B3 = 0;
    @track secTwoDue_B4 = 0;
    @track secTwoDue_B5 = 0;
    @track secTwoDue_B6 = 0;
    @track secTwoDue_B7 = 0;

    @track secThreeDue_B1 = 0;
    @track secThreeDue_B2 = 0;
    @track secThreeDue_B3 = 0;
    @track secThreeDue_B4 = 0;
    @track secThreeDue_B5 = 0;
    @track secThreeDue_B6 = 0;
    @track secThreeDue_B7 = 0;

    @track isAgeing = false;


    connectedCallback() {
        this.showTowerData = false;
        this.showSubProjectData = false;
        this.showUnitData = false;
        this.loadYearList();
        this.calculateAdvancePayment();
        this.calculatePaymentMileStoneTotal();
    }

    loadYearList() {
        this.showSpinner = true;
        getYearList()
            .then(result => {
                console.log('this.is result log',JSON.stringify(result));
                this.showSpinner = false;
                this.allFutureMilestoneYear = result;
                this.getMilestoneCollectiveData('allProject','');
                this.getMilestoneAllData();
                this.loadAllTabData('Project', '');
            })
            .catch(error => {
                console.log('this.is error log',JSON.stringify(error));
                this.showSpinner = false;
            });
    }

    onProjectSelect(event) {
        this.selectedTower = '';
        this.showTowerData = false;
        this.showSubProjectData = true;
        this.showUnitData = false;
        this.allTabSubProjectWiseData = [];

        this.allTabSubProjectWiseDataSectionOne = [];
        this.allTabSubProjectWiseDataSectionTwo = [];
        this.allTabSubProjectWiseDataSectionThree = [];

        this.secOneUnitCount = '';
        this.secOnePurchasePrice = '';
        this.secOneMilestoneDue = '';
        this.secOneCollected = '';
        this.secOneInvestor = '';
        this.secOneAdvance = '';
        this.secOneDue = '';
        this.secOneFuture = '';
        this.secOneFutureOneYear = '';
        this.secOneFutureTowYear = '';
        this.secOneFutureMilestoneDues = [];

        this.secTwoUnitCount = '';
        this.secTwoPurchasePrice = '';
        this.secTwoMilestoneDue = '';
        this.secTwoCollected = '';
        this.secTwoInvestor = '';
        this.secTwoAdvance = '';
        this.secTwoDue = '';
        this.secTwoFuture = '';
        this.secTwoFutureOneYear = '';
        this.secThreeFutureOneYear = '';
        this.secThreeFutureTwoYear = '';
        this.secTwoFutureTwoYear = '';
        this.secTwoFutureMilestoneDues = [];

        this.secThreeUnitCount = '';
        this.secThreePurchasePrice = '';
        this.secThreeMilestoneDue = '';
        this.secThreeCollected = '';
        this.secThreeInvestor = '';
        this.secThreeAdvance = '';
        this.secThreeDue = '';
        this.secThreeFuture = '';
        this.secThreeFutureMilestoneDues = [];

        this.allTabTowerWiseData = [];
        this.allTabUnitWiseData = [];
        this.allTabUnitWiseDataMain = [];
        this.allTabAgeingWiseData = [];
        var projectId = event.currentTarget.id;
        projectId = projectId.split('-')[0];
        console.log('projectId ->',projectId);
        this.getMilestoneCollectiveData('project', projectId);
        this.loadAllTabData('SubProject', projectId);
    }

    onSubProjectSelect(event) {
        this.selectedTower = '';
        this.showTowerData = true;
        this.showUnitData = false;
        this.allTabTowerWiseData = [];
        this.allTabUnitWiseData = [];
        this.allTabUnitWiseDataMain = [];
        this.allTabAgeingWiseData = [];
        var subProjectId = event.currentTarget.id;
        subProjectId = subProjectId.split('-')[0];
        this.getMilestoneCollectiveData('SubProject', subProjectId);
        this.loadAllTabData('Tower', subProjectId);
    }

    onTowerSelect(event) {
        this.selectedTower = event.currentTarget.value;
        this.showUnitData = true;
        this.allTabUnitWiseData = [];
        this.allTabUnitWiseDataMain = [];
        this.allTabAgeingWiseData = [];
        var towerId = event.currentTarget.id;
        towerId = towerId.split('-')[0];
        this.loadAgeingData(towerId);
        this.getMilestoneCollectiveData('Tower', towerId);
        this.loadAllTabData('Unit', towerId);
        this.isModalOpen = true;
    }

    onAgeingSelect(event) {
        this.allTabUnitWiseData = [];
        var bucketColor = event.currentTarget.id;
        bucketColor = bucketColor.split('-')[0];
        if (bucketColor == 'Green') {
            bucketColor = 'background-color:#B1ffB1';
        }
        else if (bucketColor == 'Yellow') {
            bucketColor = 'background-color:#FCFF6F';
        }
        else if (bucketColor == 'Amber') {
            bucketColor = 'background-color:#FFBF00';
        }
        else if (bucketColor == 'Red') {
            bucketColor = 'background-color:#FF6F59';
        }
        else if (bucketColor == 'Blue') {
            bucketColor = 'background-color:#ADD8E6';
        }

        var allTabUnitWiseData = this.allTabUnitWiseDataMain;
        var allTabUnitWiseDataTemp = [];
        for (var i = 0; i < allTabUnitWiseData.length; i++) {
            if (allTabUnitWiseData[i].bucketColor == bucketColor) {
                allTabUnitWiseDataTemp.push(allTabUnitWiseData[i]);
            }
        }
        this.allTabUnitWiseData = allTabUnitWiseDataTemp;
    }

    loadAgeingData(towerId) {
        this.showSpinner = true;
        getAgeingData({ towerId: towerId })
            .then(result => {
						    console.log('FIX');
						    console.log(result);
                let nfObject = new Intl.NumberFormat('en-US');
                for (var i = 0; i < result.length; i++) {
                    result[i].totalPurchasePrice = nfObject.format(result[i].totalPurchasePrice);
                    result[i].totalMilestoneDueTillDate = nfObject.format(result[i].totalMilestoneDueTillDate);
                    result[i].totalCollectedAmount = nfObject.format(result[i].totalCollectedAmount);
                    result[i].totalDueAmount = nfObject.format(result[i].totalDueAmount);
                }
                this.allTabAgeingWiseData = result;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadAllTabData(type, recordId) {
        this.showSpinner = true;
        getAllTabData({ type: type, recordId: recordId })
            .then(result => {
                console.log('loadAllTabData 1--> ',JSON.parse(JSON.stringify(result)));
                let nfObject = new Intl.NumberFormat('en-US');
                var allTabSubProjectWiseDataSectionOne = [];
                var allTabSubProjectWiseDataSectionTwo = [];
                var allTabSubProjectWiseDataSectionThree = [];

                var secOneUnitCount = 0;
                var secOnePurchasePrice = 0;
                var secOneMilestoneDue = 0;
                var secOneCollected = 0;
                var secOneInvestor = 0;
                var secOneAdvance = 0;
                var secOneDue = 0;
                var secOneFuture = 0;
                var secOneFutureOneYear = 0;
                var secOneFutureTowYear = 0;
                var secOneFutureMilestoneDues = [];

                var secTwoUnitCount = 0;
                var secTwoPurchasePrice = 0;
                var secTwoMilestoneDue = 0;
                var secTwoCollected = 0;
                var secTwoInvestor = 0;
                var secTwoAdvance = 0;
                var secTwoDue = 0;
                var secTwoFuture = 0;
                var secTwoFutureOneYear = 0;
                var secTwoFutureTwoYear = 0;
                var secTwoFutureMilestoneDues = [];

                var secThreeUnitCount = 0;
                var secThreePurchasePrice = 0;
                var secThreeMilestoneDue = 0;
                var secThreeCollected = 0;
                var secThreeInvestor = 0;
                var secThreeAdvance = 0;
                var secThreeDue = 0;
                var secThreeFuture = 0;
                var secThreeFutureOneYear = 0;
                var secThreeFutureTwoYear = 0;

                var secOnetotalAdvanceAmount = 0;
                var secTwototalAdvanceAmount = 0;
                var secThreetotalAdvanceAmount = 0;

                var secOneDue_B1 = 0;
                var secOneDue_B2 = 0;
                var secOneDue_B3 = 0;
                var secOneDue_B4 = 0;
                var secOneDue_B5 = 0;
                var secOneDue_B6 = 0;
                var secOneDue_B7 = 0;

                var secTwoDue_B1 = 0;
                var secTwoDue_B2 = 0;
                var secTwoDue_B3 = 0;
                var secTwoDue_B4 = 0;
                var secTwoDue_B5 = 0;
                var secTwoDue_B6 = 0;
                var secTwoDue_B7 = 0;

                var secThreeDue_B1 = 0;
                var secThreeDue_B2 = 0;
                var secThreeDue_B3 = 0;
                var secThreeDue_B4 = 0;
                var secThreeDue_B5 = 0;
                var secThreeDue_B6 = 0;
                var secThreeDue_B7 = 0;

                var secThreeFutureMilestoneDues = [];
                for (var t = 0; t < this.allFutureMilestoneYear.length; t++) {
                    secOneFutureMilestoneDues[t] = 0;
                    secTwoFutureMilestoneDues[t] = 0;
                    secThreeFutureMilestoneDues[t] = 0;
                }
                
                for (var i = 0; i < result.length; i++) {
                    var totalPurchasePrice = result[i].totalPurchasePrice;
                    var totalMilestoneDueTillDate = result[i].totalMilestoneDueTillDate;
                    var totalCollectedAmount = result[i].totalCollectedAmount;
                    var totalDueAmount = result[i].totalDueAmount;
                    var advanceAmount = result[i].advanceAmount;
                    var totalAdvanceAmount = result[i].totalAdvanceAmount;
                    var totalInvestorUnitValue = result[i].totalInvestorUnitValue;
                    var futureCollections = result[i].futureCollections;
                    var futureMilestoneDues = result[i].futureMilestoneDues;

                    result[i].totalPurchasePrice = nfObject.format(result[i].totalPurchasePrice);
                    result[i].totalMilestoneDueTillDate = nfObject.format(result[i].totalMilestoneDueTillDate);
                    result[i].totalCollectedAmount = nfObject.format(result[i].totalCollectedAmount);
                    result[i].totalDueAmount = nfObject.format(result[i].totalDueAmount);
                    result[i].advanceAmount = nfObject.format(result[i].advanceAmount);
                    result[i].totalAdvanceAmount = nfObject.format(result[i].totalAdvanceAmount);
                    result[i].totalInvestorUnitValue = nfObject.format(result[i].totalInvestorUnitValue);
                    result[i].futureCollections = nfObject.format(result[i].futureCollections);

                    if(result[i].projectName != 'All' && result[i].projectName != 'Underwriting'){
                        var milestoneYO = this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId] ? this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId][this.allFutureMilestoneYear[0]] ? this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var milestoneYT = this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId] ? this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId][this.allFutureMilestoneYear[1]] ? this.total_Payment_Milestone_Project.projectPaymentMilestoneYearMap[result[i].projectId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        var advanceYO = this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId] ? this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId][this.allFutureMilestoneYear[0]] ? this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var advanceYT = this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId] ? this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId][this.allFutureMilestoneYear[1]] ? this.advacePaymentProject.projectAdvancePaymentYearMap[result[i].projectId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        this.totalyearOne += milestoneYO - advanceYO;
                        this.totalyearTwo += milestoneYT - advanceYT;
                        result[i].YearOne = nfObject.format( milestoneYO - advanceYO);
                        result[i].YearTwo = nfObject.format(milestoneYT - advanceYT);

                    }
                    
                    if (type == 'SubProject') {
                        
                        var milestoneYO = this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId] ? this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId][this.allFutureMilestoneYear[0]] ? this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var milestoneYT = this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId] ? this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId][this.allFutureMilestoneYear[1]] ? this.total_Payment_Milestone_SubProject.subProjectPaymentMilestoneYearMap[result[i].subProjectId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        var advanceYO = this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId] ? this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId][this.allFutureMilestoneYear[0]] ? this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var advanceYT = this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId] ? this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId][this.allFutureMilestoneYear[1]] ? this.advacePaymentSubProject.subProjectAdvancePaymentYearMap[result[i].subProjectId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        
                        result[i].YearOne = nfObject.format( milestoneYO - advanceYO);
                        result[i].YearTwo = nfObject.format(milestoneYT - advanceYT);

                        if (result[i].isOngoing == true) {
                            secThreeUnitCount += result[i].totalUnit;
                            secThreePurchasePrice += totalPurchasePrice;
                            secThreeMilestoneDue += totalMilestoneDueTillDate;
                            secThreeCollected += totalCollectedAmount;
                            secThreeInvestor += totalInvestorUnitValue;
                            secThreeDue += totalDueAmount;
                            secThreeAdvance += totalAdvanceAmount;
                            secThreeFuture += futureCollections;
                            secThreeFutureOneYear += (milestoneYO - advanceYO);
                            secThreeFutureTwoYear += (milestoneYT - advanceYT)
                            secThreetotalAdvanceAmount += totalAdvanceAmount;
                            allTabSubProjectWiseDataSectionThree.push(result[i]);
                            
                        }
                        else if (result[i].section == 'Section 1') {
                            secOneUnitCount += result[i].totalUnit;
                            secOnePurchasePrice += totalPurchasePrice;
                            secOneMilestoneDue += totalMilestoneDueTillDate;
                            secOneCollected += totalCollectedAmount;
                            secOneInvestor += totalInvestorUnitValue;
                            secOneAdvance += totalAdvanceAmount;
                            secOneDue += totalDueAmount;
                            secOneFuture += futureCollections;
                            secOneFutureOneYear += (milestoneYO - advanceYO);
                            secOneFutureTowYear += (milestoneYT - advanceYT);
                            secOnetotalAdvanceAmount += totalAdvanceAmount;
                            allTabSubProjectWiseDataSectionOne.push(result[i]);
                            
                        }
                        else {
                            secTwoUnitCount += result[i].totalUnit;
                            secTwoPurchasePrice += totalPurchasePrice;
                            secTwoMilestoneDue += totalMilestoneDueTillDate;
                            secTwoCollected += totalCollectedAmount;
                            secTwoInvestor += totalInvestorUnitValue;
                            secTwoAdvance += totalAdvanceAmount;
                            secTwoDue += totalDueAmount;
                            secTwoFuture += futureCollections;
                            secTwoFutureOneYear += (milestoneYO - advanceYO);
                            secTwoFutureTwoYear += (milestoneYT - advanceYT);
                            secTwototalAdvanceAmount += totalAdvanceAmount;
                            allTabSubProjectWiseDataSectionTwo.push(result[i]);
                            
                        }

                        

                    }  
                    if(type == 'Tower'){
                        var milestoneYO = this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId] ? this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId][this.allFutureMilestoneYear[0]] ? this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var milestoneYT = this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId] ? this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId][this.allFutureMilestoneYear[1]] ? this.total_Payment_Milestone_Tower.towerPaymentMilestoneYearMap[result[i].towerId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        var advanceYO = this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId] ? this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId][this.allFutureMilestoneYear[0]] ? this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId][this.allFutureMilestoneYear[0]] : 0 : 0;
                        var advanceYT = this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId] ? this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId][this.allFutureMilestoneYear[1]] ? this.advacePaymentTower.towerAdvancePaymentYearMap[result[i].towerId][this.allFutureMilestoneYear[1]] : 0 : 0;
                        
                        result[i].YearOne = nfObject.format( milestoneYO - advanceYO);
                        result[i].YearTwo = nfObject.format(milestoneYT - advanceYT);
                    }              
                
                }
                if (type == 'Project'){
                    result[0].YearOne = nfObject.format(this.totalyearOne);
                    result[0].YearTwo = nfObject.format(this.totalyearTwo);
                    this.allTabData = result;
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabData.length; index++) {
                                console.log('index : ' , JSON.stringify(this.milestoneAgeingRecordsList));
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    console.log('index : ' , key, ' = ',mvar.allTabData[index].projectId);
                                    if(key == mvar.allTabData[index].projectId){
                                        mvar.allTabData[index] = {...mvar.allTabData[index] ,...abc[key]};
                                    }
                                });
                                console.log('index : ' , JSON.stringify(this.allTabData[index]));    
                            }
                        }
                    }, 1000);
                    setTimeout(() => {
                        if(this.milestoneALLAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabData.length; index++) {
                                console.log('index : ' , JSON.stringify(this.milestoneALLAgeingRecordsList));
                                var abc = JSON.parse(JSON.stringify(this.milestoneALLAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    console.log('index : ' , key, ' = ',mvar.allTabData[index].projectId);
                                    if(key == mvar.allTabData[index].projectId){
                                        mvar.allTabData[index] = {...mvar.allTabData[index] ,...abc[key]};
                                    }
                                });
                                console.log('index : ' , JSON.stringify(this.allTabData[index]));    
                            }
                        }
                    }, 1000);

                }else if (type == 'SubProject') {
                    this.allTabSubProjectWiseData = result;
                    this.allTabSubProjectWiseDataSectionOne = allTabSubProjectWiseDataSectionOne;
                    this.allTabSubProjectWiseDataSectionTwo = allTabSubProjectWiseDataSectionTwo;
                    this.allTabSubProjectWiseDataSectionThree = allTabSubProjectWiseDataSectionThree;

                    this.secOneUnitCount = secOneUnitCount;
                    this.secOnePurchasePrice = nfObject.format(secOnePurchasePrice);
                    this.secOneMilestoneDue = nfObject.format(secOneMilestoneDue);
                    this.secOneCollected = nfObject.format(secOneCollected);
                    this.secOneInvestor = nfObject.format(secOneInvestor);
                    this.secOneAdvance = nfObject.format(secOneAdvance);
                    this.secOneDue = nfObject.format(secOneDue);
                    this.secOneFuture = nfObject.format(secOneFuture);
                    this.secOneFutureOneYear = nfObject.format(secOneFutureOneYear);
                    this.secOneFutureTowYear = nfObject.format(secOneFutureTowYear);

                    this.secThreetotalAdvanceAmount = nfObject.format(secThreetotalAdvanceAmount);
                    this.secOnetotalAdvanceAmount = nfObject.format(secOnetotalAdvanceAmount);
                    this.secTwototalAdvanceAmount = nfObject.format(secTwototalAdvanceAmount);

                    var secOneFutureMilestoneDuesTemp = [];
                    for (var n = 0; n < secOneFutureMilestoneDues.length; n++) {
                        secOneFutureMilestoneDuesTemp.push(nfObject.format(secOneFutureMilestoneDues[n]));
                    }
                    this.secOneFutureMilestoneDues = secOneFutureMilestoneDuesTemp;

                    this.secTwoUnitCount = secTwoUnitCount;
                    this.secTwoPurchasePrice = nfObject.format(secTwoPurchasePrice);
                    this.secTwoMilestoneDue = nfObject.format(secTwoMilestoneDue);
                    this.secTwoCollected = nfObject.format(secTwoCollected);
                    this.secTwoInvestor = nfObject.format(secTwoInvestor);
                    this.secTwoAdvance = nfObject.format(secTwoAdvance);
                    this.secTwoDue = nfObject.format(secTwoDue);
                    this.secTwoFuture = nfObject.format(secTwoFuture);
                    this.secTwoFutureOneYear = nfObject.format(secTwoFutureOneYear);
                    this.secTwoFutureTwoYear = nfObject.format(secTwoFutureTwoYear);
                    var secTwoFutureMilestoneDuesTemp = [];
                    for (var n = 0; n < secTwoFutureMilestoneDues.length; n++) {
                        secTwoFutureMilestoneDuesTemp.push(nfObject.format(secTwoFutureMilestoneDues[n]));
                    }
                    this.secTwoFutureMilestoneDues = secTwoFutureMilestoneDuesTemp;

                    this.secThreeUnitCount = secThreeUnitCount;
                    this.secThreePurchasePrice = nfObject.format(secThreePurchasePrice);
                    this.secThreeMilestoneDue = nfObject.format(secThreeMilestoneDue);
                    this.secThreeCollected = nfObject.format(secThreeCollected);
                    this.secThreeInvestor = nfObject.format(secThreeInvestor);
                    this.secThreeAdvance = nfObject.format(secThreeAdvance);
                    this.secThreeDue = nfObject.format(secThreeDue);
                    this.secThreeFuture = nfObject.format(secThreeFuture);
                    this.secThreeFutureOneYear = nfObject.format(secThreeFutureOneYear);
                    this.secThreeFutureTwoYear = nfObject.format(secThreeFutureTwoYear);
                    var secThreeFutureMilestoneDuesTemp = [];
                    for (var n = 0; n < secThreeFutureMilestoneDues.length; n++) {
                        secThreeFutureMilestoneDuesTemp.push(nfObject.format(secThreeFutureMilestoneDues[n]));
                    }
                    this.secThreeFutureMilestoneDues = secThreeFutureMilestoneDuesTemp;
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabSubProjectWiseDataSectionOne.length; index++) {
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    if(key == mvar.allTabSubProjectWiseDataSectionOne[index].subProjectId){
                                        mvar.allTabSubProjectWiseDataSectionOne[index] = {...mvar.allTabSubProjectWiseDataSectionOne[index] ,...abc[key]};
                                        secOneDue_B1 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B1_0_30_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B1 = nfObject.format(secOneDue_B1);
                                        secOneDue_B2 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B2_31_60_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B2 = nfObject.format(secOneDue_B2);
                                        secOneDue_B3 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B3_61_90_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B3 = nfObject.format(secOneDue_B3);
                                        secOneDue_B4 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B4_91_120_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B4 = nfObject.format(secOneDue_B4);
                                        secOneDue_B5 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B5_121_180_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B5 = nfObject.format(secOneDue_B5);
                                        secOneDue_B6 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B6_181_360_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B6 = nfObject.format(secOneDue_B6);
                                        secOneDue_B7 += parseFloat(mvar.allTabSubProjectWiseDataSectionOne[index].B7_361_Days.replace(/,/g, ''));
                                        mvar.secOneDue_B7 = nfObject.format(secOneDue_B7);
                                        mvar.secOneDue = nfObject.format(secOneDue);
                                    }
                                });
                                secOneDue =  secOneDue_B1 + secOneDue_B2 + secOneDue_B3 + secOneDue_B4 + secOneDue_B5 + secOneDue_B6 + secOneDue_B7;
                                this.secOneDue = nfObject.format(secOneDue);
                            }
                        }
                    }, 1000);
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabSubProjectWiseDataSectionTwo.length; index++) {
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    if(key == mvar.allTabSubProjectWiseDataSectionTwo[index].subProjectId){
                                        mvar.allTabSubProjectWiseDataSectionTwo[index] = {...mvar.allTabSubProjectWiseDataSectionTwo[index] ,...abc[key]};
                                        secTwoDue_B1 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B1_0_30_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B1 = nfObject.format(secTwoDue_B1);
                                        secTwoDue_B2 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B2_31_60_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B2 = nfObject.format(secTwoDue_B2);
                                        secTwoDue_B3 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B3_61_90_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B3 = nfObject.format(secTwoDue_B3);
                                        secTwoDue_B4 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B4_91_120_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B4 = nfObject.format(secTwoDue_B4);
                                        secTwoDue_B5 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B5_121_180_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B5 = nfObject.format(secTwoDue_B5);
                                        secTwoDue_B6 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B6_181_360_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B6 = nfObject.format(secTwoDue_B6);
                                        secTwoDue_B7 += parseFloat(mvar.allTabSubProjectWiseDataSectionTwo[index].B7_361_Days.replace(/,/g, ''));
                                        mvar.secTwoDue_B7 = nfObject.format(secTwoDue_B7);
                                    }
                                });
                                secTwoDue =  secTwoDue_B1 + secTwoDue_B2 + secTwoDue_B3 + secTwoDue_B4 + secTwoDue_B5 + secTwoDue_B6 + secTwoDue_B7;
                                mvar.secTwoDue = nfObject.format(secTwoDue);
                            }
                        }
                    }, 1000);
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabSubProjectWiseDataSectionThree.length; index++) {
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    if(key == mvar.allTabSubProjectWiseDataSectionThree[index].subProjectId){
                                        mvar.allTabSubProjectWiseDataSectionThree[index] = {...mvar.allTabSubProjectWiseDataSectionThree[index] ,...abc[key]};
                                        secThreeDue_B1 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B1_0_30_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B1 = nfObject.format(secThreeDue_B1);
                                        secThreeDue_B2 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B2_31_60_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B2 = nfObject.format(secThreeDue_B2);
                                        secThreeDue_B3 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B3_61_90_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B3 = nfObject.format(secThreeDue_B3);
                                        secThreeDue_B4 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B4_91_120_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B4 = nfObject.format(secThreeDue_B4);
                                        secThreeDue_B5 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B5_121_180_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B5 = nfObject.format(secThreeDue_B5);
                                        secThreeDue_B6 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B6_181_360_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B6 = nfObject.format(secThreeDue_B6);
                                        secThreeDue_B7 += parseFloat(mvar.allTabSubProjectWiseDataSectionThree[index].B7_361_Days.replace(/,/g, ''));
                                        mvar.secThreeDue_B7 = nfObject.format(secThreeDue_B7);
                                    }
                                });
                                secThreeDue =  secThreeDue_B1 + secThreeDue_B2 + secThreeDue_B3 + secThreeDue_B4 + secThreeDue_B5 + secThreeDue_B6 + secThreeDue_B7;
                                mvar.secThreeDue = nfObject.format(secThreeDue);
                            }
                        }
                    }, 1000);
                }
                else if (type == 'Tower'){
                    this.allTabTowerWiseData = result;
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabTowerWiseData.length; index++) {
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    if(key == mvar.allTabTowerWiseData[index].towerId){
                                        mvar.allTabTowerWiseData[index] = {...mvar.allTabTowerWiseData[index] ,...abc[key]};
                                    }
                                });
                            }
                        }
                    }, 1000);
                }
                else if (type == 'Unit') {
                    this.allTabUnitWiseData = result;
                    this.allTabUnitWiseDataMain = result;
                    setTimeout(() => {
                        if(this.milestoneAgeingRecordsList != null){
                            for (let index = 0; index < this.allTabUnitWiseData.length; index++) {
                                var abc = JSON.parse(JSON.stringify(this.milestoneAgeingRecordsList));
                                const mvar = this;
                                Object.keys(abc).forEach(function(key) {
                                    if(key == mvar.allTabUnitWiseData[index].towerId.slice(1)){
                                        mvar.allTabUnitWiseData[index] = {...mvar.allTabUnitWiseData[index] ,...abc[key]};
                                    }
                                });
                            }
                        }
                    }, 1000);
                }
                this.isAll = true;
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('loadAllTabData() error => ');
                console.log(error);
                this.showSpinner = false;
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    calculateAdvancePayment(){
        calculateAdvancePayment({'paymentMilestonesIds' : null ,'type' : 'Tower'}).then((result) => {
            this.advacePaymentTower = JSON.parse(JSON.stringify(result));
            
        }).catch((error) => {
            console.log('error -> '+error);
        });

        calculateAdvancePayment({'paymentMilestonesIds' : null ,'type' : 'SubProject'}).then((result) => {
            this.advacePaymentSubProject = JSON.parse(JSON.stringify(result));            
        }).catch((error) => {
            console.log('error -> '+error);

        });

        calculateAdvancePayment({'paymentMilestonesIds' : null ,'type' : 'Project'}).then((result) => {
            this.advacePaymentProject = JSON.parse(JSON.stringify(result));            
        }).catch((error) => {
            console.log('error -> '+error);

        });
        
    }

    calculatePaymentMileStoneTotal(){
        getYearWisePaymentMilestones({'type' : 'Tower'}).then((result) => {
            this.total_Payment_Milestone_Tower = result;
            
        }).catch((error) => {
            console.log('error -> '+error);
        });

        getYearWisePaymentMilestones({'type' : 'SubProject'}).then((result) => {
            this.total_Payment_Milestone_SubProject = result;
            
        }).catch((error) => {
            console.log('error -> '+error);
        });

        getYearWisePaymentMilestones({'type' : 'Project'}).then((result) => {
            this.total_Payment_Milestone_Project = result;            
        }).catch((error) => {
            console.log('error -> '+error);

        });
        
    }

    getMilestoneCollectiveData(type,recordid){
        let nfObject = new Intl.NumberFormat('en-US');
        getMilestoneCollectiveData({type : type,recordId : recordid}).then(res => {
            this.milestoneAgeingRecordsList = res;
            let that = this;
            Object.keys(this.milestoneAgeingRecordsList).forEach(function(key) {
                that.milestoneAgeingRecordsList[key].B1Net = nfObject.format(that.milestoneAgeingRecordsList[key].B1Net);
                that.milestoneAgeingRecordsList[key].B2Net = nfObject.format(that.milestoneAgeingRecordsList[key].B2Net);
                that.milestoneAgeingRecordsList[key].B3Net = nfObject.format(that.milestoneAgeingRecordsList[key].B3Net);
                that.milestoneAgeingRecordsList[key].B4Net = nfObject.format(that.milestoneAgeingRecordsList[key].B4Net);
                that.milestoneAgeingRecordsList[key].B5Net = nfObject.format(that.milestoneAgeingRecordsList[key].B5Net);
                that.milestoneAgeingRecordsList[key].B6Net = nfObject.format(that.milestoneAgeingRecordsList[key].B6Net);
                that.milestoneAgeingRecordsList[key].B7Net = nfObject.format(that.milestoneAgeingRecordsList[key].B7Net);
                that.milestoneAgeingRecordsList[key].B1_0_30_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B1_0_30_Days);
                that.milestoneAgeingRecordsList[key].B2_31_60_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B2_31_60_Days);
                that.milestoneAgeingRecordsList[key].B3_61_90_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B3_61_90_Days);
                that.milestoneAgeingRecordsList[key].B4_91_120_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B4_91_120_Days);
                that.milestoneAgeingRecordsList[key].B5_121_180_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B5_121_180_Days);
                that.milestoneAgeingRecordsList[key].B6_181_360_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B6_181_360_Days);
                that.milestoneAgeingRecordsList[key].B7_361_Days = nfObject.format(that.milestoneAgeingRecordsList[key].B7_361_Days);
                that.milestoneAgeingRecordsList[key].overallDueAmount = nfObject.format(that.milestoneAgeingRecordsList[key].overallDueAmount);
                
            });            
        }).catch(err => {
            this.milestoneAgeingRecordsList = null;
        })
    }

    getMilestoneAllData(){
        let nfObject = new Intl.NumberFormat('en-US');
        getMilestoneAllData().then(res => {
            this.milestoneALLAgeingRecordsList = res;
            let that = this;
            Object.keys(this.milestoneALLAgeingRecordsList).forEach(function(key) {
                that.milestoneALLAgeingRecordsList[key].B1Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B1Net);
                that.milestoneALLAgeingRecordsList[key].B2Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B2Net);
                that.milestoneALLAgeingRecordsList[key].B3Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B3Net);
                that.milestoneALLAgeingRecordsList[key].B4Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B4Net);
                that.milestoneALLAgeingRecordsList[key].B5Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B5Net);
                that.milestoneALLAgeingRecordsList[key].B6Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B6Net);
                that.milestoneALLAgeingRecordsList[key].B7Net = nfObject.format(that.milestoneALLAgeingRecordsList[key].B7Net);
                that.milestoneALLAgeingRecordsList[key].B1_0_30_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B1_0_30_Days);
                that.milestoneALLAgeingRecordsList[key].B2_31_60_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B2_31_60_Days);
                that.milestoneALLAgeingRecordsList[key].B3_61_90_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B3_61_90_Days);
                that.milestoneALLAgeingRecordsList[key].B4_91_120_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B4_91_120_Days);
                that.milestoneALLAgeingRecordsList[key].B5_121_180_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B5_121_180_Days);
                that.milestoneALLAgeingRecordsList[key].B6_181_360_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B6_181_360_Days);
                that.milestoneALLAgeingRecordsList[key].B7_361_Days = nfObject.format(that.milestoneALLAgeingRecordsList[key].B7_361_Days);
                that.milestoneALLAgeingRecordsList[key].overallDueAmount = nfObject.format(that.milestoneALLAgeingRecordsList[key].overallDueAmount);
            });
            
        }).catch(err => {
            this.milestoneALLAgeingRecordsList = null;
        })
    }

    showAgeing(event){
        this.isAgeing = !this.isAgeing;
    }
}