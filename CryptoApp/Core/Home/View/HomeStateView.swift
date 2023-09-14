//
//  HomeStateView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 07.08.2023.
//

import SwiftUI

struct HomeStateView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(vm.statistics) { stat in
                StatisticView(stat: stat)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width: UIScreen.main.bounds.width,
               alignment: showPortfolio ? .trailing : .leading )
        
    }
}

struct HomeStateView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStateView(showPortfolio: .constant(false))
            .environmentObject(dev.homeVM)
    }
}
