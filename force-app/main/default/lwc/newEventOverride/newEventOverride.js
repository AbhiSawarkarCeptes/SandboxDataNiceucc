import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';
import profileName from '@salesforce/schema/User.Profile.Name';

export default class NewEventOverride extends NavigationMixin(LightningElement) {
    @track recordTypeDetails=[]; @track objectName;
    defaultRecordType; currentUserProfile;
    retrictedProfileToBrokerRecordType=['CP Head', 'CP Manager', 'CP Profile']; 
    restrictedRecordType =['Open Houses','Road Shows']; 
    showRecordTypeSelection = true; isLoading = true; isRestrictedProfile = false;

    @wire(getRecord, { recordId: Id, fields: [profileName]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserProfile = data.fields.Profile.displayValue;
            if(this.retrictedProfileToBrokerRecordType.includes(this.currentUserProfile)){
               this.isRestrictedProfile = true; 
            }
            this.objectName = 'Events__c';
        } else if (error) {
            this.error = error ;
            this.isLoading = false;
            this.showToast('Error!',error,'error');
        }
    }

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getRecordTypeDetails({error,data}){
        if(data){
            for (let key in data.recordTypeInfos) {
                if(data.recordTypeInfos[key].name!='Master'){
                   this.populateRecordTypeList(key, data.recordTypeInfos);
                }
            }
            this.isLoading = false;
        }else if(error){
            this.isLoading = false;
            this.showToast('Error!',error,'error');
        }
    }

    populateRecordTypeList(key, recordTypeInfos){
        if(this.isRestrictedProfile && !this.restrictedRecordType.includes(recordTypeInfos[key].name)){
            this.recordTypeDetails.push({ value: key, label: recordTypeInfos[key].name});
            if(recordTypeInfos[key].defaultRecordTypeMapping){
                this.defaultRecordType = key;
            }
        }else if(this.currentUserProfile == 'Channel Partners' && (recordTypeInfos[key].name == 'Video Shoot' || recordTypeInfos[key].name == 'Brokers Event')){
            this.recordTypeDetails.push({ value: key, label: recordTypeInfos[key].name});
            if(recordTypeInfos[key].defaultRecordTypeMapping){
                this.defaultRecordType = key;
            }
        } else if(!this.isRestrictedProfile && recordTypeInfos[key].name != 'Video Shoot'
        && recordTypeInfos[key].name != 'Brokers Event') {

            this.recordTypeDetails.push({ value: key, label: recordTypeInfos[key].name});
            if(recordTypeInfos[key].defaultRecordTypeMapping){
                this.defaultRecordType = key;
            }
        }
    }

    openNewEvent(){
        let selectedRecordType = this.template.querySelector('lightning-radio-group').value;
        if(selectedRecordType!=null){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Events__c',
                    actionName: 'new'
                },
                state: {
                    nooverride: '1',
                    recordTypeId: selectedRecordType    
                }
            });
        } else {
            this.showToast('','Please select any record type','warning');
        }
    }

    closeModal(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Events__c',
                actionName: 'list'
            },
            state: {       
                filterName: 'Recent' 
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}