import SwiftUI
import SwiftData

// MARK: - Models
@Model
class Todo: Identifiable, Codable { // final entfernt
    var id: UUID
    var title: String
    var dateCreated: Date
    var priority: Priority
    var category: String

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
        printTodosInDatabase()

        do {
            try modelContext.save()
            print("Todo added successfully: \(todo.title)")
            printTodosInDatabase()
        } catch {
            print("Error saving todo: \(error)")
        }

        // Reset input fields
        newTodoTitle = ""
        selectedPriority = .normal
        selectedNewCategory = "Work"
    }

    func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
        do {
            try modelContext.save()
            print("Todo deleted successfully")
            printTodosInDatabase()
        } catch {
            print("Error deleting todo: \(error)")
        }
    }

    private func printTodosInDatabase() {
        do {
            let todos = try modelContext.fetch(FetchDescriptor<Todo>())
            print("Todos in database: \(todos.first?.title ?? "No todos found")")
        } catch {
            print("Error fetching todos: \(error)")
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
    }
}

struct TodoRowView: View {
    let todo: Todo

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
            Text(todo.priority.rawValue.capitalized)
                .foregroundColor(todo.priority == .high ? .red : .blue)
        }
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
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                InputSectionView(viewModel: viewModel)
                TodoListView(viewModel: viewModel)
            }
            .navigationTitle("Todos")
        }
    }
}

// MARK: - SecondView
struct SecondView: View {
    var body: some View {
        VStack {
            Text("Favorites")
                .font(.largeTitle)
                .padding()
            Image(systemName: "heart")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.pink)
        }
    }
}

// MARK: - ThirdView
struct ThirdView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            Image(systemName: "gear")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
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

            SecondView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            ThirdView()
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
