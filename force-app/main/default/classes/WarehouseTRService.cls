public with sharing class WarehouseTRService {

    public static void createCells(List<Warehouse__c> processingRecords, Boolean isUpdate) {

        List<Cell__c> cellsToInsert = new List<Cell__c>();

        Map<Id, Set<String>> whIdToExistedCellAddressesMap;

        if (isUpdate) {
            whIdToExistedCellAddressesMap = WarehouseUtil.getWarehouseIdToExistedCellAddressesMap(processingRecords);
        }

        for (Warehouse__c warehouse_i : processingRecords) {
            
            Set<String> addressesOfExistedCellsForCurWarehouse;

            if (isUpdate) {
                addressesOfExistedCellsForCurWarehouse = whIdToExistedCellAddressesMap.get(warehouse_i.Id);
            }

            Integer whWidth = Integer.valueOf(warehouse_i.Width__c);
            Integer whLength = Integer.valueOf(warehouse_i.Length__c);
            Integer whLevel = Integer.valueOf(warehouse_i.Level__c);

            for (Integer width_i = 1; width_i <= whWidth; width_i++) {
                for (Integer length_j = 1; length_j <= whLength; length_j++) {
                    for (Integer level_k = 1; level_k <= whLevel; level_k++) {

                        String address = WarehouseUtil.getCellAddress(width_i, length_j, level_k);

                        if (isUpdate && addressesOfExistedCellsForCurWarehouse.contains(address)) {
                            continue;
                        }

                        Cell__c cell = new Cell__c(
                            Name = warehouse_i.Name + ' ' + address,
                            Warehouse__c = warehouse_i.Id,
                            Width__c = String.valueOf(width_i),
                            Length__c = String.valueOf(length_j),
                            Level__c = String.valueOf(level_k),
                            Address__c = address
                        );
                        cellsToInsert.add(cell);
                    }
                }
            }
        }

        if (cellsToInsert.isEmpty()) {
            return;
        }

        insert cellsToInsert;
    }

    public static void updateCellsNames(List<Warehouse__c> processingRecords) {

        Map<Id, List<Cell__c>> warehouseIdToExistedCellsMap = WarehouseUtil.getWarehouseIdToExistedCellsMap(processingRecords);

        List<Cell__c> cellsToUpdate = new List<Cell__c>();

        for (Warehouse__c warehouse_i : processingRecords) {
            
            for (Cell__c cell_j : warehouseIdToExistedCellsMap.get(warehouse_i.Id)) {
                cell_j.Name = warehouse_i.Name + ' ' + cell_j.Address__c;
                cellsToUpdate.add(cell_j);
            }
        }

        if (cellsToUpdate.isEmpty()) {
            return;
        }

        update cellsToUpdate;
    }
}