import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import Booking_Sale_Value__c from '@salesforce/schema/Task__c.Booking_Sale_Value__c';
import Customer_Full_Name__c from '@salesforce/schema/Task__c.Customer_Full_Name__c';
import Communication_Mode__c from '@salesforce/schema/Task__c.Communication_Mode__c';
import Call_Status__c from '@salesforce/schema/Task__c.Call_Status__c';
import createTaskOnCall from '@salesforce/apex/CollectionDashboardController.createTaskOnCall';
import Customer_Interested__c from '@salesforce/schema/Task__c.Customer_Interested__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PrimaryMobileNumber__c from '@salesforce/schema/Booking__c.PrimaryMobileNumber__c';
const fields = [PrimaryMobileNumber__c];

export default class CrmTeamCallIntg extends NavigationMixin(LightningElement) {
    @api recordId
    bookingSale = Booking_Sale_Value__c;
    customerName = Customer_Full_Name__c;
    communicationMode = Communication_Mode__c;
    CallStatus = Call_Status__c;
    customerInterested = Customer_Interested__c;
    @wire(getRecord, { recordId: '$recordId', fields })
    Booking__c;
    bookingId = ''; 
    newTaskId; taskRecordId; communicationVal; notesVal;

    CallOption(event) {
        this.createNewTask(this.recordId);
        const clickToDial = this.template.querySelector('lightning-click-to-dial');
        clickToDial.click();
    }


    handleSuccess(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Task created successfully',
                variant: 'success'
            })
        );
    }

    get mobileNumber() {
        let phone = getFieldValue(this.Booking__c.data, PrimaryMobileNumber__c);
        if(phone != undefined && phone != null){
            console.log('Phone numerb -> '+phone.replace(/[^a-zA-Z0-9]/g, ''));
            return phone.replace(/[^a-zA-Z0-9]/g, '');
        }

    }

    getCommunicationMode(event){
        this.communicationVal = event.target.value;
        console.log('~~COmmu: '+this.communicationVal);
    }
    getNotes(event){
        this.notesVal = event.target.value; 
        console.log('~~Notes: '+this.notesVal);
    }
    handleSubmit(event){
        this.taskRecordId = this.newTaskId;

    }

    createNewTask(bookingId) {
        createTaskOnCall({ bookingId: bookingId })
            .then(result => {
                this.newTaskId = result;
                this.isModalOpenCallLog = true;
                console.log('Tasks ID: '+this.newTaskId);
            })
            .catch(error => {
            });
       
    }

    closeModal() {
        this.isModalOpen = false;
        this.isModalOpenCallLog = false;
    }

    navigateToBooking() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });
    }
}