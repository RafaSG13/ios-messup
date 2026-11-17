import SwiftUI
import MUDesignSystem

struct SpacingShowcaseView: View {
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("size01 (2pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size01)
            }
            VStack(alignment: .leading) {
                Text("size02 (4pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size02)
            }
            VStack(alignment: .leading) {
                Text("size03 (8pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size03)
            }
            VStack(alignment: .leading) {
                Text("size04 (16pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size04)
            }
            VStack(alignment: .leading) {
                Text("size05 (20pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size05)
            }
            VStack(alignment: .leading) {
                Text("size06 (24pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size06)
            }
            VStack(alignment: .leading) {
                Text("size07 (32pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size07)
            }
            VStack(alignment: .leading) {
                Text("size08 (40pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size08)
            }
            VStack(alignment: .leading) {
                Text("size09 (48pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size09)
            }
            VStack(alignment: .leading) {
                Text("size10 (64pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size10)
            }
            VStack(alignment: .leading) {
                Text("size11 (80pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size11)
            }
            VStack(alignment: .leading) {
                Text("size12 (96pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size12)
            }
            VStack(alignment: .leading) {
                Text("size13 (112pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size13)
            }
            VStack(alignment: .leading) {
                Text("size14 (128pt)")
                Rectangle()
                    .fill(.blue)
                    .frame(height: MUDesignSystemSpacing.size14)
            }
        }
        .navigationTitle("Spacing")
    }
}

#Preview {
    SpacingShowcaseView()
}