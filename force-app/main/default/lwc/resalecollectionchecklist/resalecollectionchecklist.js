import { LightningElement, api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import getBookingDetails from '@salesforce/apex/resaleprocesscontroller.getBookingDetails';

export default class Resalecollectionchecklist extends NavigationMixin(LightningElement)  
{
    @api recordId;
    @api bookingrecord;
    resaletype=false;
    bcccompleted;
    UnprocessedReceipt;
    handoverstatus;
    countofpdc;
    amountofpdc;
    othercharges;
    latecharges;
    totalonaccount;
    paidpercetage;
    duepayments;
    

    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
        event.preventDefault();
        const fields = event.detail.fields;
        //fields.BCC_completed__c=this.bcccompleted;
        //fields.Handover_Status_Completed__c=this.handoverstatus;
        //fields.Count_of_PDC_s_available__c=this.countofpdc;
        //fields.Amount_of_PDC__c=this.amountofpdc;
        //fields.Other_Charges_paid__c=this.othercharges;
        //fields.Late_payment_charges__c=this.latecharges;
        //fields.Total_on_account_money__c=this.totalonaccount;
        //fields.Paid_percentage__c=this.paidpercetage;
        //fields.Due_payments__c=this.duepayments;
        fields.is_cheklist_completed__c=true;

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.recordId=event.detail.id;
            const evt = new ShowToastEvent({
                title: ' Success',
                message: 'Collection Checklist Submitted',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        
        setTimeout(() => {
            this.navigateToRecordPage();
        }, 100);
    }
    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Resale_Process__c',
                actionName: 'view'
            }
        });
    }

    @wire(getBookingDetails, {resaleid:'$recordId', record:'resale'})
    wiredBookingDetailsList({error,data}) {
        if (data) {
            this.bookingrecord = data;
            for(var key in this.bookingrecord)
            {
                if(key=='resaletype')
                {
                    if(this.bookingrecord[key]=='Resale with Mortgage')
                    {
                        this.resaletype=true;
                    }
                }
                if(key=='bcccompleted')
                {
                    this.bcccompleted=this.bookingrecord[key];
                }
                if(key=='UnprocessedReceipt')
                {
                    this.UnprocessedReceipt=this.bookingrecord[key];
                }
                if(key=='handoverstatus')
                {
                    this.handoverstatus=this.bookingrecord[key];
                }
                if(key=='countofpdc')
                {
                    this.countofpdc=this.bookingrecord[key];
                }
                if(key=='amountofpdc')
                {
                    this.amountofpdc=this.bookingrecord[key];
                }
                if(key=='othercharges')
                {
                    this.othercharges=this.bookingrecord[key];
                }
                if(key=='latecharges')
                {
                    this.latecharges=this.bookingrecord[key];
                }
            }
        }
        if(error){
            console.log('wiredBookingList -> ',JSON.parse(JSON.stringify(error)));
        }
    }
}