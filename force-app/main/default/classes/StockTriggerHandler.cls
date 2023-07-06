public class StockTriggerHandler extends TriggerHandler {

    // public static Boolean skip = false;
    private StockTriggerHandlerHelper helper = new StockTriggerHandlerHelper();
    
    protected override void beforeInsert(){
        // if (skip) return;
    }
    
    protected override void beforeUpdate(){
        // if (skip) return;        
        helper.checkStockSizes((List<Stock__c>) Trigger.new, (Map<Id, Stock__c>) Trigger.oldMap );
    }
    
    protected override void afterInsert(){
        // if (skip) return;
        helper.createStorageUnits((List<Stock__c>) Trigger.new);
        helper.createTemporaryStorage();
    }
    
    protected override void afterUpdate(){
        // if (skip) return;
        helper.modifyStorageUnits((List<Stock__c>) Trigger.new, (Map<Id, Stock__c>) Trigger.oldMap );
        helper.createTemporaryStorage();
    }
    

}

