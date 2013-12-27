public class JsonDeserializerTest : Object {
	public static void add_tests() {
		Test.add_func("/gcouchbase/json/deserialize/json", () => {
			var json = new Couchbase.JSON.Deserializer();
			assert( json != null );
		});
		Test.add_func("/gcouchbase/json/deserialize/json/string", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize( """{"foo":"bar"}""", typeof( TestStringObject ) );
			assert( o != null );
			assert( o is TestStringObject );
			assert( ( (TestStringObject) o ).foo == "bar" );
		});
		Test.add_func("/gcouchbase/json/deserialize/json/int", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize( """{"foo":42}""", typeof( TestIntObject ) );
			assert( o != null );
			assert( o is TestIntObject );
			assert( ( (TestIntObject) o ).foo == 42 );
		});
		Test.add_func("/gcouchbase/json/deserialize/json/double", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize( """{"foo":62.31}""", typeof( TestDoubleObject ) );
			assert( o != null );
			assert( o is TestDoubleObject );
			assert( ( (TestDoubleObject) o ).foo == 62.31 );
		});
		Test.add_func("/gcouchbase/json/deserialize/json/bool", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize( """{"foo":true}""", typeof( TestBoolObject ) );
			assert( o != null );
			assert( o is TestBoolObject );
			assert( ( (TestBoolObject) o ).foo == true );
		});
		Test.add_func("/gcouchbase/json/deserialize/json/object", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize( """{"bar":{"foo":["bar","baz"]}}""", typeof( TestObjectObject ) );
			assert( o != null );
			assert( o is TestObjectObject );
			assert( ( (TestObjectObject) o ).bar != null );
			// TODO: Arrays
		});
		Test.add_func("/gcouchbase/json/deserialize/json/everything", () => {
			var json = new Couchbase.JSON.Deserializer();
			Object o = json.deserialize(
				"""{"foo_baz":"bar","some_int":42,"is_something":false,"list_of_things":["thing","another","so wow"],"super_container":{"container":{"foo":["bar","baz"]},"example":"I am here"}}""",
				typeof( TestEverythingObject )
			);
			assert( o != null );
			assert( o is TestEverythingObject );
			TestEverythingObject to = (TestEverythingObject) o;
			assert( to.super_container != null );
			assert( to.foo_baz == "bar" );
			assert( to.some_int == 42 );
			assert( to.is_something == false );
			assert( to.super_container.example == "I am here" );
			assert( to.super_container.container != null );
			assert( to.super_container.container.foo != null );
			// TODO: Arrays
		});
		// Test.add_func("/gcouchbase/json/serialize/json/string_array", () => {
		// 	var json = new Couchbase.JSON.Serializer();
		// 	string result = json.serialize( new TestStringArrayObject() );
		// 	assert( result != null );
		// 	assert( result == """{"foo":["bar","baz"]}""" );
		// });
		// Test.add_func("/gcouchbase/json/serialize/json/string_arraylist", () => {
		// 	var json = new Couchbase.JSON.Serializer();
		// 	string result = json.serialize( new TestStringArrayListObject() );
		// 	assert( result != null );
		// 	assert( result == """{"foo":["bar","baz"]}""" );
		// });
		// Test.add_func("/gcouchbase/json/serialize/json/ignore", () => {
		// 	var json = new Couchbase.JSON.Serializer();
		// 	string result = json.serialize( new TestIgnoreObject() );
		// 	assert( result != null );
		// 	assert( result == """{"not_ignored":"woohoo"}""" );
		// });
		// Test.add_func("/gcouchbase/json/serialize/json/rename", () => {
		// 	var json = new Couchbase.JSON.Serializer();
		// 	string result = json.serialize( new TestRenameObject() );
		// 	assert( result != null );
		// 	assert( result == """{"renamed":"woohoo"}""" );
		// });
	}
}

