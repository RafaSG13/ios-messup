//
//  TotalBalanceCardView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct TotalBalanceCardView: View {
    let gradient = LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Total Balance")
                     .font(.title2)
                 Text("€ 1.000.000")
                     .font(.largeTitle)
                     .bold()
            }
            HStack {
                Text("5222  2654  8977  7655")
                    .font(.title2)
                Spacer()
                Image("logoMastercard")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 30)
            }
        }
        .padding()
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.85))
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    TotalBalanceCardView()
}
