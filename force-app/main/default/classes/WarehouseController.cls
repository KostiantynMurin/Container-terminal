/**
 * @description  WarehouseController.
 * @author Kostiantyn Murin
 * @date 07-07-2023
 */
public with sharing class WarehouseController {

    /**
     * @description  getWarehouseStructure.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     * @param recordId warehouse Id
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> getWarehouseStructure(String recordId) {
        try {
            Container_Warehouse__c warehouse = [SELECT Id,
                                                       Length__c,
                                                       Width__c,
                                                       Max_Cell_Level__c
                                                FROM Container_Warehouse__c
                                                WHERE Id = :recordId];
            ContainerWarehouseStructure structure = new ContainerWarehouseStructure(warehouse);
            return new Map<String, Object>{
                'isSuccess' => true,
                'responseObj' => new Map<String, Object>{
                                    'matrix' => structure.getWarehouseMatrix(),
                                    'warehouseWidth' => structure.getWidth(),
                                    'warehouseLength' => structure.getLength()
                                }
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'isSuccess' => false,
                'responseObj' => null,
                'message' => e.getMessage()
            };
        }
    }

    /**
     * @description  getUnlocatedContainerList.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> getUnlocatedContainerList(){
        try {
            List<Container__c> unlocatedContainerList = [SELECT Id,
                                                                Issuance_Date__c,
                                                                Status__c
                                                         FROM Container__c
                                                         WHERE Warehouse_Cell__c = NULL
                                                         AND Status__c != 'Issued'
                                                         ORDER BY Issuance_Date__c DESC];
        return new Map<String, Object>{
            'isSuccess' => true,
            'responseObj' => unlocatedContainerList
        };
            
        } catch (Exception e) {
            return new Map<String, Object>{
                'isSuccess' => false,
                'responseObj' => null,
                'message' => e.getMessage()
            };
        }
    }
}