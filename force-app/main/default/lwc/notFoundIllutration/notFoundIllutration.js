import { LightningElement, api } from 'lwc';
export default class NotFoundIllutration extends LightningElement {

    @api nounits = false;
    @api expired = false;
    @api message;
}