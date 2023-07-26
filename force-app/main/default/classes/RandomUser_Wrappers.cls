public class RandomUser_Wrappers {
	// Obtain Randomly Generated Users
	public class Users {
		public List<Result> results;
		public Info info;
	}

	public class Result {
		public String gender;
		public Name name;
		public Location location;
		public String email;
		public Login login;
		public Dob dob;
		public Registered registered;
		public String phone;
		public String cell;
		public Id id;
		public Picture picture;
		public String nat;
	}

	public class Picture {
		public String large;
		public String medium;
		public String thumbnail;
	}

	public class Id {
		public String name;
		public String value;
	}

	public class Registered {
		public String date_w; // date - origen
		public Integer age;
	}

	public class Dob {
		public String date_w; // date - origen
		public Integer age;
	}
	public class Login {
		public String uuid;
		public String username;
		public String password;
		public String salt;
		public String md5;
		public String sha1;
		public String sha256;
	}

	public class Location {
		public Street street;
		public String city;
		public String state;
		public String country;
		public String postcode;
		public Coordinates coordinates;
		public Timezone timezone;
	}

	public class Timezone {
		public String offset;
		public String description;
	}

	public class Coordinates {
		public String latitude;
		public String longitude;
	}

	public class Street {
		public Integer number_w; // number - origen
		public String name;
	}

	public class Name {
		public String title;
		public String first;
		public String last;
	}

	public class Info {
		public String seed;
		public Integer results;
		public Integer page;
		public String version;
	}

	public static RandomUser_Wrappers.Users parseObtainRandomlyGeneratedUser(
		RandomUser_Callout pCallout
	) {
		String responseBody = pCallout.getResponseBody()
			.replace('"date":', '"date_w":')
			.replace('"number":', '"number_w":');
		return (RandomUser_Wrappers.Users) System.JSON.deserialize(
			responseBody,
			RandomUser_Wrappers.Users.class
		);
	}
}