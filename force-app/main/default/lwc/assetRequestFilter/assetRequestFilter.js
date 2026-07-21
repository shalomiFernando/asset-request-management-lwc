import { LightningElement, api } from 'lwc';

export default class AssetRequestFilter extends LightningElement {

    @api departmentOptions = [];
    @api assetTypeOptions = [];
    @api statusOptions = [];
    @api priorityOptions = [];

    filterValues = {
        employeeName: '',
        department: '',
        assetType: '',
        status: '',
        priority: '',
        dateFrom: '',
        dateTo: ''
    };

    get employeeName() { return this.filterValues.employeeName; }
    get department() { return this.filterValues.department; }
    get assetType() { return this.filterValues.assetType; }
    get status() { return this.filterValues.status; }
    get priority() { return this.filterValues.priority; }
    get dateFrom() { return this.filterValues.dateFrom; }
    get dateTo() { return this.filterValues.dateTo; }

    handleChange(event) {
        const field = event.target.name;
        this.filterValues[field] = event.target.value;
    }

    handleSearch() {
        this.dispatchEvent(
            new CustomEvent('search', {
                detail: { filters: this.filterValues }
            })
        );
    }

    handleClear() {
        this.filterValues = {
           employeeName: '',
           department: '',
           assetType: '',
           status: '',
           priority: '',
           dateFrom: '',
           dateTo: ''
        };

        const inputs = this.template.querySelectorAll(
            'lightning-input, lightning-combobox'
        );
        inputs.forEach(input => {
            input.value = null;
        });

        this.dispatchEvent(
           new CustomEvent('search', {
              detail: { filters: this.filterValues }
           })
        );
    }
}