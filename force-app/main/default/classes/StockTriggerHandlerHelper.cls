public class StockTriggerHandlerHelper {
    private static Integer BASE_CHAR_NUMBER = 64;
    public void modifyStorageUnits(List<Stock__c> newList, Map<Id, Stock__c> oldmap) {
        Map<Id, Stock__c> modifiedStocksMap = new Map<Id, Stock__c>();
        for (Stock__c stock : newList){
            Stock__c oldStockValue = oldmap.get(stock.Id);
            if ( stock.Length__c != oldStockValue.Length__c || 
                stock.Width__c != oldStockValue.Width__c ||
                stock.Height__c != oldStockValue.Height__c ){
                    modifiedStocksMap.put(stock.Id, stock);
            }
        }

        createStorageUnits(modifiedStocksMap.values());
    }

    public void checkStockSizes(List<Stock__c> newList, Map<Id, Stock__c> oldmap) {
        for (Stock__c stock : newList){
            Stock__c oldStockValue = oldmap.get(stock.Id);
            if ( stock.Length__c < oldStockValue.Length__c ){
                stock.Length__c.addError('Can\'t be less than previous value');
            }
            if ( stock.Width__c < oldStockValue.Width__c ){
                stock.Width__c.addError('Can\'t be less than previous value');
            }
            if ( stock.Height__c < oldStockValue.Height__c ){
                stock.Height__c.addError('Can\'t be less than previous value');
            }
        }
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
                        storageUnit.Uniq_Id__c = storageUnit.Name + '_' + stock.Id;
                        storageUnitsToInsert.add(storageUnit);
                    }
                }
            }
        }
        upsert storageUnitsToInsert Uniq_Id__c;
    }

}