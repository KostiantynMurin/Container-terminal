public with sharing class WarehouseTRUtil {
    
    //in order to convert width into the corresponding letter
    public static final Integer ASCII_CHARACTER_BASE = 64;

    public static Map<Id, Set<String>> getWarehouseIdToExistedCellAddressesMap(List<Warehouse__c> warehouses) {

        Map<Id, Set<String>> whIdToExistedCellAddressesMap = new Map<Id, Set<String>>();

        for (Cell__c cell_i : getExistedCells(warehouses)) {
            
            if (!whIdToExistedCellAddressesMap.containsKey(cell_i.Warehouse__c)) {
                whIdToExistedCellAddressesMap.put(cell_i.Warehouse__c, new Set<String>());
            }
            whIdToExistedCellAddressesMap.get(cell_i.Warehouse__c).add(cell_i.Address__c);
        }

        return whIdToExistedCellAddressesMap;
    }

    public static Map<Id, List<Cell__c>> getWarehouseIdToExistedCellsMap(List<Warehouse__c> warehouses) {

        Map<Id, List<Cell__c>> warehouseIdToExistedCellsMap = new Map<Id, List<Cell__c>>();

        for (Cell__c cell_i : getExistedCells(warehouses)) {
            
            if (!warehouseIdToExistedCellsMap.containsKey(cell_i.Warehouse__c)) {
                warehouseIdToExistedCellsMap.put(cell_i.Warehouse__c, new List<Cell__c>());
            }
            warehouseIdToExistedCellsMap.get(cell_i.Warehouse__c).add(cell_i);
        }

        return warehouseIdToExistedCellsMap;
    }

    public static List<Cell__c> getExistedCells(List<Warehouse__c> warehouses) {

        List<Cell__c> cells = [
            SELECT Id
                 , Warehouse__c
                 , Address__c
                 , Name
            FROM Cell__c
            WHERE Warehouse__c IN: warehouses
        ];

        return cells;
    }

    public static String getCellAddress(Integer width, Integer length, Integer level) {
        String address = String.fromCharArray(new List<Integer>{ASCII_CHARACTER_BASE + width}) + length + 'L' + level;
        return address;
    }
}