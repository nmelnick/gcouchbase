using LibCouchbase;

public static int main( string[] args ) {
	var tc = new TestClient();
	tc.start();

	return 1;
}

public static void report_status( string name, StatusResponse status ) {
	stdout.printf( "%s Result: 0x%02x ( %s )\n", name, status, ( status == StatusResponse.SUCCESS ? "success" : ":(" ) );
}

public class TestClient : Object {
	private Client instance;

	public int start() {
		StatusResponse status;
		var connect_options = ConnectionOptions() {
			host = "http://localhost:8091/pools"
		};
		var io_options = IOOptions() {
			version = 0,
			v0_type = IOType.DEFAULT,
			v0_cookie = null
		};
		stdout.printf( "libcouchbase version %s\n", Client.get_version() );

		status = create_io_options( ref connect_options.v0_io, ref io_options );
		report_status( "ioopt", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}
		status = Client.create( out instance, ref connect_options );
		report_status( "create", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		stdout.printf( "Timeout is %u, View timeout is %u\n", instance.timeout, instance.view_timeout );

		// instance.sync_mode = SyncMode.SYNCHRONOUS;
		instance.set_error_callback(error_callback);

		status = instance.connect();
		report_status( "connect", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		status = instance.wait();
		report_status( "wait", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		stdout.printf( "Host is %s, Port is %s\n", instance.host, instance.port );
		stdout.printf( "Cluster has %d node(s) and %d replica(s).\n", instance.num_nodes, instance.num_replicas );

		instance.set_get_callback(get_callback);

		GetCommand*[] get_cmds = new GetCommand*[1];
		var gc = GetCommand() {
			key = "foo".data
		};
		get_cmds[0] = &gc;
		status = instance.get( null, get_cmds );
		report_status( "get", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		var dt = new DateTime.now_utc();
		var cs = Checksum.compute_for_string( ChecksumType.MD5, dt.to_string() );
		StoreCommand*[] store_cmds = new StoreCommand*[1];
		var sc = StoreCommand() {
			key = cs.data,
			bytes = """{"checksum":"%s"}""".printf( cs ).data,
			operation = Storage.ADD
		};
		store_cmds[0] = &sc;
		status = instance.store( null, store_cmds );
		report_status( "store", status );
		stdout.printf( "Stored: %s\n", cs );

		status = instance.wait();
		report_status( "wait", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		TouchCommand*[] touch_cmds = new TouchCommand*[1];
		var tc = TouchCommand() {
			key = cs.data,
			exptime = 10000
		};
		touch_cmds[0] = &tc;
		status = instance.touch( null, touch_cmds );
		report_status( "touch", status );

		status = instance.wait();
		report_status( "wait", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		RemoveCommand*[] remove_cmds = new RemoveCommand*[1];
		var rc = RemoveCommand() {
			key = cs.data
		};
		remove_cmds[0] = &rc;
		status = instance.remove( null, remove_cmds );
		report_status( "remove", status );

		status = instance.wait();
		report_status( "wait", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		VerbosityCommand*[] verbosity_cmds = new VerbosityCommand*[1];
		var vc = VerbosityCommand() {
			level = Verbosity.WARNING
		};
		verbosity_cmds[0] = &vc;
		status = instance.set_verbosity( null, verbosity_cmds );
		report_status( "verbosity", status );

		instance.flush_buffers();

		stdout.printf( "Instance is %swaiting\n", ( instance.is_waiting > 0 ? "" : "not " ) );

		HttpRequest req = HttpRequest();
		HttpCommand cmd = HttpCommand() {
			path = "_design/dev_foo/_view/foo".data,
			body = null,
			method = HttpMethod.GET,
			chunked = 0,
			content_type = "application/json"
		};

		instance.set_http_complete_callback(http_complete_callback);

		status = instance.make_http_request( null, HttpType.VIEW, ref cmd, ref req );
		report_status( "make_http_request", status );

		status = instance.wait();
		report_status( "wait", status );
		if ( status != StatusResponse.SUCCESS ) {
			return -1;
		}

		return 1;
	}
}

public static void get_callback( Client instance, void* cookie, StatusResponse response, GetResponseInfo response_info ) {
	if ( response != StatusResponse.SUCCESS ) {
		stdout.printf( "Failed to retrieve %s: %d\n", (string) response_info.key, response );
	} else {
		stdout.printf( "Data for key %s:\n%s\n", response_info.key_string(), response_info.bytes_string() );
	}
}

public static void error_callback( Client instance, StatusResponse response, string? error ) {
	stdout.printf( "Error %d: %s\n", response, error );
}

public static void http_complete_callback ( HttpRequest request, Client instance,
		void* cookie, StatusResponse status, HttpResponse* response ) {
	stdout.printf( "Received request from path '%s', status %d\n", response.path_string(), response.status );
	stdout.printf( "%s\n", response.bytes_string() );
}

