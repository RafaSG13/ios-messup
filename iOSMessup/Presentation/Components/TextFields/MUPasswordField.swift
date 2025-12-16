//
//  MUPasswordField.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/6/25.
//

import SwiftUI

struct MUPasswordField: View {
    @Binding var password: String
    var headerText: String

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size02) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.accent)
                .bold()
            SecureField("Password", text: $password)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .textContentType(.password)
        }
    }
}
