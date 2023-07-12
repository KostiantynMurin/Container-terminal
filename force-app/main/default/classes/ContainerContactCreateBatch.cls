global without sharing class ContainerContactCreateBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {

    List<Container__c> containers;

    public ContainerContactCreateBatch(List<Container__c> containers) {
        this.containers = containers;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, External_Contact_ID__c FROM Container__c';

        if (containers != null && containers.size() > 0) {
            query += ' WHERE Id IN :containers';
        }
        else {
            query += ' WHERE Contact__c = null';
        }

        return Database.getQueryLocator(query);
     }
 
     global void execute(Database.BatchableContext BC, List<Container__c> scope) { 
        
        Set<String> contactExtIds = new Set<String>();
        for (Container__c container : scope) {
            contactExtIds.add(container.External_Contact_ID__c);
        }

        List<Contact> contacts = [SELECT Id, External_ID__c FROM Contact WHERE External_ID__c IN :contactExtIds];
        Map<String, Contact> contactMap = new Map<String, Contact>();
        for (Contact contact : contacts) {
            contactMap.put(contact.External_ID__c, contact);
        }

        List<Contact> newContacts = new List<Contact>();
        for (String extContactId : contactExtIds) {
            if (!contactMap.containsKey(extContactId)) {
                Contact newContact = getNewContactInfo();
                if (newContact == null) continue;
                newContact.External_ID__c = extContactId;
                newContacts.add(newContact);
                contactMap.put(newContact.External_ID__c, newContact);
            }
        }

        if (newContacts.size() > 0) {
            insert newContacts;
        }

        for(Container__c container : scope){
            if (contactMap.containsKey(container.External_Contact_ID__c)) {
                container.Contact__c = contactMap.get(container.External_Contact_ID__c).Id;
            }
        }

        update scope;
    }   

    private Contact getNewContactInfo() {
        try {                  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();

            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint('https://randomuser.me/api/');
            req.setMethod('GET');
            res = http.send(req);
            String sJson = res.getBody();
            
            return parseContactFromJson(sJson);
       }
       catch (Exception e) {         
          System.debug('Error:' + e.getMessage() + 'Line no:' + e.getLineNumber() );  
          return null;         
       }
    }

    private Contact parseContactFromJson(String jsonStr) {
        Contact contact = new Contact();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        List<Object> results = (List<Object>) jsonMap.get('results');
        Map<String, Object> result = (Map<String, Object>) results[0];
        Map<String, Object> name = (Map<String, Object>) result.get('name');
        Map<String, Object> location = (Map<String, Object>) result.get('location');
        Map<String, Object> street = (Map<String, Object>) location.get('street');
        Map<String, Object> dob = (Map<String, Object>) result.get('dob');
        Map<String, Object> registered = (Map<String, Object>) result.get('registered');

        contact.FirstName = (String) name.get('first');
        contact.LastName = (String) name.get('last');
        contact.Email = (String) result.get('email');
        contact.Phone = (String) result.get('phone');
        contact.MobilePhone = (String) result.get('cell');
        contact.Birthdate = Date.valueOf(((String) dob.get('date')).substringBefore('T'));
        contact.MailingStreet = (String) street.get('name');
        contact.MailingCity = (String) location.get('city');
        contact.MailingState = (String) location.get('state');
        contact.MailingPostalCode = String.valueOf(location.get('postcode'));
        contact.MailingCountry = (String) location.get('country');

        return contact;
    }
 
    global void finish(Database.BatchableContext BC){}
}