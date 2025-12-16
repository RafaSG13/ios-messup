//
//  MUTextField.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/6/25.
//

import SwiftUI

struct MUTextField: View {
    @Binding var text: String
    var placeholder: String
    var headerText: String
    var autocapitalization: UITextAutocapitalizationType = .none
    var textContentType: UITextContentType?

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size02) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.accent)
                .bold()
            TextField(placeholder, text: $text)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .autocapitalization(autocapitalization)
                .textContentType(textContentType)
        }
    }
}
