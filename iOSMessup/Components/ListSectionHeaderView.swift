//
//  Untitled.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

struct ListSectionHeaderView: View {
    var sectionTitle: String
    var destination: AnyView
    var body: some View {
        HStack {
            Text("Transactions")
                .font(.title2)
                .bold()
            Spacer()
            NavigationLink(destination: destination) {
                Text("View all")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
