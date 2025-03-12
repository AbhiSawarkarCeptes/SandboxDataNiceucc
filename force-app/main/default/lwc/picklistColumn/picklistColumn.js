import LightningDatatable from 'lightning/datatable';
import picklistColumn from './picklistColumn1.html';
import pickliststatic from './pickliststatic.html';

export default class PicklistColumn extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}