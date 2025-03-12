import { LightningElement, track } from 'lwc';
import Arrow_Image_URL from '@salesforce/resourceUrl/dropdownarrow';
import Pnc_Image_URL from '@salesforce/resourceUrl/PncImg';
import { loadStyle } from 'lightning/platformResourceLoader';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';

export default class AboutPageLwc extends LightningElement {
    @track isDropdownVisible = false;
    @track showOurLegacyTemplate = false;
    @track showOurQualityTemplate = false;

    backgroundCircle = 'background: url('+portalAssests + '/assets/images/bg-circle.svg) left 13% center no-repeat';
    
    dropdownArrow = Arrow_Image_URL;
    pncimage = Pnc_Image_URL;

    showDropdown() {
        this.isDropdownVisible = true;
    }

    hideDropdown() {
        this.isDropdownVisible = false;
    }

    showOurLegacy() {
        this.showOurLegacyTemplate = true;
        this.showOurQualityTemplate = false;
    }

    showOurQuality() {
        this.showOurLegacyTemplate = false;
        this.showOurQualityTemplate = true;
    }
}