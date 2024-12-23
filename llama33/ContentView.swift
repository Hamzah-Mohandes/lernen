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

// Kategorie für Artikel
enum Kategorie: String, Identifiable, CaseIterable, Codable {
    case getränke = "Getränke"
    case kuchen = "Kuchen"

    var id: String { self.rawValue }
}

// Model für Artikel (Getränke oder Kuchen)
struct Artikel: Identifiable, Codable {
    var id = UUID()
    let name: String
    let preis: Double
    var anzahl: Int
    let kategorie: Kategorie
}

// Model für Tisch
struct Tisch: Identifiable, Codable {
    let id: Int
    var artikel: [Artikel]

    static let anzahlTische = 15

    static func alleTische() -> [Tisch] {
        let artikelListe = [
            Artikel(name: "Cola", preis: 3.50, anzahl: 0, kategorie: .getränke),
            Artikel(name: "Bier", preis: 4.00, anzahl: 0, kategorie: .getränke),
            Artikel(name: "Wein", preis: 5.50, anzahl: 0, kategorie: .getränke),
            Artikel(name: "Apfelkuchen", preis: 4.50, anzahl: 0, kategorie: .kuchen),
            Artikel(name: "Schokokuchen", preis: 5.00, anzahl: 0, kategorie: .kuchen)
        ]
        return (1...anzahlTische).map { Tisch(id: $0, artikel: artikelListe) }
    }

    // Berechne den Gesamtpreis für diesen Tisch
    func berechneGesamtpreis() -> Double {
        artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }
}

// Hauptansicht
struct ContentView: View {
    @State private var tische: [Tisch] = Tisch.alleTische() // Alle Tische initialisieren

    var body: some View {
        NavigationView {
            List(tische) { tisch in
                NavigationLink(destination: KategorieView(tisch: Binding(
                    get: { tische[tische.firstIndex(where: { $0.id == tisch.id })!] },
                    set: { newValue in
                        if let index = tische.firstIndex(where: { $0.id == tisch.id }) {
                            tische[index] = newValue
                        }
                    }
                ))) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Tisch \(tisch.id)")
                                .font(.headline)
                            
                            Text("Gesamtpreis: \(String(format: "%.2f", tisch.berechneGesamtpreis())) €")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                       
                    }
                 
                    
                }
            }
            .navigationTitle("")
            .font(.title)
            .accentColor(.blue) // Hauptfarbe
            .background(Color(.systemGray6)) // Hintergrundfarbe
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text("Tische")
                        .font(.largeTitle)
                        .foregroundColor(.blue) // Hauptfarbe
                        .padding(.top, 20)
                    
                }
                    
                
            }
            
        }
    }
}

// Ansicht für Kategorien
struct KategorieView: View {
    @Binding var tisch: Tisch
    @State private var ausgewählteKategorie: Kategorie?
    @State private var zeigeSheet: Bool = false

    var body: some View {
        List(Kategorie.allCases) { kategorie in
            Button(action: {
                ausgewählteKategorie = kategorie
                zeigeSheet = true
            }) {
                HStack {
                    Image(systemName: kategorie == .getränke ? "cup.and.saucer.fill" : "birthday.cake.fill")
                        .foregroundColor(.blue) // Hauptfarbe
                    Text(kategorie.rawValue)
                        .foregroundColor(.blue) // Hauptfarbe
                }
            }
        }
        .navigationTitle("")
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("Tische \(tisch.id)")
                    .font(.largeTitle)
                    .foregroundColor(.blue) // Hauptfarbe
                    .padding(.top, 20)
            }
        }
        .sheet(isPresented: $zeigeSheet) {
            if let kategorie = ausgewählteKategorie {
                KategorieSheet(tisch: $tisch, kategorie: kategorie, zeigeSheet: $zeigeSheet)
            }
        }
        .background(Color(.systemGray6)) // Hintergrundfarbe
    }
}

// Eingabeformular für Artikelanzahl in der Kategorie
struct KategorieSheet: View {
    @Binding var tisch: Tisch
    let kategorie: Kategorie
    @Binding var zeigeSheet: Bool
    @State private var vorherigerPreis: Double = 0.0 // Speichert den vorherigen Preis

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
                            .onChange(of: artikel.anzahl) { _ in
                                // Aktualisiere die Preisänderung
                                updatePreisÄnderung()
                            }
                    }
                }

                // Gesamtpreis des Tisches anzeigen
                HStack {
                    Text("Gesamtpreis: ")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.2f", berechneGesamtpreis())) €")
                        .font(.headline)
                        .foregroundColor(.blue) // Hauptfarbe
                }
                .padding()

                // Anzeige der Preisänderung
                HStack {
                    Text("Preisänderung: ")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.2f", berechnePreisänderung())) €")
                        .font(.headline)
                        .foregroundColor(berechnePreisänderung() >= 0 ? .green : .red) // Akzentfarbe
                }
                .padding()

                // Schließen-Button
                Button(action: {
                    // Aktualisiere vorherigen Preis beim Schließen
                    vorherigerPreis = berechneGesamtpreis()
                    zeigeSheet = false
                }) {
                    Text("Schließen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // Hauptfarbe
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onAppear {
                // Initialisiere den vorherigen Preis beim Öffnen des Sheets
                if vorherigerPreis == 0.0 {
                    vorherigerPreis = berechneGesamtpreis()
                }
            }
            .navigationTitle(kategorie.rawValue)
            .background(Color(.systemGray6)) // Hintergrundfarbe
        }
    }

    // Funktion zur Berechnung des Gesamtpreises
    func berechneGesamtpreis() -> Double {
        tisch.artikel.reduce(0) { sum, artikel in
            sum + (Double(artikel.anzahl) * artikel.preis)
        }
    }

    // Funktion zur Berechnung der Preisänderung
    func berechnePreisänderung() -> Double {
        berechneGesamtpreis() - vorherigerPreis
    }

    // Funktion zum Aktualisieren der Preisänderung
    func updatePreisÄnderung() {
        let neuerPreis = berechneGesamtpreis()
        vorherigerPreis = vorherigerPreis == 0.0 ? neuerPreis : vorherigerPreis
    }
}

// Vorschau
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
