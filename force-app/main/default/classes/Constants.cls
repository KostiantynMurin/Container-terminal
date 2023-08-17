public with sharing class Constants {

    // Container Allocation Statuses
    public static final String AWAITING_ISSUANCE = 'Awaiting issuance';
    public static final String AWAITING_SHIPMENT = 'Awaiting shipment';
    public static final String ARRIVED_FOR_ISSUANCE = 'Arrived for issuance';
    public static final String ARRIVED_FOR_SHIPMENT = 'Arrived for shipment';

    public static final List<String> AWAITING_STATUS_LIST = new List<String> { AWAITING_ISSUANCE, AWAITING_SHIPMENT };
    public static final List<String> ARRIVED_STATUS_LIST = new List<String> { ARRIVED_FOR_ISSUANCE, ARRIVED_FOR_SHIPMENT };

    // Container Statuses
    public static final String ARRIVED = 'Arrived';
    public static final String CREDITED = 'Credited';
    public static final String ISSUED = 'Issued';

}