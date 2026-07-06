import { LightningElement, api } from 'lwc';

export default class AssetRequestGrid extends LightningElement {

    @api columns;
    @api requests;
}