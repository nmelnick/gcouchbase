public class ViewQueryTest {
	public static void add_tests() {
		Test.add_func("/gcouchbase/viewquery/root", () => {
			var vq = new Couchbase.ViewQuery();
			assert( vq != null );
		});
		Test.add_func("/gcouchbase/viewquery/standard", () => {
			var vq = new Couchbase.ViewQuery()
				.design("dev_test")
				.view("by_something");
			assert( vq != null );
			assert( vq.path_query() == "/_design/dev_test/_view/by_something" );
		});
		Test.add_func("/gcouchbase/viewquery/key", () => {
			var vq = new Couchbase.ViewQuery()
				.design("dev_test")
				.view("by_something")
				.key(""""what"""");
			assert( vq != null );
			assert( vq.path_query() == "/_design/dev_test/_view/by_something?key=%22what%22" );
		});
		Test.add_func("/gcouchbase/viewquery/limit", () => {
			var vq = new Couchbase.ViewQuery()
				.design("dev_test")
				.view("by_something")
				.limit(10);
			assert( vq != null );
			assert( vq.path_query() == "/_design/dev_test/_view/by_something?limit=10" );
		});
		Test.add_func("/gcouchbase/viewquery/stale", () => {
			var vq = new Couchbase.ViewQuery()
				.design("dev_test")
				.view("by_something")
				.stale(Couchbase.StaleMode.OK);
			assert( vq != null );
			assert( vq.path_query() == "/_design/dev_test/_view/by_something?stale=ok" );
		});
	}
}
