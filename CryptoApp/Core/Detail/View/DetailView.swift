//
//  DetailView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 28.08.2023.
//

import SwiftUI

struct DetailLoadingView: View {
    
    @Binding var coin: CoinModel?

    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    
    @StateObject private var vm: DetailViewModel
    private var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let spacing: CGFloat = 30
    
    @State private var showDescription: Bool = false
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            //1
            ChartView(coin: vm.coin)
                .padding(.vertical)
            //2
            VStack(spacing: 20.0) {
                overviewTitle
                Divider()
                descriptionSection
                Divider()
                overviewGrid
                additionalTitle
                Divider()
                additionalGrid
                Divider()
                websiteSection
            }
            .padding()
        }
        .background(
            Color.theme.background
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(vm.coin.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                navigationBarTrailingItems
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(coin: dev.coin)
        }
    }
}

extension DetailView {
    
    private var navigationBarTrailingItems: some View {
        HStack {
            Text(vm.coin.symbol.uppercased())
                .font(.headline)
            .foregroundColor(Color.theme.secondaryText)
            CoinImageView(coin: vm.coin)
                .frame(width: 30, height: 30)
        }
    }
    
    private var overviewTitle: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var additionalTitle: some View {
        Text("Additional Details")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var overviewGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.overviewStatistics) { overviewStatistics in
                    StatisticView(stat: overviewStatistics)
                }
            })
    }
    private var additionalGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.additionalStatistics) { additionalStatistics in
                    StatisticView(stat: additionalStatistics)
                }
            })
    }
    
    private var descriptionSection: some View {
        ZStack {
            if let coinDescription = vm.coinDescription, !coinDescription.isEmpty {
                VStack(alignment: .leading) {
                    Text(coinDescription)
                        .lineLimit(showDescription ? nil : 3)
                        .font(.callout)
                        .foregroundColor(.theme.secondaryText)
                    Button {
                        withAnimation(.easeInOut) {
                            showDescription.toggle()
                        }
                    } label: {
                        Text(showDescription ? "Less" : "Read more...")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                    }
                    .accentColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var websiteSection: some View {
        HStack {
            Spacer()
            if let websiteString = vm.websiteURL , let url = URL(string: websiteString) {
                Link("Website", destination: url)
            }
            Spacer()
            if let redditString = vm.redditURL , let url = URL(string: redditString) {
                Link("Reddit", destination: url)
            }
            Spacer()
        }
        .accentColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.headline)
    }
}
