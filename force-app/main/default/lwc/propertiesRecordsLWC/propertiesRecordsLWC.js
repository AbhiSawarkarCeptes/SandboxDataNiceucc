import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPropertyList from '@salesforce/apex/PropertyRecordsLWCController.getPropertyList';
import searchProjectRecord from '@salesforce/apex/PropertyRecordsLWCController.searchProjectRecord';
import searchTowersRecord from '@salesforce/apex/PropertyRecordsLWCController.searchTowersRecord';
import searchFloorRecord from '@salesforce/apex/PropertyRecordsLWCController.searchFloorRecord';
import validateHoldProperty from '@salesforce/apex/PropertyRecordsLWCController.validateHoldProperty';

const columns = [
    { label: 'Property Name', fieldName: 'propertyId', type: 'url', typeAttributes: { label: { fieldName: 'PropStrength__Property_Name__c' }, target: '_blank' }},
    { label: 'Project Name', fieldName: 'PropStrength__Project_Name__c', type: 'url', typeAttributes: { label: { fieldName: 'projName' }, target: '_blank' }},
    { label: 'Property Type Code', fieldName: 'PropStrength__Property_Type__c', type: 'url', typeAttributes: { label: { fieldName: 'PropStrength__Property_Type_Name__c' }, target: '_blank' }},
    { label: 'Tower Name', fieldName: 'PropStrength__Tower__c', type: 'url', typeAttributes: { label: { fieldName: 'towerName' }, target: '_blank' }},
    { label: 'Floor Name', fieldName: 'PropStrength__Floor__c',  type: 'url', typeAttributes: { label: { fieldName: 'floorName' }, target: '_blank' }},
    { label: 'Super Area', fieldName: 'PropStrength__Super_Area__c', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }},
    { label: 'Basic Sale Price', fieldName: 'PropStrength__Rate_per_unit_area__c',type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }},
    { label: 'Unit Status', fieldName: 'unitStatus',type: 'text'},
];


export default class PropertiesRecordsLWC extends LightningElement {
    searchKeyProject = '';
    searchKeyTower = '';
    columns = columns;
    searchKeyFloor = '';
    showResults = false;
    showResultsTower = false;
    showResultsFloor = false;
    searchResults = [];
    searchResultsTower = [];
    searchResultsFloor = [];
    searchPrjId = '';
    searchTowerId = '';
    searchFloorId = '';
    towerInput = false;
    floorInput = false;
    showGetBtn = false;
    showPropertiesData = false;
    noRecord = false;
    selectedBtn = false;
    propertiesMap = new Map(); 
    selectedPropertyList = []; 
    selectedPropertyIds = [];
    dataList = [];
    isShowModal = false;
    showSpinner = false;
    preselectedRow = [];


    connectedCallback() {
        this.showSpinner = true;
        this.searchProjects();
        this.towerInput = true;
        this.floorInput = true;
        this.showGetBtn = true;
        this.selectedBtn = true;
    }

    handleSearchKeyChange(event) {
        console.log('in handleSearchKeyChange');
        this.searchKeyProject = event.target.value;
        this.showResults = true;
        if (this.searchKeyProject.length == 0 || this.searchKeyProject == undefined) {
            console.log('in condition handleSearchKeyChange');
            this.searchKeyProject = '';
            this.searchPrj = '';
            this.showResults = false;
            this.handleTowerClose();
            this.towerInput = true;
            this.floorInput = true;
            this.showGetBtn = true;
            this.searchTowerId = '';
            this.searchFloorId = '';
            this.searchKeyTower = '';
            this.searchPrjId = '';
            this.searchKeyFloor = '';
            this.showPropertiesData = false;

        } else {
            this.searchProjects();
        }
    }
    showDialog() {
        this.searchProjects();
        this.showResults = true;
    }
    handleProjectClose() {
        this.showResults = false;
    }
    handleResultClick(event) {
        this.towerInput = false;
        this.searchPrjId = event.target.title;
        this.searchKeyProject = event.target.dataset.id;
        this.showResults = false;
        console.log(this.searchPrjId);
        console.log(this.searchKeyProject);
        this.handleTowerClose();
        this.showSpinner = true;
        this.searchTowers();
    }

    searchProjects() {
        searchProjectRecord({
            searchKeyWrd: this.searchKeyProject,
            recId: ''
        }).then(result => {
            this.searchResults = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    handleSearchKeyChangeTower(event) {
        this.searchKeyTower = event.target.value;
        this.showResultsTower = true;
        if (this.searchKeyTower.length == 0 || this.searchKeyTower == undefined) {
            this.searchKeyTower = '';
            this.searchTwr = '';
            this.showResultsTower = false;
            this.floorInput = true;
            this.showGetBtn = true;
            this.searchTowerId = '';
            this.searchFloorId = '';
            this.searchKeyFloor = '';
            this.showPropertiesData = false;
            this.handleFloorClose();

        } else {
            this.searchTowers();
        }
    }
    showDialogTower() {
        this.searchTowers();
        this.showResultsTower = true;
    }
    handleTowerClose() {
        this.showResultsTower = false;
    }
    handleResultClickTower(event) {
        this.searchTowerId = event.target.title;
        this.searchKeyTower = event.target.dataset.id;
        this.showResultsTower = false;
        this.floorInput = false;
        this.showGetBtn = false;
        this.handleFloorClose();
        this.showSpinner = true;
        this.searchFloor();
    }
    searchTowers() {
        searchTowersRecord({
            searchKeyWrd: this.searchKeyTower,
            recId: this.searchPrjId
        }).then(result => {
            this.showSpinner = false;
            this.searchResultsTower = result;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }
    handleSearchKeyChangeFloor(event) {
        this.searchKeyFloor = event.target.value;
        this.showResultsFloor = true;
        console.log('in handleSearchKeyChangebooking');
        if (this.searchKeyFloor.length == 0 || this.searchKeyFloor == undefined) {
            console.log('in condition handleSearchKeyChangebooking');
            this.searchKeyFloor = '';
            this.searchFloorId = '';
            this.showResultsFloor = false;
        } else {
            this.searchFloor();
        }
    }
    showDialogFloor() {
        this.searchFloor();
        this.showResultsFloor = true;
    }
    handleFloorClose() {
        this.showResultsFloor = false;
    }
    handleResultClickFloor(event) {
        this.searchFloorId = event.target.title;
        this.searchKeyFloor = event.target.dataset.id;
        this.showResultsFloor = false;
    }

    searchFloor() {
        searchFloorRecord({
            searchKeyWrd: this.searchKeyFloor,
            recId: this.searchTowerId
        }).then(result => {
            this.showSpinner = false;
            this.searchResultsFloor = result;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }
    handleClick() {
        this.showSpinner = true;
        this.preselectedRow = [];
        getPropertyList({
            projId : this.searchPrjId  ,
            towerId : this.searchTowerId, 
            floorId : this.searchFloorId
        }).then(result => {
                if(result.length != 0) {
                    this.dataList = result.map(property => {
                        this.propertiesMap.set(property.Id, property.PropStrength__Property_Name__c);
                        console.log('------->',property);
                        const mappedproperty = {
                            ...property,
                            Id: property.Id,
                            propertyId: `/${property.Id}`,
                            PropStrength__Project_Name__c: `/${property.PropStrength__Project_Name__c}`,
                            projName : property.PropStrength__Project_Name__r.Name,
                            towerName : property.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                            floorName : property.PropStrength__Floor__c != undefined ? property.PropStrength__Floor__r.PropStrength__Floor_Name__c : '',
                            PropStrength__Property_Type__c: `/${property.PropStrength__Property_Type__c}`,
                            PropStrength__Tower__c: `/${property.PropStrength__Tower__c}`,
                            PropStrength__Floor__c: property.PropStrength__Floor__c != undefined ? `/${property.PropStrength__Floor__c}` : '',
                            unitStatus: property.PropStrength__Allotted__c  ? 'Sold' : property.PropStrength__Property_on_hold_for_Reallocation__c  ? 'Hold' : property.PropStrength__Property_Alloted_Through_Offer__c  ? 'Booked' : 'Available'
                        };
                        return mappedproperty;
                    });
                    this.showPropertiesData = true;
                    this.noRecord = false;
                }
                else{
                    this.noRecord = true;
                    this.showPropertiesData = false;
                    this.propertiesMap = new Map();
                }
                this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });

    }

    handleRowSelection() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        let ids = [];
        if(selectedRecords.length > 0){
            selectedRecords.forEach(currentItem => {
                ids.push(currentItem.Id);
            });
            this.preselectedRow = ids;
            this.selectedBtn = false;
        }   
        else {
            this.preselectedRow = [];
            this.selectedBtn = true;
        }
    }
    handleSelect() {
        this.selectedPropertyList = [];
        let idList = [];
        let flag = false;     
        this.preselectedRow.forEach(currentItem => {
            let map = [];
            map = {
                'Id' : currentItem,
                'Name' : this.propertiesMap.get(currentItem)
            }
            idList.push(currentItem);
            this.selectedPropertyList.push(map)
        }); 
         
         validateHoldProperty({
            propId : idList              
        }).then(result => {
          console.log('---',result)
          console.log(typeof(result))
          if(result == true){
              console.log('-111--',result);              
              alert('The selected property is put on hold by other User.');
          }
          else  
           this.isShowModal = true;          
        });
        
          
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
    createQuote() {
        let idList = [];
        this.selectedPropertyList.forEach(currentItem => {
            idList.push(currentItem.Id);
        })
        const idsList = idList.filter(Boolean).join(',');
        const vfPageUrl = `/apex/CreateQuoteMultiUnitClone?idList=${encodeURIComponent(idsList)}`;
        window.open(vfPageUrl, '_blank');
        this.hideModalBox();
    }
}