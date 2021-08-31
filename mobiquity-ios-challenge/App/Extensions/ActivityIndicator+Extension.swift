//
//  ActivityIndicator+Extension.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import UIKit

extension UIActivityIndicatorView {
    func performAnimation(_ perform: Bool) {
        if perform {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
}
