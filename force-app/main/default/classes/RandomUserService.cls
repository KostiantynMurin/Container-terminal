public with sharing class RandomUserService {
    private static final String END_POINT = 'https://randomuser.me/api/';
    private static final String RANDOM_USER_WRAPPER_ERROR_MSG = 'Random User Wraper data is not valid!';

    public static Contact obtainContactByRandomUser(String externalContactId) {
        HttpResponse response = HTTPCalloutService.makeHttpCallout(END_POINT);
        RandomUserWrapper randomUserWrapper = RandomUserWrapper.parse(response.getBody());
        if (randomUserWrapper != null && randomUserWrapper.results != null) {
            return generateContact(externalContactId, randomUserWrapper);
        }
        else {
            throw new RandomUserServiceException(RANDOM_USER_WRAPPER_ERROR_MSG);
        }
    }

    private static Contact generateContact(String externalId, RandomUserWrapper randomUserWrapper) {
        return new Contact(
            External_Contact_Id__c = externalId,
            Salutation = randomUserWrapper?.results[0]?.name?.title,
            FirstName = randomUserWrapper?.results[0]?.name?.first,
            LastName = randomUserWrapper?.results[0]?.name?.last,
            Email = randomUserWrapper?.results[0]?.email,
            Phone = randomUserWrapper?.results[0]?.phone
        );
    }

    public class RandomUserServiceException extends Exception {}
}