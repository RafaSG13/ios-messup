import SwiftUI
import MUDesignSystem

struct SelectableCellShowcaseView: View {
    @State private var selectionCount: Int = 0

    var body: some View {
        List {
            SelectableCell {
                selectionCount += 1
            } label: {
                Text("Tap me! (Taps: \(selectionCount))")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, MUDesignSystemSpacing.size02)

            SelectableCell {
                print("Tapped another cell")
            } label: {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("Another tappable cell")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, MUDesignSystemSpacing.size02)
        }
        .navigationTitle("Selectable Cell")
    }
}

#Preview {
    SelectableCellShowcaseView()
}