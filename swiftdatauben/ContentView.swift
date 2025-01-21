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

struct InputSectionView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var isButtonTapped = false

    var body: some View {
        VStack(spacing: 10) {
            TextField("New Todo", text: $viewModel.newTodoTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Picker("Priority", selection: $viewModel.selectedPriority) {
                ForEach(Todo.Priority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized).tag(priority)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Picker("Category", selection: $viewModel.selectedNewCategory) {
                ForEach(["Work", "Personal", "Shopping"], id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Button(action: {
                viewModel.addTodo()
                withAnimation {
                    isButtonTapped = true
                }
                // Adds a delay before returning the button (cancel) animation.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        isButtonTapped = false
                    }
                }
            }) {
                Text("Add Todo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isButtonTapped ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
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
        List {
            ForEach(filteredTodos) { todo in
                TodoRowView(todo: todo)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteTodo(todo)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: { indexSet in
                indexSet.map { filteredTodos[$0] }.forEach(viewModel.deleteTodo)
            })
        }
        .animation(.easeInOut, value: filteredTodos)  // Animate list appearance/changes
    }
}

struct TodoRowView: View {
    var todo: Todo
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(todo.title)
                    .font(.headline)
                Text(todo.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
                    .foregroundColor(.red)
            }
            Text(todo.priority.rawValue.capitalized)
                .foregroundColor(todo.priority == .high ? .red : .blue)
        }
        .transition(.opacity)   // Apply transition on favorite toggle
    }
}

@MainActor
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: TodoViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: TodoViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: { viewModel.selectedCategory = category }) {
                                Text(category)
                                    .padding()
                                    .background(viewModel.selectedCategory == category ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .scaleEffect(viewModel.selectedCategory == category ? 1.2 : 1.0)
                                    // Animate scale effect for category selection
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedCategory)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .id(viewModel.categories)  // Ensures layout knows about changes
                .animation(.easeInOut, value: viewModel.selectedCategory) // Animates HStack layout changes

                InputSectionView(viewModel: viewModel)

                TodoListView(viewModel: viewModel)
                    .listStyle(.plain)  // For full flexibility with animations
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedCategory)
            .navigationTitle("Todos")
        }
        .onAppear { // Example: Add an overall entry animation
            withAnimation(.easeInOut(duration: 1.0)) {
                self.viewModel.selectedCategory = self.viewModel.categories.first!
            }
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
                            TodoRowView(todo: todo)
                                .transition(.opacity)
                                .animation(.spring(), value: todo.isFavorite)
                        }
                        .onDelete(perform: deleteFavoriteTodos)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func deleteFavoriteTodos(at offsets: IndexSet) {
        offsets.map { favoriteTodos[$0] }.forEach(modelContext.delete)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting favorite todos: \(error)")
        }
    }
}

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

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Todo.self)
}
