import { LightningElement, api } from 'lwc';

export default class PerformanceDashboardPopOver extends LightningElement {
    @api index;
    @api cpname
    @api smname
    @api sdname
    // @api smname
    // @api sdname
    handleClose(event) {
        console.log(this.index, "index");
        const myEvent = new CustomEvent('close', {
            detail: { index: event.currentTarget.dataset.index }
        });

        this.dispatchEvent(myEvent)
    }
    // get salesManager()
    // {
    //     return this.smname?this.smname:'';
    // }
    // get salesDirector()
    // {
    //     return this.sdname?this.sdname:'';
    // }
}