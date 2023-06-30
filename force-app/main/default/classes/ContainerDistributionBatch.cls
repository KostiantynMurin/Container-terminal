public class ContainerDistributionBatch implements Database.Batchable<Container__c>, Database.Stateful {
    
    private Integer currentDayNumber;
    private Integer amountOfContainersForCurrentDay;
    private Date dateOfCurrentDay;
    private Map<Integer, Integer> dayNumberToAmountOfContainers;
    private Map<Integer, Date> dayNumberToDate;
    private WarehousesDataService whDataService;

    public Iterable<Container__c> start(Database.BatchableContext bc) {

        List<Container__c> containers = [
            SELECT Id
            FROM Container__c
            WHERE Status__c = 'Arrived For Delivery'
            AND Warehouse_Cell__c = null
            ORDER BY Contact_Ext_Id__c
        ];

        if (containers.isEmpty()) {
            return containers;
        }

        Integer numberOfDays = 5;
        Decimal amountOfContainers = (Decimal) containers.size();

        Decimal amountOfContainersPerDayRaw = amountOfContainers / numberOfDays;
        amountOfContainersPerDayRaw.setScale(0);

        Integer amountOfContainersPerDay = amountOfContainersPerDayRaw.intValue();
        Integer amountOfContainersForLastDay = amountOfContainersPerDay;

        Integer delta = amountOfContainers.intValue() - (amountOfContainersPerDay * numberOfDays);

        if (delta != 0) {
            amountOfContainersForLastDay = amountOfContainersForLastDay + delta;
        }
        
        if (amountOfContainersForLastDay <= 0) {

            if (amountOfContainersForLastDay == 0) {
                numberOfDays--;
            } else if (amountOfContainersForLastDay < 0) {
                
                do {
                    numberOfDays--;
                    amountOfContainersForLastDay = amountOfContainersPerDay + amountOfContainersForLastDay;
                } while (amountOfContainersForLastDay != 0);
            }

            amountOfContainersForLastDay = amountOfContainersPerDay;
        }

        dayNumberToDate = new Map<Integer, Date>();
        dayNumberToAmountOfContainers = new Map<Integer, Integer>();

        for (Integer i = 1; i < numberOfDays + 1; i++) {

            dayNumberToDate.put(i, Date.today().addDays(i + 1));

            Integer amount = amountOfContainersPerDay;

            if (i == numberOfDays) {
                amount = amountOfContainersForLastDay;
            }

            dayNumberToAmountOfContainers.put(i, amount);
        }

        currentDayNumber = numberOfDays;
        amountOfContainersForCurrentDay = dayNumberToAmountOfContainers.get(currentDayNumber);
        dateOfCurrentDay = dayNumberToDate.get(currentDayNumber);

        whDataService = WarehousesDataService.getInstance();

        return containers;
    }

    public void execute(Database.BatchableContext BC, List<Container__c> scope) {

        for (Container__c container_i : scope) {
            
            if (amountOfContainersForCurrentDay == 0) {
                currentDayNumber--;
                amountOfContainersForCurrentDay = dayNumberToAmountOfContainers.get(currentDayNumber);
                dateOfCurrentDay = dayNumberToDate.get(currentDayNumber);
            }

            CellDataWrapper cdw = whDataService.getEmptyCell();

            container_i.Date_Of_Issue__c = dateOfCurrentDay;
            container_i.Status__c = 'Waiting For Delivery';

            if (cdw.getLevel() == 1) {
                container_i.Warehouse_Cell__c = cdw.cellId;
                whDataService.placeContainerToCell(container_i, cdw);
            } else {

                CellDataWrapper previousCell = whDataService.getPreviousCell(cdw);

                if (!previousCell.isContainerForShipment()) {
                    container_i.Warehouse_Cell__c = cdw.cellId;
                    whDataService.placeContainerToCell(container_i, cdw);
                }
            }

            amountOfContainersForCurrentDay--;
        }

        update scope;
    }

    public void finish(Database.BatchableContext BC) {

    }
}