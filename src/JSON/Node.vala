namespace Couchbase.JSON {
	public class Node : Object {
		private Json.Node node;

		public Node( Json.Node node ) {
			this.node = node;
		}

		public Json.Node copy () {
			return node.copy();
		}
		public Json.Array dup_array () {
			return node.dup_array();
		}
		public Json.Object dup_object() {
			return node.dup_object();
		}
		public string dup_string() {
			return node.dup_string();
		}
		public void free() {
			node.free();
		}
		public weak Json.Array get_array() {
			return node.get_array();
		}
		public bool get_boolean() {
			return node.get_boolean();
		}
		public double get_double() {
			return node.get_double();
		}
		public int64 get_int() {
			return node.get_int();
		}
		public Json.NodeType get_node_type() {
			return node.get_node_type();
		}
		public weak Json.Object get_object() {
			return node.get_object();
		}
		public unowned Json.Node get_parent() {
			return node.get_parent();
		}
		public unowned string get_string() {
			return node.get_string();
		}
		public Value get_value() {
			return node.get_value();
		}
		public Type get_value_type() {
			return node.get_value_type();
		}
		public unowned Json.Node init(Json.NodeType type) {
			return node.init(type);
		}
		public unowned Json.Node init_array(Json.Array? array) {
			return node.init_array(array);
		}
		public unowned Json.Node init_boolean(bool value) {
			return node.init_boolean(value);
		}
		public unowned Json.Node init_double(double value) {
			return node.init_double(value);
		}
		public unowned Json.Node init_int(int64 value) {
			return node.init_int(value);
		}
		public unowned Json.Node init_null() {
			return node.init_null();
		}
		public unowned Json.Node init_object(Json.Object? object) {
			return node.init_object(object);
		}
		public unowned Json.Node init_string(string? value) {
			return node.init_string(value);
		}
		public bool is_null() {
			return node.is_null();
		}
		public void set_array(Json.Array array) {
			node.set_array(array);
		}
		public void set_boolean(bool value) {
			node.set_boolean(value);
		}
		public void set_double(double value) {
			node.set_double(value);
		}
		public void set_int(int64 value) {
			node.set_int(value);
		}
		public void set_object(Json.Object object) {
			node.set_object(object);
		}
		public void set_parent(Json.Node parent) {
			node.set_parent(parent);
		}
		public void set_string(string value) {
			node.set_string(value);
		}
		public void set_value(Value value) {
			node.set_value(value);
		}
		public void take_array(owned Json.Array array) {
			node.take_array(array);
		}
		public void take_object(owned Json.Object object) {
			node.take_object(object);
		}
		public unowned string type_name() {
			return node.type_name();
		}
	}
}
