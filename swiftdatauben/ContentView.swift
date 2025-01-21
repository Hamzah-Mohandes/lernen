import SwiftUI
import SwiftData

// MARK: - Models
@Model
class Todo: Identifiable {
    var id: UUID
    var title: String
    var dateCreated: Date
    var priority: Priority
    var category: String
    var isFavorite: Bool = false

    enum Priority: String, CaseIterable, Codable, Hashable {
        case low
        case normal
        case high
    }

    init(title: String, dateCreated: Date = Date(), priority: Priority, category: String) {
        self.id = UUID()
        self.title = title
        self.dateCreated = dateCreated
        self.priority = priority
        self.category = category
    }
}

// MARK: - ViewModels
@MainActor
class TodoViewModel: ObservableObject {
    @Published var selectedCategory = "All"
    @Published var newTodoTitle = ""
    @Published var selectedPriority: Todo.Priority = .normal
    @Published var selectedNewCategory = "Work"

    let categories = ["All", "Work", "Personal", "Shopping"]
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        let todo = Todo(
            title: newTodoTitle,
            dateCreated: Date(),
            priority: selectedPriority,
            category: selectedNewCategory
        )
        modelContext.insert(todo)

        do {
            try modelContext.save()
            print("Todo added successfully: \(todo.title)")
        } catch {
            print("Error saving todo: \(error)")
        }

        newTodoTitle = ""
        selectedPriority = .normal
        selectedNewCategory = "Work"
    }

    func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
        do {
            try modelContext.save()
            print("Todo deleted successfully")
        } catch {
            print("Error deleting todo: \(error)")
        }
    }
}

// MARK: - Views

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            HomeView(modelContext: modelContext)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: TodoViewModel
    @State private var showAddTodoSheet = false

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: TodoViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("Todos")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#333333"))
                        .padding(.top, 20)
                    
                    TextField("Search", text: .constant(""))
                        .padding(10)
                        .background(Color(hex: "#F5F5F5"))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryButton(category: category, isSelected: viewModel.selectedCategory == category) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }

                // Todo List
                TodoListView(viewModel: viewModel)
                    .padding(.horizontal, 20)

                Spacer()

                // Floating Action Button
                FloatingActionButton {
                    showAddTodoSheet = true
                }
                .padding(.bottom, 20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddTodoSheet) {
                AddTodoView(viewModel: viewModel, isPresented: $showAddTodoSheet)
            }
        }
    }
}

struct AddTodoView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Todo")) {
                    TextField("Title", text: $viewModel.newTodoTitle)
                    Picker("Priority", selection: $viewModel.selectedPriority) {
                        ForEach(Todo.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    Picker("Category", selection: $viewModel.selectedNewCategory) {
                        ForEach(viewModel.categories.filter { $0 != "All" }, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addTodo()
                        isPresented = false
                    }
                    .disabled(viewModel.newTodoTitle.isEmpty)
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "#333333"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "#4A90E2") : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isSelected)
        }
    }
}

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Query private var todos: [Todo]

    var filteredTodos: [Todo] {
        if viewModel.selectedCategory == "All" {
            return todos
        }
        return todos.filter { $0.category == viewModel.selectedCategory }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredTodos) { todo in
                    TodoCardView(todo: todo, viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                        .animation(.easeInOut(duration: 0.3), value: filteredTodos)
                }
            }
        }
    }
}

struct TodoCardView: View {
    var todo: Todo
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(todo.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Text(todo.category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#777777"))
            }
            Spacer()
            Button(action: {
                todo.isFavorite.toggle()
                do {
                    try modelContext.save()
                } catch {
                    print("Error saving favorite status: \(error)")
                }
            }) {
                Image(systemName: todo.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(todo.isFavorite ? Color(hex: "#50E3C2") : Color(hex: "#777777"))
                    .scaleEffect(todo.isFavorite ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: todo.isFavorite)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color(hex: "#4A90E2"))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteTodos: [Todo]

    init() {
        // Verwenden Sie das #Predicate-Makro von SwiftData
        _favoriteTodos = Query(filter: #Predicate<Todo> { todo in
            todo.isFavorite == true
        })
    }

    var body: some View {
        NavigationView {
            VStack {
                if favoriteTodos.isEmpty {
                    Text("No Favorite Todos")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(favoriteTodos) { todo in
                            TodoCardView(todo: todo, viewModel: TodoViewModel(modelContext: modelContext))
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), value: todo.isFavorite)
                        }
                        .onDelete(perform: deleteFavoriteTodos)
                    }
                    .animation(.easeInOut(duration: 0.5), value: favoriteTodos) // Animates list changes
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func deleteFavoriteTodos(at offsets: IndexSet) {
        withAnimation {
            offsets.map { favoriteTodos[$0] }.forEach(modelContext.delete)
            do {
                try modelContext.save()
            } catch {
                print("Error deleting favorite todos: \(error)")
            }
        }
    }
}

// MARK: - Helper Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Todo.self)
}
