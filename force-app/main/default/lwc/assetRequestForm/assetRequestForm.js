import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import saveAssetRequest from '@salesforce/apex/AssetRequestController.saveAssetRequest';

export default class AssetRequestForm extends LightningModal  {
    
    @api departmentOptions;
    @api assetTypeOptions;
    @api priorityOptions;

    quantity;
    priority;
    assetType;
    department;
    employeeName;
    dateRequired;
    employeeEmail;
    justification;
    dateRequested;

    handleChange(event) {
        const field = event.target.name;

        switch(field) {
            case 'employeeName':
                this.employeeName = event.target.value;
                break;
            case 'dateRequired':
                this.dateRequired = event.target.value;
                break;
            case 'employeeEmail':
                this.employeeEmail = event.target.value;
                break;
            case 'quantity':
                this.quantity = event.target.value;
                break;
            case 'department':
                this.department = event.target.value;
                break;
            case 'justification':
                this.justification = event.target.value;
                break;
            case 'assetType':
                this.assetType = event.target.value;
                break;
            case 'dateRequested':
                this.dateRequested = event.target.value;
                break;
            case 'priority':
                this.priority = event.target.value;
                break;
        }
    }

    handleSave() {
        const requestData = {
            employeeName: this.employeeName || null,
            dateRequired: this.dateRequired || null,
            employeeEmail: this.employeeEmail || null,
            quantity: this.quantity || null,
            department: this.department || null,
            justification: this.justification || null,
            assetType: this.assetType || null,
            dateRequested: this.dateRequested || null,
            priority: this.priority || null
        };

        if (!this.employeeName || !this.employeeEmail || !this.department || !this.assetType || 
            !this.dateRequested || !this.dateRequired || !this.quantity || !this.priority) {
            
            console.log('Error occured at child handleSave');
            this.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }

        saveAssetRequest({ request: requestData })
            .then(result => {
                this.close(result);
            })
            .catch(error => {
                console.error('Error saving asset request:', error);
            }
        );
    }

    handleCancel() {
        this.close('cancel');
    }
}