namespace Couchbase {
	/**
	 * Full metadata associated with a key-value pair after storing in Couchbase.
	 */
	public class StoreResult : Object {
		/**
		 * Key, as a uint8[] buffer
		 */
		public uint8[] key { get; set; }
		/**
		 * Check-and-set value
		 */
		public uint64 cas { get; set; }

		private StoreResult() {}

		internal StoreResult.from_response_info( LibCouchbase.StoreResponseInfo info ) {
			this.key = info.key;
			this.cas = info.cas;
		}

		/**
		 * Retrieve key as string.
		 */
		public string key_string() {
			return LibCouchbase.uint8_to_terminated_string( key[0:key.length] );
		}
	}
}