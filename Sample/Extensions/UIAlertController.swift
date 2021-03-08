//
//  UIAlertController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

extension UIAlertController {
    
    /// Finds the currently visible window of the current scene and presents the alert on that one.
    /// Shows nothing if either no window is found or the window has no root view contorller.
    func prompt() {
        
        guard let window = UIApplication.shared.windows.first(where: { (window) -> Bool in window.isKeyWindow})
        else {
            return
        }
        
        window.rootViewController?.present(self,
                                           animated: true,
                                           completion: nil)
    }
    
    /// Creates and prompts a simple alert just as a hint to the user.
    /// - Parameters:
    ///   - title: title used in the alert
    ///   - message:message body to be displayed in the alert
    ///   - button: caption on the only button, defaults to "Close"
    static func simpleDialog(title: String = "Oops", message: String, button: String = "Close") {
        
        let close = UIAlertAction(title: button, style: .default, handler: nil)
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(close)
        
        DispatchQueue.main.async {
            alert.prompt()
        }
    }
}
