namespace Couchbase {
	/**
	 * Represents an individual row in a ViewResult.
	 */
	public class ViewRow : Object {
		public Client client { private get; set; }

		/**
		 * ID of the given row
		 */
		public string id { get; set; }

		/**
		 * The key of the given row
		 */
		public string key { get; set; }

		/**
		 * The value of the given row
		 */
		public string value { get; set; }

		/**
		 * Retrieve the document associated with this row as the given object.
		 */
		public G get_document<G>() {
			return client.get_object<G>(id);
		}
	}
}