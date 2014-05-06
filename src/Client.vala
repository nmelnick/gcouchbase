namespace Couchbase {

	internal struct BufferBag {
		public bool has_result;
		public Object result;
	}

	/**
	 * Possible errors when creating or connecting the client.
	 */
	public errordomain ClientError {
		/**
		 * Error occurred within libcouchbase
		 */
		LIBRARY_ERROR,
		/**
		 * Error occurred connecting to the Couchbase server
		 */
		CONNECT_ERROR
	}

	/**
	 * Possible errors when parsing or executing a query.
	 */
	public errordomain QueryError {
		/**
		 * A design document was not provided
		 */
		MISSING_DESIGN_DOCUMENT,
		/**
		 * A view was not provided
		 */
		MISSING_VIEW,
		/**
		 * Error executing query
		 */
		EXECUTE_ERROR
	}

	/**
	 * Set the storage mode when using a store_ method.
	 */
	public enum StoreMode {
		/**
		 * Add a key to the bucket, and fail if it already exists.
		 */
		ADD,
		/**
		 * Replace the key in the bucket, and fail if it doesn't exist.
		 */
		REPLACE,
		/**
		 * Add a key to the bucket, replace if it already exists.
		 */
		SET
	}

	/**
	 * This class represents the connection to the Couchbase server, as well as
	 * the current state of the connection to the server.
	 * 
	 * Example use:
	 * {{{
	 *   Couchbase.Client client;
	 *   try {
	 *       client = new Couchbase.Client("http://localhost:8091/pools");
	 *   } catch ( Couchbase.ClientError ce ) {
	 *       stderr.printf( "ERROR: %s\n", ce.message );
	 *       return;
	 *   }
	 *   string? value = client.get("my-key");
	 *   stdout.printf( "The value for 'my-key' is: %s\n".printf(value) );
	 * }}}
	 */
	public class Client : Object {
		/**
		 * The backing libcouchbase client instance.
		 */
		public LibCouchbase.Client instance;

		private JSON.Serializer serializer = new JSON.Serializer();
		private JSON.Deserializer deserializer = new JSON.Deserializer();

		/**
		 * Set the number of usec the library should allow an operation to
		 * be valid.
		 *
		 * Please note that the timeouts are <b>not</b> that accurate,
		 * because they may be delayed by the application code before it
		 * drives the event loop.
		 *
		 * Please note that timeouts is not stored on a per operation
		 * base, but on the instance. That means you <b>can't</b> pipeline
		 * two requests after each other with different timeout values.
		 */
		public uint32 timeout {
			get { return instance.timeout; }
			set { instance.timeout = value; }
		}

		public uint32 view_timeout {
			get { return instance.view_timeout; }
			set { instance.view_timeout = value; }
		}

		/**
		 * Get the current host
		 */
		public string host {
			get { return instance.host; }
		}

		/**
		 * Get the current port
		 */
		public int port {
			get { return int.parse( instance.port ); }
		}

		/**
		 * Returns true if the event loop is running now.
		 */
		public bool is_waiting {
			get { return ( instance.is_waiting > 0 ); }
		}

		/**
		 * Get the number of the replicas in the cluster
		 */
		public int num_replicas {
			get { return instance.num_replicas; }
		}

		/**
		 * Get the number of the nodes in the cluster
		 */
		public int num_nodes {
			get { return instance.num_nodes; }
		}

		/**
		 * Create a new Couchbase Client with optional parameters. The default
		 * will connect to localhost on port 8091, with the default bucket and
		 * no password.
		 *
		 * Default example to localhost:8091:
		 * {{{
		 *   var client = new Couchbase.Client("http://localhost:8091/pools");
		 * }}}
		 * Example to outside host, using the bucket "mybucket".
		 * {{{
		 *   var client = new Couchbase.Client( "http://cb-server:8091", "mybucket" );
		 * }}}
		 *
		 * @param host Host or hosts to connect to. This can be a single URI in
		 *             the form [[http://localhost:8091/pools]], or a list of
		 *             host:port, separated by ';'.
		 * @param username Username or bucket name
		 * @param password Password for the given bucket
		 */
		public Client( string host, string? username = null, string? password = null ) throws ClientError {

			// Set connection options
			var connect_options = LibCouchbase.ConnectionOptions();
			if ( host != null ) {
				connect_options.v0_host = host;
			}
			if ( username != null ) {
				connect_options.v0_bucket = username;
				connect_options.v0_user = username;
			}
			if ( password != null ) {
				connect_options.v0_passwd = password;
			}

			// Set IO on connection options
			var io_options = LibCouchbase.IOOptions() {
				v0_type = LibCouchbase.IOType.DEFAULT,
				v0_cookie = null
			};
			var status = LibCouchbase.create_io_options( ref connect_options.v0_io, ref io_options );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				throw new ClientError.LIBRARY_ERROR( "Library returned 0x%02x on create_io_options".printf(status) );
			}

			// Create instance
			status = LibCouchbase.Client.create( out instance, ref connect_options );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				throw new ClientError.LIBRARY_ERROR(
					"Error creating instance: %s".printf( instance.get_error(status) )
				);
			}

			// Connect
			status = instance.connect();
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				throw new ClientError.CONNECT_ERROR(
					instance.get_error(status)
				);
			}
			status = instance.wait();
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				throw new ClientError.CONNECT_ERROR(
					instance.get_error(status)
				);
			}
		}

		/**
		 * Retrieve the string value of a key
		 *
		 * Example:
		 * {{{
		 *   string? value = client.get("my-key");
		 * }}}
		 *
		 * @param key Key to retrieve
		 * @return String, or null if the key isn't found
		 */
		public new string? get( string key ) {
			uint8[]? bytes = get_bytes(key);
			if ( bytes != null ) {
				return LibCouchbase.uint8_to_terminated_string(bytes);
			}
			return null;
		}

		/**
		 * Retrieve the deserialized object of the value attached to a key. If
		 * the object has a "key_id" property, it will be set to the key.
		 *
		 * Example:
		 * {{{
		 *   ExampleObject? value = client.get_object<ExampleObject>("my-key");
		 * }}}
		 *
		 * @param key Key to retrieve
		 * @return Object type, or null if the key isn't found
		 */
		public T? get_object<T>( string key ) {
			string? json = this.get(key);
			if ( json != null ) {
				Object deserialized = deserializer.deserialize( json, typeof(T) );
				if ( deserialized.get_class().find_property("key-id") != null ) {
					var value = Value( typeof(string) );
					value.set_string(key);
					deserialized.set_property( "key-id", value );
				}
				return (T) deserialized;
			}
			return null;
		}

		/**
		 * Set a string value in the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var success = client.set( "my-key", "example" );
		 *   // Add a key with expiration 30 seconds from now
		 *   success = client.set( "my-expiring", "example", ( time() + 30 ) );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public new bool set( string key, string value, time_t expires = -1 ) {
			return store( StoreMode.SET, key, value, expires );
		}

		/**
		 * Set a key and an object in the bucket.
		 *
		 * Example:
		 * {{{
		 *   var example_object = new ExampleObject();
		 *   example_object.test = "pass";
		 *   var success = client.set_object( "my-key", example_object );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool set_object( string key, Object value, time_t expires = -1 ) {
			return store_object( StoreMode.SET, key, value, expires );
		}

		/**
		 * Replace a string value in the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Replace an existing key
		 *   var success = client.replace( "my-key", "example" );
		 *   // Replace a key with expiration 30 seconds from now
		 *   success = client.replace( "my-expiring", "example", ( time() + 30 ) );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool replace( string key, string value, time_t expires = -1 ) {
			return store( StoreMode.REPLACE, key, value, expires );
		}

		/**
		 * Replace an object in the bucket.
		 *
		 * Example:
		 * {{{
		 *   var example_object = new ExampleObject();
		 *   example_object.test = "pass";
		 *   var success = client.replace_object( "my-key", example_object );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool replace_object( string key, Object value, time_t expires = -1 ) {
			return store_object( StoreMode.REPLACE, key, value, expires );
		}

		/**
		 * Add a string value to the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var success = client.add( "my-key", "example" );
		 *   // Replace a key with expiration 30 seconds from now
		 *   success = client.add( "my-expiring", "example", ( time() + 30 ) );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool add( string key, string value, time_t expires = -1 ) {
			return store( StoreMode.ADD, key, value, expires );
		}

		/**
		 * Add an object to the bucket.
		 *
		 * Example:
		 * {{{
		 *   var example_object = new ExampleObject();
		 *   example_object.test = "pass";
		 *   var success = client.add_object( "my-key", example_object );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool add_object( string key, Object value, time_t expires = -1 ) {
			return store_object( StoreMode.ADD, key, value, expires );
		}

		/**
		 * Store a string value in the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var success = client.store( StoreMode.ADD, "my-key", "example" );
		 *   if (success) {
		 *       // This will fail
		 *       success = client.store( StoreMode.ADD, "my-key", "example2" );
		 *   }
		 *   // Add a key with expiration 30 seconds from now
		 *   success = client.store( StoreMode.ADD, "my-expiring", "example", ( time() + 30 ) );
		 * }}}
		 *
		 * @param mode The StoreMode for this action: ADD, REPLACE, or SET
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool store( StoreMode mode, string key, string value, time_t expires = -1 ) {
			return store_bytes( mode, key, value.data, expires );
		}

		/**
		 * Store a serialized object value in the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var example_object = new ExampleObject();
		 *   example_object.test = "pass";
		 *   var success = client.store( StoreMode.ADD, "my-key", example_object );
		 * }}}
		 *
		 * @param mode The StoreMode for this action: ADD, REPLACE, or SET
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool store_object( StoreMode mode, string key, Object value, time_t expires = -1  ) {
			var serialized = serializer.serialize(value);
			return store( mode, key, serialized, expires );
		}

		/**
		 * Append a string to an existing key.
		 *
		 * Example:
		 * {{{
		 *   var success = client.append( "my-key", " again" );
		 *   // Append with previous operation
		 *   GetResult result = client.get_result("my-key");
		 *   success = client.append( "my-key", " again", result.cas );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public bool append( string key, string value, uint64 cas = 0 ) {
			return append_bytes( key, value.data, cas );
		}

		/**
		 * Prepend a string to an existing key.
		 *
		 * Example:
		 * {{{
		 *   var success = client.prepend( "my-key", "again " );
		 *   // Prepend with previous operation
		 *   GetResult result = client.get_result("my-key");
		 *   success = client.append( "my-key", "again ", result.cas );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public bool prepend( string key, string value, uint64 cas = 0 ) {
			return prepend_bytes( key, value.data, cas );
		}

		/**
		 * Decrement a stored value by the given offset, provided the value can
		 * be parsed as an integer value.
		 *
		 * Example:
		 * {{{
		 *   // Decrement "num-key" by 1, start at 100 if it doesn't exist.
		 *   var cas = client.decrement( "num-key", 100, 1 );
		 * }}}
		 *
		 * @param key The key
		 * @param initial_value Value stored if key doesn't exist
		 * @param offset Amount to decrement. As Couchbase only deals with
		 *               unsigned integers, the lowest can be 0.
		 * @param expires Optionally, the time this key should expires
		 * @return CAS value of key if changed, 0 if not
		 */
		public uint64 decrement( string key, uint64 initial_value, uint64 offset, time_t expires = -1  ) {
			int64 delta = 0;
			delta -= (int64) offset;
			return arithmetic( key, initial_value, delta, expires );
		}

		/**
		 * Increment a stored value by the given offset, provided the value can
		 * be parsed as an integer value.
		 *
		 * Example:
		 * {{{
		 *   // Increment "num-key" by 1, start at 100 if it doesn't exist.
		 *   var cas = client.increment( "num-key", 100, 1 );
		 * }}}
		 *
		 * @param key The key
		 * @param initial_value Value stored if key doesn't exist
		 * @param offset Amount to increment. As Couchbase only deals with
		 *               unsigned integers, the lowest can be 0.
		 * @param expires Optionally, the time this key should expires
		 * @return CAS value of key if changed, 0 if not
		 */
		public uint64 increment( string key, uint64 initial_value, uint64 offset, time_t expires = -1  ) {
			return arithmetic( key, initial_value, (int64) offset, expires );
		}

		/**
		 * Remove a stored key/value pair from the bucket.
		 *
		 * Example:
		 * {{{
		 *   bool success = client.remove("example-key");
		 * }}}
		 *
		 * @param key Key to remove
		 * @return true if key is removed
		 */
		public bool remove( string key ) {
			LibCouchbase.RemoveCommand*[] remove_cmds = new LibCouchbase.RemoveCommand*[1];
			var rc = LibCouchbase.RemoveCommand() {
				key = key.data
			};
			remove_cmds[0] = &rc;
			var status = instance.remove( null, remove_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return false;
			}
			instance.wait();
			return true;
		}

		/**
		 * Update the expiration time of an existing key.
		 *
		 * Example:
		 * {{{
		 *   bool success = client.touch( "example-key", ( time_t() + 30 ) );
		 * }}}
		 *
		 * @param key Key to touch
		 * @param expires New expiration time
		 * @return true if key is updated
		 */
		public bool touch( string key, time_t expires ) {
			LibCouchbase.TouchCommand*[] touch_cmds = new LibCouchbase.TouchCommand*[1];
			var tc = LibCouchbase.TouchCommand() {
				key = key.data,
				exptime = expires
			};
			touch_cmds[0] = &tc;
			var status = instance.touch( null, touch_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return false;
			}
			instance.wait();
			return true;
		}

		/**
		 * Retrieve the bytes value of a key
		 *
		 * Example:
		 * {{{
		 *   uint8[]? value = client.get_bytes("my-key");
		 * }}}
		 *
		 * @param key Key to retrieve
		 * @return Byte array, or null if the key isn't found
		 */
		public uint8[]? get_bytes( string key ) {
			GetResult? result = get_result(key);
			if ( result != null ) {
				return result.bytes;
			}
			return null;
		}

		/**
		 * Retrieve the full metadata associated with a given key.
		 *
		 * Example:
		 * {{{
		 *   GetResult value = client.get_result("my-key");
		 *   if ( value.cas > 0 ) {
		 *       stdout.printf( "Success: %s\n", value.bytes_string() );
		 *   }
		 * }}}
		 *
		 * @param key Key to retrieve
		 * @return GetResult instance, or null if the key isn't found
		 */
		public GetResult? get_result( string key ) {
			instance.set_get_callback(cb_get);

			var buffer_bag = BufferBag();
			LibCouchbase.GetCommand*[] get_cmds = new LibCouchbase.GetCommand*[1];
			var gc = LibCouchbase.GetCommand() {
				key = key.data
			};
			get_cmds[0] = &gc;
			var status = instance.get( &buffer_bag, get_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return null;
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				return (GetResult) buffer_bag.result;
			}
			return null;
		}

		/**
		 * Store a byte array value in the bucket.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var success = client.store_bytes( StoreMode.ADD, "my-key", "example".data );
		 *   if (success) {
		 *       // This will fail
		 *       success = client.store_bytes( StoreMode.ADD, "my-key", "example2".data );
		 *   }
		 *   // Add a key with expiration 30 seconds from now
		 *   success = client.store_bytes( StoreMode.ADD, "my-expiring", "example".data, ( time() + 30 ) );
		 * }}}
		 *
		 * @param mode The StoreMode for this action: ADD, REPLACE, or SET
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public bool store_bytes( StoreMode mode, string key, uint8[] value, time_t expires = -1 ) {
			StoreResult? result = store_bytes_result( mode, key, value, expires );
			if ( result != null ) {
				return true;
			}
			return false;
		}

		/**
		 * Store a byte array value in the bucket, and retrieve the full
		 * metadata associated with the pair.
		 *
		 * Example:
		 * {{{
		 *   // Add a new key
		 *   var result = client.store_bytes_result( StoreMode.ADD, "my-key", "example".data );
		 *   var cas = result.cas;
		 * }}}
		 *
		 * @param mode The StoreMode for this action: ADD, REPLACE, or SET
		 * @param key The key
		 * @param value The value
		 * @param expires Optionally, the unix timestamp when the key expires
		 * @return true if the key/value pair was stored successfully
		 */
		public StoreResult? store_bytes_result( StoreMode mode, string key, uint8[] value, time_t expires = -1 ) {
			instance.set_store_callback(cb_store);

			var buffer_bag = BufferBag();
			LibCouchbase.StoreCommand*[] store_cmds = new LibCouchbase.StoreCommand*[1];
			var sc = LibCouchbase.StoreCommand() {
				key = key.data,
				bytes = value
			};
			switch (mode) {
				case StoreMode.ADD:
					sc.operation = LibCouchbase.Storage.ADD;
					break;
				case StoreMode.REPLACE:
					sc.operation = LibCouchbase.Storage.REPLACE;
					break;
				case StoreMode.SET:
					sc.operation = LibCouchbase.Storage.SET;
					break;
				default:
					sc.operation = LibCouchbase.Storage.ADD;
					break;
			}
			if ( expires > -1 ) {
				sc.exptime = expires;
			}
			store_cmds[0] = &sc;
			var status = instance.store( &buffer_bag, store_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return null;
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				return (StoreResult) buffer_bag.result;
			}

			return null;
		}

		/**
		 * Append bytes to an existing key.
		 *
		 * Example:
		 * {{{
		 *   var success = client.append_bytes( "my-key", " again".data );
		 *   // Append with previous operation
		 *   GetResult result = client.get_result("my-key");
		 *   success = client.append_bytes( "my-key", " again".data, result.cas );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public bool append_bytes( string key, uint8[] value, uint64 cas = 0 ) {
			StoreResult? result = append_bytes_result( key, value, cas );
			if ( result != null ) {
				return true;
			}
			return false;
		}

		/**
		 * Append bytes to an existing key, and retrieve the full metadata
		 * associated with the pair.
		 *
		 * Example:
		 * {{{
		 *   var result = client.append_bytes_result( "my-key", " again".data );
		 *   var cas = result.cas;
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public StoreResult? append_bytes_result( string key, uint8[] value, uint64 cas = 0 ) {
			instance.set_store_callback(cb_store);

			var buffer_bag = BufferBag();
			LibCouchbase.StoreCommand*[] store_cmds = new LibCouchbase.StoreCommand*[1];
			var sc = LibCouchbase.StoreCommand() {
				key = key.data,
				bytes = value,
				operation = LibCouchbase.Storage.APPEND
			};
			if ( cas > 0 ) {
				sc.cas = cas;
			}
			store_cmds[0] = &sc;
			var status = instance.store( &buffer_bag, store_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return null;
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				return (StoreResult) buffer_bag.result;
			}

			return null;
		}

		/**
		 * Prepend bytes to an existing key.
		 *
		 * Example:
		 * {{{
		 *   var success = client.prepend_bytes( "my-key", "again ".data );
		 *   // Prepend with previous operation
		 *   GetResult result = client.get_result("my-key");
		 *   success = client.prepend_bytes( "my-key", "again ".data, result.cas );
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public bool prepend_bytes( string key, uint8[] value, uint64 cas = 0 ) {
			StoreResult? result = prepend_bytes_result( key, value, cas );
			if ( result != null ) {
				return true;
			}
			return false;
		}

		/**
		 * Prepend bytes to an existing key, and retrieve the full metadata
		 * associated with the pair.
		 *
		 * Example:
		 * {{{
		 *   var result = client.prepend_bytes_result( "my-key", "again ".data );
		 *   var cas = result.cas;
		 * }}}
		 *
		 * @param key The key
		 * @param value The value
		 * @param cas Optionally, the CAS as retrieved from a get_result()
		 *            operation
		 * @return true if the command was successful
		 */
		public StoreResult? prepend_bytes_result( string key, uint8[] value, uint64 cas = 0 ) {
			instance.set_store_callback(cb_store);

			var buffer_bag = BufferBag();
			LibCouchbase.StoreCommand*[] store_cmds = new LibCouchbase.StoreCommand*[1];
			var sc = LibCouchbase.StoreCommand() {
				key = key.data,
				bytes = value,
				operation = LibCouchbase.Storage.PREPEND
			};
			if ( cas > 0 ) {
				sc.cas = cas;
			}
			store_cmds[0] = &sc;
			var status = instance.store( &buffer_bag, store_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return null;
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				return (StoreResult) buffer_bag.result;
			}

			return null;
		}

		/**
		 * Execute a query against the current connection.
		 * @param query Complete ViewQuery
		 */
		public ViewResult? get_query( ViewQuery query ) throws QueryError {
			instance.set_http_complete_callback(cb_http_complete);

			var req = LibCouchbase.HttpRequest();
			var cmd = LibCouchbase.HttpCommand() {
				path = query.path_query().data,
				method = LibCouchbase.HttpMethod.GET,
				chunked = 0,
				content_type = "application/json"
			};
			var buffer_bag = BufferBag();
			var status = instance.make_http_request(
				&buffer_bag,
				LibCouchbase.HttpType.VIEW,
				ref cmd,
				ref req
			);
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				throw new QueryError.EXECUTE_ERROR( instance.get_error(status) );
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				var result = (ViewResult) deserializer.deserialize(
					( (GetResult) buffer_bag.result ).bytes_string(),
					typeof(ViewResult)
				);
				result.set_client(this);
				return result;
			}

			return null;
		}

		private uint64 arithmetic( string key, uint64 initial_value, int64 delta, time_t expires = -1  ) {
			instance.set_arithmetic_callback(cb_arithmetic);

			var buffer_bag = BufferBag();
			LibCouchbase.ArithmeticCommand*[] arithmetic_cmds = new LibCouchbase.ArithmeticCommand*[1];
			var ac = LibCouchbase.ArithmeticCommand() {
				key = key.data,
				create = 1,
				initial = initial_value,
				delta = delta
			};
			if ( expires > -1 ) {
				ac.exptime = expires;
			}
			arithmetic_cmds[0] = &ac;
			var status = instance.arithmetic( &buffer_bag, arithmetic_cmds );
			if ( status != LibCouchbase.StatusResponse.SUCCESS ) {
				return 0;
			}
			instance.wait();
			if ( buffer_bag.has_result ) {
				uint64* cas_result = (uint64*) buffer_bag.result;
				return *cas_result;
			}

			return 0;
		}

		private static void cb_get( LibCouchbase.Client instance, void* cookie, LibCouchbase.StatusResponse status, LibCouchbase.GetResponseInfo response_info ) {
			BufferBag* buffer_bag = (BufferBag*) cookie;
			if ( status == LibCouchbase.StatusResponse.SUCCESS ) {
				buffer_bag.has_result = true;
				buffer_bag.result = new GetResult.from_response_info(response_info);
			}
		}

		private static void cb_store( LibCouchbase.Client instance, void* cookie, LibCouchbase.Storage operation, LibCouchbase.StatusResponse status, LibCouchbase.StoreResponseInfo response_info ) {
			BufferBag* buffer_bag = (BufferBag*) cookie;
			if ( status == LibCouchbase.StatusResponse.SUCCESS ) {
				buffer_bag.has_result = true;
				buffer_bag.result = new StoreResult.from_response_info(response_info);
			}
		}

		private static void cb_arithmetic( LibCouchbase.Client instance, void* cookie, LibCouchbase.StatusResponse status, LibCouchbase.ArithmeticResponseInfo response_info ) {
			BufferBag* buffer_bag = (BufferBag*) cookie;
			if ( status == LibCouchbase.StatusResponse.SUCCESS ) {
				buffer_bag.has_result = true;
				var result = new GenericResult();
				uint64 cas = response_info.cas;
				result.pointer = &cas;
				buffer_bag.result = result;
			}
		}

		private static void cb_http_complete( LibCouchbase.HttpRequest request, LibCouchbase.Client instance, void* cookie, LibCouchbase.StatusResponse status, LibCouchbase.HttpResponse* response ) {
			BufferBag* buffer_bag = (BufferBag*) cookie;
			if ( status == LibCouchbase.StatusResponse.SUCCESS ) {
				buffer_bag.has_result = true;
				var result = new GetResult();
				result.bytes = response.bytes;
				buffer_bag.result = result;
			}
		}
	}
}