//
//  CoinRowView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 01.08.2023.
//

import SwiftUI

struct CoinRowView: View {
    
    let coin: CoinModel
    let showHoldingsColumn: Bool
    
    var body: some View {
        HStack(spacing: 0.0) {
            // MARK: - LEFT
            leftColumn
            Spacer()
            // MARK: - CENTRE
            if showHoldingsColumn {
                centerColumn
            }
            // MARK: - RIGTH
            rigthColumn
        }
        .font(.subheadline)
        .background(
            Color.theme.background.opacity(0.001)
        )
    }
}

extension CoinRowView {
    
    // MARK: - LEFT
    private var leftColumn: some View {
        HStack(spacing: 0.0) {
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .frame(minWidth: 30)
            CoinImageView(coin: coin)
                .frame(width: 30, height: 30)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(.leading, 6)
                .foregroundColor(Color.theme.accent)
        }
    }
    // MARK: - CENTRE
    private var centerColumn: some View {
        VStack(alignment: .trailing) {
            Text(coin.currentHoldingsValue.asCurrencyWith2Decimals())
                .bold()
            Text((coin.currentHoldings ?? 0).asNumberString())
        }
        .foregroundColor(Color.theme.accent)
    }
    // MARK: - RIGTH
    private var rigthColumn: some View {
        VStack(alignment: .trailing) {
            Text("\(coin.currentPrice.asCurrencyWith6Decimals())$")
                .bold()
                .foregroundColor(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentString() ?? "")
                .foregroundColor(
                    (coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red
                )
        }
        .frame(width: UIScreen.main.bounds.width / 3.5 , alignment: .trailing)
    }
    
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        CoinRowView(coin: dev.coin, showHoldingsColumn: true)
    }
}
