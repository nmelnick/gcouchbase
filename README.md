GCouchbase
==========

Introduction
------------
GCouchbase attempts to provide a reasonable client library for Couchbase Server,
somewhat mimicing the .NET Client Library. It is designed to be used with Vala,
but theoretically can be used by any GObject application.

Installation
------------
GCouchbase requires libcouchbase 2.0 or higher to be installed already. See
[http://www.couchbase.com/communities/c/getting-started](Couchbase C Getting Started)
for more details on how to get it installed. You will also need Vala 0.18 or
higher, GLib 2.32 or higher, and CMake 2.8 or higher.

From there, create a directory called `build`, and `cd` into it. Execute
`cmake ..` to check prerequisites, `make` to make the library, and then
`sudo make install` to install the library.

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
