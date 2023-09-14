//
//  StatisticView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 07.08.2023.
//

import SwiftUI

struct StatisticView: View {
    
    let stat: StatisticModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(stat.title)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
            Text(stat.value)
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            HStack(spacing: 4.0) {
                Image(systemName: "triangle.fill")
                    .font(.caption2)
                    .rotationEffect(
                        Angle(degrees:
                                (stat.percentageChange ?? 0) >= 0 ? 0 : 180 )
                    )
                    .foregroundColor(
                        (stat.percentageChange ?? 0) >= 0 ? Color.theme.green : Color.theme.red
                    )
                Text(stat.percentageChange?.asPercentString() ?? "")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                .bold()
            }
            .opacity(stat.percentageChange == nil ? 0.0 : 1.0)
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            StatisticView(stat: dev.state1)
            StatisticView(stat: dev.state2)
            StatisticView(stat: dev.state3)
        }
    }
}
