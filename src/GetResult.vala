namespace Couchbase {
	/**
	 * Full metadata associated with a key-value pair in Couchbase.
	 */
	public class GetResult : Object {
		/**
		 * Key, as a uint8[] buffer
		 */
		public uint8[] key { get; set; }
		/**
		 * Value bytes, as a uint8[] buffer
		 */
		public uint8[] bytes { get; set; }
		/**
		 * Flags attached to value
		 */
		public uint32 flags { get; set; }
		/**
		 * Check-and-set value
		 */
		public uint64 cas { get; set; }

		private GetResult() {}

		internal GetResult.from_response_info( LibCouchbase.GetResponseInfo info ) {
			this.key = info.key;
			this.bytes = info.bytes;
			this.flags = info.flags;
			this.cas = info.cas;
		}

		/**
		 * Retrieve key as string.
		 */
		public string key_string() {
			return LibCouchbase.uint8_to_terminated_string( key[0:key.length] );
		}

		/**
		 * Retrieve bytes as string.
		 */
		public string bytes_string() {
			return LibCouchbase.uint8_to_terminated_string( bytes[0:bytes.length] );
		}
	}
}