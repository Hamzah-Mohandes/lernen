import SwiftUI

// 1. Struktur für unsere Einkaufsitems
struct EinkaufsItem: Identifiable {
    let id = UUID()
    var name: String
    var menge: Int
    var erledigt: Bool
}

struct ContentView: View {
    // 2. State Variablen
    @State private var einkaufsliste: [EinkaufsItem] = [
        EinkaufsItem(name: "Äpfel", menge: 5, erledigt: false),
        EinkaufsItem(name: "Brot", menge: 1, erledigt: false),
        EinkaufsItem(name: "Milch", menge: 2, erledigt: false)
    ]
    
    @State private var neuesItem: String = ""
    @State private var neueMenge: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // 3. Eingabebereich
                HStack {
                    TextField("Neues Item", text: $neuesItem)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Menge", text: $neueMenge)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .keyboardType(.numberPad)
                    
                    Button(action: hinzufügenItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                    }
                }
                .padding()
                
                // 4. Liste der Items
                List {
                    ForEach(einkaufsliste) { item in
                        HStack {
                            // Checkbox
                            Image(systemName: item.erledigt ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.erledigt ? .green : .gray)
                                .onTapGesture {
                                    toggleErledigt(item)
                                }
                            
                            // Item Details
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .strikethrough(item.erledigt)
                                Text("\(item.menge) Stück")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    // 5. Löschfunktion
                    .onDelete(perform: löscheItems)
                }
            }
            .navigationTitle("Einkaufsliste")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: alleItemsLöschen) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    // 6. Funktionen für Array-Operationen
    func hinzufügenItem() {
        guard !neuesItem.isEmpty,
              let anzahl = Int(neueMenge),
              anzahl > 0 else { return }
        
        let item = EinkaufsItem(name: neuesItem, menge: anzahl, erledigt: false)
        einkaufsliste.append(item)
        
        // Eingabefelder zurücksetzen
        neuesItem = ""
        neueMenge = ""
    }
    
    func toggleErledigt(_ item: EinkaufsItem) {
        if let index = einkaufsliste.firstIndex(where: { $0.id == item.id }) {
            einkaufsliste[index].erledigt.toggle()
        }
    }
    
    func löscheItems(at offsets: IndexSet) {
        einkaufsliste.remove(atOffsets: offsets)
    }
    
    func alleItemsLöschen() {
        einkaufsliste.removeAll()
    }
}

#Preview {
    ContentView()
}

//warum Array sind wichtig ? weill viel kleine App und Grösse app schreiben wir mit Array oder Collection :) wie das -> 
