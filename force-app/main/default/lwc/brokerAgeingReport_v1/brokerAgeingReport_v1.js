import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import picklistValues from '@salesforce/apex/BrokerRegistrationFormExternalController.picklistValues';
import getBRData from '@salesforce/apex/BrokerRegAgeingReportController.getBRData';
import { REPORT_DATA } from 'c/brokerAgeingReportConstants';

export default class BrokerAgeingReport_v1 extends LightningElement {

    includedStatusAPI = REPORT_DATA.STATUS_INCLUDED;
    showSpinner = true;
    brQueredData =[]; totalRecordCount=0; brokerStatusPickVal={}; ageingData=[];

    @wire(getBRData,{includedStatusAPI:'$includedStatusAPI'})
    wiredGetReportData({ data, error }) {
        if (data) {
            this.brQueredData = JSON.parse(JSON.stringify(data));
            this.getPicklistValues();
        } else {
            let err = JSON.stringify(error);
            this.showSpinner = false;
            this.showToast('Error', 'Some error occured on Wire Method: '+err, 'error');
        }
    }

    getPicklistValues(){
        picklistValues({
            objectName: 'Broker_Registration__c',
            fieldName: 'Status__c'
        }).then(result => {
            let tmpAry =result;
            let tempMap = tmpAry.reduce(function(map, obj) {
                map[obj.value] = obj.label;
                return map;
            }, {});
            this.brokerStatusPickVal = tempMap;
            this.parseRecordData();
        }).catch(error => {
            this.showSpinner = false;
            let err = JSON.stringify(error);
            this.showToast('Error', 'Error occured on Getting Pick Values- '+err, 'error');
        })
    }

    parseRecordData(){
        this.totalRecordCount = this.brQueredData.length;
        if(this.totalRecordCount>0){
            let tempAry =[];
            let tempMap ={};
            this.brQueredData.forEach(obj=>{
                let tempObj =obj;
                if(tempObj.Status__c){
                    tempObj.statusLabel = this.brokerStatusPickVal[tempObj.Status__c];
                    if(tempObj.Histories){
                        tempObj.noOfDays = this.getDateDifference(tempObj.Histories[0].CreatedDate);
                    } else{
                        if(tempObj.Broker_Created_Date__c){
                            tempObj.noOfDays = this.getDateDifference(tempObj.Broker_Created_Date__c);
                        } else {
                            tempObj.noOfDays = this.getDateDifference(tempObj.CreatedDate);
                        }
                    }
                } else {
                    tempObj.statusLabel='';
                    if(tempObj.Broker_Created_Date__c){
                        tempObj.noOfDays = this.getDateDifference(tempObj.Broker_Created_Date__c);
                    } else {
                        tempObj.noOfDays = this.getDateDifference(tempObj.CreatedDate);
                    }
                }
                tempAry.push(tempObj);
            });
            let tempObjData = REPORT_DATA.DUMMY_DATA[0]; let dum =0;
            console.log('JSON: '+JSON.stringify(tempAry));
            tempAry.forEach(obj=>{
                let stats;
                if(obj.Status__c==undefined){
                    stats='No_Status';
                } else {
                    stats=obj.Status__c
                }
                
                if(obj.noOfDays>=0 && obj.noOfDays<=2){
                    tempObjData[stats].days_0_2 = tempObjData[stats].days_0_2+1;
                } else if(obj.noOfDays>2 && obj.noOfDays<=5){
                    tempObjData[stats].days_3_5 = tempObjData[stats].days_3_5+1;
                } else if(obj.noOfDays>5 && obj.noOfDays<=10){
                    tempObjData[stats].days_6_10 = tempObjData[stats].days_6_10+1;
                } else {
                    tempObjData[stats].moreThan10 = tempObjData[stats].moreThan10+1;
                }
            });
            let tempAry1 =[];
            Object.entries(tempObjData).map(([key, value]) => {
                tempAry1.push(value);
            });
            this.ageingData = tempAry1;
        }
    }

    getDateDifference(calDate){
        let tempDate = new Date(calDate);
        let todayDate = new Date();
        let diffTime = Math.abs(todayDate-tempDate);
        let countNo = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        //let countNo = parseInt((todayDate-tempDate)/ (1000*60*60*24));
        return countNo;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title: title, message: message,variant: variant,mode: 'dismissable'}),
        );
    }

}