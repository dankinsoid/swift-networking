#if canImport(UIKit)
import Foundation

public extension NetworkClient {

	/// Configures the network client to retry requests that failed due to the app being in the background.
	/// - Parameters:
	///   - retryLimit: An optional integer specifying the maximum number of retries for a request.
	///                 If `nil`, it will retry indefinitely until successful.
	///   - wasInBackgroundService: A closure providing a `WasInBackgroundService` instance.
	/// - Returns: An instance of `NetworkClient` configured with retry behavior upon entering the foreground.
	func retryWhenEnterForeground(
		retryLimit: Int? = nil,
		wasInBackgroundService: @autoclosure @escaping () -> WasInBackgroundService
	) -> NetworkClient {
		configs {
			$0.httpClient = RetryAfterBackgroundClient(
				base: $0.httpClient,
				retryLimit: retryLimit,
				wasInBackgroundService: wasInBackgroundService
			)
		}
	}
}

private struct RetryAfterBackgroundClient: HTTPClient {

	let base: HTTPClient
	let retryLimit: Int?
	let wasInBackgroundService: () -> WasInBackgroundService

	func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		var count = 0
		let didEnterBackground = wasInBackgroundService()
		func needRetry() -> Bool {
			guard didEnterBackground.wasInBackground else {
				return false
			}
			if let retryLimit {
				return count <= retryLimit
			}
			return true
		}

		func retry() async throws -> (Data, HTTPURLResponse) {
			count += 1
			didEnterBackground.reset()
			didEnterBackground.start()
			return try await self.data(for: request)
		}

		let response: HTTPURLResponse
		let data: Data
		do {
			(data, response) = try await retry()
		} catch {
			if needRetry() {
				return try await retry()
			}
			throw error
		}
		if !response.isStatusCodeValid, needRetry() {
			return try await retry()
		}
		return (data, response)
	}
}
#endif
