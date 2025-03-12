import { LightningElement,wire } from 'lwc';
import getGeneralInstructions from '@salesforce/apex/CsoAnnouncementBoard.getGeneralInstructions';

export default class GeneralInstructions extends LightningElement {
    generalInstructions
    @wire(getGeneralInstructions)
    wiredGeneralInstructions({ data, error }) {
        if (data) {
            this.generalInstructions = data;
            console.log('general instructions are ', this.generalInstructions);
        } else if (error) {
            console.error('Error fetching general instructions', error);
        }
    }


}