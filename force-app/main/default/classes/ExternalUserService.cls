/**
 * @description  ExternalUserService.
 * @author Kostiantyn Murin
 * @date 24-06-2023
 */
public with sharing class ExternalUserService {

    /**
     * @description  getContactByExtId - making callout to external system.
     * @author Kostiantyn Murin
     * @date 24-06-2023
     * @param externalId String
     * @return new Contact or null if exception will catched
     */
    public static Contact getContactByExtId(String externalId) {
        ExternalUser externalUser;
        try {
            HTTPCalloutService service = new HTTPCalloutService('Random_User_API');
            System.JSONParser parser = System.JSON.createParser(service.sendRequest().getBody());
            externalUser = new ExternalUser(parser);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return generateContact(externalId, externalUser);
    }

    private static Contact generateContact(String externalId, ExternalUser externalUser) {
        return new Contact(
            External_Id__c = externalId,
            Salutation = externalUser?.results[0]?.Name?.title,
            FirstName = externalUser?.results[0]?.Name?.first,
            LastName = externalUser?.results[0]?.Name?.last,
            Email = externalUser?.results[0]?.email,
            Phone = externalUser?.results[0]?.phone,
            MobilePhone = externalUser?.results[0]?.cell
        );
    }
}