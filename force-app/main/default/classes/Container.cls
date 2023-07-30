public with sharing class Container {
    public static final String STATUS_ARRIVED_ISSUANCE = 'Arrived for issuance';
    public static final String STATUS_ARRIVED_SHIPMENT = 'Arrived for shipment';
    public static final String STATUS_AWAITING_ISSUANCE = 'Awaiting issuance';
    public static final String STATUS_AWAITING_SHIPMENT = 'Awaiting shipment';
    public static final String STATUS_SHIPPED = 'Shipped';

    public static final String SOURCE_IS_TRUCK = 'Truck';
    public static final String SOURCE_IS_SHIP = 'Ship';

    public Id id; 
    public String externalId; 
    public Date deliveryDate; 
    public String warehouse;
    public String status;
    public String contact;
    public String description;
    public String serialNumber;
    
    // Constructor
    public Container(
        String externalId, 
        Date deliveryDate, 
        String warehouse, 
        String status, 
        String contact, 
        String description, 
        String serialNumber)
        {
            this.externalId = externalId;
            this.deliveryDate = deliveryDate;
            this.warehouse = warehouse;
            this.status = status;
            this.contact = contact;
            this.description = description;
            this.serialNumber = serialNumber;
    }

    // Comparable interface implementation
    public Integer compareTo(Container__c containerToCompare) {
        if (deliveryDate == containerToCompare.DeliveryDate__c) return 0;
        if (deliveryDate > containerToCompare.DeliveryDate__c) return 1;
        return -1;
    }
}