//
//  HomeView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 01.08.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio:Bool = false
    @State private var showPortfolioView:Bool = false
    
    //for seque
    @State private var selectedCoin:CoinModel? = nil
    @State private var showDetailView:Bool = false
    
    //Setting
    @State private var showSettingsView:Bool = false

    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            VStack {
                homeHeader
                HomeStateView(showPortfolio: $showPortfolio)
                SearchBarView(searchText: $vm.searchText)
                columnTitle
                if !showPortfolio {
                    allCoinList
                        .transition(.move(edge: .leading))
                        .refreshable {
                            vm.reloadData()
                        }
                }
                if showPortfolio {
                    ZStack(alignment: .top) {
                        if vm.portfolioCoins.isEmpty && vm.searchText.isEmpty {
                            portfolioEmptyText
                        } else {
                            portfolioCoinList
                        }
                    }
                    .transition(.move(edge: .trailing))
                    .refreshable {
                        vm.reloadData()
                    }
                }
                Spacer(minLength: 0)
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
        .background(
            NavigationLink(
                destination: DetailLoadingView(coin: $selectedCoin),
                isActive: $showDetailView,
                label: {
                    EmptyView()
                })
        )
    }
}

extension HomeView {
    
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none,value: showPortfolio)
                .onTapGesture {
                    if showPortfolio {
                        showPortfolioView.toggle()
                    } else {
                        showSettingsView.toggle()
                    }
                }
                .background(CircleButtonAnimationView(animate: $showPortfolio))
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(.degrees(showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    //Func Tap Seque ->to detail view
    private func sequeToDetail(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
    
    private var allCoinList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 8))
                    .onTapGesture {
                        sequeToDetail(coin: coin)
                    }
                    .listRowBackground(Color.theme.background)
            }
        }
        .listStyle(.inset)
        //Transition left button pushed shevron
    }
    
    private var portfolioCoinList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 8))
                    .onTapGesture {
                        sequeToDetail(coin: coin)
                    }
                    .listRowBackground(Color.theme.background)
            }
        }
        .listStyle(.inset)
        //Transition left button pushed shevron
    }
    
    private var portfolioEmptyText: some View {
        Text("You haven't added any coins to your portfolio yet. Click the + button to get started! 😫")
            .font(.callout)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.accent)
            .multilineTextAlignment(.center)
            .padding(50)
    }
    
    private var columnTitle: some View {
        HStack {
            HStack(spacing: 4.0) {
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1 : 0)
                    .rotationEffect(.degrees(vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
            Spacer()
            if showPortfolio {
                HStack(spacing: 4.0) {
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortOption == .holding || vm.sortOption == .holdingReversed) ? 1 : 0)
                        .rotationEffect(.degrees(vm.sortOption == .holding ? 0 : 180))

                }
                .onTapGesture {
                    withAnimation(.default) {
                        vm.sortOption = vm.sortOption == .holding ? .holdingReversed : .holding
                    }
                }
            }
            HStack(spacing: 4.0) {
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1 : 0)
                    .rotationEffect(.degrees(vm.sortOption == .price ? 0 : 180))

            }
            .frame(width: UIScreen.main.bounds.width / 3.5 , alignment: .trailing)
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                }
            }
            
            Button {
                withAnimation(.linear(duration: 2.0)) {
                    vm.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
            }
            .rotationEffect(.degrees(vm.isLoading ? 360 : 0), anchor: .center)

        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}
