//
//  DrawerOptionButton.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

struct DrawerOptionButton: View {
    var text: String
    var icon: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground).opacity(0.5))
            HStack{
                Text(text)
                    .font(.title3)
                    .padding()
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
            }
            .bold()
        }
        .frame(maxHeight: 50)
        .padding(.horizontal)
    }
}
