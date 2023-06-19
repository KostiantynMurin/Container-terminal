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
        for (Container_Warehouse__c containerWarehouse : newList) {
            createCellEntries(containerWarehouse, warehouseCellToInsertList);
        }
        DMLExecutor.doUpsert(warehouseCellToInsertList, Warehouse_Cell__c.Address__c);
    }

    private static void createCellEntries(Container_Warehouse__c containerWarehouse, List<Warehouse_Cell__c> warehouseCellToInsertList) {
        for (Integer widthAxis = 1; widthAxis <= containerWarehouse.Width__c; widthAxis++) {
            for (Integer lengthAxis = 1; lengthAxis <= containerWarehouse.Length__c; lengthAxis++) {
                for (Integer level = 1; level <= containerWarehouse.Max_Cell_Level__c; level++) {
                    warehouseCellToInsertList.add(
                        new Warehouse_Cell__c(
                            Container_Warehouse__c = containerWarehouse.Id,
                            Address__c = getCellAddress(widthAxis, lengthAxis, level),
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
}