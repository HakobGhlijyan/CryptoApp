//
//  CoinImageService.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 04.08.2023.
//

import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image:UIImage? = nil
    
    private var imageCoinSubscription: AnyCancellable?
    private let coin: CoinModel
    
    private let fileManager = LocalFileManager.instance
    
    private let folderName = "coin_images_folder"
    private let imageName:String
    
    init(coin: CoinModel) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = fileManager.getImage(imageName: coin.id, folderName: folderName) {
            image = savedImage
            print("Image load from FileManager")
        } else {
            downloadCoinImage()
            print("Image download now")
        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageCoinSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedImage) in
                guard let self = self , let downloadImage = returnedImage else { return }
                self.image = downloadImage
                self.imageCoinSubscription?.cancel()
                self.fileManager.saveImage(image: downloadImage, imageName: self.imageName, folderName: self.folderName)
                
            })
    }
}
