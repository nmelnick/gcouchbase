public class ClientTest {
	public static void add_tests() {
		Test.add_func("/gcouchbase/client/connect/success", () => {
			Couchbase.Client a;
			try {
				a = new Couchbase.Client("http://localhost:8091/pools");
			} catch (Error e) {
				assert_not_reached();
			}
			assert( a != null );
		});
		Test.add_func("/gcouchbase/client/connect/bad_host", () => {
			Couchbase.Client a;
			bool has_error = false;
			try {
				a = new Couchbase.Client("c290mv093mg3ior");
			} catch (Error e) {
				has_error = true;
				assert( e is Couchbase.ClientError.CONNECT_ERROR );
			}
			assert(has_error);
		});
		Test.add_func("/gcouchbase/client/property/port", () => {
			var client = get_client();
			assert( client.port == 8091 );
		});
		Test.add_func("/gcouchbase/client/property/is_waiting", () => {
			var client = get_client();
			assert( client.is_waiting == false );
		});
		Test.add_func("/gcouchbase/client/get_result/invalid_key", () => {
			var client = get_client();
			Couchbase.GetResult? result = client.get_result("does_not_exist_1");
			assert( result == null );
		});
		Test.add_func("/gcouchbase/client/get_result/valid_key", () => {
			var client = get_client();
			Couchbase.GetResult? result = client.get_result("foo");
			assert( result != null );
			assert( result.key_string() == "foo" );
			assert( result.bytes_string().replace(" ", "").replace("\n", "") == """{"freaking":"bar"}""" );
		});
		Test.add_func("/gcouchbase/client/get_bytes/invalid_key", () => {
			var client = get_client();
			uint8[]? bytes = client.get_bytes("does_not_exist_1");
			assert( bytes == null );
		});
		Test.add_func("/gcouchbase/client/get_bytes/valid_key", () => {
			var client = get_client();
			uint8[]? bytes = client.get_bytes("foo");
			assert( bytes != null );
		});
		Test.add_func("/gcouchbase/client/get/invalid_key", () => {
			var client = get_client();
			string? str = client.get("does_not_exist_1");
			assert( str == null );
		});
		Test.add_func("/gcouchbase/client/get/valid_key", () => {
			var client = get_client();
			string? str = client.get("foo");
			assert( str != null );
			assert( str.replace(" ", "").replace("\n", "") == """{"freaking":"bar"}""" );
		});
		Test.add_func("/gcouchbase/client/get_object", () => {
			var client = get_client();
			FreakingClass? fc = client.get_object<FreakingClass>("foo");
			assert( fc != null );
			assert( fc.freaking == "bar" );
			assert( fc.key_id == "foo" );
		});
		Test.add_func("/gcouchbase/client/store_bytes_result/valid-kv", () => {
			var client = get_client();
			Couchbase.StoreResult? result = client.store_bytes_result(
				Couchbase.StoreMode.SET, "hey-o", "some data1".data );
			assert( result != null );
			assert( result.key_string() == "hey-o" );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data1" );
		});
		Test.add_func("/gcouchbase/client/store_bytes_result/valid-kv-expire", () => {
			var client = get_client();
			time_t expire = time_t() + 60;
			Couchbase.StoreResult? result = client.store_bytes_result(
				Couchbase.StoreMode.SET, "hey-o", "some data2".data, expire );
			assert( result != null );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data2" );
		});
		Test.add_func("/gcouchbase/client/store_bytes/valid-kv", () => {
			var client = get_client();
			bool result = client.store_bytes(
				Couchbase.StoreMode.SET, "hey-o", "some data3".data );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data3" );
		});
		Test.add_func("/gcouchbase/client/store_bytes/valid-kv-expire", () => {
			var client = get_client();
			time_t expire = time_t() + 60;
			bool result = client.store_bytes(
				Couchbase.StoreMode.SET, "hey-o", "some data4".data, expire );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data4" );
		});
		Test.add_func("/gcouchbase/client/store/valid-kv", () => {
			var client = get_client();
			bool result = client.store(
				Couchbase.StoreMode.SET, "hey-o", "some data5" );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data5" );
		});
		Test.add_func("/gcouchbase/client/store/valid-kv-expire", () => {
			var client = get_client();
			time_t expire = time_t() + 60;
			bool result = client.store(
				Couchbase.StoreMode.SET, "hey-o", "some data6", expire );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data6" );
		});
		Test.add_func("/gcouchbase/client/store_object", () => {
			var client = get_client();
			var fc = new FreakingClass();
			fc.freaking = "whoa";
			bool result = client.store_object(
				Couchbase.StoreMode.SET, "baz", fc );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("baz");
			assert( get_result != null );
			assert( get_result.bytes_string() == """{"freaking":"whoa"}""" );
		});
		Test.add_func("/gcouchbase/client/append_bytes_result/valid-kv", () => {
			var client = get_client();
			Couchbase.StoreResult? result = client.append_bytes_result(
				"hey-o", "data".data );
			assert( result != null );
			assert( result.key_string() == "hey-o" );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data6data" );
		});
		Test.add_func("/gcouchbase/client/append_bytes/valid-kv", () => {
			var client = get_client();
			bool result = client.append_bytes( "hey-o", "data".data );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data6datadata" );
		});
		Test.add_func("/gcouchbase/client/append/valid-kv", () => {
			var client = get_client();
			bool result = client.append( "hey-o", "data" );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-o");
			assert( get_result != null );
			assert( get_result.bytes_string() == "some data6datadatadata" );
		});
		Test.add_func("/gcouchbase/client/prepend_bytes_result/valid-kv", () => {
			var client = get_client();
			client.store(
				Couchbase.StoreMode.SET, "hey-a", "some data" );
			Couchbase.StoreResult? result = client.prepend_bytes_result(
				"hey-a", "data".data );
			assert( result != null );
			assert( result.key_string() == "hey-a" );
			Couchbase.GetResult? get_result = client.get_result("hey-a");
			assert( get_result != null );
			assert( get_result.bytes_string() == "datasome data" );
		});
		Test.add_func("/gcouchbase/client/prepend_bytes/valid-kv", () => {
			var client = get_client();
			bool result = client.prepend_bytes( "hey-a", "data".data );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-a");
			assert( get_result != null );
			assert( get_result.bytes_string() == "datadatasome data" );
		});
		Test.add_func("/gcouchbase/client/prepend/valid-kv", () => {
			var client = get_client();
			bool result = client.prepend( "hey-a", "data" );
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("hey-a");
			assert( get_result != null );
			assert( get_result.bytes_string() == "datadatadatasome data" );
		});
		Test.add_func("/gcouchbase/client/increment/new", () => {
			var client = get_client();
			uint64 result = client.increment( "exp-inc", 0, 1 );
			assert( result > 0 );
			Couchbase.GetResult? get_result = client.get_result("exp-inc");
			assert( get_result != null );
			assert( get_result.bytes_string() == "0" );
		});
		Test.add_func("/gcouchbase/client/increment/exist", () => {
			var client = get_client();
			uint64 result = client.increment( "exp-inc", 0, 1 );
			assert( result > 0 );
			Couchbase.GetResult? get_result = client.get_result("exp-inc");
			assert( get_result != null );
			assert( get_result.bytes_string() == "1" );
		});
		Test.add_func("/gcouchbase/client/decrement/exist", () => {
			var client = get_client();
			uint64 result = client.decrement( "exp-inc", 0, 1 );
			assert( result > 0 );
			Couchbase.GetResult? get_result = client.get_result("exp-inc");
			assert( get_result != null );
			assert( get_result.bytes_string() == "0" );
		});
		Test.add_func("/gcouchbase/client/touch/exist", () => {
			var client = get_client();
			bool result = client.touch( "hey-o", ( time_t() + 30 ) );
			assert( result == true );
		});
		Test.add_func("/gcouchbase/client/z_post_action/remove", () => {
			var client = get_client();
			bool result = client.remove("exp-inc");
			assert( result == true );
			Couchbase.GetResult? get_result = client.get_result("exp-inc");
			assert( get_result == null );

			result = client.remove("hey-o");
			assert( result == true );
			get_result = client.get_result("hey-o");
			assert( get_result == null );

			result = client.remove("hey-a");
			assert( result == true );
			get_result = client.get_result("hey-a");
			assert( get_result == null );

			result = client.remove("baz");
			assert( result == true );
			get_result = client.get_result("baz");
			assert( get_result == null );
		});
		Test.add_func("/gcouchbase/client/query", () => {
			var client = get_client();
			var query = new Couchbase.ViewQuery()
				.design("dev_foo")
				.view("by_foo")
				.key(""""bar"""")
				.full_set();
			var result = client.get_query(query);
			assert( result != null );
			assert( result.total_rows > 0 );
			assert( result.rows != null );
			assert( result.rows.size == 1 );
			assert( result.rows[0].id == "foo" );
			assert( result.rows[0].key == "bar" );
		});
		Test.add_func("/gcouchbase/client/query/doc", () => {
			var client = get_client();
			var query = new Couchbase.ViewQuery()
				.design("dev_foo")
				.view("by_foo")
				.key(""""bar"""")
				.full_set();
			var result = client.get_query(query);
			assert( result != null );
			assert( result.total_rows > 0 );
			var doc = result.rows[0].get_document<FreakingClass>();
			assert( doc != null );
			assert( doc.freaking == "bar" );
		});
	}

	private static Couchbase.Client get_client() {
		Couchbase.Client a;
		try {
			a = new Couchbase.Client("http://localhost:8091/pools");
		} catch (Error e) {
			assert_not_reached();
		}
		return a;
	}
}

public class FreakingClass : Object {
	public string? key_id { get; set; }
	public string? freaking { get; set; }
}