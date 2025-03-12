import { LightningElement, api } from 'lwc';
import getProjects from '@salesforce/apex/CollectionDashboardController.getProjects';
import DatatableCss from '@salesforce/resourceUrl/DatatableCss';
import {loadStyle} from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';






export default class TerminationDashboard extends LightningElement {

    allTowers = [];
    projectoptions = [];
    @api selectedProject;
    @api selectedTower;
    toweroptions = [];
    @api result = [];
    @api columns = [];
    searchTerm = '';
    @api getVisibilityOfFilterSelection = false
    @api isRejectedVisible = false;
    @api isResubmitVisible  = false;
    @api isApproveVisible = false;
    @api isTowerDisable ;
    @api isCollection = false;
    isCssLoaded = false;
    



    connectedCallback() {
        this.loadProjects();
    }
   

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, DatatableCss).then(()=>{
        }).catch(err=>{ 
            this.showNotification('', reduceErrors(err).toString(), 'error');
        })
    }

    loadProjects() {
        getProjects()
            .then(result => {
                this.projectData = result;
                let projects = [];
                let towers = [];
                let obj = { label: 'All', value: 'All' };
                towers.push(obj);
                for (let i = 0; i < result.length; i++) {
                    let projectObj = { label: result[i].Name, value: result[i].Id };
                    projects.push(projectObj);
                    let towerData = result[i].Towers__r;
                    if (towerData != null && towerData != undefined) {
                        for (let j = 0; j < towerData.length; j++) {
                            let towerObj = { label: towerData[j].Name, value: towerData[j].Id };
                            towers.push(towerObj);
                        }
                    }
                }
                this.allTowers = towers;
                projects.unshift({ label: 'All', value: 'All' });
                this.projectoptions = projects;
            })
            .catch(err => {
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
    }

    handleProjectChange(event) {
        const lwcEvent = new CustomEvent('projectchange', {
            detail: {
                projectId:  event.detail.value
            }
        });
        this.dispatchEvent(lwcEvent);
        if(event.detail.value == 'All'){
            this.getBookingDetails(event.detail.value);
        }else{
            this.loadTowers(event.detail.value);
        }
    }

    handleTowerChange(event) {
        this.getBookingDetails(event.detail.value);
    }

    loadTowers(projId) {
        let projectData = this.projectData;
        let projectIndex = this.projectData.findIndex(rec => rec.Id === projId);
        let towers = [];
        if (projectIndex !== -1) {
            let towerData = projectData[projectIndex].Towers__r;
            if (towerData) {
            towers = towerData.map(tower => {
                return {
                    label: tower.Name, value: tower.Id
                };
            });
        }
        }
        towers.unshift({ label: 'All', value: 'All' });
        this.toweroptions = towers;
    }

    getBookingDetails(selectedTower) {
        const lwcEvent = new CustomEvent('fetchbookingdetails', {
            detail: {
                towerId: selectedTower,
            }
        });
        this.dispatchEvent(lwcEvent);
    }

    callRowAction(event) {
        const recId = event.detail.row.bookingIdVal;
        const actionName = event.detail.action.name;
        const terminationRemarks = event.detail.row.terminationRemarks;
        const lwcEvent = new CustomEvent('requestforcancellation', {
                detail: {
                    recIds: [recId],
                    actionName  : actionName,
                    terminationRemarks: terminationRemarks
                }
            });
        this.dispatchEvent(lwcEvent);
      
    }

    handleSearch(event) {
        const lwcEvent = new CustomEvent('search', {
            detail: {
                searchTerm: event.detail.value,
            }
        });
        this.dispatchEvent(lwcEvent);
    }

    
    handleSelectedRecords(event) {
        const actionName = event.target.name;
        let selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecords.length) {
        let selectedBookingIds =[];
        selectedRecords.forEach(element => {
            selectedBookingIds.push(element.bookingIdVal);
        });
        const lwcEvent = new CustomEvent('requestforcancellation', {
            detail: {
                recIds: selectedBookingIds,
                actionName : actionName
            }
        });
        this.dispatchEvent(lwcEvent);
    } else {
        this.showNotification('Select Records','Please select the rows to proceed','error');
    }
    }

    get getVisibilityOfTable() {
        return  this.selectedProject   && this.selectedTower;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    get getApproveButtonLabel() {
        return this.isCollection ? 'Submit Selected Rows' : 'Approve Selected Rows';
    }

    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.result.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.result.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.result[i][rowKey] === undefined ? '' : this.result[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Booking Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
   
    
}