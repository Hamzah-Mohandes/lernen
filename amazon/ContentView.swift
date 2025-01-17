import SwiftUI
import SwiftData

// MARK: - Datenmodell
@Model
class Aufgabe {
    var titel: String
    var beschreibung: String
    var istErledigt: Bool
    var priorität: Priorität
    var erstelltAm: Date
    
    enum Priorität: Int, Codable {
        case niedrig, mittel, hoch
        
        var symbol: String {
            switch self {
            case .niedrig: "⭐️"
            case .mittel: "⭐️⭐️"
            case .hoch: "⭐️⭐️⭐️"
            }
        }
    }
    
    init(titel: String = "", beschreibung: String = "", priorität: Priorität = .mittel) {
        self.titel = titel
        self.beschreibung = beschreibung
        self.istErledigt = false
        self.priorität = priorität
        self.erstelltAm = Date()
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Query(sort: \Aufgabe.erstelltAm, order: .reverse) private var aufgaben: [Aufgabe]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNeueAufgabe = false
    @State private var neuerTitel = ""
    @State private var neueBeschreibung = ""
    @State private var neuePriorität = Aufgabe.Priorität.mittel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(aufgaben) { aufgabe in
                    HStack {
                        // Checkbox
                        Image(systemName: aufgabe.istErledigt ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(aufgabe.istErledigt ? .green : .gray)
                            .onTapGesture {
                                aufgabe.istErledigt.toggle()
                            }
                        
                        VStack(alignment: .leading) {
                            Text(aufgabe.titel)
                                .font(.headline)
                                .strikethrough(aufgabe.istErledigt)
                            
                            if !aufgabe.beschreibung.isEmpty {
                                Text(aufgabe.beschreibung)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(aufgabe.priorität.symbol)
                    }
                }
                .onDelete(perform: löscheAufgaben)
            }
            .navigationTitle("Meine Aufgaben")
            .toolbar {
                Button(action: { showingNeueAufgabe.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .sheet(isPresented: $showingNeueAufgabe) {
                NavigationStack {
                    Form {
                        TextField("Titel", text: $neuerTitel)
                        TextField("Beschreibung", text: $neueBeschreibung, axis: .vertical)
                            .lineLimit(3...6)
                        
                        Picker("Priorität", selection: $neuePriorität) {
                            Text("Niedrig").tag(Aufgabe.Priorität.niedrig)
                            Text("Mittel").tag(Aufgabe.Priorität.mittel)
                            Text("Hoch").tag(Aufgabe.Priorität.hoch)
                        }
                    }
                    .navigationTitle("Neue Aufgabe")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Abbrechen") {
                                showingNeueAufgabe = false
                                resetForm()
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Speichern") {
                                speichereAufgabe()
                            }
                            .disabled(neuerTitel.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Hilfsfunktionen
    private func speichereAufgabe() {
        let aufgabe = Aufgabe(
            titel: neuerTitel,
            beschreibung: neueBeschreibung,
            priorität: neuePriorität
        )
        modelContext.insert(aufgabe)
        showingNeueAufgabe = false
        resetForm()
    }
    
    private func löscheAufgaben(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(aufgaben[index])
        }
    }
    
    private func resetForm() {
        neuerTitel = ""
        neueBeschreibung = ""
        neuePriorität = .mittel
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Aufgabe.self, inMemory: true)
}
