trigger StockTrigger on Stock__c(before insert, before update, after insert, after update, before delete, after delete) {
    new StockTriggerHandler().run();
}