public with sharing class ContainerTRUtil {
    
    public static Map<String, Id> getExternalIdToContactIdMap(Set<String> contactsExternalIds) {

        Map<String, Id> externalIdToContactIdMap = new Map<String, Id>();

        for (Contact cont_i : [SELECT Id
                                    , External_Id__c
                               FROM Contact
                               WHERE External_Id__c IN: contactsExternalIds]) {

            externalIdToContactIdMap.put(cont_i.External_Id__c, cont_i.Id);
        }

        return externalIdToContactIdMap;
    }

    public static Integer getAmountOfContainersInBufferZone() {

        List<AggregateResult> results = [
            SELECT Count(Id) amountOfContainersInBufferZone
            FROM Container__c
            WHERE Warehouse_Cell__r.Warehouse__r.RecordTypeId =: WarehouseUtil.bufferZoneRTId
        ];

        if (results.isEmpty()) {
            return 0;
        }

        return (Integer) results.get(0).get('amountOfContainersInBufferZone');
    }
}