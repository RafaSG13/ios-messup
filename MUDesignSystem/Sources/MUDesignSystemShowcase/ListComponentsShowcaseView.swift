import SwiftUI
import MUDesignSystem

struct ListComponentsShowcaseView: View {
    @State private var mockItems: [ShowcaseItem] = [
        ShowcaseItem(id: UUID(), name: "Item 1"),
        ShowcaseItem(id: UUID(), name: "Item 2"),
        ShowcaseItem(id: UUID(), name: "Item 3")
    ]
    @State private var selectedItem: ShowcaseItem?

    var body: some View {
        List {
            ListSectionHeaderView(sectionTitle: "Section Header", destination: AnyView(Text("Section Detail View")))
                .padding(.vertical)

            Section("Custom Vertical For Each") {
                MUCustomVerticalForEach(items: $mockItems, selection: $selectedItem) { item in
                    Text(item.name)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                } onDelete: { item, indexSet in
                    mockItems.remove(atOffsets: indexSet)
                }
                .onChange(of: selectedItem) { _, newValue in
                    if let selected = newValue {
                        print("Selected item: \(selected.name)")
                    }
                }
            }
        }
        .navigationTitle("List Components")
    }
}


#Preview {
    ListComponentsShowcaseView()
}