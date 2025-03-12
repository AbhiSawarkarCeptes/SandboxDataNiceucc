import { LightningElement } from 'lwc';
import searchProject from '@salesforce/apex/UnitRequestHoldLWCController.searchProjectRecord';
import searchUnitRecord from '@salesforce/apex/UnitRequestHoldLWCController.searchUnit';
import uploadFile from '@salesforce/apex/UnitRequestHoldLWCController.uploadFile'
import createUnitHold from '@salesforce/apex/UnitRequestHoldLWCController.createUnitHoldRecord';
import { NavigationMixin } from 'lightning/navigation';

export default class UnitRequestHoldLWC extends LightningElement {
    searchKeyProj = '';
    searchKeyUnit = '';
    searchResultsPC;
    searchResultsUnit;
    showResultsPC = false;
    showResultsUnit = false;
    projectId;
    unitId = '';
    showUnitLookUp = false;
    showUploadButtom = false;
    recordId;
    progress = 0;
    isProgressing = false;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];
    fileData = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    timeHrs = '0';
    showSpinner = false;
    customerFirstName = '';
    customerMiddleName = '';
    customerlastName = '';
    disableSaveButton = false;

    get options() {
        return [
            { label: '1 hour', value: '1 hour' },
            { label: '2 hour', value: '2 hour' },
            { label: '3 hour', value: '3 hour' },
            { label: '4 hour', value: '4 hour' },
            { label: '5 hour', value: '5 hour' },
            { label: '6 hour', value: '6 hour' },
            { label: '7 hour', value: '7 hour' },
            { label: '8 hour', value: '8 hour' },
            { label: '9 hour', value: '9 hour' },
            { label: '10 hour', value: '10 hour' },
            { label: '11 hour', value: '11 hour' },
            { label: '12 hour', value: '12 hour'},
            { label: '13 hour', value: '13 hour' },
            { label: '14 hour', value: '14 hour' },
            { label: '15 hour', value: '15 hour' },
            { label: '16 hour', value: '16 hour' },
            { label: '17 hour', value: '17 hour' },
            { label: '18 hour', value: '18 hour' },
            { label: '19 hour', value: '19 hour' },
            { label: '20 hour', value: '20 hour' },
            { label: '21 hour', value: '21 hour' },
            { label: '22 hour', value: '22 hour' },
            { label: '23 hour', value: '23 hour' },
            { label: '1 Day', value: '1 Day' },
            // { label: '3 Days', value: '3 Days' },
            // { label: '4 Days', value: '4 Days' },
            // { label: '5 Days', value: '5 Days' },
            // { label: '6 Days', value: '6 Days' },
            // { label: '7 Days', value: '7 Days' },
            
        ];
    }

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
        }
        reader.readAsDataURL(file)
    }
    handleClick(recId){
        console.log('OUTPUT : ',recId);
        const {base64, filename, recordId} = this.fileData
        uploadFile({ 
            base64 : base64,
            filename: filename,
            recordId : recId}).then(result=>{
            this.showSpinner = false;
            window.open('/lightning/r/Unit_Hold__c/'+recId+'/view', '_self');
        })
        .catch(error => {
            
        });
    }

    connectedCallback() {
        this.showUnitLookUp = true;
        this.showUploadButtom = true;
        this.disableSaveButton = true;
        this.searchPCs();
    }

    handleResultClickPC(event) {
        console.log('handle result click');
        this.showResultsPC = false;
        this.searchKeyProj = event.target.dataset.id;
        console.log('handle result click'+ this.searchKeyProj);
        this.projectId = event.target.title;
        console.log('handle result click'+ this.projectId);
        this.searchUnit();
        this.showUnitLookUp = false;   
    }
    handleResultUnit(event) {
        console.log(event.target.title,'**--**--**',event.target.dataset.id);
        this.showResultsUnit = false;
        this.searchKeyUnit = event.target.dataset.id;
        this.unitId = event.target.title;
        this.showUnitLookUp = false;   
        this.recordId = event.target.title;
        this.showUploadButtom = false;
        this.disableSaveButton = false;
    }
    handleSearchKeyChangePC(event) {
        console.log('in handleSearchKeyChangePC');
        this.searchKeyProj = event.target.value;
        this.showUnitLookUp = true;
        this.showResultsUnit = false;
        this.showResultsPC = true;
        if (this.searchKeyProj.length == 0 || this.searchKeyProj == undefined) {
            this.searchKeyProj = '';
            this.searchKeyUnit = '';
            this.unitId = '';
            this.showResultsUnit = false;
            this.showUploadButtom = true;
            this.showResultsPC = false;
            this.disableSaveButton = true;
            this.areAccountDetailVisible = false;
            this.arebrokeLadgersVisible = false;
        }
        this.searchPCs();
    }
    handleSearchKeyChangeUnit(event) {
        this.searchKeyUnit = event.target.value;
        this.showResultsUnit = true;
        if (this.searchKeyUnit.length == 0 || this.searchKeyUnit == undefined) {
            this.searchKeyUnit = '';
            this.showResultsUnit = false;
            this.showUploadButtom = true;
            this.disableSaveButton = true;
            this.areAccountDetailVisible = false;
            this.arebrokeLadgersVisible = false;
        }
        this.searchUnit();
    }
    searchPCs(){
        this.showSpinner = true;
        searchProject({
            searchKeyWrd: this.searchKeyProj,
            recId : ''
        }).then(result => { 
            this.showSpinner = false
            console.log(' this.searchResultsPC',  this.searchResultsPC);
            this.searchResultsPC =  result;
            console.log(' this.searchResultsPC 1',  this.searchResultsPC);
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }
    searchUnit(){
        searchUnitRecord({
            searchKeyWrd: this.searchKeyUnit,
            projId : this.projectId
        }).then(result => {
            console.log(' this.searchResultsUnit',  this.searchResultsUnit);
            this.searchResultsUnit =  result;
            console.log(' this.searchResultsUnit 1',  this.searchResultsUnit);
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }
    showDialogPC() {
        this.showResultsPC = true;
    }
    showDialogUnit() {
        this.showResultsUnit = true;
    }
    handleChange(event) {
        this.timeHrs =  event.detail.value;
        console.log(event.detail.value);
        console.log(this.timeHrs);
        
    }
    handleInputChange(event) {
        console.log(event.target.title);
        console.log(event.target.value);

        if(event.target.title == 'first') {
            console.log('First');
            this.customerFirstName = event.target.value;
            console.log(this.customerFirstName);
        }
        if(event.target.title == 'middle') {
            this.customerMiddleName = event.target.value;
        }
        if(event.target.title == 'last') {
            this.customerlastName = event.target.value;
        }
    }
    handleSave(event) {
       this.showSpinner = true;
       console.log(this.customerFirstName);
       console.log(this.customerlastName);
       console.log(this.timeHrs);
        var flag = false;
        if(this.customerFirstName == '') {
            alert('Please Enter the First Name');
            flag = true;
        }
        if(!flag && this.customerlastName == '') {
            alert('Please Enter your Last(Family) Name');
            flag = true;
        }
        if(!flag && this.timeHrs == '0') {
            alert('Please Select the Requested Time');
            flag = true;
        }
        if(!flag && this.fileData.filename == '') {
            alert('Please upload a file');
            flag = true;
        }
        if(!flag) {
            var customerName = this.customerFirstName+' '+this.customerMiddleName+' '+this.customerlastName;
            createUnitHold({
                name : customerName,
                reqHrs : this.timeHrs,
                unitId : this.unitId
            })
            .then(result => {
                console.log(result);
                console.log(this.fileData);
                if(this.fileData.filename != '') {
                    this.handleClick(result);
                }
                else{
                    window.open('/lightning/r/Unit_Hold__c/'+result+'/view', '_self');
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
        }
        else {
            this.showSpinner = false;
        }
    }
}