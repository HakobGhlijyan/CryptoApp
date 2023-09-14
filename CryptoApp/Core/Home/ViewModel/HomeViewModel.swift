//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 02.08.2023.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
 
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var statistics: [StatisticModel] = []
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading:Bool = false
    @Published var searchText: String = ""
    
    @Published var sortOption: SortOption = .holding
    
    //ENUM SORTING
    enum SortOption {
        case rank
        case rankReversed
        case holding
        case holdingReversed
        case price
        case priceReversed
    }
 
    init() {
        addSubscribers()
    }
    
    // THIS ALL UPDATE ALL PARAMENTS - PUBLISHER AND SUNBSCRIBER
    func addSubscribers() {
        //1 UPDATE ALL COINS
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
//            .map(filterCoin)                                                                  // no sort
            .map(filterAndSortCoins)                                                            // Add sort - filter 4 type is price view
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        //2 UPDATE COIN IS COREDATA
        $allCoins
            .combineLatest(portfolioDataService.$savedEntitityes)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] (returnedCoins) in
                // guard and make is return sorted needed arrat
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)     // Add sort - filter 2 type is portfolio view
            }
            .store(in: &cancellables)
        
        //3 UPDATE MARKETDATA
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] (returnedStates) in
                self?.statistics = returnedStates
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    // UPDATE PORTFOLIO
    func updatePortfolio(coin:CoinModel, amount:Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    // RELOAD DATA
    func reloadData() {
        // start loading , getCoins and getData, and update publisher 1 - 2 - 3 , and after 3 make isloading false
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        // Vibration Haptic
        HapticManager.notification(type: .success)
    }
    
    // for UPDATE ALL COINS - 1. Filter
    private func filterCoin(text:String, coin: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coin
        }
        let lowercasedText = text.lowercased()
        return coin.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    // for UPDATE ALL COINS - 2. Filter
    private func filterAndSortCoins(text:String, coin: [CoinModel], sort:SortOption) -> [CoinModel] {
        var updatedCoins = filterCoin(text: text, coin: coin)
        //sort
       sortCoins(sort: sort, coins: &updatedCoins)
        // return
        return updatedCoins
    }
 
    //SORT by Type
    // 1 this sort only prise view - holding not
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .rank,.holding:
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed,.holdingReversed:
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        }
    }
    
    // 2 this sort portfoli view - holding
    private func sortPortfolioCoinsIfNeeded(coins:[CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holding:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default:
            return coins
        }
    }
    
    
    // for UPDATE COIN IS COREDATA
    private func mapAllCoinsToPortfolioCoins(allCoins:[CoinModel], portfolioEntities:[PortfolioEntity]) -> [CoinModel] {
        allCoins
            .compactMap { (coin) -> CoinModel? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    // for UPDATE MARKETDATA
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoin: [CoinModel]) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        guard let data = marketDataModel else {
            return stats
        }
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        // Value - All Coin Sum
        let portfolioValue =
            portfolioCoin
            .map({ $0.currentHoldingsValue })                                               // this is transform Array Double All number
            .reduce(0, +)                                                                   // this is Sum All Number in one , and return ONE DOUBLE
        
        // PercentageChange - All Coin Sum
        let portfolioPercent =
            portfolioCoin
            .map { (coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = coin.priceChangePercentage24H ?? 0 / 100
                let previousValue = currentValue * ( 1 + percentChange )
                return previousValue                                                        // this is transform Array Percent Double All number
            }
            .reduce(0, +)                                                                   // this is Sum All Number in one , and return ONE DOUBLE
        
//        let percentageChange = ((portfolioValue - portfolioPercent) / portfolioPercent) * 100 - false
        let percentageChange = ((portfolioValue - portfolioPercent) / portfolioPercent) // ok
        
        let portfolio = StatisticModel(
            title: "Portfolio Value",
            value: portfolioValue.asCurrencyWith2Decimals(),                                // Number - 0.00 type
            percentageChange: percentageChange)
 
        stats.append(contentsOf: [marketCap,volume,btcDominance,portfolio])
        return stats
    }
 
}
