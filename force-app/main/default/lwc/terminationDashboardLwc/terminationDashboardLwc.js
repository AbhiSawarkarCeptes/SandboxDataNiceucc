import { LightningElement, api } from 'lwc';
import getProjects from '@salesforce/apex/TerminationDashboardLwcController.getProjects';
import DatatableCss from '@salesforce/resourceUrl/DatatableCss';
import {loadStyle} from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';





export default class TerminationDashboardLwc extends LightningElement {

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
                    let towerData = result[i].PropStrength__Towers__r;
                    if (towerData != null && towerData != undefined) {
                        for (let j = 0; j < towerData.length; j++) {
                            let towerObj = { label: towerData[j].PropStrength__Tower_Name__c, value: towerData[j].Id };
                            towers.push(towerObj);
                        }
                    }
                }
                this.allTowers = towers;
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
        this.loadTowers(event.detail.value);
    }

    handleTowerChange(event) {
        this.getBookingDetails(event.detail.value);
    }

    loadTowers(projId) {
        let projectData = this.projectData;
        let projectIndex = this.projectData.findIndex(rec => rec.Id === projId);
        let towers = [];
        if (projectIndex !== -1) {
            let towerData = projectData[projectIndex].PropStrength__Towers__r;
            if (towerData) {
            towers = towerData.map(tower => {
                return {
                    label: tower.PropStrength__Tower_Name__c, value: tower.Id
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
        const recId = event.detail.row.bookingId.replace('/','');
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
                if (!selectedBookingIds.includes(element.bookingId.replace('/', ''))) {
                    selectedBookingIds.push(element.bookingId.replace('/', ''));
                }
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
   
    
}