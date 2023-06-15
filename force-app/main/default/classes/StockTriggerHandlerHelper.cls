public class StockTriggerHandlerHelper {
    private static Integer BASE_CHAR_NUMBER = 64;
    public void modifyStorageUnits(List<Stock__c> newList, Map<Id, Stock__c> oldmap) {
        Map<Id, Stock__c> modifiedStocksMap = new Map<Id, Stock__c>();
        if (oldmap != null){
            for (Stock__c stock : newList){
                Stock__c oldStockValue = oldmap.get(stock.Id);
                if ( stock.Length__c != oldStockValue.Length__c || 
                    stock.Width__c != oldStockValue.Width__c ||
                    stock.Height__c != oldStockValue.Height__c ){
                        modifiedStocksMap.put(stock.Id, stock);
                }
            }
        }
        Map<Id, Storage_Unit__c> storageUnitsOfModifiedStocksMap = new Map<Id, Storage_Unit__c>([
            SELECT Id
                , Stock__c
                , Name
            FROM Storage_Unit__c
            WHERE Stock__c IN :modifiedStocksMap.keySet()
        ]);

        List<Container__c> containersOnModifiedStocks = [
            SELECT Id
                , Storage_Unit__c
                , Storage_Unit__r.Name
                , Storage_Unit__r.Stock__c
            FROM Container__c
            WHERE Storage_Unit__c IN : storageUnitsOfModifiedStocksMap.keySet()
        ];

        for(Container__c container : containersOnModifiedStocks) {
            container.Position_Before_Stock_Modification__c = container.Storage_Unit__r.Name + '_' + 
                container.Storage_Unit__r.Stock__c;
        }
        if(!containersOnModifiedStocks.isEmpty()){
            update containersOnModifiedStocks;
        }
        if (!storageUnitsOfModifiedStocksMap.values().isEmpty()){
            delete storageUnitsOfModifiedStocksMap.values();
        }
        if(!modifiedStocksMap.values().isEmpty()){
            createStorageUnits(modifiedStocksMap.values());
        }
        // TODO: realize replace batch on stock change
        // Database.execute(new ReplaceContainersOnStockChangeBatch(), 1);
    }

    public void createStorageUnits(List<Stock__c> newList) {
        List<Storage_Unit__c> storageUnitsToInsert = new List<Storage_Unit__c>();

        for (Stock__c stock : newList) {
            for( Integer length = 1; length <= stock.Length__c; length++){
                for( Integer width = 1; width <= stock.Width__c; width++){
                    for( Integer height = 1; height <= stock.Height__c; height++){
                        Storage_Unit__c storageUnit = new Storage_Unit__c();
                        String lengthChar = String.fromCharArray( new List<integer> { BASE_CHAR_NUMBER + length });
                        String widthNumber = String.valueOf(width);
                        String heightValue = 'L' + height;
                        storageUnit.Length_Position__c = length;
                        storageUnit.Width_Position__c = width;
                        storageUnit.Height_Position__c = height;
                        storageUnit.Name = lengthChar + widthNumber + heightValue;
                        storageUnit.Stock__c = stock.Id;
                        storageUnitsToInsert.add(storageUnit);
                    }
                }
            }
        }
        insert storageUnitsToInsert;
    }

}