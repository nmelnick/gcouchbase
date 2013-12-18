public class ClientTest {
	public static void add_tests() {
		Test.add_func("/gcouchbase/client/init", () => {
			var a = new Couchbase.Client();
			assert( a != null );
		});
	}
}