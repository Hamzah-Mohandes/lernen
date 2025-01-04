//import SwiftUI
//import Foundation
//
//// Model für die API-Antwort
//struct LLaMAResponse: Codable {
//    let output: String
//}
//
//// Model für die API-Anfrage
//struct LLaMARequest: Encodable {
//    let model: String
//    let messages: [LLaMAMessage]
//    let functions: [LLaMAFunction]
//}
//
//struct LLaMAMessage: Encodable {
//    let role: String
//    let content: String
//}
//
//struct LLaMAFunction: Encodable {
//    let name: String
//    let description: String
//    let parameters: LLaMAFunctionParameters
//    let `function_call`: LLaMAFunctionCall?
//}
//
//struct LLaMAFunctionParameters: Encodable {
//    let type: String
//    let properties: [String: LLaMAFunctionProperty]
//    let required: [String]
//}
//
//struct LLaMAFunctionProperty: Encodable {
//    let type: String
//    let description: String
//}
//
//struct LLaMAFunctionCall: Encodable {
//    let name: String
//}
//
//// API-Klasse
//class LLaMAAPI {
//    let apiKey: String = "LA-9bbc9aa2fc914d06a7ae9c461964cdc040a4fe5ab0204c46905c956745cb6a2f"
//    let baseUrl = "https://api.meta.ai/v1/llama/3.3/generate"
//
//    func generateText(input: String, completion: @escaping (LLaMAResponse?) -> Void) {
//        var request = URLRequest(url: URL(string: baseUrl)!, cachePolicy:.useProtocolCachePolicy)
//        request.httpMethod = "POST"
//        
//        let params = LLaMARequest(
//            model: "llama3.3-70b",
//            messages: [
//                LLaMAMessage(role: "user", content: input)
//            ],
//            functions: [
//                LLaMAFunction(
//                    name: "get_email_summary",
//                    description: "Get the current value of emails",
//                    parameters: LLaMAFunctionParameters(
//                        type: "object",
//                        properties: [
//                            "value": LLaMAFunctionProperty(type: "integer", description: "Quantity of emails"),
//                            "login": LLaMAFunctionProperty(type: "string", description: "login")
//                        ],
//                        required: ["value", "login"]
//                    ),
//                    `function_call`: LLaMAFunctionCall(name: "get_email_summary")
//                )
//            ]
//        )
//        
//        request.httpBody = try? JSONEncoder().encode(params)
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Fehler: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            if let data = data {
//                do {
//                    let response = try JSONDecoder().decode(LLaMAResponse.self, from: data)
//                    completion(response)
//                } catch {
//                    print("Fehler: \(error.localizedDescription)")
//                    completion(nil)
//                }
//            }
//        }.resume()
//    }
//}
//
//// View-Modell
//class LLaMAViewModel: ObservableObject {
//    @Published var input: String = ""
//    @Published var output: String = ""
//    private let api = LLaMAAPI()
//
//    func generateText() {
//        api.generateText(input: input) { response in
//            if let response = response {
//                self.output = response.output
//            } else {
//                self.output = "Fehler: Keine Antwort erhalten"
//            }
//        }
//    }
//}
//
//// View
//struct ContentView: View {
//    @StateObject var viewModel = LLaMAViewModel()
//
//    var body: some View {
//        VStack {
//            TextField("Eingabe", text: $viewModel.input)
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            Button("Generieren") {
//                viewModel.generateText()
//            }
//            Text(viewModel.output)
//        }
//    .padding()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}




import SwiftUI

// MARK: - Datenmodelle

enum Kategorie: String, Identifiable, CaseIterable, Codable, Hashable {
    case getränke = "Getränke"
    case kuchen = "Kuchen"

    var id: String { self.rawValue }
}

struct Artikel: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let preis: Double
    var anzahl: Int
    let kategorie: Kategorie
}

struct Tisch: Identifiable, Codable, Hashable {
    let id: Int
    var artikel: [Artikel]

    func berechneGesamtpreis() -> Double {
        artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }
}

// MARK: - StateContainer
class AppState: ObservableObject {
    @Published var tische: [Tisch] = []
    @Published var bestellungen: [Tisch] = []
    @Published var ausgewählteTischnummer: Int?
    @Published var navigationPath = NavigationPath()
}

// MARK: - Hauptansicht
struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        TabView {
            NavigationStack(path: $appState.navigationPath) {
                HomeView(
                    ausgewählteTischnummer: $appState.ausgewählteTischnummer,
                    tische: $appState.tische,
                    bestellungen: $appState.bestellungen
                )
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            KücheView(bestellungen: $appState.bestellungen)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Küche")
                }

            KellnerView(
                bestellungen: $appState.bestellungen,
                tische: $appState.tische
            )
            .tabItem {
                Image(systemName: "person.fill")
                Text("Kellner")
            }
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @Binding var ausgewählteTischnummer: Int?
    @Binding var tische: [Tisch]
    @Binding var bestellungen: [Tisch]

    var body: some View {
        VStack {
            if ausgewählteTischnummer == nil {
                TischnummerEingabeView(ausgewählteTischnummer: $ausgewählteTischnummer, tische: $tische)
            } else {
                if let tisch = tische.first(where: { $0.id == ausgewählteTischnummer }) {
                    KategorieView(
                        tisch: Binding(
                            get: { tisch },
                            set: { newValue in
                                if let index = tische.firstIndex(where: { $0.id == tisch.id }) {
                                    tische[index] = newValue
                                }
                            }
                        ),
                        bestellungen: $bestellungen,
                        ausgewählteTischnummer: $ausgewählteTischnummer
                    )
                } else {
                    Text("Tisch nicht gefunden")
                }
            }
        }
        .navigationTitle("Home")
    }
}

// MARK: - TischnummerEingabeView
struct TischnummerEingabeView: View {
    @Binding var ausgewählteTischnummer: Int?
    @Binding var tische: [Tisch]
    @State private var tischnummer: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Tischnummer eingeben", text: $tischnummer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()

            Button(action: {
                if let nummer = Int(tischnummer) {
                    ausgewählteTischnummer = nummer
                    if !tische.contains(where: { $0.id == nummer }) {
                        tische.append(Tisch(id: nummer, artikel: [
                            Artikel(name: "Cola", preis: 3.50, anzahl: 0, kategorie: .getränke),
                            Artikel(name: "Bier", preis: 4.00, anzahl: 0, kategorie: .getränke),
                            Artikel(name: "Wein", preis: 5.50, anzahl: 0, kategorie: .getränke),
                            Artikel(name: "Apfelkuchen", preis: 4.50, anzahl: 0, kategorie: .kuchen),
                            Artikel(name: "Schokokuchen", preis: 5.00, anzahl: 0, kategorie: .kuchen)
                        ]))
                    }
                }
            }) {
                Text("Tisch auswählen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - KategorieView
struct KategorieView: View {
    @Binding var tisch: Tisch
    @Binding var bestellungen: [Tisch]
    @Binding var ausgewählteTischnummer: Int?

    var body: some View {
        List(Kategorie.allCases) { kategorie in
            NavigationLink(value: kategorie) {
                HStack {
                    Image(systemName: kategorie == .getränke ? "cup.and.saucer.fill" : "birthday.cake.fill")
                    Text(kategorie.rawValue)
                }
            }
        }
        .navigationDestination(for: Kategorie.self) { kategorie in
            ArtikelView(
                tisch: $tisch,
                kategorie: kategorie,
                bestellungen: $bestellungen
            )
        }
        .navigationTitle("Tisch \(tisch.id)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Fertig") {
                    if let index = bestellungen.firstIndex(where: { $0.id == tisch.id }) {
                        bestellungen[index] = tisch
                    } else {
                        bestellungen.append(tisch)
                    }
                    ausgewählteTischnummer = nil
                }
            }
        }
    }
}

// MARK: - ArtikelView
struct ArtikelView: View {
    @Binding var tisch: Tisch
    let kategorie: Kategorie
    @Binding var bestellungen: [Tisch]
    @State private var ausgewählterArtikelIndex: Int? = nil

    var body: some View {
        VStack {
            // Liste der Artikel
            List {
                ForEach(Array(tisch.artikel.enumerated()).filter { $0.element.kategorie == kategorie }, id: \.element.id) { index, artikel in
                    Button(action: {
                        ausgewählterArtikelIndex = index
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(artikel.name)
                                Text(String(format: "%.2f €", artikel.preis))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(artikel.anzahl)x")
                        }
                    }
                }
            }

            // Steuerelemente für den ausgewählten Artikel
            if let index = ausgewählterArtikelIndex {
                VStack {
                    Text("Ausgewählt: \(tisch.artikel[index].name)")
                        .font(.headline)
                        .padding()

                    HStack(spacing: 20) {
                        Button(action: {
                            if tisch.artikel[index].anzahl > 0 {
                                tisch.artikel[index].anzahl -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        }

                        Text("\(tisch.artikel[index].anzahl)")
                            .font(.title)
                            .frame(width: 50)

                        Button(action: {
                            tisch.artikel[index].anzahl += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
            }
        }
        .navigationTitle(kategorie.rawValue)
    }
}

// MARK: - KücheView
struct KücheView: View {
    @Binding var bestellungen: [Tisch]

    var body: some View {
        NavigationView {
            List {
                ForEach(bestellungen) { tisch in
                    if tisch.artikel.contains(where: { $0.anzahl > 0 }) {
                        Section(header: Text("Tisch \(tisch.id)")) {
                            ForEach(tisch.artikel.filter { $0.anzahl > 0 }) { artikel in
                                HStack {
                                    Text(artikel.name)
                                    Spacer()
                                    Text("\(artikel.anzahl)x")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Küche")
        }
    }
}

// MARK: - KellnerView
struct KellnerView: View {
    @Binding var bestellungen: [Tisch]
    @Binding var tische: [Tisch]

    var body: some View {
        NavigationStack {
            List {
                ForEach(bestellungen) { tisch in
                    if tisch.artikel.contains(where: { $0.anzahl > 0 }) {
                        NavigationLink(value: tisch.id) {
                            VStack(alignment: .leading) {
                                Text("Tisch \(tisch.id)")
                                    .font(.headline)
                                ForEach(tisch.artikel.filter { $0.anzahl > 0 }) { artikel in
                                    Text("\(artikel.name): \(artikel.anzahl)x")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { tischID in
                if let tisch = bestellungen.first(where: { $0.id == tischID }) {
                    KategorieView(
                        tisch: Binding(
                            get: { tisch },
                            set: { newValue in
                                if let index = bestellungen.firstIndex(where: { $0.id == tischID }) {
                                    bestellungen[index] = newValue
                                }
                                if let index = tische.firstIndex(where: { $0.id == tischID }) {
                                    tische[index] = newValue
                                }
                            }
                        ),
                        bestellungen: $bestellungen,
                        ausgewählteTischnummer: .constant(tischID)
                    )
                } else {
                    Text("Tisch nicht gefunden")
                }
            }
            .navigationTitle("Kellner")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        // Füge Beispieldaten hinzu
        appState.tische = [
            Tisch(id: 1, artikel: [
                Artikel(name: "Cola", preis: 3.50, anzahl: 2, kategorie: .getränke),
                Artikel(name: "Apfelkuchen", preis: 4.50, anzahl: 1, kategorie: .kuchen)
            ])
        ]
        appState.bestellungen = appState.tische
        
        return ContentView()
            .environmentObject(appState)
    }
}
