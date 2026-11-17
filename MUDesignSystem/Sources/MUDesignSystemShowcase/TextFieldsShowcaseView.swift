import SwiftUI
import MUDesignSystem

struct TextFieldsShowcaseView: View {
    @State private var textInput: String = ""
    @State private var passwordInput: String = ""

    var body: some View {
        List {
            MUTextField(text: $textInput, placeholder: "Enter text", headerText: "Generic Text Field")
            MUPasswordField(password: $passwordInput, headerText: "Password Field")
        }
        .navigationTitle("Text Fields")
    }
}

#Preview {
    TextFieldsShowcaseView()
}