//
//  AppDelegate.swift
//  ImageNet Downloader
//
//  Created by Onoulade on 01/07/2018.
//  Copyright © 2018 Dadu Prod. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func openFromFile(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["txt"]
        
        if (dialog.Jean-Victor DelpratrunModal() == .OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                print(result)
                let path = result!
                if let rootViewController = NSApplication.shared.mainWindow?.windowController?.contentViewController as? ViewController {
                    do {
                        let text = try String(contentsOf: path, encoding: .utf8)
                        rootViewController.inputField.stringValue = text
                        rootViewController.updateLabels("appDelegate")
                    }
                    catch {
                        return
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

