public without sharing class CellTriggerHandler {
    
    public void onBeforeInsert(List<Cell__c> newCells) {
        calculateCode(newCells, null);
    }

    public void onBeforeUpdate(List<Cell__c> newCells, Map<Id, Cell__c> oldCells) {
        calculateCode(newCells, oldCells);
    }

    private void calculateCode(List<Cell__c> cells, Map<Id, Cell__c> oldCells) {
        for (Cell__c cell : cells) {
            if (oldCells == null || 
                cell.Row__c != oldCells.get(cell.Id).Row__c ||
                cell.Column__c != oldCells.get(cell.Id).Column__c ||
                cell.Level__c != oldCells.get(cell.Id).Level__c) {

                cell.Code__c = cell.Row__c + String.valueOf(cell.Column__c + 1) + 'L' + String.valueOf(cell.Level__c + 1);
            }
        }
    }

}