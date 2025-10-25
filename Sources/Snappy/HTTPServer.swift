import Foundation
import Network

/// Minimal HTTP server that exposes preset snapping endpoints.
final class HttpServer: @unchecked Sendable {
    typealias RequestHandler = @Sendable (SnapAction) -> Void

    private let port: NWEndpoint.Port
    private var listener: NWListener?
    private let handler: RequestHandler
    private let queue = DispatchQueue(label: "dev.snappy.http")

    init(port: UInt16, handler: @escaping RequestHandler) {
        guard let port = NWEndpoint.Port(rawValue: port) else {
            fatalError("Invalid port \(port)")
        }
        self.port = port
        self.handler = handler
    }

    func start() {
        guard listener == nil else { return }
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            print("Failed to start HTTP server on port \(port): \(error)")
            return
        }

        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                guard let self else { return }
                print("HTTP server listening on port \(self.port)")
            case .failed(let error):
                print("HTTP server failed: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.setupConnection(connection)
        }

        listener?.start(queue: queue)
    }

    private func setupConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            if case .ready = state {
                self.receive(on: connection)
            }
        }
        connection.start(queue: queue)
    }

    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let data, !data.isEmpty {
                self.handleRequest(data: data, connection: connection)
            }

            if let error {
                print("Connection error: \(error)")
                connection.cancel()
                return
            }

            if isComplete {
                connection.cancel()
            } else {
                self.receive(on: connection)
            }
        }
    }

    private func handleRequest(data: Data, connection: NWConnection) {
        guard let requestString = String(data: data, encoding: .utf8) else {
            sendResponse(
                on: connection,
                status: "400 Bad Request",
                body: "{\"error\":\"invalid_encoding\"}"
            )
            return
        }

        let lines = requestString.split(separator: "\r\n", omittingEmptySubsequences: false)
        guard let requestLine = lines.first else {
            sendResponse(
                on: connection,
                status: "400 Bad Request",
                body: "{\"error\":\"missing_request_line\"}"
            )
            return
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else {
            sendResponse(
                on: connection,
                status: "400 Bad Request",
                body: "{\"error\":\"invalid_request_line\"}"
            )
            return
        }

        let method = parts[0]
        let path = parts[1]

        guard method == "POST" else {
            sendResponse(
                on: connection,
                status: "405 Method Not Allowed",
                body: "{\"error\":\"only_post_supported\"}"
            )
            return
        }

        let pathComponents = path.split(separator: "/").filter { !$0.isEmpty }
        guard pathComponents.count == 2, pathComponents[0] == "snap", let action = SnapAction(pathComponent: pathComponents[1]) else {
            sendResponse(
                on: connection,
                status: "404 Not Found",
                body: "{\"error\":\"unknown_route\"}"
            )
            return
        }

        handler(action)
        sendResponse(on: connection, status: "200 OK", body: "{\"status\":\"ok\",\"action\":\"\(action.description)\"}")
    }

    private func sendResponse(on connection: NWConnection, status: String, body: String) {
        let responseLines = [
            "HTTP/1.1 \(status)",
            "Content-Type: application/json",
            "Content-Length: \(body.utf8.count)",
            "Connection: Close",
            "",
            body
        ]
        let response = responseLines.joined(separator: "\r\n")
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { [weak connection] error in
            if let error {
                print("Failed to send response: \(error)")
            }
            connection?.cancel()
        })
    }
}
