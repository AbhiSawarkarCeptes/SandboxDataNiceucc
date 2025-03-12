import { LightningElement } from 'lwc';
import getRecordsData from '@salesforce/apex/TradeLicenseSearchController.getRecordsData';

export default class TradeLicenseSearch extends LightningElement {
    queryTerm;
    isLoading = false;
    showtableError = true;
    dataRecords;
    sobhaDataRecords;
    brokerDataRecords;
    sobhaShowtable = false;
    brokerShowtable = false;
    handleKeyUp(evt) {
        this.showtable = false;
        this.sobhaShowtable = false;
        this.showtableError = true;
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.isLoading = true;
            this.queryTerm = evt.target.value;
            getRecordsData({ firstSearchKey: this.queryTerm })
                .then(data => {
                    console.log('data',data);
                    if (data.length == 0 || (data[0].channelpartnerList.length == 0 && data[0].sobhaConnectList.length == 0
                        && data[0].brokerList.length == 0)) {
                        this.showtableError = false;
                    }
                    else {
                        if (data[0] && data[0].channelpartnerList.length > 0) {
                            this.dataRecords = data[0];
                            this.showtable = true;
                        }
                        if (data[0] && data[0].sobhaConnectList.length > 0) {
                            this.sobhaDataRecords = data[0];
                            this.sobhaShowtable = true;
                        }
                        if (data[0] && data[0].brokerList.length > 0) {
                            this.brokerDataRecords = data[0];
                            this.brokerShowtable = true;
                        }
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    this.isLoading = false;
                    // handle error
                    console.error('Error fetching attachments:', error);
                });
        }
    }
    redirect(event) {

    }
}