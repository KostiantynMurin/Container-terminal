/**
 * @description  ExternalUser wrapper.
 * @author Kostiantyn Murin
 * @date 24-06-2023
 */
public class ExternalUser {

    public List<Results> results {get;set;}

	/**
	 * @description  ExternalUser constructor.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
    public ExternalUser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'results') {
						results = arrayOfResults(parser);
					} else {
						System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'ExternalUser', text}));
						consumeObject(parser);
					}
				}
			}
		}
	}

	/**
	 * @description  Results wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
    public class Results {
		public String gender {get;set;} 
		public Name name {get;set;} 
		public Location location {get;set;} 
		public String email {get;set;} 
		public String phone {get;set;} 
		public String cell {get;set;} 

		/**
		 * @description  Results constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'cell') {
							cell = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'Results', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	/**
	 * @description  Timezone wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public class Timezone {
		public String offset {get;set;} 
		public String description {get;set;} 

		/**
		 * @description  Timezone constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'TimeZone', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	} 

	/**
	 * @description  Coordinates wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public class Coordinates {
		public String latitude {get;set;} 
		public String longitude {get;set;} 

		/**
		 * @description  Coordinates constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'Coordinates', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/**
	 * @description  Street wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public class Street {
		public Integer number_Z {get;set;} // in json: number
		public String name {get;set;} 

		/**
		 * @description  Street constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'Street', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/**
	 * @description  Name wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public class Name {
		public String title {get;set;} 
		public String first {get;set;} 
		public String last {get;set;} 

		/**
		 * @description  Name constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'Name', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/**
	 * @description  Location wrapper.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public class Location {
		public Street street {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 
		public String postcode {get;set;} 
		public Coordinates coordinates {get;set;} 
		public Timezone timezone {get;set;} 

		/**
		 * @description  Location constructor.
		 * @author Kostiantyn Murin
		 * @date 24-06-2023
		 */
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
							postcode = parser.getText();
						} else if (text == 'coordinates') {
							coordinates = new Coordinates(parser);
						} else if (text == 'timezone') {
							timezone = new Timezone(parser);
						} else {
							System.debug(LoggingLevel.WARN, String.format(Label.JSON_Parser_Error_Message, new List<Object>{'Location', text}));
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/**
	 * @description  JSON parse method.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
	public static ExternalUser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExternalUser(parser);
	}
	
	/**
	 * @description  consumeObject method.
	 * @author Kostiantyn Murin
	 * @date 24-06-2023
	 */
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