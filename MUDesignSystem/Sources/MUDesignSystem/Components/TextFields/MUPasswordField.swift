//
//  MUPasswordField.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/6/25.
//

import SwiftUI

public struct MUPasswordField: View {
    @Binding var password: String
    var headerText: String

    public init(password: Binding<String>, headerText: String) {
        self._password = password
        self.headerText = headerText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size02) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.designSystem.accent)
                .bold()
            SecureField("Password", text: $password)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .textContentType(.password)
        }
    }
}
