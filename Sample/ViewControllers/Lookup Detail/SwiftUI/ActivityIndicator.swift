//
//  ActivityIndicator.swift
//  Sample
//
//  Created by user2o on 19.03.21.
//
// [SOURCE](https://programmingwithswift.com/swiftui-activity-indicator/)

import SwiftUI

/// A SwiftUI wrapper for a simple UIActivityIndicator.
/// Always spins when visible. Always large. No fancy stuff here.
struct ActivityIndicator: UIViewRepresentable {
        
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        // Create UIActivityIndicatorView
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        // Nothing to do here.
    }
}
