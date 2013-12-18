GCouchbase
==========

Introduction
------------
GCouchbase attempts to provide a reasonable client library for Couchbase Server,
somewhat mimicing the .NET Client Library. It is designed to be used with Vala,
but theoretically can be used by any GObject application.

Basic Usage
-----------

Create a client:
```
var client = new Couchbase.Client("http://localhost:8091/pools");
```

Store a value:
```
bool success = client.store( "example-key", "some value" );
```

Retrieve that value:
```
string? val = client.get("example-key");
```

Advanced Couchbase Operations
-----------------------------
The libcouchbase instance can be accessed via the client.instance field. Through
that interface, one can do asynchronous calls, perform raw HTTP actions, and
manipulate data through CAS easily. See the valadoc for libcouchbase for more
information on how to use those methods.

VAPI
----
The vapi/ directory contains the core vapi for using libcouchbase. The doc/
directory will generate documentation based on that vapi as well as the
GCouchbase library.
