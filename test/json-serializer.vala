public class JsonSerializerTest : Object {
	public static void add_tests() {
		Test.add_func("/gcouchbase/json/serialize/json", () => {
			var json = new Couchbase.JSON.Serializer();
			assert( json != null );
		});
		Test.add_func("/gcouchbase/json/serialize/json/string", () => {
			var json = new Couchbase.JSON.Serializer();
			var o = new TestStringObject();
			o.foo = "bar";
			string result = json.serialize(o);
			assert( result != null );
			assert( result == """{"foo":"bar"}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/underscore", () => {
			Couchbase.JSON.JSONConfig.transform_dash_to_underscore = true;
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestStringUnderscoreObject() );
			assert( result != null );
			assert( result == """{"foo_baz":"bar"}""" );

			Couchbase.JSON.JSONConfig.transform_dash_to_underscore = false;
			result = json.serialize( new TestStringUnderscoreObject() );
			assert( result != null );
			assert( result == """{"foo-baz":"bar"}""" );


			Couchbase.JSON.JSONConfig.transform_dash_to_underscore = true;
		});
		Test.add_func("/gcouchbase/json/serialize/json/int", () => {
			var json = new Couchbase.JSON.Serializer();
			var o = new TestIntObject();
			o.foo = 42;
			string result = json.serialize(o);
			assert( result != null );
			assert( result == """{"foo":42}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/double", () => {
			var json = new Couchbase.JSON.Serializer();
			var o = new TestDoubleObject();
			o.foo = 62.31;
			string result = json.serialize(o);
			assert( result != null );
			assert( """{"foo":62.31""" in result ); // Double precision issue?
		});
		Test.add_func("/gcouchbase/json/serialize/json/bool", () => {
			var json = new Couchbase.JSON.Serializer();
			var o = new TestBoolObject();
			o.foo = true;
			string result = json.serialize(o);
			assert( result != null );
			assert( result == """{"foo":true}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/datetime", () => {
			var json = new Couchbase.JSON.Serializer();
			var o = new TestDateTimeObject();
			o.foo = new DateTime.utc( 2014, 3, 15, 15, 5, 2 );
			string result = json.serialize(o);
			assert( result != null );
			assert( result == """{"foo":"2014-03-15T15:05:02Z"}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/string_array", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestStringArrayObject.with_data() );
			assert( result != null );
			assert( result == """{"foo":["bar","baz"]}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/string_arraylist", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestStringArrayListObject.with_data() );
			assert( result != null );
			assert( result == """{"foo":["bar","baz"]}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/object", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestObjectObject.with_data() );
			assert( result != null );
			assert( result == """{"bar":{"foo":["bar","baz"]}}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/everything", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestEverythingObject.with_data() );
			assert( result != null );
			assert( result == """{"foo_baz":"bar","some_int":42,"is_something":false,"list_of_things":["thing","another","so wow"],"super_container":{"container":{"foo":["bar","baz"]},"example":"I am here"}}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/ignore", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestIgnoreObject() );
			assert( result != null );
			assert( result == """{"not_ignored":"woohoo"}""" );
		});
		Test.add_func("/gcouchbase/json/serialize/json/rename", () => {
			var json = new Couchbase.JSON.Serializer();
			string result = json.serialize( new TestRenameObject() );
			assert( result != null );
			assert( result == """{"renamed":"woohoo"}""" );
		});
	}
}

