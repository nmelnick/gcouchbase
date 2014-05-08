using Gee;
namespace Couchbase.JSON {

	/**
	 * Deserialize from JSON to a given class type.
	 * For properties made of ArrayList, be sure to instantiate the ArrayList
	 * so the deserializer knows the inner type. It seems wasteful, but without
	 * it, Vala has no idea what the generic type is.
	 */
	public class Deserializer : Object {
		public delegate bool DeserializeNode( ref Value v, Json.Node node );
		public static HashMap<Json.NodeType,DeserializeNodeWrapper> deserializers { get; set; default = new HashMap<Json.NodeType,DeserializeNodeWrapper>(); }

		public Deserializer() {
			deserializers[ Json.NodeType.NULL ] = new DeserializeNodeWrapper(parse_null);
			deserializers[ Json.NodeType.VALUE ] = new DeserializeNodeWrapper(parse_value);
			deserializers[ Json.NodeType.ARRAY ] = new DeserializeNodeWrapper(parse_array);
			deserializers[ Json.NodeType.OBJECT ] = new DeserializeNodeWrapper(parse_object);
		}

		public Object? deserialize( string serialized, Type object_type ) {
			Object? o = null;
			try {
				var parser = new Json.Parser();
				parser.load_from_data( serialized, -1 );
				var root = parser.get_root();
				Value v = Value( object_type );
				parse_object( ref v, root );
				o = v.get_object();
			} catch (Error e) {
				stderr.printf( "%s\n", e.message );
			}
			return o;
		}

		public static bool parse_object( ref Value v, Json.Node node ) {
			Object o = Object.new( v.type() );
			Json.Object jo = node.get_object();
			// Iterate through properties in given object
			foreach ( ParamSpec ps in o.get_class().list_properties() ) {
				// Skip "privatized" properties
				if ( ps.name.substring( 0, 1 ) == "-" ) {
					continue;
				}

				if ( ps.get_blurb() != null && ps.get_blurb() == "ignore" ) {
					continue;
				}

				var underscored = ps.name.replace( "-", "_" );
				Json.Node? member = null;
				if ( jo.has_member(underscored) ) {
					member = jo.get_member(underscored);
				} else if ( jo.has_member( ps.name ) ) {
					member = jo.get_member( ps.name );
				}
				if ( member != null ) {
					Value member_v = Value( ps.value_type );
					o.get_property( ps.name, ref member_v );
					if ( deserializers[ member.get_node_type() ].deserializer( ref member_v, member ) ) {
						o.set_property( ps.name, member_v );
					}
				}
			}
			v.set_object(o);
			return true;
		}

		public static bool parse_value( ref Value v, Json.Node node ) {
			var generic_type = v.type();
			switch ( generic_type.name() ) {
				case "gchararray":
					v.set_string( node.get_string() );
					break;
				case "gint":
					v.set_int( (int) node.get_int() );
					break;
				case "gint64":
					v.set_int64( node.get_int() );
					break;
				case "gboolean":
					v.set_boolean( node.get_boolean() );
					break;
				case "gdouble":
					v.set_double( node.get_double() );
					break;
				case "CouchbaseJSONNode":
					v.set_object( new Node(node) );
					break;
				case "GDateTime":
					var timeval = TimeVal();
					if ( timeval.from_iso8601( node.get_string() ) ) {
						var dt = new DateTime.from_timeval_utc(timeval);
						v.set_boxed(dt);
					} else {
						warning( "Unable to convert %s as ISO-8601 to DateTime".printf( node.get_string() ) );
					}
					break;
				default:
					return false;
			}
			return true;
		}

		public static bool parse_array( ref Value v, Json.Node node ) {
			Json.Array array = node.get_array();
			if ( array.get_length() == 0 ) {
				return false;
			}
			string type_name = v.type().name();
			if ( type_name == "GeeArrayList" ) {
				return parse_arraylist( ref v, array );
			} else if ( type_name == "GStrv" ) {
				return parse_stringarray( ref v, array );
			} else if ( type_name == "GIntv" ) {
				return parse_intarray( ref v, array );
			} else if ( type_name == "CouchbaseJSONNode" ) {
				v.set_object( new Node(node) );
				return true;
			}
			return false;
		}

		public static bool parse_null( ref Value v, Json.Node node ) {
			return false;
		}

		private static bool parse_arraylist( ref Value v, Json.Array array ) {
			Type generic_type = array.get_element(0).get_value_type();
			switch (generic_type.name()) {
				case "gchararray":
					ArrayList<string> new_array = new ArrayList<string>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_string() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gint":
					ArrayList<int> new_array = new ArrayList<int>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( (int) node.get_int() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gint64":
					ArrayList<int64?> new_array = new ArrayList<int64?>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_int() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gdouble":
					ArrayList<double?> new_array = new ArrayList<double?>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_double() );
						}
					);
					v.set_object(new_array);
					return true;
				case "JsonObject":
					var target_value = ( (ArrayList) v ).element_type;
					ArrayList<Object> new_array = new ArrayList<Object>();
					array.foreach_element(
						( array, index, node ) => {
							Value obj_v = Value(target_value);
							parse_object( ref obj_v, node );
							new_array.add( (Object) obj_v );
						}
					);
					v.set_object(new_array);
					return true;
				default:
					if ( generic_type.is_object() ) {
						ArrayList<Object> new_array = new ArrayList<Object>();
						array.foreach_element(
							( array, index, node ) => {
								Value obj_v = Value(generic_type);
								parse_object( ref obj_v, node );
								new_array.add( (Object) obj_v );
							}
						);
						v.set_object(new_array);
						return true;
					}
					break;
			}
			return false;
		}

		private static bool parse_stringarray( ref Value v, Json.Array array ) {
			string[] new_array = new string[ array.get_length() ];
			array.foreach_element(
				( array, index, node ) => {
					new_array[index] = node.get_string();
				}
			);
			v.set_boxed(new_array);
			return true;
		}

		private static bool parse_intarray( ref Value v, Json.Array array ) {
			int[] new_array = new int[ array.get_length() ];
			array.foreach_element(
				( array, index, node ) => {
					new_array[index] = (int) node.get_int();
				}
			);
			v.set_boxed(new_array);
			return true;
		}
	}

	public class DeserializeNodeWrapper : Object {
		public unowned Deserializer.DeserializeNode? deserializer { get; set; }

		public DeserializeNodeWrapper( Deserializer.DeserializeNode? dn ) {
			this.deserializer = dn;
		}
	}
}