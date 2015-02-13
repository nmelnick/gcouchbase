using Gee;
namespace Couchbase {
	/**
	 * Represents the result of a view query.
	 */
	public class ViewResult : Object {
		private Client client;

		/**
		 * Total rows in the view result. May not match the number of rows in
		 * this response if limit or skip were used.
		 */
		public int total_rows { get; set; }

		/**
		 * ArrayList of ViewRow objects.
		 */
		public ArrayList<ViewRow> rows { get; set; default = new ArrayList<ViewRow>(); }

		internal void set_client( Client client ) {
			this.client = client;
			if ( rows != null ) {
				foreach ( var row in rows ) {
					row.client = client;
				}
			}
		}
	}
}