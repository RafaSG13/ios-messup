//
//  MUTextField.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/6/25.
//

import SwiftUI

public struct MUTextField: View {
    @Binding var text: String
    var placeholder: String
    var headerText: String
    var autocapitalization: TextInputAutocapitalization = .never
    var textContentType: UITextContentType?

    public init(text: Binding<String>,
                placeholder: String,
                headerText: String,
                autocapitalization: TextInputAutocapitalization = .never,
                textContentType: UITextContentType? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.headerText = headerText
        self.autocapitalization = autocapitalization
        self.textContentType = textContentType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size02) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.designSystem.accent)
                .bold()
            TextField(placeholder, text: $text)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .textInputAutocapitalization(autocapitalization)
                .textContentType(textContentType)
        }
    }
}
