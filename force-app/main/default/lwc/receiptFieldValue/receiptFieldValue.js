import { LightningElement, api } from 'lwc';

export default class ReceiptFieldValue extends LightningElement {
    @api receiptId;
    @api fieldName;
    @api receiptData;



   get fieldValue() {
    if (this.receiptData && this.receiptId && this.fieldName) {
        const receipt = this.receiptData.find(receipt => receipt.Id === this.receiptId);
        if (receipt) {
            // Split the field name if it contains dots
            const fieldParts = this.fieldName.split('.');
            let value = receipt;
            // Traverse the object properties
            fieldParts.forEach(part => {
                if (value && typeof value === 'object') {
                    value = value[part];
                } else {
                    // If the property doesn't exist or is not an object, set value to undefined
                    value = undefined;
                }
            });
            return value !== undefined ? value : '';
        }
    }
    return '';
}


}