import Foundation
import VDCodable
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension NetworkClient {

	/// Configures the network client to use a custom decoder as specified by the provided mapping function.
	/// - Parameter mapper: A closure that takes an existing `DataDecoder` and returns a modified `DataDecoder`.
	/// - Returns: An instance of `NetworkClient` configured with the specified decoder.
	func mapDecoder(_ mapper: @escaping (any DataDecoder) -> any DataDecoder) -> NetworkClient {
		configs {
			$0.bodyDecoder = mapper($0.bodyDecoder)
		}
	}
}
