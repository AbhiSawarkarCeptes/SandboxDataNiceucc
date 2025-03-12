import { LightningElement, api } from 'lwc';

export default class BrPortalPerformancePopOver extends LightningElement {
    @api index;
    @api cpname;
    @api smname;
    @api sdname;

    // renderedCallback() {
    //     const popover = this.template.querySelector('.moreInfo-popover-style');
    //     const button = this.template.querySelector(`[data-index="${this.index}"]`);
    //     if (button && popover) {
    //         const buttonRect = button.getBoundingClientRect();
    //         popover.style.top = `${buttonRect.bottom + window.scrollY}px`;
    //         popover.style.left = `${buttonRect.left + window.scrollX}px`;
    //         popover.style.right = 'auto';
    //     }
    // }

    handleClose(event) {
        console.log(this.index, "index");
        const myEvent = new CustomEvent('close', {
            detail: { index: event.currentTarget.dataset.index }
        });
        this.dispatchEvent(myEvent);
    }
}