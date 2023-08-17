public with sharing class RandomUserWrapper {

	public class Timezone {
		public String offset {get;set;} 
		public String description {get;set;} 

		public Timezone(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'offset') {
							offset = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Timezone consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Results {
		public String gender {get;set;} 
		public Name name {get;set;} 
		public Location location {get;set;} 
		public String email {get;set;} 
		public Login login {get;set;} 
		public Dob dob {get;set;} 
		public Dob registered {get;set;} 
		public String phone {get;set;} 
		public String cell {get;set;} 
		public Picture picture {get;set;} 
		public String nat {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'gender') {
							gender = parser.getText();
						} else if (text == 'name') {
							name = new Name(parser);
						} else if (text == 'location') {
							location = new Location(parser);
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'login') {
							login = new Login(parser);
						} else if (text == 'dob') {
							dob = new Dob(parser);
						} else if (text == 'registered') {
							registered = new Dob(parser);
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'cell') {
							cell = parser.getText();
						} else if (text == 'picture') {
							picture = new Picture(parser);
						} else if (text == 'nat') {
							nat = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Results> results {get;set;} 
	public Info info {get;set;} 

	public RandomUserWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'results') {
						results = arrayOfResults(parser);
					} else if (text == 'info') {
						info = new Info(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'RandomUserWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Dob {
		public String date_Z {get;set;} // in json: date
		public Integer age {get;set;} 

		public Dob(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'date') {
							date_Z = parser.getText();
						} else if (text == 'age') {
							age = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Dob consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Picture {
		public String large {get;set;} 
		public String medium {get;set;} 
		public String thumbnail {get;set;} 

		public Picture(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'large') {
							large = parser.getText();
						} else if (text == 'medium') {
							medium = parser.getText();
						} else if (text == 'thumbnail') {
							thumbnail = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Picture consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Coordinates {
		public String latitude {get;set;} 
		public String longitude {get;set;} 

		public Coordinates(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'latitude') {
							latitude = parser.getText();
						} else if (text == 'longitude') {
							longitude = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Coordinates consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Street {
		public Integer number_Z {get;set;} // in json: number
		public String name {get;set;} 

		public Street(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'number') {
							number_Z = parser.getIntegerValue();
						} else if (text == 'name') {
							name = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Street consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Login {
		public String uuid {get;set;} 
		public String username {get;set;} 
		public String password {get;set;} 
		public String salt {get;set;} 
		public String md5 {get;set;} 
		public String sha1 {get;set;} 
		public String sha256 {get;set;} 

		public Login(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uuid') {
							uuid = parser.getText();
						} else if (text == 'username') {
							username = parser.getText();
						} else if (text == 'password') {
							password = parser.getText();
						} else if (text == 'salt') {
							salt = parser.getText();
						} else if (text == 'md5') {
							md5 = parser.getText();
						} else if (text == 'sha1') {
							sha1 = parser.getText();
						} else if (text == 'sha256') {
							sha256 = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Login consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Info {
		public String seed {get;set;} 
		public Integer results {get;set;} 
		public Integer page {get;set;} 
		public String version {get;set;} 

		public Info(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'seed') {
							seed = parser.getText();
						} else if (text == 'results') {
							results = parser.getIntegerValue();
						} else if (text == 'page') {
							page = parser.getIntegerValue();
						} else if (text == 'version') {
							version = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Info consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Name {
		public String title {get;set;} 
		public String first {get;set;} 
		public String last {get;set;} 

		public Name(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'title') {
							title = parser.getText();
						} else if (text == 'first') {
							first = parser.getText();
						} else if (text == 'last') {
							last = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Name consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Location {
		public Street street {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 
		public Integer postcode {get;set;} 
		public Coordinates coordinates {get;set;} 
		public Timezone timezone {get;set;} 

		public Location(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'street') {
							street = new Street(parser);
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'postcode') {
							postcode = parser.getIntegerValue();
						} else if (text == 'coordinates') {
							coordinates = new Coordinates(parser);
						} else if (text == 'timezone') {
							timezone = new Timezone(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Location consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static RandomUserWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new RandomUserWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Results> arrayOfResults(System.JSONParser p) {
        List<Results> res = new List<Results>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Results(p));
        }
        return res;
    }
}