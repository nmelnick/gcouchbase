using Gee;
namespace Couchbase {
	/**
	 * Object to build a query to a view. Uses fluent design pattern to build
	 * a query object that can be passed to client.get_query().
	 *
	 * Example use:
	 * {{{
	 *   var query = new ViewQuery()
	 *       .design("dev_recipes")
	 *       .view("by_ingredient")
	 *       .key(""""carrots"""")
	 *       .limit(30);
	 *   var query_result = client.get_query(query);
	 *   foreach ( var result in query_result.rows ) {
	 *       var recipe = result.get_document<Recipe>();
	 *       stdout.printf( "%s\n", recipe.name );
	 *   }
	 * }}}
	 */
	public class ViewQuery : Object {
		private string? query_design_doc;
		private string? query_view;
		private string? query_start_key;
		private string? query_end_key;
		private string? query_key;
		private bool query_is_descending = false;
		private bool query_use_full_set = false;
		private bool query_group_results = false;
		private int query_limit = 0;
		private int query_skip = 0;
		
		/**
		 * Set the design doc to query from.
		 * @param design_doc Design document name
		 */
		public ViewQuery design ( string design_doc ) {
			this.query_design_doc = design_doc;
			return this;
		}

		/**
		 * Set the view to query with.
		 * @param view View name
		 */
		public ViewQuery view ( string view ) {
			this.query_view = view;
			return this;
		}

		/**
		 * Return results in descending order by key.
		 * @param is_descending ( = true )
		 */
		public ViewQuery descending ( bool is_descending = true ) {
			this.query_is_descending = is_descending;
			return this;
		}

		/**
		 * If using a development view, use the full cluster data set to return
		 * a value.
		 * @param use_full_set ( = true )
		 */
		public ViewQuery full_set ( bool use_full_set = true ) {
			this.query_use_full_set = use_full_set;
			return this;
		}

		/**
		 * Group the results using the reduce function to a group or single row.
		 * @param group_results ( = true )
		 */
		public ViewQuery group ( bool group_results = true ) {
			this.query_group_results = group_results;
			return this;
		}

		/**
		 * Return records with a value equal to or greater than the specified
		 * key. Key must be specified as a JSON value, so to specify "example",
		 * the quotes must exist in the value.
		 * @param start_key Start key value
		 */
		public ViewQuery start_key ( string start_key ) {
			this.query_start_key = start_key;
			return this;
		}

		/**
		 * Stop returning records when the specified key is reached. Key must be
		 * specified as a JSON value, so to specify "example", the quotes must
		 * exist in the value.
		 * @param end_key End key value
		 */
		public ViewQuery end_key ( string end_key ) {
			this.query_end_key = end_key;
			return this;
		}

		/**
		 * Return only documents that match the specified key. Key must be
		 * specified as a JSON value, so to specify "example", the quotes must
		 * exist in the value.
		 * @param key Key value
		 */
		public ViewQuery key ( string key ) {
			this.query_key = key;
			return this;
		}

		/**
		 * Limit the number of the returned documents to the specified number.
		 * @param limit Max number of returned documents
		 */
		public ViewQuery limit ( int limit ) {
			this.query_limit = limit;
			return this;
		}

		/**
		 * Skip this number of records before starting to return the results.
		 * @param skip Number of records to skip
		 */
		public ViewQuery skip ( int skip ) {
			this.query_skip = skip;
			return this;
		}

		public string path_query() {
			var pairs = new string[0];
			string path = "/_design/%s/_view/%s".printf( query_design_doc, query_view );
			if ( query_start_key != null ) {
				pairs += "startkey=%s".printf( Uri.escape_string(query_start_key) );
			}
			if ( query_end_key != null ) {
				pairs += "endkey=%s".printf( Uri.escape_string(query_end_key) );
			}
			if ( query_key != null ) {
				pairs += "key=%s".printf( Uri.escape_string(query_key) );
			}
			if ( query_is_descending ) {
				pairs += "descending=true";
			}
			if ( query_use_full_set ) {
				pairs += "full_set=true";
			}
			if ( query_group_results ) {
				pairs += "group=true";
			}
			if ( query_limit > 0 ) {
				pairs += "limit=%d".printf(query_limit);
			}
			if ( query_skip > 0 ) {
				pairs += "skip=%d".printf(query_skip);
			}

			if ( pairs.length > 0 ) {
				path = path + "?" + string.joinv( "&", pairs );
			}
			return path;
		}
	}
}