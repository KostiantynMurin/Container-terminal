/**
 * @description  Trigger handler for the Container_Warehouse__c object.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public class ContainerWarehouseTriggerHandler  implements ITriggerHandler {

    private static final List<String> WAREHOUSE_PARAM_LIST = new List<String>{ 'Width__c', 'Length__c', 'Max_Cell_Level__c' };

    /**
     * @description   Before insertion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newList List<SObject>
     */
    public void beforeInsert(List<SObject> newList) {}

    /**
     * @description   Before updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        validateParams(newMap, oldMap);
    }

    /**
     * @description   Before deletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param oldMap Map<Id, SObject> newMap
     */
    public void beforeDelete(Map<Id, SObject> oldMap) {}

    /**
     * @description   After insertion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     */
    public void afterInsert(Map<Id, SObject> newMap) {
        generateWarehouseCellEntries((List<Container_Warehouse__c>)newMap.values());
        publishPlatformEvent(newMap);
    }

    /**
     * @description   After updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        generateWarehouseCellEntries(newMap, oldMap);
        publishPlatformEvent(newMap);
    }

    /**
     * @description   After deletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterDelete(Map<Id, SObject> oldMap) {}

    /**
     * @description   After undeletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUndelete(Map<Id, SObject> oldMap) {}

    private void generateWarehouseCellEntries(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<Container_Warehouse__c> updatedRecordsList = new List<Container_Warehouse__c>();
        for (Id recordId : newMap.keySet()) {
            Container_Warehouse__c newRecord = (Container_Warehouse__c)newMap.get(recordId);
            Container_Warehouse__c oldRecord = (Container_Warehouse__c)oldMap.get(recordId);
            if (newRecord.Width__c > oldRecord.Width__c ||
                newRecord.Length__c > oldRecord.Length__c ||
                newRecord.Max_Cell_Level__c > oldRecord.Max_Cell_Level__c) 
            {
                    updatedRecordsList.add(newRecord);
            }
        }
        generateWarehouseCellEntries(updatedRecordsList);
    }

    private void generateWarehouseCellEntries(List<Container_Warehouse__c> newList) {
        List<Warehouse_Cell__c> warehouseCellToInsertList = new List<Warehouse_Cell__c>();
        Map<String, Warehouse_Cell__c> uniqueAddressToUpstreamCellMap = new Map<String, Warehouse_Cell__c>();
        for (Container_Warehouse__c containerWarehouse : newList) {
            createCellEntries(containerWarehouse, warehouseCellToInsertList, uniqueAddressToUpstreamCellMap);
        }
        DMLExecutor.doUpsert(warehouseCellToInsertList, Warehouse_Cell__c.Unique_Address__c);
        createCellRelation(warehouseCellToInsertList, uniqueAddressToUpstreamCellMap);
    }

    private static void createCellEntries(Container_Warehouse__c containerWarehouse, List<Warehouse_Cell__c> warehouseCellToInsertList, Map<String, Warehouse_Cell__c> uniqueAddressToUpstreamCellMap) {
        for (Integer widthAxis = 1; widthAxis <= containerWarehouse.Width__c; widthAxis++) {
            for (Integer lengthAxis = 1; lengthAxis <= containerWarehouse.Length__c; lengthAxis++) {
                for (Integer level = 1; level <= containerWarehouse.Max_Cell_Level__c; level++) {
                    String cellAddress = getCellAddress(widthAxis, lengthAxis, level);
                    String uniqueCellAddress = containerWarehouse.Name + '-' + cellAddress;
                    String upstreamCellUniqueAddress = 
                        level < containerWarehouse.Max_Cell_Level__c
                            ? containerWarehouse.Name + '-' + getCellAddress(widthAxis, lengthAxis, level + 1)
                            : '';
                    Warehouse_Cell__c warehouseCellReference = 
                        String.isNotBlank(upstreamCellUniqueAddress)
                            ? new Warehouse_Cell__c(Unique_Address__c = upstreamCellUniqueAddress)
                            : null;
                    uniqueAddressToUpstreamCellMap.put(uniqueCellAddress, warehouseCellReference);
                    warehouseCellToInsertList.add(
                        new Warehouse_Cell__c(
                            Name = uniqueCellAddress,
                            Container_Warehouse__c = containerWarehouse.Id,
                            Address__c = cellAddress,
                            Unique_Address__c = uniqueCellAddress,
                            Level__c = level
                        )
                    );
                }
            }
        }
    }

    private static String getCellAddress(Integer widthAxis, Integer lengthAxis, Integer level) {
        return getColumnLetter(widthAxis) + lengthAxis + 'L' + level;
    }

    private static String getColumnLetter(Integer widthAxis) {
        String letter = '';
    
        if (widthAxis > 0 && widthAxis <= 26) {
            letter = String.fromCharArray(new List<Integer>{widthAxis + 64});
        } else if (widthAxis > 26) {
            Integer quotient = (widthAxis - 1) / 26;
            Integer remainder = Math.mod(widthAxis - 1, 26);
    
            // If the widthAxis exceeds 26, get the first letter of the column
            // from the remainder after dividing by 26 and add it to the result
            letter += getColumnLetter(quotient);
            letter += getColumnLetter(remainder + 1);
        }
        return letter;
    }

    private static void validateParams(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        for (SObject newRecord : newMap.values()) {
            SObject oldRecord = oldMap.get((Id)newRecord.get('Id'));
            for (String fieldApiName : WAREHOUSE_PARAM_LIST) {
                if ((Decimal)newRecord.get(fieldApiName) < (Decimal)oldRecord.get(fieldApiName)) {
                    newRecord.addError(fieldApiName, Label.NewValueLessThanPrevious);
                }
            }
        }
    }

    private void publishPlatformEvent(Map<Id, SObject> newMap){
        PlatformEventBuilder.publishContainerWarehouseUpdateEvent(newMap.keySet());
    }

    private void createCellRelation(List<Warehouse_Cell__c> existingCellList, Map<String, Warehouse_Cell__c> uniqueAddressToUpstreamCellMap) {
        for (Warehouse_Cell__c cell : existingCellList) {
            cell.Upstream_Cell__r = uniqueAddressToUpstreamCellMap.get(cell.Unique_Address__c);
        }
        DMLExecutor.doUpdate(existingCellList);
    }
}