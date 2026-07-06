import { LightningElement, api } from 'lwc';

export default class ReusablePagination extends LightningElement {

    @api currentPage;
    @api totalPages;

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('pagechange', { detail: { pageNumber: this.currentPage - 1 } }));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('pagechange', { detail: { pageNumber: this.currentPage + 1 } }));
    }

}