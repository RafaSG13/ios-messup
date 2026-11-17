import SwiftUI
import MUDesignSystem

struct ProgressIndicatorsShowcaseView: View {
    @State private var progressValue: CGFloat = 0.5

    var body: some View {
        List {
            VStack {
                Text("Circular Saving Progress View")
                CircularSavingProgressView(progress: progressValue, lineWidth: 15, progressColor: .green, backgroundColor: .gray.opacity(0.3)) {
                    VStack {
                        Text("\(Int(progressValue * 100))%")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.green)
                        Text("Progress")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 150, height: 150)
            }
            .padding()

            VStack(alignment: .leading) {
                Text("Progress Bar")
                ProgressBar(progress: progressValue, barColor: LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing), progressColor: LinearGradient(colors: [.blue], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 20)
            }
            .padding()

            Slider(value: $progressValue, in: 0...1) {
                Text("Progress Value")
            } minimumValueLabel: {
                Text("0%")
            } maximumValueLabel: {
                Text("100%")
            }
        }
        .navigationTitle("Progress Indicators")
    }
}

#Preview {
    ProgressIndicatorsShowcaseView()
}