//
//  Uiapplication+Extension.swift
//  LocalMind
//
//  Created by Arkadiy KAZAZYAN on 28/10/2025.
//

#if canImport(UIKit)
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
