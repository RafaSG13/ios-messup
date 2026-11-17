import SwiftUI
import MUDesignSystem

struct LoadingHudShowcaseView: View {
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Button("Toggle Loading HUD") {
                isLoading.toggle()
            }
            .padding()

            Text("This is some content behind the loading HUD.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
        }
        .navigationTitle("Loading HUD")
        .loadingHUD(isLoading: isLoading)
    }
}

#Preview {
    LoadingHudShowcaseView()
}