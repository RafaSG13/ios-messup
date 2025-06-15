//
//  DepositCellvView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

struct DepositCellView: View {
    var deposit: Deposit

    private enum ViewTraits {
        static let imageSize: CGFloat = 40
        static let imageInternalPadding: CGFloat = 5
        static let generalPadding: CGFloat = 10
        static let backgroundColor: Color = .secondary.opacity(0.15)
        static let cornerRadius: CGFloat = 10
        static let generalSpacing: CGFloat = 10
        static let cellHeight: CGFloat = 70
    }

    var body: some View {
        HStack(spacing: ViewTraits.generalPadding) {
            Image(systemName: deposit.foundingSource.icon)
                .resizable()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .scaledToFill()
                .padding(ViewTraits.imageInternalPadding)
                .background(deposit.foundingSource.color)
                .foregroundColor(.white)
                .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))

            VStack(alignment: .leading) {
                Text(deposit.concept)
                    .bold()
                    .font(.headline)
                Text(deposit.foundingSource.rawValue)
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(deposit.amount.toMoneyString())
                    .bold()
                    .foregroundStyle(.green)
                Text(deposit.date.formatted())
                    .font(.caption)
            }
        }
        .padding(ViewTraits.generalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: ViewTraits.cellHeight)
        .background(ViewTraits.backgroundColor)
        .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))
    }
}

//MARK: - Previews

#Preview {
    DepositCellView(deposit: Deposit.mock)
}

//MARK: - DepositCellView + SelectableCell

extension DepositCellView {
    func selectableCell(_ onTap: @escaping () -> Void) -> some View {
        self.modifier(SelectableCell(onTap: onTap))
    }
}
