//
//  WebsocketManager.swift
//  WebsocketMethod
//
//  Created by Hualiteq International on 2026/1/14.
//
//

import SwiftUI
import Combine

@Observable
class WebSocketManager {
    var isConnected = false
    var messages: [String] = []
    var connectionStatus = "Disconnected"
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "wss://echo.websocket.org")!
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        print("⚠️ Attemping to connect to Websocket")
        webSocketTask?.resume()
        print("⚠️ Websocket task resumed")
        
        isConnected = true
        connectionStatus = "Connected"
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    func send(_ message: String) {
        let timestamp = Date()
        print("📤 [\(timestamp)] Attempting to send: '\(message)'")
        
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ [\(Date())] FAILED to send after \(Date().timeIntervalSince(timestamp))s: \(error)")
            } else {
                print("✅ [\(Date())] Sent successfully after \(Date().timeIntervalSince(timestamp))s")
                print("   ⏳ Waiting for server response...")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 [\(Date())] SERVER CONFIRMED: Received echo back: '\(text)'")
                    print("   ✅✅ FULL ROUND TRIP SUCCESSFUL!")
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                    }
                case .data(let data):
                    print("📦 Received data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
                
            case .failure(let error):
                print("❌ Receive error: \(error)")
            }
        }
    }
    
    // Add ping to keep connection alive
    func ping() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
}

// Usage in SwiftUI View
struct WebSocketView: View {
    @State private var manager = WebSocketManager()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            Text(manager.connectionStatus)
                .padding()
            
            HStack {
                Button(manager.isConnected ? "Disconnect" : "Connect") {
                    if manager.isConnected {
                        manager.disconnect()
                    } else {
                        manager.connect()
                    }
                }
                
                Button("Ping") {
                    manager.ping()
                }
                .disabled(!manager.isConnected)
                
                Button("Test") {
                    manager.ping()
                }
            }
            
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    manager.send(messageText)
                    messageText = ""
                }
                .disabled(!manager.isConnected)
            }
            .padding()
            
            List(manager.messages, id: \.self) { message in
                Text(message)
            }
        }
    }
}
