//
//  UIApplication.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 07.08.2023.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
