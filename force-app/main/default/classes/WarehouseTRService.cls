public with sharing class WarehouseTRService {

    //in order to convert width into the corresponding letter
    public static final Integer ASCII_CHARACTER_BASE = 64;

    public static void createCells(List<Warehouse__c> processingRecords, Boolean isUpdate) {

        List<Cell__c> cellsToInsert = new List<Cell__c>();

        Map<Id, Set<String>> whIdToExistedCellAddressesMap;

        if (isUpdate) {
            whIdToExistedCellAddressesMap = WarehouseTRUtil.getWarehouseIdToExistedCellAddressesMap(processingRecords);
        }

        for (Warehouse__c wh_i : processingRecords) {
            
            Set<String> addressesOfExistedCellsForCurWarehouse;

            if (isUpdate) {
                addressesOfExistedCellsForCurWarehouse = whIdToExistedCellAddressesMap.get(wh_i.Id);
            }

            Integer whWidth = Integer.valueOf(wh_i.Width__c);
            Integer whLength = Integer.valueOf(wh_i.Length__c);
            Integer whLevel = Integer.valueOf(wh_i.Level__c);

            for (Integer width = 1; width <= whWidth; width++) {
                for (Integer length = 1; length <= whLength; length++) {
                    for (Integer level = 1; level <= whLevel; level++) {

                        String address = String.fromCharArray(new List<Integer>{ASCII_CHARACTER_BASE + width}) + length + 'L' + level;

                        if (isUpdate && addressesOfExistedCellsForCurWarehouse.contains(address)) {
                            continue;
                        }

                        Cell__c cell = new Cell__c(
                            Name = wh_i.Name + ' ' + address,
                            Warehouse__c = wh_i.Id,
                            Width__c = String.valueOf(width),
                            Length__c = String.valueOf(length),
                            Level__c = String.valueOf(level),
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

        Map<Id, List<Cell__c>> warehouseIdToExistedCellsMap = WarehouseTRUtil.getWarehouseIdToExistedCellsMap(processingRecords);

        List<Cell__c> cellsToUpdate = new List<Cell__c>();

        for (Warehouse__c wh_i : processingRecords) {
            
            for (Cell__c cell_j : warehouseIdToExistedCellsMap.get(wh_i.Id)) {
                cell_j.Name = wh_i.Name + ' ' + cell_j.Address__c;
                cellsToUpdate.add(cell_j);
            }
        }

        if (cellsToUpdate.isEmpty()) {
            return;
        }

        update cellsToUpdate;
    }
}