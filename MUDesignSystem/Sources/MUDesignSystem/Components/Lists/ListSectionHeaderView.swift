import SwiftUI

public struct ListSectionHeaderView: View {
    var sectionTitle: String
    var destination: AnyView?

    public init(sectionTitle: String, destination: AnyView? = nil) {
        self.sectionTitle = sectionTitle
        self.destination = destination
    }

    public var body: some View {
        HStack {
            Text(sectionTitle)
                .font(.title2)
                .bold()
            Spacer()
            if let destination {
                NavigationLink(destination: destination) {
                    Text("View all")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
