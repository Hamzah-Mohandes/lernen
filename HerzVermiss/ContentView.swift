import SwiftUI
import SwiftData
import Foundation

// Definiere das Todo-Datenmodell
@Model
class Todo {
    var title: String
    var dateCreated: Date
    var priority: Priority

    enum Priority: String, CaseIterable, Codable {
        case low
        case normal
        case high
    }

    // Benutzerdefinierter Initialisierer
    init(title: String, dateCreated: Date = Date(), priority: Priority) {
        self.title = title
        self.dateCreated = dateCreated
        self.priority = priority
    }
}


class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false

    var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }
}

struct InputSection: View {
    @Binding var title: String
    @Binding var priority: Todo.Priority
    var onSubmit: () -> Void
    var isDarkMode: Bool

    var body: some View {
        VStack {
            TextField("Neues Todo", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker("Priorität", selection: $priority) {
                ForEach(Todo.Priority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized).tag(priority)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: {
                onSubmit()
            }) {
                Text("Hinzufügen")
                    .font(.headline)
                    .padding()
                    .background(isDarkMode ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Todo.dateCreated) private var todos: [Todo]
    @State private var newTodoTitle = ""
    @State private var selectedPriority: Todo.Priority = .normal
    @State private var scale: CGFloat = 1.0
    @State private var name: String = ""
    @State private var isAnimating: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeBackground
                
                VStack(spacing: 20) {
                    InputSection(
                        title: $newTodoTitle,
                        priority: $selectedPriority,
                        onSubmit: addTodo,
                        isDarkMode: themeManager.isDarkMode
                    )
                    
                    List {
                        ForEach(todos) { todo in
                            HStack {
                                Text(todo.title)
                                Spacer()
                                Text(todo.priority.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                    
                    TextField("Gib deinen Namen ein", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        withAnimation {
                            isAnimating.toggle()
                            scale = isAnimating ? 1.5 : 1.0
                        }
                    }) {
                        Text("Drücke mich!")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if !name.isEmpty {
                        Text("Hallo, \(name)!")
                            .font(.title2)
                            .padding()
                            .scaleEffect(scale)
                            .animation(.easeInOut(duration: 0.5), value: scale)
                    }
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: scale)
                        .onAppear {
                            if isAnimating {
                                scale = 1.2
                            }
                        }
                }
                .padding()
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        ThemeToggleButton()
                        EditButton()
                    }
                }
            }
        }
    }
    
    private var themeBackground: some View {
        themeManager.backgroundColor
            .ignoresSafeArea()
    }
    
    private func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        
        let todo = Todo(title: newTodoTitle, dateCreated: Date(), priority: selectedPriority)
        modelContext.insert(todo)
        newTodoTitle = ""
        selectedPriority = .normal
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { modelContext.delete(todos[$0]) }
        }
    }
}

struct ThemeToggleButton: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: {
            themeManager.toggleTheme()
        }) {
            Text(themeManager.isDarkMode ? "Hell" : "Dunkel")
                .padding()
                .background(themeManager.isDarkMode ? Color.white : Color.black)
                .foregroundColor(themeManager.isDarkMode ? Color.black : Color.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ContentView()
}
