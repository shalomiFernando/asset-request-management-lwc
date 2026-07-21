import { LightningElement, api } from 'lwc';

export default class ReusableMessagePanel extends LightningElement {
    @api message;       
    @api messageType;   

    get iconName() {
        switch (this.messageType) {
            case 'error':
                return 'utility:error';
            case 'warning':
                return 'utility:warning';
            case 'info':
                return 'utility:info';
            case 'empty':
                return 'utility:ban'; // or 'utility:search' for no records
            default:
                return 'utility:info';
        }
    }
}