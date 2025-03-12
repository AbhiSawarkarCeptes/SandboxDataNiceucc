import { LightningElement,api,track } from 'lwc';
import getTaskData from '@salesforce/apex/reEnquiryLayoutForTSAController.getTaskData';
export default class LightningExampleAccordionBasic extends LightningElement {
    
    @api recordId; 
    @track reEnquiryValues = [];
    @track objRecordId;


    connectedCallback(){
    getTaskData({
        leadLookup: this.recordId      
    }).then(result => {
            //this.dataArray = result;
            var taskDataArray = [];
            for(var i =0 ; i< result.length ; i++){
                taskDataArray.push(result[i]);      
            }
            this.reEnquiryValues = taskDataArray;
            //console.log('reenquriylsit' + this.reEnquiryValues);
        }).catch(error => {
            //console.log('error:', error);
        });           
}
}