import { LightningElement, track } from 'lwc';
import { open, minimize, getAllUtilityInfo } from 'lightning/platformUtilityBarApi';
import { subscribe } from 'lightning/empApi';
import publishEvent from '@salesforce/apex/TaskUtilityJSONHandler.publishEvent';

export default class TaskUtilityEventHandler extends LightningElement {
    channelName = '/event/Task_NICE_Event__e';
    @track eventData;
    @track isSubscribed;
    @track isEventProcessed = false;
    @track jsonData = {};

    connectedCallback() {
        this.handleSubscribe();
    }

    handleSubscribe() {
        const self = this;
        const messageCallback = (response) => {
            //console.log('piblished/received json data=>', response)
            const payload = response.data.payload;
            if (payload.Event_Type__c === 'Open') {
                const jsonData = self.createJsonData('Open_Popup', payload.Task_Id__c, payload.UserId__c);
                self.openUtilityBar(jsonData);
            } else if (payload.Event_Type__c === 'Close_Popup') {
                self.closeUtilityBar();
            }
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.isSubscribed = response;
        }).catch((error) => {
            console.error('Error during subscription:', error);
        });
    }

    getJsonData(Event_Type, Task_Id, UserId) {
        return {
            "Task_Id__c": Task_Id,
            "UserId__c": UserId,
            "Event_Type__c": Event_Type
        };
    }

    openUtilityBar(jsonData) {
        getAllUtilityInfo().then((utilityInfo) => {
            utilityInfo.forEach((util) => {
                if (util.utilityLabel === 'Task') {
                    open(util.id);
                    setTimeout(() => {
                        this.publishCustomEvent(jsonData);
                    }, 1500);
                }
            });
        }).catch((error) => {
            console.error('Error opening utility bar:', error);
        });
    }

    closeUtilityBar() {
        getAllUtilityInfo().then((utilityInfo) => {
            utilityInfo.forEach((util) => {
                if (util.utilityLabel === 'Task') {
                    minimize(util.id);
                    console.log('Close Event Published!');
                }
            });
        }).catch((error) => {
            console.error('Error closing utility bar:', error);
        });
    }

    createJsonData(Event_Type, Task_Id, UserId) {
        return {
            "Event_Type": Event_Type,
            "Task_Id": Task_Id,
            "UserId": UserId
        };
    }

    publishCustomEvent(jsonData) {
        publishEvent({ jsonString: JSON.stringify(jsonData) })
            .then(() => {
                console.log('Open Event Published!');
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
}