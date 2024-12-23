import SwiftUI
import Combine

// AuthModel
struct AuthModel {
    var username: String
    var password: String

    func validateCredentials() -> Bool {
        return username == "12345" && password == "12345"
    }
}

// AuthViewModel
class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var loginError: String = ""
    @Published var isLoggedIn: Bool = false

    private var authModel: AuthModel {
        return AuthModel(username: username, password: password)
    }

    func login() {
        if authModel.validateCredentials() {
            isLoggedIn = true
            loginError = ""
        } else {
            loginError = "Invalid username or password"
        }
    }
}

// AuthView
struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                viewModel.login()
            }) {
                Text("Login")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            if !viewModel.loginError.isEmpty {
                Text(viewModel.loginError)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}

// HomeView
struct HomeView: View {
    var body: some View {
        Text("Home View")
            .font(.largeTitle)
            .padding()
    }
}

// ContentView
struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                AuthView(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Login")
                    }
            }
        } else {
            AuthView(viewModel: viewModel)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
