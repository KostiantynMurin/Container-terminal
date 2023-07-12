import { LightningElement, wire, api } from 'lwc';

import getCells from '@salesforce/apex/WarehouseItemsController.getCells';

export default class WarehouseItemsView extends LightningElement {

    @api recordId;

    rows = []; 
    columns = []; 
    warehouseItems = [];

    @wire(getCells, { warehouseId: '$recordId' })
    wiredWarehouseItems({ error, data }) {
        if (data) {
            console.log('data', data);
            this.rows = [...new Set(data.map(item => item.row))].sort();
            this.columns = [...new Set(data.map(item => item.column))].sort();

            this.warehouseItems = this.rows.map(row => {
                return {
                    name: row,
                    columns: this.columns.map(column => {
                        return { 
                            name : column, 
                            cells : data.filter(item => item.row === row && item.column === column).sort((a, b) => b.level - a.level).map(item => {
                                const containerColor = item.status === 'Waiting for delivery' ? 'lightgreen' : item.status === 'Waiting for loading' ? 'lightblue' : 'white';
                                return {
                                    ...item,
                                    containerLink : '/' + item.containerId,
                                    style: `background-color: ${containerColor};`
                                };
                            }),
                        }
                    })
                }
            });

            console.log('warehouseItems', JSON.parse(JSON.stringify(this.warehouseItems)));
        } else if (error) {
            console.error(error);
        }
    }
}