//
//  Untitled.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

struct ListSectionHeaderView: View {
    var sectionTitle: String
    var route: Route
    var body: some View {
        HStack {
            Text(sectionTitle)
                .font(.title2)
                .bold()
            Spacer()
            NavigationLink(destination: route.destination) {
                Text("View all")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
