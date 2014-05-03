# GCouchbase

## Introduction

GCouchbase attempts to provide a reasonable client library for Couchbase Server,
somewhat mimicing the .NET Client Library. It is designed to be used with Vala,
but theoretically can be used by any GObject application.

## Installation

GCouchbase requires libcouchbase 2.0 or higher to be installed already. See
[http://www.couchbase.com/communities/c/getting-started](Couchbase C Getting Started)
for more details on how to get it installed. You will also need Vala 0.18 or
higher, GLib 2.32 or higher, and CMake 2.8 or higher.

From there, create a directory called `build`, and `cd` into it. Execute
`cmake ..` to check prerequisites, `make` to make the library, and then
`sudo make install` to install the library.

## Connecting to Couchbase and Simple Operations

A connection to Couchbase is created when you instantiate a new Couchbase.Client
instance. Once you have an open instance, you can execute any operation against
the open Client. You may open more than one Client instance, but manage them
appropriately.

In the following example, we will create a new client, store a value, and grab
that same value:

```vala
Couchbase.Client client;
try {
	client = new Couchbase.Client("http://localhost:8091/pools");
} catch ( ClientError ce ) {
	stdout.printf( "Error connecting: %s\n", ce.message );
	return;
}
bool success = client.set( "example-key", "some value" );
string? val = client.get("example-key");
stdout.printf( "example-key is '%s'\n", val );
```

Chances are, you're actually dealing with objects that you want to exchange
with Couchbase, and that's handled by GCouchbase as well. For example, if one
was working with the beer-sample in Couchbase, it could look like this:

```vala
public class Beer : Object {
	public string type { get; set; }
	public string name { get; set; }
	public double abv { get; set; }
	public int ibu { get; set; }
	public int srm { get; set; }
	public int upc { get; set; }
	public string brewery_id { get; set; }
	public string updated { get; set; }
	public string description { get; set; }
	public string style { get; set; }
	public string category { get; set; }
}

public static int main( string[] args ) {
	// Connect to Couchbase. Skipping the exception check, but shouldn't in prod
	var client = new Couchbase.Client("http://localhost:8091/pools");

	// This will return a Beer object
	var beer = client.get_object<Beer>("21st_amendment_brewery_cafe-21a_ipa");

	// Now you can alter the object and save a new one
	beer.ibu++;
	client.replace_object( "21st_amendment_brewery_cafe-21a_ipa", beer );

	return 1;
}
```

## Searching

Search is provided using Couchbase views. To perform a query on a view, a
ViewQuery object must be created to set the query options, and then that query
can be passed to the Couchbase server.

```vala
// Using the "beer" design document, "by_name" view, provide 20 results.
var query = new Couchbase.ViewQuery()
					.design("beer")
					.view("by_name")
					.limit(20);

// Execute the query
var response = client.get_query(query);

// Response has 'total_rows' and 'rows'. 
foreach ( Couchbase.ViewRow row in response.rows ) {
	// Output the ID and Name
	stdout.printf( "%s: %s\n", row.id, row.key );

	// Get the rest of the document as a Beer object
	var beer = row.get_document<Beer>();
	stdout.printf( "IBU: %d\n", beer.ibu );
}
```

## Advanced Couchbase Operations

The libcouchbase instance can be accessed via the client.instance field. Through
that interface, one can do asynchronous calls, perform raw HTTP actions, and
manipulate data through CAS easily. See the valadoc for libcouchbase for more
information on how to use those methods.

## VAPI

The vapi/ directory contains the core vapi for using libcouchbase. The doc/
directory will generate documentation based on that vapi as well as the
GCouchbase library.

## For more information

Home Page: http://gcouchbase.ambitionframework.org

Online API Documentation: http://gcouchbase.ambitionframework.org/static/valadoc/couchbase/
