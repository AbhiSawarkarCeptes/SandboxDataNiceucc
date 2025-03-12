import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
    
export default class DocusignUtilityComponent extends LightningElement {
    @track status;
    @track message;
    @track bookingId;
    @track userId;
    //@track recordId;
    userId = Id;
    @api recordId;
    
    subscription = {};
    @api channelName = '/event/Docusign_Result__e';
    
    connectedCallback() {
        console.log("record id : "+this.recordId);
        // Register error listener     
        this.registerErrorListener();
        this.handleSubscribe();
    }
    
    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            //console.log('New message received 1: ', JSON.stringify(response));
            //console.log('New message received 2: ', response);
            var obj = JSON.parse(JSON.stringify(response));
            console.log(obj);
            console.log(self);
            console.log(obj.data.payload.MessageToDisplay__c);
            console.log(self.channelName);
            let bookingId = obj.data.payload.Booking_Id__c;
            let userIdPE = obj.data.payload.User_Id__c;
            let objData = obj.data.payload;

            self.message = objData.MessageToDisplay__c;
            //self.bookingId = objData.Booking_Id__c;
            //self.userId = objData.User_Id__c;
            if (self.recordId == bookingId && self.userId == userIdPE) {
                if (self.message.includes("successfully")) {
                    const evt = new ShowToastEvent({
                        title: 'Docusign Status',
                        message: self.message,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    self.dispatchEvent(evt);
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Docusign Status',
                        message: self.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    self.dispatchEvent(evt);
                }
            }
        };
    
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
    
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
    
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}