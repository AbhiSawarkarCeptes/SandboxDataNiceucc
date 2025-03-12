import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllTabData from '@salesforce/apex/CollectionDashboardManagementPS.getAllTabData';
import getAgeingData from '@salesforce/apex/CollectionDashboardManagementPS.getAgeingData';
import getYearList from '@salesforce/apex/CollectionDashboardManagementPS.getYearList';

export default class CollectionDashboardPS extends NavigationMixin(LightningElement) {

    @track isAll = false;
    @track isModalOpen = false;

    @track allTabData = [];
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

    @track secOneUnitCount;
    @track secOnePurchasePrice;
    @track secOneMilestoneDue;
    @track secOneCollected;
    @track secOneInvestor;
    @track secOneDue;
    @track secOneFuture;
    @track secOneFutureMilestoneDues = [];

    @track secTwoUnitCount;
    @track secTwoPurchasePrice;
    @track secTwoMilestoneDue;
    @track secTwoCollected;
    @track secTwoInvestor;
    @track secTwoDue;
    @track secTwoFuture;
    @track secTwoFutureMilestoneDues = [];

    @track secThreeUnitCount;
    @track secThreePurchasePrice;
    @track secThreeMilestoneDue;
    @track secThreeCollected;
    @track secThreeInvestor;
    @track secThreeDue;
    @track secThreeFuture;
    @track secThreeFutureMilestoneDues = [];


    connectedCallback() {
        this.showTowerData = false;
        this.showSubProjectData = false;
        this.showUnitData = false;
        this.loadYearList();
    }

    loadYearList() {
        this.showSpinner = true;
        getYearList()
            .then(result => {
                this.showSpinner = false;
                this.allFutureMilestoneYear = result;
                this.loadAllTabData('Project', '');
            })
            .catch(error => {
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
        this.secOneDue = '';
        this.secOneFuture = '';
        this.secOneFutureMilestoneDues = [];

        this.secTwoUnitCount = '';
        this.secTwoPurchasePrice = '';
        this.secTwoMilestoneDue = '';
        this.secTwoCollected = '';
        this.secTwoInvestor = '';
        this.secTwoDue = '';
        this.secTwoFuture = '';
        this.secTwoFutureMilestoneDues = [];

        this.secThreeUnitCount = '';
        this.secThreePurchasePrice = '';
        this.secThreeMilestoneDue = '';
        this.secThreeCollected = '';
        this.secThreeInvestor = '';
        this.secThreeDue = '';
        this.secThreeFuture = '';
        this.secThreeFutureMilestoneDues = [];

        this.allTabTowerWiseData = [];
        this.allTabUnitWiseData = [];
        this.allTabUnitWiseDataMain = [];
        this.allTabAgeingWiseData = [];
        var projectId = event.currentTarget.id;
        projectId = projectId.split('-')[0];
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
                console.log('------->'+result);
                let nfObject = new Intl.NumberFormat('en-US');
                var allTabSubProjectWiseDataSectionOne = [];
                var allTabSubProjectWiseDataSectionTwo = [];
                var allTabSubProjectWiseDataSectionThree = [];

                var secOneUnitCount = 0;
                var secOnePurchasePrice = 0;
                var secOneMilestoneDue = 0;
                var secOneCollected = 0;
                var secOneInvestor = 0;
                var secOneDue = 0;
                var secOneFuture = 0;
                var secOneFutureMilestoneDues = [];

                var secTwoUnitCount = 0;
                var secTwoPurchasePrice = 0;
                var secTwoMilestoneDue = 0;
                var secTwoCollected = 0;
                var secTwoInvestor = 0;
                var secTwoDue = 0;
                var secTwoFuture = 0;
                var secTwoFutureMilestoneDues = [];

                var secThreeUnitCount = 0;
                var secThreePurchasePrice = 0;
                var secThreeMilestoneDue = 0;
                var secThreeCollected = 0;
                var secThreeInvestor = 0;
                var secThreeDue = 0;
                var secThreeFuture = 0;
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
                    var totalInvestorUnitValue = result[i].totalInvestorUnitValue;
                    var futureCollections = result[i].futureCollections;
                    var futureMilestoneDues = result[i].futureMilestoneDues;

                    result[i].totalPurchasePrice = nfObject.format(result[i].totalPurchasePrice);
                    result[i].totalMilestoneDueTillDate = nfObject.format(result[i].totalMilestoneDueTillDate);
                    result[i].totalCollectedAmount = nfObject.format(result[i].totalCollectedAmount);
                    result[i].totalDueAmount = nfObject.format(result[i].totalDueAmount);
                    result[i].totalInvestorUnitValue = nfObject.format(result[i].totalInvestorUnitValue);
                    result[i].futureCollections = nfObject.format(result[i].futureCollections);
                    for (var j = 0; j < result[i].futureMilestoneDues.length; j++) {
                        result[i].futureMilestoneDues[j] = nfObject.format(result[i].futureMilestoneDues[j]);
                    }
                    if (type == 'SubProject') {
                        if (result[i].isOngoing == true) {
                            secThreeUnitCount += result[i].totalUnit;
                            secThreePurchasePrice += totalPurchasePrice;
                            secThreeMilestoneDue += totalMilestoneDueTillDate;
                            secThreeCollected += totalCollectedAmount;
                            secThreeInvestor += totalInvestorUnitValue;
                            secThreeDue += totalDueAmount;
                            secThreeFuture += futureCollections;
                            allTabSubProjectWiseDataSectionThree.push(result[i]);
                            for (var t = 0; t < this.allFutureMilestoneYear.length; t++) {
                                var fM = futureMilestoneDues[t];
                                fM = fM.replaceAll(',', '');
                                secThreeFutureMilestoneDues[t] = (parseInt(secThreeFutureMilestoneDues[t]) + parseInt(fM));
                            }
                        }
                        else if (result[i].section == 'Section 1') {
                            secOneUnitCount += result[i].totalUnit;
                            secOnePurchasePrice += totalPurchasePrice;
                            secOneMilestoneDue += totalMilestoneDueTillDate;
                            secOneCollected += totalCollectedAmount;
                            secOneInvestor += totalInvestorUnitValue;
                            secOneDue += totalDueAmount;
                            secOneFuture += futureCollections;
                            allTabSubProjectWiseDataSectionOne.push(result[i]);
                            for (var t = 0; t < this.allFutureMilestoneYear.length; t++) {
                                var fM = futureMilestoneDues[t];
                                fM = fM.replaceAll(',', '');
                                secOneFutureMilestoneDues[t] = (parseInt(secOneFutureMilestoneDues[t]) + parseInt(fM));
                            }
                        }
                        else {
                            secTwoUnitCount += result[i].totalUnit;
                            secTwoPurchasePrice += totalPurchasePrice;
                            secTwoMilestoneDue += totalMilestoneDueTillDate;
                            secTwoCollected += totalCollectedAmount;
                            secTwoInvestor += totalInvestorUnitValue;
                            secTwoDue += totalDueAmount;
                            secTwoFuture += futureCollections;
                            allTabSubProjectWiseDataSectionTwo.push(result[i]);
                            for (var t = 0; t < this.allFutureMilestoneYear.length; t++) {
                                var fM = futureMilestoneDues[t];
                                fM = fM.replaceAll(',', '');
                                secTwoFutureMilestoneDues[t] = (parseInt(secTwoFutureMilestoneDues[t]) + parseInt(fM));
                            }
                        }
                    }
                }
                if (type == 'Project')
                    this.allTabData = result;
                else if (type == 'SubProject') {
                    this.allTabSubProjectWiseData = result;
                    this.allTabSubProjectWiseDataSectionOne = allTabSubProjectWiseDataSectionOne;
                    this.allTabSubProjectWiseDataSectionTwo = allTabSubProjectWiseDataSectionTwo;
                    this.allTabSubProjectWiseDataSectionThree = allTabSubProjectWiseDataSectionThree;

                    this.secOneUnitCount = secOneUnitCount;
                    this.secOnePurchasePrice = nfObject.format(secOnePurchasePrice);
                    this.secOneMilestoneDue = nfObject.format(secOneMilestoneDue);
                    this.secOneCollected = nfObject.format(secOneCollected);
                    this.secOneInvestor = nfObject.format(secOneInvestor);
                    this.secOneDue = nfObject.format(secOneDue);
                    this.secOneFuture = nfObject.format(secOneFuture);
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
                    this.secTwoDue = nfObject.format(secTwoDue);
                    this.secTwoFuture = nfObject.format(secTwoFuture);
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
                    this.secThreeDue = nfObject.format(secThreeDue);
                    this.secThreeFuture = nfObject.format(secThreeFuture);
                    var secThreeFutureMilestoneDuesTemp = [];
                    for (var n = 0; n < secThreeFutureMilestoneDues.length; n++) {
                        secThreeFutureMilestoneDuesTemp.push(nfObject.format(secThreeFutureMilestoneDues[n]));
                    }
                    this.secThreeFutureMilestoneDues = secThreeFutureMilestoneDuesTemp;
                }
                else if (type == 'Tower')
                    this.allTabTowerWiseData = result;
                else if (type == 'Unit') {
                    this.allTabUnitWiseData = result;
                    this.allTabUnitWiseDataMain = result;
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
}