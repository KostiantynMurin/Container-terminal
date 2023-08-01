import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe } from "lightning/empApi";
import getWarehouseStructure from '@salesforce/apex/WarehouseController.getWarehouseStructure';
const REFRESH_DATA_CW_STATE = "/event/Container_Warehouse_Update__e";

export default class WarehouseState extends LightningElement {
    @api recordId;
    warehouseStructure = [];
    rows = [];
    _columns = [];

    get columns() {
        return this._columns;
    }

    set columns(columns) {
        this._columns = [...columns];
    }

    connectedCallback() {
        this.init();
        subscribe(REFRESH_DATA_CW_STATE, -1, this.handleRefreshPlatformEvent.bind(this));
    }

    disconnectedCallback() {
        unsubscribe(REFRESH_DATA_CW_STATE);
    }

    async init() {
        this.isSpinnerActive = true;
        await this.getWarehouseStructure();
        this.buildColumns();
        this.rows = this.createDataStructure(this.warehouseStructure);
    }
    
    buildColumns() {
        const width = this.warehouseStructure.matrix.length;
        const columns = [];
        for (let i = 1; i <= width; i++) {
            const letter = this.getLetterFromNumber(i);
            columns.push(
                {
                    id: i,
                    label: letter,
                    fieldName: letter,
                    wrapText: true
                }
            );
        }
        this.columns = columns;
    }

    async getWarehouseStructure() {
        try {
            const response = await getWarehouseStructure({
                recordId: this.recordId
            });
            if (!response.isSuccess) {
                console.error(response.message);
            }
            this.warehouseStructure = response.responseObj;
        } catch (error) {
            console.error(error);
        }
    }

    createDataStructure(warehouseStructure) {
        let structure = [];
        for (let index = 0; index < warehouseStructure.warehouseLength; index++) {
            let row = {};
            for (let j = 0; j < this.columns.length; j++) {
                let rowKey = this.columns[j].fieldName;
                let cellValues = [];
                for (let k = warehouseStructure.matrix[j][index].length - 1; k >= 0; k--) {
                    let cell = warehouseStructure.matrix[j][index][k];
                    cellValues.push(
                        !cell.Is_Empty__c
                            ? cell.Address__c.substring(2) + ' ' + 
                                new Date(cell?.Containers__r[0]?.Issuance_Date__c).toISOString().split('T')[0] + ' ' + 
                                cell?.Containers__r[0]?.Status__c
                            : cell.Address__c.substring(2) + ' Empty'
                    );
                }
                row[rowKey] = cellValues.join('\n');
            }
            structure.push(row);
        }
        return structure;
    }
    
    getLetterFromNumber(number) {
        const baseCharCode = 'A'.charCodeAt(0) - 1;
        const charCode = baseCharCode + number;
        return String.fromCharCode(charCode);
    }

    handleRefreshPlatformEvent(event) {
        this.refreshPlatformEvent(event);
    }

    async refreshPlatformEvent(event) {
        const validRow = this.checkValidRow(event.data.payload.UpdatedRows__c);
        if (!!validRow) {
            this.init();
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