import SwiftUI

struct HomeView: View {
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack {
            Text("Willkommen im Home-Bereich!")
                .font(.largeTitle)
                .padding()

            Button(action: {
                isImagePickerPresented.toggle() // ImagePicker anzeigen
            }) {
                Text("Foto aufnehmen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Zeige das aufgenommene Bild an, falls vorhanden
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(isPresented: $isImagePickerPresented, image: $selectedImage) // ImagePicker verwenden
        }
    }
}

#Preview {
    HomeView()
}