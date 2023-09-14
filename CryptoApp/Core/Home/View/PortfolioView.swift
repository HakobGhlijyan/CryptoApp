//
//  PortfolioView.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 08.08.2023.
//

import SwiftUI

struct PortfolioView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quentityText:String = ""
    @State private var showCheckmark:Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    coinLogoList
                    if selectedCoin != nil {
                        portfolioInputSelection
                    }
                }
            }
            .background(
                Color.theme.background
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trealingNavBarButton
                }
                ToolbarItem(placement: .principal) {
                    principalNavBarInfo
                }
            }
            .onChange(of: vm.searchText) { value in
                if value == "" {
                    removeSelectionCoin()
                }
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}

extension PortfolioView {
    
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(
                                    selectedCoin?.id == coin.id ? Color.theme.green : Color.clear,
                                    lineWidth: 1)
                        )
                        .onTapGesture {
                            updadeSelectedCoin(coin: coin)
                        }
                }
            }
            .frame(height: 120)
            .padding(.leading)
        }
    }
    
    private func updadeSelectedCoin(coin: CoinModel) {
        selectedCoin = coin
        
        //check coin is In portfolioarray? - $0.id == coin.id , and check amount = currentHoldings..
        if let portfolioCoin = vm.portfolioCoins.first(where: { $0.id == coin.id }),
           let amount = portfolioCoin.currentHoldings {
            quentityText = "\(amount)"
           } else {
             quentityText = ""
           }
    }
    
    private var portfolioInputSelection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Current prise of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            Divider()
            HStack {
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4", text: $quentityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
            Divider()
            HStack {
                Text("Current value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
        }
        .padding()
        .font(.headline)
    }
    
    // FUNC Current value
    private func getCurrentValue() -> Double {
        if let quantity = Double(quentityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    private var principalNavBarInfo: some View {
        HStack(spacing: 10.0) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1 : 0)
            Text("Change Saved!!")
                .opacity(showCheckmark ? 1 : 0)
        }
        .foregroundColor(.theme.green)
        .font(.headline)
    }
    
    private var trealingNavBarButton : some View {
        HStack {
            Button {
                saveButtonPressed()
            } label: {
                Text("Save".uppercased())
            }
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quentityText) ? 1 : 0) )
        }
        .font(.headline)
    }
    
    // FUNC Check Button Save
    private func saveButtonPressed() {
        
        guard
            let coin = selectedCoin,
            let amount = Double(quentityText)
        else { return }
        
        // save to portfolio
        // Add coin - and add quentityText
        vm.updatePortfolio(coin: coin, amount: amount)
        
        // show checkmark
        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectionCoin()
        }
        // Dismiss Keyboard
        UIApplication.shared.endEditing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeIn) {
                showCheckmark = false
            }
        }
    }
    
    private func removeSelectionCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
}
