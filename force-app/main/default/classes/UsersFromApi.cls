public with sharing class UsersFromApi {

    public List<GeneratedContact> results;

    public class GeneratedContact {
        public String gender;
        public ContactName nameX;
        public String email;
        public String phone;
        public String cell;
        public ContactLocation location;
    }

    public class ContactName {
        public String title;
        public String first;
        public String last;
    }

    public class ContactLocation {
        public ContactStreet street;
        public String city;
        public String state;
        public String country;
        public String postcode;
    }

    public class ContactStreet {
        public String numberX;
        public String nameX;
    }
}