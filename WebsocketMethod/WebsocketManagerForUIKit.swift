//
//  WebsocketManagerForUIKit.swift
//  WebsocketMethod
//
//  Created by Hualiteq International on 2026/1/14.
//

import UIKit

class WebSocketViewController: UIViewController {
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    
    private let statusLabel = UILabel()
    private let connectButton = UIButton(type: .system)
    private let pingButton = UIButton(type: .system)
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let messagesTextView = UITextView()
    private let logTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Status label
        statusLabel.text = "Disconnected 🔴"
        statusLabel.textAlignment = .center
        statusLabel.font = .boldSystemFont(ofSize: 18)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Connect button
        connectButton.setTitle("Connect", for: .normal)
        connectButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        connectButton.addTarget(self, action: #selector(toggleConnection), for: .touchUpInside)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectButton)
        
        // Ping button
        pingButton.setTitle("Ping", for: .normal)
        pingButton.addTarget(self, action: #selector(sendPing), for: .touchUpInside)
        pingButton.isEnabled = false
        pingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pingButton)
        
        // Message input
        messageTextField.placeholder = "Enter message"
        messageTextField.borderStyle = .roundedRect
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageTextField)
        
        // Send button
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        // Messages display
        let messagesLabel = UILabel()
        messagesLabel.text = "Messages Received:"
        messagesLabel.font = .boldSystemFont(ofSize: 14)
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesLabel)
        
        messagesTextView.isEditable = false
        messagesTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        messagesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messagesTextView.layer.borderWidth = 1
        messagesTextView.layer.cornerRadius = 8
        messagesTextView.backgroundColor = .systemGray6
        messagesTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesTextView)
        
        // Console log display
        let logLabel = UILabel()
        logLabel.text = "Console Log:"
        logLabel.font = .boldSystemFont(ofSize: 14)
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logLabel)
        
        logTextView.isEditable = false
        logTextView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        logTextView.layer.borderColor = UIColor.systemGray4.cgColor
        logTextView.layer.borderWidth = 1
        logTextView.layer.cornerRadius = 8
        logTextView.backgroundColor = .black
        logTextView.textColor = .green
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            connectButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            connectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            connectButton.widthAnchor.constraint(equalToConstant: 100),
            
            pingButton.centerYAnchor.constraint(equalTo: connectButton.centerYAnchor),
            pingButton.leadingAnchor.constraint(equalTo: connectButton.trailingAnchor, constant: 10),
            pingButton.widthAnchor.constraint(equalToConstant: 80),
            
            messageTextField.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 20),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            
            messagesLabel.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 20),
            messagesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            messagesTextView.topAnchor.constraint(equalTo: messagesLabel.bottomAnchor, constant: 8),
            messagesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messagesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messagesTextView.heightAnchor.constraint(equalToConstant: 120),
            
            logLabel.topAnchor.constraint(equalTo: messagesTextView.bottomAnchor, constant: 20),
            logLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            logTextView.topAnchor.constraint(equalTo: logLabel.bottomAnchor, constant: 8),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        print(message) // Also print to Xcode console
        
        DispatchQueue.main.async { [weak self] in
            self?.logTextView.text += logMessage
            
            // Auto-scroll to bottom
            let range = NSRange(location: self?.logTextView.text.count ?? 0, length: 0)
            self?.logTextView.scrollRangeToVisible(range)
        }
    }
    
    private func addMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            self?.messagesTextView.text += "[\(timestamp)] \(message)\n"
            
            // Auto-scroll to bottom
            let range = NSRange(location: self?.messagesTextView.text.count ?? 0, length: 0)
            self?.messagesTextView.scrollRangeToVisible(range)
        }
    }
    
    @objc private func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connect()
        }
    }
    
    private func connect() {
        guard let url = URL(string: "wss://echo.websocket.org") else {
            log("❌ Invalid URL")
            return
        }
        
        log("⚠️ Attempting to connect to WebSocket...")
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        log("⚠️ WebSocket task resumed")
        
        isConnected = true
        statusLabel.text = "Connected 🟢"
        statusLabel.textColor = .systemGreen
        connectButton.setTitle("Disconnect", for: .normal)
        sendButton.isEnabled = true
        pingButton.isEnabled = true
        
        receiveMessage()
        
        // Check connection state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if let state = self?.webSocketTask?.state {
                switch state {
                case .running:
                    self?.log("✅ WebSocket state: RUNNING")
                case .suspended:
                    self?.log("⏸️ WebSocket state: SUSPENDED")
                case .canceling:
                    self?.log("🚫 WebSocket state: CANCELING")
                case .completed:
                    self?.log("⚠️ WebSocket state: COMPLETED")
                @unknown default:
                    self?.log("❓ WebSocket state: UNKNOWN")
                }
            }
        }
    }
    
    private func disconnect() {
        log("🔴 Disconnecting WebSocket...")
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        statusLabel.text = "Disconnected 🔴"
        statusLabel.textColor = .systemRed
        connectButton.setTitle("Connect", for: .normal)
        sendButton.isEnabled = false
        pingButton.isEnabled = false
        
        log("✅ Disconnected successfully")
    }
    
    @objc private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else {
            log("⚠️ Cannot send empty message")
            return
        }
        
        let timestamp = Date()
        log("📤 [\(timestamp)] Attempting to send: '\(text)'")
        
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { [weak self] error in
            let elapsed = Date().timeIntervalSince(timestamp)
            
            if let error = error {
                self?.log("❌ [\(Date())] FAILED to send after \(elapsed)s: \(error.localizedDescription)")
            } else {
                self?.log("✅ [\(Date())] Sent successfully after \(elapsed)s")
                self?.log("   ⏳ Waiting for server response...")
                
                DispatchQueue.main.async {
                    self?.messageTextField.text = ""
                }
            }
        }
    }
    
    @objc private func sendPing() {
        log("🏓 Sending ping...")
        
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                self?.log("❌ Ping failed: \(error.localizedDescription)")
            } else {
                self?.log("✅ Ping successful - connection is alive!")
            }
        }
    }
    
    private func receiveMessage() {
        log("👂 Listening for messages...")
        
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.log("📨 [\(Date())] SERVER CONFIRMED: Received echo back: '\(text)'")
                    self?.log("   ✅✅ FULL ROUND TRIP SUCCESSFUL!")
                    self?.addMessage(text)
                    
                case .data(let data):
                    self?.log("📦 Received data: \(data.count) bytes")
                    
                @unknown default:
                    self?.log("❓ Received unknown message type")
                    break
                }
                
                // Keep listening for more messages
                self?.receiveMessage()
                
            case .failure(let error):
                self?.log("❌ Receive error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    self?.statusLabel.text = "Error 🔴"
                    self?.statusLabel.textColor = .systemRed
                    self?.disconnect()
                }
            }
        }
    }
    
    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
