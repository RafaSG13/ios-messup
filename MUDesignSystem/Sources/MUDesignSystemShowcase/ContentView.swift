import SwiftUI
import MUDesignSystem

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Design Tokens") {
                    NavigationLink("Colors") {
                        ColorsShowcaseView()
                    }
                    NavigationLink("Spacing") {
                        SpacingShowcaseView()
                    }
                }
                Section("Components") {
                    NavigationLink("Text Fields") {
                        TextFieldsShowcaseView()
                    }
                    NavigationLink("Progress Indicators") {
                        ProgressIndicatorsShowcaseView()
                    }
                    NavigationLink("List Components") {
                        ListComponentsShowcaseView()
                    }
                }
                Section("View Modifiers") {
                    NavigationLink("Loading HUD") {
                        LoadingHudShowcaseView()
                    }
                    NavigationLink("Selectable Cell") {
                        SelectableCellShowcaseView()
                    }
                }
            }
            .navigationTitle("MUDesignSystem Showcase")
        }
    }
}

#Preview {
    ContentView()
}