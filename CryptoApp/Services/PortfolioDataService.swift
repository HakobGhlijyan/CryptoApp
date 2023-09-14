//
//  PortfolioDataService.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 10.08.2023.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let container: NSPersistentContainer
    
    private let containerName:String = "PortfolioContainer"
    private let entityName:String = "PortfolioEntity"
    
    @Published var savedEntitityes:[PortfolioEntity] = []
    
    //MARK: - Init
    init() {
        //make container
        container = NSPersistentContainer(name: containerName)
        //load container
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data : \(error.localizedDescription)")
            }
            //ADD Get class initialisation
            self.get()
        }
    }
    
    //MARK: PUBLIC FUNCS
    func updatePortfolio(coin:CoinModel, amount:Double) {
        // Check if coin is allready in portfolio -----  ID - coinID == coin.id
        if let entity = savedEntitityes.first(where: { $0.coinID == coin.id }) {
            //check amount , is cheked type added func
            if amount > 0 {
                // call func update
                update(entity: entity, amount: amount)
            } else {
                // call func delete - if 0 add , is delete
                delete(entity: entity)
            }
        } else {
            // call add , not amount type
            add(coin: coin, amount: amount)
        }
    }
    
    
    //MARK: PRIVATE FUNCS
    //MARK: - get Fetchrequest
    private func get() {
        // fetch request
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        //do catch - fetch in ViewContext
        do {
            savedEntitityes = try container.viewContext.fetch(request)
        } catch let error {
            print("Error Load Fetch request : \(error.localizedDescription)")
        }
    }
    
    //MARK: - ADD
    /*
     In fun add item CoinModel - and change type in PortfolioEntity , and new amount
     */
    private func add(coin:CoinModel, amount:Double) {
        //Entity
        let entity = PortfolioEntity(context: container.viewContext)
        //add Paramets
        entity.coinID = coin.id
        entity.amount = amount
        //After add coin , apply change
        applyChanges()
        
    }
    
    //MARK: - Update
    private func update(entity:PortfolioEntity, amount:Double) {
        entity.amount = amount
        applyChanges()
    }
    
    //MARK: - Delete
    private func delete(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    //MARK: - SAVE
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Save Error : \(error.localizedDescription)")
        }
    }
    
    //MARK: - ADD
    private func applyChanges() {
        save()
        get()
    }
    
}
