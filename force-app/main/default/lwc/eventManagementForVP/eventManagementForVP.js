import { LightningElement,wire,track } from 'lwc';
import eventWithinCurrentMonth from '@salesforce/apex/eventManagementForVPController.eventWithinCurrentMonth'
const columns = [
    {
        label: 'Event name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true
    },
    { label: 'Type', fieldName: 'Type' },
    { label: 'City', fieldName: 'City' },
    { label: 'Country', fieldName: 'Country' },
    { label: 'Start Date', fieldName: 'StartDate', type: 'date' },
    { label: 'End Date', fieldName: 'EndDate', type: 'date' },
    {
        label: 'CreatedBy',
        fieldName: 'createdbyId',
        type: 'url',
        typeAttributes: {label: { fieldName: 'createdbyName' }, 
        target: '_blank'},
        sortable: true
    },
];
export default class EventManagementForVP extends LightningElement {
    columns = columns;
    @track data = [];
   
     // JS Properties 
     pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
     records = []; //All records available in the data table
     totalRecords = 0; //Total no.of records
     pageSize; //No.of records to be displayed per page
     totalPages; //Total no.of pages
     pageNumber = 1; //Page number    
     @track recordsToDisplay = []; //Records to be displayed on the page
     
     get bDisableFirst() {
         return this.pageNumber == 1;
     }
     get bDisableLast() {
         return this.pageNumber == this.totalPages;
     }
     // connectedCallback method called when the element is inserted into a document
     connectedCallback() {
        eventWithinCurrentMonth().then(response =>{
             // fetch contact records from apex method 
             response.forEach(eventData => {
                var obj = {};
                console.log('eventData===',eventData)
                obj.nameUrl= '/'+eventData.Id;
                obj.Name = eventData.Name;
                obj.City = eventData.City_Country__c;
                obj.Country = eventData.Country__c;
                obj.StartDate = eventData.Date_Of_Event__c;
                obj.EndDate = eventData.End_Date_Of_Event__c;
                obj.createdbyId = '/'+eventData.CreatedById;
                obj.createdbyName = eventData.CreatedBy.Name;
                obj.Type = eventData.RecordType.Name;
                this.records.push(obj);
            })
            this.records = [...this.records];
            // this.records = this.data;
            this.totalRecords = this.records.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.paginationHelper(); // call helper menthod to update pagination logic
            
        }).catch(error =>{

        });
        
        
     }
     handleRecordsPerPage(event) {
         this.pageSize = event.target.value;
         this.paginationHelper();
     }
     previousPage() {
         this.pageNumber = this.pageNumber - 1;
         this.paginationHelper();
     }
     nextPage() {
         this.pageNumber = this.pageNumber + 1;
         this.paginationHelper();
     }
     firstPage() {
         this.pageNumber = 1;
         this.paginationHelper();
     }
     lastPage() {
         this.pageNumber = this.totalPages;
         this.paginationHelper();
     }
     // JS function to handel pagination logic 
     paginationHelper() {
         this.recordsToDisplay = [];
         var temp = [];
         // calculate total pages
         this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
         // set page number 
         if (this.pageNumber <= 1) {
             this.pageNumber = 1;
         } else if (this.pageNumber >= this.totalPages) {
             this.pageNumber = this.totalPages;
         }
         // set records to display on current page 
         for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
             if (i === this.totalRecords) {
                 break;
             }
             temp.push(this.records[i]);
         }
         this.recordsToDisplay = [...temp];
         console.log(' this.recordsToDisplay===', this.recordsToDisplay)
     }
   
}