//
//  LocalFileManager.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 06.08.2023.
//

import SwiftUI

class LocalFileManager {
    
    static let instance = LocalFileManager()
    private init() {}
    
    //MARK: - SAVE IMAGE
    func saveImage(image: UIImage, imageName:String, folderName:String) {
        
        //1 create folder
        createFolderIfNeeded(folderName: folderName)
        
        //2 get path for image
        guard
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
        else { return }
        
        //3 Write - save image to path
        do {
            try data.write(to: url)
        } catch let error {
            print("Error saving image. Image: \(imageName) , Error: \(error.localizedDescription)")
        }
    }
    
    //MARK: - GET IMAGE
    func getImage(imageName:String, folderName:String) -> UIImage? {
        guard
        let url = getURLForImage(imageName: imageName, folderName: folderName),
        FileManager.default.fileExists(atPath: url.path())
        else {
            return nil
        }
        return UIImage(contentsOfFile: url.path())
    }
    
    //MARK: - CREATE FOLDER
    private func createFolderIfNeeded(folderName: String) {
        
        guard let url = getURLForFolder(folderName: folderName) else { return }
        
        if !FileManager.default.fileExists(atPath: url.path()) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch let error {
                print("Error create folder. Folder: \(folderName) , Error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - GET URL FOLDER
    private func getURLForFolder(folderName: String) -> URL? {
        
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        return url.appendingPathComponent(folderName)
    }
    
    //MARK: - GET URL Image
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        
        guard let folderURL = getURLForFolder(folderName: folderName) else { return nil }
        
        return folderURL.appendingPathComponent(imageName + ".png")
    }
 
}

// UNIVERSAL FILE MANAGER //
