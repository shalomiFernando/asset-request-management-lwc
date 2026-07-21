import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import user from '@salesforce/apex/AssetRequestController.getUser';
import getPaginatedRequests from '@salesforce/apex/AssetRequestController.getPaginatedRequests';
import assetRequestForm from 'c/assetRequestForm';
import setPickListValues from '@salesforce/apex/AssetRequestController.setPickListValues';
import updateAssetRequests from '@salesforce/apex/AssetRequestController.updateAssetRequests';

export default class AssetRequest extends LightningElement {

    requests = [];
    showForm = false;

    currentPage = 1;
    pageSize = 6;
    totalPages;
    userInfo;

    departmentOptions = [];
    assetTypeOptions = [];
    statusOptions = [];
    priorityOptions = [];

    currentFilters = {};

    columns = [
        {
            label: 'Request No.',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view_record',
                variant: 'base'
            }
        },
        { label: 'Employee Name', fieldName: 'Employee_Name__c' },
        { label: 'Department', fieldName: 'Department__c' },
        { label: 'Asset Type', fieldName: 'Asset_Type__c' },
        { label: 'Requested Date', fieldName: 'Requested_Date__c', type: 'date' },
        { label: 'Required By Date', fieldName: 'Required_By_Date__c', type: 'date', editable: true },
        { label: 'Quantity', fieldName: 'Quantity__c', editable: true },
        { label: 'Priority', fieldName: 'Priority__c', editable: true },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Estimated Cost', fieldName: 'Estimated_Cost__c', editable: true },
        { label: 'Manager Comments', fieldName: 'Manager_Comments__c', editable: true }
   ];

    connectedCallback() {
        this.loadPaginatedRequests();
    
        user().then(result => {
            this.userInfo = result;
        });

        setPickListValues({ fieldNames: ['Department__c','Asset_Type__c','Status__c','Priority__c'] })
        .then(result => {
                this.departmentOptions = result.Department__c.map(val => ({ value: val, label: val }));
                this.assetTypeOptions = result.Asset_Type__c.map(val => ({ value: val, label: val }));
                this.statusOptions = result.Status__c.map(val => ({ value: val, label: val }));
                this.priorityOptions = result.Priority__c.map(val => ({ value: val, label: val }));
        });
    }

    get userName() {
        return this.userInfo ? this.userInfo.Name : '';
    }

    get userTitle() {
        return this.userInfo ? this.userInfo.Title : '';
    }

    async handleNewRequest() {
        const result = await assetRequestForm.open({
            size: 'small',
            departmentOptions: this.departmentOptions,
            assetTypeOptions: this.assetTypeOptions,
            priorityOptions: this.priorityOptions
        });
        
        if (result && result !== 'cancel') {
            console.log('Form data returned:', result);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Asset Request saved successfully',
                    variant: 'success'
                })
            );

            this.requests = [...this.requests, result];
        } 
        else {
            console.log('Modal dismissed');
        }
    }

    loadPaginatedRequests(filters = {}) {
        getPaginatedRequests({
           pageNumber: this.currentPage,
           pageSize: this.pageSize,
           filters: filters
        })
        .then(result => {
            this.requests = result.records.map(req => {
                return {
                    ...req,
                    recordLink: `/s/asset-request/${req.Id}/${req.Name}`
                };
            });
            this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleSearch(event) {
        this.currentPage = 1;
        this.currentFilters = event.detail.filters;
        this.loadPaginatedRequests(this.currentFilters);
    }

    handlePageChange(event) {
        this.currentPage = event.detail.pageNumber;
        this.loadPaginatedRequests(this.currentFilters);
    }

    handleUpdate(event) {
        const updatedFields = event.detail;
        console.log('Updated fields from child:', updatedFields);

        updateAssetRequests({ data: updatedFields })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully',
                    variant: 'success'
                })
            );
            this.loadPaginatedRequests(); 
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    get disablePrevious() {
       return this.currentPage <= 1;
    }

    get disableNext() {
       return this.currentPage >= this.totalPages;
    }
}