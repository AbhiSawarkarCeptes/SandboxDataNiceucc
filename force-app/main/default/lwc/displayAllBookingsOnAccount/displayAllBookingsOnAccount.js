import { LightningElement, api, wire, track } from 'lwc';
import getChildRecords from '@salesforce/apex/DisplayAllBookingsOnAccountController.getApplicantDetails';
import baseURL from '@salesforce/apex/DisplayAllBookingsOnAccountController.baseURL';

const columns = [
    {
        label: 'Applicant Detail',
        fieldName: 'appLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },  {
        label: 'Booking',
        fieldName: 'BookingLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'booking' }, target: '_blank' }
    }, {
        label: 'Opportunity',
        fieldName: 'OpportunityLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'opportunity' }, target: '_blank' }
    },  {
        label: 'Applicant Number',
        fieldName: 'Applicant_Number__c',
        type: 'text'
    },{
        label: 'Account Name',
        fieldName: 'AccountLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Account' }, target: '_blank' }
    }
];

export default class DisplayAllBookingsOnAccount extends LightningElement {
    @api recordId;
    @track data=[];
    columns = columns;
    bsUrl;
    
    @wire(baseURL)
    getBaseURL({ data, error })
    {
        if(data)
        {
        this.bsUrl=data+'/';
        console.log('Base url is ', this.bsUrl);
        }
    }

   
    @wire(getChildRecords, { accountId: '$recordId' })
    wiredChildRecords({ data, error }) {
        if (data) {
            data = JSON.parse(JSON.stringify(data));
            data.forEach(res => {
                res.appLink = '/' + res.Id;
                res.BookingLink = '/' + res.Booking__c;
                res.OpportunityLink = '/' + res.Booking__r.Opportunity__c;
                res.AccountLink = '/' + res.Account__c;
                res.booking=res.Booking__r.Name;
                res.opportunity=res.Booking__r.Opportunity__r.Name;
                res.Account=res.Account__r.Name

            });
            this.data = data;
        } else if (error) {
            console.error('Error loading child records:', JSON.stringify(error));
        }
    }
    
    

}