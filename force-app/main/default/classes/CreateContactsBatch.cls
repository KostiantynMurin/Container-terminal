public with sharing class CreateContactsBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful, Schedulable {

    List<Container__c> containersWithoutContacts;
    Map<String, Id> externalIdToContactIdMap = new Map<String, Id>();

    public Iterable<String> start(Database.BatchableContext bc) {

        containersWithoutContacts = [
            SELECT Id
                , External_Contact_Id__c
            FROM Container__c
            WHERE Contact__c = NULL
            AND External_Contact_Id__c != NULL
        ];
        Set<String> contactsExternalIds = new Set<String>();
        for(Container__c container : containersWithoutContacts) {
            contactsExternalIds.add(container.External_Contact_Id__c);
        }
        List<String> externalIdList = new List<String>(contactsExternalIds);
        return externalIdList;

    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Contact_Generator');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res;

        List<Contact> contactsToInsert = new List<Contact>();
        for(String externalId : scope) {
            try {
                Contact cont = new Contact();
                res = http.send(req);
                System.debug(res.getBody());
                if(res.getStatusCode() != 200) {
                    throw new CreateContactsBatchException('issue with contact ' + cont.Id + ', data is not recieved');
                }
                String body = res.getBody();
                body = body.replaceAll('name', 'nameX');
                body = body.replaceAll('number', 'numberX');
                UsersFromApi returnedUsers = (UsersFromApi) JSON.deserialize(body, UsersFromApi.class);
                UsersFromApi.GeneratedContact retrievedContact = returnedUsers.results.get(0);

                cont.External_Id__c = externalId;
                cont.Phone = retrievedContact.phone;
                cont.Email = retrievedContact.email;
                cont.MobilePhone = retrievedContact.cell;
                cont.FirstName = retrievedContact.nameX.first;
                cont.LastName = retrievedContact.nameX.last;
                cont.MailingCity = retrievedContact.location.city;
                cont.MailingStreet = retrievedContact.location.street.numberX + ' ' + retrievedContact.location.street.nameX;
                cont.MailingPostalCode = retrievedContact.location.postcode;
                cont.MailingCountry = retrievedContact.location.country;
                cont.MailingState = retrievedContact.location.state;
                contactsToInsert.add(cont);
            } catch (CreateContactsBatchException ex ) {
                System.debug(ex.getMessage());
                continue;
            }
        }

        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;
            for(Contact cont : contactsToInsert){
                externalIdToContactIdMap.put(cont.External_Id__c, cont.Id);
            }
        }


    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateContactsBatch(), 80);
    }

    public void finish(Database.BatchableContext BC) {
        for( Container__c container : containersWithoutContacts){
            container.Contact__c = externalIdToContactIdMap.get(container.External_Contact_Id__c);
        }
        update containersWithoutContacts;
        Database.executeBatch(new DistributeContainersFromShipBatch(), 200);
    }

    public class CreateContactsBatchException extends Exception {}

}


