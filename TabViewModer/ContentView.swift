import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var waveAnimation: Bool = false
    @State private var particleAnimation: Bool = false

    enum Tab: String, CaseIterable {
        case home = "house.fill"
        case favorites = "heart.fill"
        case settings = "gearshape.fill"
        case login = "person.fill"

        var title: String {
            switch self {
            case .home: return "Home"
            case .favorites: return "Favorites"
            case .settings: return "Settings"
            case .login: return "Login"
            }
        }

        var color: Color {
            switch self {
            case .home: return .blue
            case .favorites: return .pink
            case .settings: return .green
            case .login: return .orange
            }
        }
    }

    var body: some View {
        ZStack {
            // Dynamischer Hintergrund basierend auf dem ausgewählten Tab
            LinearGradient(gradient: Gradient(colors: [selectedTab.color.opacity(0.2), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Hauptinhalt der ausgewählten Ansicht
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(Tab.home)

                    FavoritesView()
                        .tag(Tab.favorites)

                    SettingsView()
                        .tag(Tab.settings)

                    LoginView(selectedTabColor: selectedTab.color)
                        .tag(Tab.login)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Benutzerdefinierte Tab-Leiste mit animierten Wellen und Partikeln
                ZStack(alignment: .bottom) {
                    // Animierte Welle
                    if waveAnimation {
                        WaveView(color: selectedTab.color)
                            .frame(height: 10)
                            .offset(y: -40)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    waveAnimation = false
                                }
                            }
                    }

                    // Partikel-Effekt
                    if particleAnimation {
                        ParticleView(color: selectedTab.color)
                            .offset(y: -60)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    particleAnimation = false
                                }
                            }
                    }

                    // Tab-Leiste
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Spacer()
                            TabButton(tab: tab, selectedTab: $selectedTab, waveAnimation: $waveAnimation, particleAnimation: $particleAnimation)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            // Glas-Effekt
                            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)

                            // Farbverlauf für die Tab-Leiste
                            LinearGradient(gradient: Gradient(colors: [selectedTab.color.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear) // Transparenter Hintergrund für die Tab-Leiste
                .clipped() // Verhindert, dass die Partikel über die Tab-Leiste hinausgehen
            }
            .edgesIgnoringSafeArea(.bottom) // Ignoriere den Safe Area unten
        }
    }
}

// Benutzerdefinierte Tab-Schaltfläche mit erweiterten Effekten
struct TabButton: View {
    let tab: ContentView.Tab
    @Binding var selectedTab: ContentView.Tab
    @Binding var waveAnimation: Bool
    @Binding var particleAnimation: Bool

    @State private var isVibrating: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                selectedTab = tab
                waveAnimation = true
                particleAnimation = true
                isVibrating = true
                
                // Vibration zurücksetzen nach der Animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isVibrating = false
                }
            }
        }) {
            VStack {
                // Symbol mit Parallax-, Glow- und Vibrations-Effekt
                ZStack {
                    // Holographischer Glow
                    if selectedTab == tab {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .scaleEffect(1.5)
                            .blur(radius: 10)
                            .opacity(selectedTab == tab ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: selectedTab)
                    }

                    Image(systemName: tab.rawValue)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .white : .gray.opacity(0.7))
                        .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                        .offset(y: selectedTab == tab ? -10 : 0)
                        .shadow(color: selectedTab == tab ? .white.opacity(0.8) : .clear, radius: 10, x: 0, y: 5)
                        .rotationEffect(.degrees(isVibrating ? 10 : 0)) // Vibrationseffekt
                        .offset(x: isVibrating ? 5 : 0) // Vibrationseffekt
                        .animation(
                            .interpolatingSpring(stiffness: 100, damping: 5)
                            .repeatCount(1, autoreverses: true),
                            value: isVibrating
                        )
                }

                // Text mit Animation
                Text(tab.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(selectedTab == tab ? .white : .gray.opacity(0.7))
                    .offset(y: selectedTab == tab ? -5 : 0)
                    .opacity(selectedTab == tab ? 1 : 0.7)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedTab)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Animierte Welle unter dem ausgewählten Tab
struct WaveView: View {
    var color: Color

    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addCurve(to: CGPoint(x: size.width, y: size.height),
                              control1: CGPoint(x: size.width * 0.25, y: size.height * 0.75),
                              control2: CGPoint(x: size.width * 0.75, y: size.height * 0.25))
                path.addLine(to: CGPoint(x: size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.closeSubpath()
            }
            context.fill(path, with: .color(color.opacity(0.5)))
        }
        .frame(height: 20)
        .scaleEffect(x: 1, y: waveAnimation ? 1.5 : 1)
        .animation(.easeInOut(duration: 0.5), value: waveAnimation)
    }

    @State private var waveAnimation: Bool = false

    init(color: Color) {
        self.color = color
        self.waveAnimation = true
    }
}

// Partikel-Effekt
struct ParticleView: View {
    var color: Color

    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                Circle()
                    .fill(color.opacity(0.5))
                    .frame(width: 5, height: 5)
                    .offset(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...0))
                    .animation(.easeOut(duration: 1).delay(Double(index) * 0.05), value: particleAnimation)
            }
        }
    }

    @State private var particleAnimation: Bool = false

    init(color: Color) {
        self.color = color
        self.particleAnimation = true
    }
}

// Glas-Effekt für die Tab-Leiste
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

// Beispiel-Views für die Tabs
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    ForEach(0..<10) { index in
                        Text("Home Item \(index + 1)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
    }
}

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Favorites")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    ForEach(0..<10) { index in
                        Text("Favorite Item \(index + 1)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    ForEach(0..<10) { index in
                        Text("Settings Item \(index + 1)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
    }
}

// Login-View mit animierten Buttons
struct LoginView: View {
    var selectedTabColor: Color
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var isRegistering: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("Username", text: $username)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            // Login-Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isLoggingIn = true
                    // Simuliere den Login-Prozess
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLoggingIn = false
                    }
                }
            }) {
                Text("Login")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTabColor) // Farbe dynamisch anpassen
                    .cornerRadius(10)
                    .scaleEffect(isLoggingIn ? 1.1 : 1.0) // Zoom-In-Effekt
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isLoggingIn)
            }
            .padding(.horizontal)

            // Register-Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isRegistering = true
                    // Simuliere den Registrierungsprozess
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRegistering = false
                    }
                }
            }) {
                Text("Register")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTabColor.opacity(0.8)) // Farbe dynamisch anpassen
                    .cornerRadius(10)
                    .scaleEffect(isRegistering ? 1.1 : 1.0) // Zoom-In-Effekt
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRegistering)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// Preview
#Preview {
    ContentView()
}
