public class ContactsCreationBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    
    private String query = 'SELECT Id'
                              + ', Contact_Ext_Id__c'
                        + ' FROM Container__c ';
    private String condition;
    private Integer chunkSize = 75;
    
    public ContactsCreationBatch() {
        this.query += ' WHERE Contact__c = null AND Contact_Ext_Id__c != null';
        this.query += ' ORDER BY Contact_Ext_Id__c';
    }
    
    public ContactsCreationBatch(Integer chunkSize) {
        this();
        if (chunkSize != null && chunkSize != 0 && chunkSize < 100) {
            this.chunkSize = chunkSize;
        }
    }

    public ContactsCreationBatch(String condition) {
        this.condition = condition;
        query += condition != null ? condition : '';
        this.query += ' ORDER BY Contact_Ext_Id__c';
    }

    public ContactsCreationBatch(String condition, Integer chunkSize) {

        this(condition);

        if (chunkSize != null && chunkSize != 0 && chunkSize < 100) {
            this.chunkSize = chunkSize;
        }
    }

    public void execute(SchedulableContext sc) {
        if (String.isBlank(condition)) {
            Database.executeBatch(new ContactsCreationBatch(), this.chunkSize);
        } else {
            Database.executeBatch(new ContactsCreationBatch(condition), this.chunkSize);
        } 
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Container__c> scope) {

        Map<String, Contact> externalIdToContactMap = new Map<String, Contact>();

        for (Container__c container_i : scope) {
            
            if (externalIdToContactMap.containsKey(container_i.Contact_Ext_Id__c)) {
                continue;
            }

            String response = HttpRequestUtil.sendRequest('callout:RandomuserApi', null, 'application/json', null, 'GET', null);
            response = response.replace('name', 'nameParam').replace('number', 'numberParam');
            ContactsWrapper cw = (ContactsWrapper) JSON.deserialize(response, ContactsWrapper.class);

            Contact contact = cw.getContacts().get(0);
            contact.External_Id__c = container_i.Contact_Ext_Id__c;

            externalIdToContactMap.put(container_i.Contact_Ext_Id__c, contact);
        }

        if (externalIdToContactMap.isEmpty()) {
            return;
        }

        insert externalIdToContactMap.values();

        for (Container__c container_i : scope) {
            container_i.Contact__c = externalIdToContactMap.get(container_i.Contact_Ext_Id__c).Id;
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new ContainerDistributionBatch());
    }

    public class ContactsWrapper {

        List<ContactWrapper> results;

        public List<Contact> getContacts() {

            List<Contact> contacts = new List<Contact>();

            if (results == null || results.isEmpty()) {
                return contacts;
            }

            for (ContactWrapper cw_i : results) {

                Contact cont = new Contact(
                    FirstName = cw_i.nameParam.first,
                    LastName = cw_i.nameParam.last,
                    Email = cw_i.email,
                    Phone = cw_i.phone,
                    MobilePhone = cw_i.cell,
                    MailingCountry = cw_i.location.country,
                    MailingState = cw_i.location.state,
                    MailingCity = cw_i.location.city,
                    MailingPostalCode = cw_i.location.postCode,
                    MailingStreet = cw_i.location.street.getStreet()
                );

                contacts.add(cont);
            }

            return contacts;
        }
    }

    public class ContactWrapper {
        String gender;
        ContactNameWrapper nameParam;
        ContactLocationWrapper location;
        String email;
        String phone;
        String cell;
    }

    public class ContactNameWrapper {
        String title;
        String first;
        String last;
    }

    public class ContactLocationWrapper {
        ContactStreetWrapper street;
        String city;
        String state;
        String country;
        String postCode;
    }

    public class ContactStreetWrapper {
        Integer numberParam;
        String nameParam;

        public String getStreet() {
            return numberParam + ' ' + nameParam;
        }
    }
}