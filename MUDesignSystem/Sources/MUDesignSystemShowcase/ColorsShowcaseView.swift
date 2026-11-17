import SwiftUI
import MUDesignSystem

struct ColorsShowcaseView: View {
    var body: some View {
        List {
            Text("Dark Green")
                .listRowBackground(MUDesignSystemColors.darkGreen)
                .foregroundColor(.white)
            Text("Generic Background")
                .listRowBackground(MUDesignSystemColors.genericBackground)
            Text("Mint Accent")
                .listRowBackground(MUDesignSystemColors.mintAccent)
            Text("Accent (alias for Mint Accent)")
                .listRowBackground(MUDesignSystemColors.accent)
        }
        .navigationTitle("Colors")
    }
}

#Preview {
    ColorsShowcaseView()
}