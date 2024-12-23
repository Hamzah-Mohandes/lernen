import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // Nachrichtenbereich
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        HStack {
                            if message.role == "user" {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Eingabebereich
            HStack {
                TextField("Type your message...", text: $viewModel.userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 44)
                    .padding(.leading)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            .padding()
        }
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(role: "assistant", content: "Hi! How can I assist you today?")
    ]
    @Published var userInput: String = ""
    
    private let apiKey = "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"
    private let apiURL = "https://api-inference.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    
    // Funktion zum Senden von Nachrichten und Abrufen von Antworten
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        // Benutzer-Nachricht zur Chat-Historie hinzufügen
        let userMessage = ChatMessage(role: "user", content: userInput)
        messages.append(userMessage)
        
        // API-Anfrage vorbereiten
        let body: [String: Any] = [
            "inputs": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": userInput]
            ]
        ]
        
        // Benutzer-Eingabe zurücksetzen
        userInput = ""
        
        // API-Aufruf
        Task {
            do {
                let response = try await queryAPI(body: body)
                if let assistantMessage = response.first?["generated_text"] as? String {
                    DispatchQueue.main.async {
                        let message = ChatMessage(role: "assistant", content: assistantMessage)
                        self.messages.append(message)
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // API-Anfrage an Hugging Face
    private func queryAPI(body: [String: Any]) async throws -> [[String: Any]] {
        guard let url = URL(string: apiURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
    }
}


struct preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
