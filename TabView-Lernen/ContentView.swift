import SwiftUI

// Datenmodelle
struct Story: Identifiable {
    let id = UUID()
    let username: String
    let imageUrl: String
    let hasUnseenStory: Bool
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}

// Neue Modelle für Einstellungen
struct UserSettings: Codable {
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var chatFontSize: Double
    var language: String
}

// ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var stories: [Story] = [
        Story(username: "Maria", imageUrl: "person.1", hasUnseenStory: true),
        Story(username: "Thomas", imageUrl: "person.2", hasUnseenStory: true),
        Story(username: "Sarah", imageUrl: "person.3", hasUnseenStory: false)
    ]
    @Published var userSettings = UserSettings(
        isDarkMode: false,
        notificationsEnabled: true,
        chatFontSize: 16,
        language: "Deutsch"
    )
    
    func sendMessage(_ content: String) {
        let message = ChatMessage(
            sender: "Ich",
            content: content,
            timestamp: Date(),
            isFromCurrentUser: true
        )
        withAnimation {
            messages.append(message)
        }
    }
}

// Neue View für Story-Anzeige
struct StoryView: View {
    let story: Story
    @Environment(\.dismiss) var dismiss
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Fortschrittsbalken
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(height: 2)
                        .overlay(
                            Rectangle()
                                .fill(.white)
                                .frame(width: geometry.size.width * progress)
                                .animation(.linear(duration: 5), value: progress),
                            alignment: .leading
                        )
                }
                .frame(height: 2)
                
                // Story-Content
                Spacer()
                Image(systemName: story.imageUrl)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
        }
        .onAppear {
            progress = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                dismiss()
            }
        }
    }
}

// Neue View für Einstellungen
struct SettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Erscheinungsbild")) {
                    Toggle("Dark Mode", isOn: $viewModel.userSettings.isDarkMode)
                    
                    VStack {
                        Text("Schriftgröße: \(Int(viewModel.userSettings.chatFontSize))")
                        Slider(value: $viewModel.userSettings.chatFontSize, in: 12...24)
                    }
                }
                
                Section(header: Text("Benachrichtigungen")) {
                    Toggle("Benachrichtigungen aktivieren", isOn: $viewModel.userSettings.notificationsEnabled)
                }
                
                Section(header: Text("Sprache")) {
                    Picker("Sprache", selection: $viewModel.userSettings.language) {
                        Text("Deutsch").tag("Deutsch")
                        Text("English").tag("English")
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarItems(trailing: Button("Fertig") {
                dismiss()
            })
        }
    }
}

// Aktualisierte ContentView
struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var newMessage = ""
    @State private var showingStoryCreator = false
    @State private var selectedStory: Story? = nil
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Hintergrund
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stories mit Tap-Funktion
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            // Story erstellen Button
                            VStack {
                                Button(action: { showingStoryCreator = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 70, height: 70)
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                Text("Deine Story")
                                    .font(.caption)
                            }
                            
                            // Stories anderer Nutzer
                            ForEach(viewModel.stories) { story in
                                VStack {
                                    Button(action: { selectedStory = story }) {
                                        ZStack {
                                            Circle()
                                                .stroke(story.hasUnseenStory ? .blue : .gray, lineWidth: 2)
                                                .frame(width: 74, height: 74)
                                            
                                            Image(systemName: story.imageUrl)
                                                .font(.system(size: 40))
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                        }
                                    }
                                    Text(story.username)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Chat-Nachrichten
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    
                    // Nachrichteneingabe
                    HStack(spacing: 15) {
                        Button(action: {}) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        TextField("Nachricht", text: $newMessage)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                        
                        Button(action: {
                            if !newMessage.isEmpty {
                                viewModel.sendMessage(newMessage)
                                newMessage = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(45))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Chats")
            .navigationBarItems(
                leading: Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                },
                trailing: Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                }
            )
            .sheet(item: $selectedStory) { story in
                StoryView(story: story)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStoryCreator) {
                StoryCreatorView()
            }
        }
    }
}

// Chat-Bubble Komponente
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(message.isFromCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
}

// Neue View für Story-Erstellung
struct StoryCreatorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var image: Image?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    Button(action: { showingImagePicker = true }) {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("Foto auswählen")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                    }
                }
            }
            .navigationTitle("Story erstellen")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Teilen") {
                    // Hier Story-Sharing-Logik implementieren
                    dismiss()
                }
                .disabled(image == nil)
            )
        }
    }
}

// Vorschau
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
