public class ContainerTriggerHandlerHelper {
    public void createContactsForContainers(List<Container__c> newList) {
        List<Contact> contactsToInsert = new List<Contact>();
        for(Container__c container : newList) {
            if (container.External_Contact_Id__c){
                Contact cont = new Contact();
                cont.External_Id__c = container.External_Contact_Id__c;
                contactsToInsert.add(cont);
            }
        }
        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }
    }
}