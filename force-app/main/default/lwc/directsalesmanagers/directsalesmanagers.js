import { LightningElement, wire, track } from 'lwc';
import getsalesmanagers from '@salesforce/apex/getdirectsalesmanagers.getsalesmanagers';
export default class Directsalesmanagers extends LightningElement 
{
    @track columns= [{
        label: 'Sales Manager Name',
        fieldName: 'Salesmanager',
        type: 'text',
        cellAttributes: { alignment: 'left' } },
    {
        label: 'Availability Status',
        fieldName: 'Availability_Status__c',
        type: 'text',
        sortable: true
    }
];
    @track dsaleslst;
    @wire(getsalesmanagers)
    wiredDirsalesList({
        error,
        data
    }) {
        if (data) {
            this.dsaleslst = data.map(row=>{
                return{...row, Salesmanager: row.Sales_Manager__r.Name}
            })
        } else if (error) {
            this.error = error;
        }
    }
}