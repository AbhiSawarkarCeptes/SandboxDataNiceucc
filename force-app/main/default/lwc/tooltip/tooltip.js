import { LightningElement, api, track } from 'lwc';

export default class Tooltip extends LightningElement {
    @api tooltipText;
    @track showTooltip = false;

    handleMouseEnter() {
        this.showTooltip = true;
    }

    handleMouseLeave() {
        this.showTooltip = false;
    }

    connectedCallback() {
        this.template.addEventListener('mouseenter', this.handleMouseEnter.bind(this));
        this.template.addEventListener('mouseleave', this.handleMouseLeave.bind(this));
    }
}