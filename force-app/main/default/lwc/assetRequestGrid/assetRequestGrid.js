import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AssetRequestGrid extends NavigationMixin(LightningElement) {

    @api columns;
    @api requests;

    @track draftValues = [];

    handleCellChange(event) {
        console.log('Cell changed:', event.detail.draftValues);
        this.draftValues = event.detail.draftValues;
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('Saving inline edits:', updatedFields);

        this.dispatchEvent(new CustomEvent('update', { detail: updatedFields }));
        this.draftValues = [];
    }

    handleRowAction(event) {
        const row = event.detail.row;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Asset_Request__c',
                actionName: 'view'
            }
        });
   }
}