public with sharing class WarehouseHelper {

    // Method to find a target cell for a given container.
    public static Cell__c findTargetCellForContainer(Container__c theContainer, List<Cell__c> cellList) {
        // Initialize targetCell to null
        Cell__c targetCell = null;

        // Iterate through all cells in the warehouse
        for (Cell__c theCell : cellList) {
            // If the cell's level is one and the status is 'Free', assign the cell to the targetCell and break the loop
            if (theCell.Level__c == 1 && theCell.Status__c == Cell.STATUS_FREE) {
                targetCell = theCell;
                break;
            }

            // If the cell's level is one and it contains a container to be shipped, 
            // check if there is a free cell in the same column but on a different level
            else if (theCell.Level__c == 1 && theCell.Status__c == Cell.STATUS_OCCUPIED && theCell.Container__r.DeliveryDate__c != null) {
                for (Cell__c innerCell : cellList) {
                    // Check if the cell is in the same column but on a different level and is free
                    Boolean isTheSameColumn = innerCell.Column__c == theCell.Column__c;
                    Boolean notFirstCell = innerCell.Level__c > 1;
                    Boolean isFree = innerCell.Status__c == Cell.STATUS_FREE;
                    Boolean hasSameDeliveryDate = theContainer.DeliveryDate__c == theCell.Container__r.DeliveryDate__c;

                    if (isTheSameColumn && notFirstCell && isFree && hasSameDeliveryDate) {
                        // Move the container in cell to innerCell
                        targetCell = innerCell;
                        break;
                    }
                }
            }
        }
        return targetCell;
    }

    public static Map<Integer, String> getWidthMapping() {
        return new Map<Integer, String>{
            1 => 'A',
            2 => 'B',
            3 => 'C',
            4 => 'D',
            5 => 'E',
            6 => 'F',
            7 => 'G',
            8 => 'J',
            9 => 'H',
            10 => 'K'
        };
    }

    
    public static Date calculateDeliveryDate(Integer step, Integer containerSize, Boolean isFromShip){
        Date sundayDate = Date.today().toStartOfWeek().addDays(6);
        if (isFromShip){
            // Divide containers evenly by day of the week
            Integer deliveryDays = WarehouseManager.DELIVERY_DAYS;
            Integer containersPerDay = Math.round(containerSize / deliveryDays);
            Integer targetDay = containersPerDay > 0 
            ? (Integer)Math.floor(step / containersPerDay) - 1
            : 1;
            return sundayDate.addDays(targetDay);
        } else {
            // Calculate Sunday to deploy containers on the Ship
            return sundayDate;
        }
    }
}