using Gee;
namespace Couchbase {
	/**
	 * Represents the result of a view query.
	 */
	public class ViewResult : Object {
		public Client client { private get; set; }

		/**
		 * Total rows in the view result. May not match the number of rows in
		 * this response if limit or skip were used.
		 */
		public int total_rows { get; set; }

		/**
		 * ArrayList of ViewRow objects.
		 */
		public ArrayList<ViewRow> rows { get; set; }
	}
}