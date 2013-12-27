using Gee;
namespace Couchbase.JSON {

	/**
	 * Deserialize from JSON.
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
				default:
					return false;
			}
			return true;
		}

		public static bool parse_array( ref Value v, Json.Node node ) {
			// stdout.printf( "Type: %s\n", v.type().name() );
			Json.Array array = node.get_array();
			if ( array.get_length() == 0 ) {
				return false;
			}
			array.foreach_element(
				( array, index, node ) => {

				}
			);
			return false;
		}

		public static bool parse_null( ref Value v, Json.Node node ) {
			return false;
		}

		// private static void serialize_arraylist( Value v, Json.Builder b ) {
		// 	Type generic_type = ( (ArrayList) v ).element_type;
		// 	b.begin_array();
		// 	switch (generic_type.name()) {
		// 		case "gchararray":
		// 			ArrayList<string> array = (ArrayList<string>) v;
		// 			foreach ( var element in array ) {
		// 				b.add_string_value(element);
		// 			}
		// 			break;
		// 		case "gint":
		// 			ArrayList<int> array = (ArrayList<int>) v;
		// 			foreach ( var element in array ) {
		// 				b.add_int_value(element);
		// 			}
		// 			break;
		// 		case "gboolean":
		// 			ArrayList<bool> array = (ArrayList<bool>) v;
		// 			foreach ( var element in array ) {
		// 				b.add_boolean_value(element);
		// 			}
		// 			break;
		// 		case "gdouble":
		// 			ArrayList<double?> array = (ArrayList<double?>) v;
		// 			foreach ( var element in array ) {
		// 				b.add_double_value(element);
		// 			}
		// 			break;
		// 		case "GObject":
		// 			ArrayList<Object> array = (ArrayList<Object>) v;
		// 			foreach ( var element in array ) {
		// 				serialize_object_as_object( element, b );
		// 			}
		// 			break;
		// 	}
		// 	b.end_array();
		// }
	}

	public class DeserializeNodeWrapper : Object {
		public unowned Deserializer.DeserializeNode? deserializer { get; set; }

		public DeserializeNodeWrapper( Deserializer.DeserializeNode? dn ) {
			this.deserializer = dn;
		}
	}
}