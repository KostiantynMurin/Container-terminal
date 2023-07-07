import { LightningElement, api } from 'lwc';
import getUnlocatedContainerList from '@salesforce/apex/WarehouseController.getUnlocatedContainerList';
import { subscribe, unsubscribe } from "lightning/empApi";
const REFRESH_CONTAINERS_DATA = "/event/Unlocated_Container_Created__e";

export default class UnlocatedContainerList extends LightningElement {
    @api recordId;
    unlocatedContainerList = [];
    columns = [
        { label: 'Id', fieldName: 'Id'},
        { label: 'Status', fieldName: 'Status__c'},
        { label: 'Issuance Date', fieldName: 'Issuance_Date__c' }
    ];

    async connectedCallback(){
        await this.getUnlocatedContainerList();
        subscribe(REFRESH_CONTAINERS_DATA, -1, this.handleRefreshPlatformEvent.bind(this));
    }

    disconnectedCallback() {
        unsubscribe(REFRESH_CONTAINERS_DATA);
    }

    async getUnlocatedContainerList() {
        try {
            const response = await getUnlocatedContainerList();
            if (!response.isSuccess) {
                console.error(response.message);
            }
            this.unlocatedContainerList = response.responseObj;
        } catch (error) {
            console.error(error);
        }
    }

    handleRefreshPlatformEvent(event) {
        this.refreshPlatformEvent(event);
    }

    async refreshPlatformEvent(event) {
        const validRow = this.checkValidRow(event.data.payload.UpdatedRows__c);
        if (!!validRow) {
            await this.getUnlocatedContainerList();
        }
    }

    checkValidRow(data) {
        const updatedRows = JSON.parse(data);
        return updatedRows.find((row) => {
            for (const property in row) {
                if (row[property] !== this[property]) {
                    return false;
                }
            }
            return true;
        });
    }
}