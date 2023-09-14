//
//  CoinDataService.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 03.08.2023.
//

import Foundation
import Combine

class CoinDataService {
    
    @Published var allCoins:[CoinModel] = []
    var coinSubscription: AnyCancellable?
    
    init() {
//        getCoins()
        getCoinsLocalJSON()
    }
    
    //MARK: - 1
    func getCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        else { return }
        
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoin) in
                self?.allCoins = returnedCoin
                self?.coinSubscription?.cancel()
            })
    }
    
    //MARK: - 2
    private func getCoinsLocalJSON() {
        
        guard let url = Bundle.main.url(forResource: "CoinDataService", withExtension: "json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard
                let newData = data,
                let coinData = try? JSONDecoder().decode([CoinModel].self, from: newData) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.allCoins = coinData
            }
        }
        .resume()
    }
}
