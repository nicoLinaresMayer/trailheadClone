import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class UnitView extends NavigationMixin(LightningElement) {
    @api unit;

    viewRecord(event) {
        // Navigate to Unit__c record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.dataset.prop,
                "objectApiName": "Unit__c",
                "actionName": "view"
            },
        });
    }
}