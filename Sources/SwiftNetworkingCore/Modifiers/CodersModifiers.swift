import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension NetworkClient {

	/// Sets a request body encoder.
	///
	/// - Parameter encoder: A request body encoder.
	///
	/// - Returns: A new network client with the request body encoder.
	func bodyEncoder(_ encoder: some ContentEncoder) -> NetworkClient {
		configs(\.bodyEncoder, encoder)
	}

	/// Sets a response body decoder.
	///
	/// - Parameter decoder: A response body decoder.
	///
	/// - Returns: A new network client with the response body decoder.
	func bodyDecoder(_ decoder: some DataDecoder) -> NetworkClient {
		configs(\.bodyDecoder, decoder)
	}
}

public extension NetworkClient.Configs {

	/// A request body encoder.
	var bodyEncoder: any ContentEncoder {
		get { self[\.bodyEncoder] ?? JSONEncoder() }
		set { self[\.bodyEncoder] = newValue }
	}

	/// A response body decoder.
	var bodyDecoder: any DataDecoder {
		get { self[\.bodyDecoder] ?? JSONDecoder() }
		set { self[\.bodyDecoder] = newValue }
	}
}