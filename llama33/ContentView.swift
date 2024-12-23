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

// Modell für Artikel
struct Artikel: Identifiable, Codable {
    var id = UUID()
    let name: String
    let preis: Double
    var anzahl: Int
    let kategorie: Kategorie
}

// Enum für Kategorien
enum Kategorie: String, Codable, CaseIterable, Identifiable {
    case getränke = "Getränke"
    case kuchen = "Kuchen"
    var id: String { self.rawValue }
}

// Modell für Tisch
struct Tisch: Identifiable, Codable {
    let id: Int
    var artikel: [Artikel]
    var geschlossen: Bool = false

    // Beispiel-Daten für Artikel
    static let beispielArtikel: [Artikel] = [
        Artikel(name: "Cola", preis: 3.50, anzahl: 0, kategorie: .getränke),
        Artikel(name: "Bier", preis: 4.00, anzahl: 0, kategorie: .getränke),
        Artikel(name: "Wein", preis: 5.50, anzahl: 0, kategorie: .getränke),
        Artikel(name: "Apfelkuchen", preis: 4.50, anzahl: 0, kategorie: .kuchen),
        Artikel(name: "Schwarzwälder", preis: 5.00, anzahl: 0, kategorie: .kuchen)
    ]

    // Alle Tische erstellen
    static let anzahlTische = 15

    static func alleTische() -> [Tisch] {
        return (1...anzahlTische).map {
            Tisch(id: $0, artikel: beispielArtikel)
        }
    }
}

// Hauptansicht
struct ContentView: View {
    @State private var tische: [Tisch] = Tisch.alleTische()

    var body: some View {
        NavigationView {
            List($tische) { $tisch in
                HStack {
                    NavigationLink(destination: TischDetailView(tisch: $tisch)) {
                        Text("Tisch \(tisch.id)")
                    }
                    Spacer()
                    Text("\(String(format: "%.2f", berechneGesamtpreis(tisch: tisch))) €")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Tische")
        }
    }

    // Funktion zur Berechnung des Gesamtpreises pro Tisch
    func berechneGesamtpreis(tisch: Tisch) -> Double {
        tisch.artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }
}

// Detailansicht für einen Tisch
struct TischDetailView: View {
    @Binding var tisch: Tisch
    @State private var zeigeSheet: Bool = false
    @State private var ausgewählteKategorie: Kategorie?

    var body: some View {
        VStack {
            // Buttons für Kategorien
            ForEach(Kategorie.allCases) { kategorie in
                Button(action: {
                    ausgewählteKategorie = kategorie
                    zeigeSheet = true
                }) {
                    Text(kategorie.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Spacer()

            // Gesamtpreis des Tisches anzeigen
            Text("Gesamtpreis: \(String(format: "%.2f", berechneGesamtpreis())) €")
                .font(.headline)
                .padding()

            // Schließen-Button
            Button(action: {
                tisch.geschlossen.toggle()
            }) {
                Text(tisch.geschlossen ? "Tisch wieder öffnen" : "Tisch schließen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tisch.geschlossen ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $zeigeSheet) {
            if let kategorie = ausgewählteKategorie {
                KategorieSheet(tisch: $tisch, kategorie: kategorie, zeigeSheet: $zeigeSheet)
            }
        }
        .navigationTitle("Tisch \(tisch.id)")
    }

    // Funktion zur Berechnung des Gesamtpreises
    func berechneGesamtpreis() -> Double {
        tisch.artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }
}

// Sheet für Artikel einer Kategorie
struct KategorieSheet: View {
    @Binding var tisch: Tisch
    let kategorie: Kategorie
    @Binding var zeigeSheet: Bool

    var body: some View {
        NavigationView {
            VStack {
                // Liste der Artikel in der ausgewählten Kategorie
                List($tisch.artikel.filter { $0.wrappedValue.kategorie == kategorie }) { $artikel in
                    HStack {
                        Text(artikel.name)
                        Spacer()
                        Text("\(String(format: "%.2f", artikel.preis)) €")
                        TextField("Anzahl", value: $artikel.anzahl, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50)
                            .keyboardType(.numberPad)
                    }
                }

                // Gesamtpreis des Tisches anzeigen
                HStack {
                    Text("Gesamtpreis: ")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.2f", berechneGesamtpreis())) €")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()

                // Schließen-Button
                Button(action: {
                    zeigeSheet = false
                }) {
                    Text("Schließen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle(kategorie.rawValue)
        }
    }

    // Funktion zur Berechnung des Gesamtpreises
    func berechneGesamtpreis() -> Double {
        tisch.artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
