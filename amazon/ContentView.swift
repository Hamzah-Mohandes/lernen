import SwiftUI
import SwiftData

// MARK: - 1. Datenmodell
@Model // Markiert die Klasse als SwiftData-Modell
class Notiz {
    var titel: String      // Titel der Notiz
    var text: String       // Text der Notiz
    var erstelltAm: Date   // Erstellungsdatum
    var istWichtig: Bool   // Wichtigkeitsstatus
    
    init(titel: String = "", text: String = "", istWichtig: Bool = false) {
        self.titel = titel
        self.text = text
        self.erstelltAm = Date()
        self.istWichtig = istWichtig
    }
}

// MARK: - 2. Hauptansicht
struct ContentView: View {
    // Zugriff auf gespeicherte Notizen
    @Query(sort: \Notiz.erstelltAm, order: .reverse) private var notizen: [Notiz]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNeueNotiz = false
    @State private var suchText = ""
    @State private var showingDebugInfo = false
    
    var body: some View {
        NavigationStack {
            List {
                // Debug-Sektion
                if showingDebugInfo {
                    Section("Debug Information") {
                        Text("Anzahl Notizen: \(notizen.count)")
                        Text("Wichtige Notizen: \(notizen.filter { $0.istWichtig }.count)")
                        
                        // Zeige Speicherort
                        Text("Datenbank Pfad:")
                            .font(.caption)
                        Text(URL.applicationSupportDirectory.path())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Normale Notizenliste
                ForEach(notizen) { notiz in
                    NavigationLink(destination: NotizDetailView(notiz: notiz)) {
                        NotizZeile(notiz: notiz)
                    }
                }
                .onDelete(perform: notizLöschen)
            }
            .navigationTitle("Meine Notizen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNeueNotiz.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { 
                        showingDebugInfo.toggle()
                        if showingDebugInfo {
                            druckeDatenbankInfo()
                            exportiereDaten()
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(showingDebugInfo ? .blue : .gray)
                    }
                }
            }
            .sheet(isPresented: $showingNeueNotiz) {
                NeueNotizView()
            }
        }
        .onAppear {
            druckeDatenbankInfo()
        }
        .preferredColorScheme(.dark)
    }
    
    private func notizLöschen(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notizen[index])
        }
    }
    
    // Debug-Funktionen
    private func druckeDatenbankInfo() {
        print("📊 Datenbank Status:")
        print("📁 Pfad:", URL.applicationSupportDirectory.path())
        print("📝 Anzahl Notizen:", notizen.count)
        
        for (index, notiz) in notizen.enumerated() {
            print("\(index + 1). \(notiz.titel) (\(notiz.erstelltAm.formatted()))")
        }
    }
    
    private func exportiereDaten() {
        let exportText = notizen.map { notiz in
            """
            Titel: \(notiz.titel)
            Text: \(notiz.text)
            Erstellt: \(notiz.erstelltAm.formatted())
            Wichtig: \(notiz.istWichtig ? "Ja" : "Nein")
            ----------------
            """
        }.joined(separator: "\n")
        
        print("📝 Exportierte Daten:\n\(exportText)")
    }
}

// MARK: - 3. Neue Notiz View
struct NeueNotizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var titel = ""
    @State private var text = ""
    @State private var istWichtig = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notiz Details") {
                    TextField("Titel", text: $titel)
                    TextField("Text", text: $text, axis: .vertical)
                        .lineLimit(5...10)
                    Toggle("Wichtig", isOn: $istWichtig)
                }
            }
            .navigationTitle("Neue Notiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        speichereNotiz()
                    }
                    .disabled(titel.isEmpty)
                }
            }
        }
    }
    
    private func speichereNotiz() {
        let neueNotiz = Notiz(titel: titel, text: text, istWichtig: istWichtig)
        modelContext.insert(neueNotiz)
        dismiss()
    }
}

// MARK: - 4. Notiz Detail View
struct NotizDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var notiz: Notiz
    
    var body: some View {
        Form {
            Section {
                TextField("Titel", text: $notiz.titel)
                TextField("Text", text: $notiz.text, axis: .vertical)
                    .lineLimit(5...10)
                Toggle("Wichtig", isOn: $notiz.istWichtig)
            }
            
            Section {
                Text("Erstellt am: \(notiz.erstelltAm.formatted())")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notiz bearbeiten")
    }
}

// MARK: - 5. Hilfsviews
struct NotizZeile: View {
    let notiz: Notiz
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(notiz.titel)
                    .font(.headline)
                Text(notiz.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if notiz.istWichtig {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}

// MARK: - 6. Preview
#Preview {
    ContentView()
        .modelContainer(for: Notiz.self, inMemory: true)
}
