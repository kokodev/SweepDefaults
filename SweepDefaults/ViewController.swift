//
//  ViewController.swift
//  SweepDefaults
//
//  Created by Riess, Manuel on 30.10.16.
//  Copyright © 2016 kokodev.de - All rights reserved.
//

import Cocoa
import CoreFoundation

private class DefaultsEntry: NSObject {
    // Objects used in bindings need to be NSObjects...
    // Structs cannot be subclasses of NSObject
    dynamic var id: String?
    dynamic var value: Any?
    dynamic var selected = false

    convenience init(id: String, value: Any) {
        self.init()

        self.id = id
        self.value = value
    }
}

class ViewController: NSViewController {

    @IBOutlet weak var appIdentifierField: NSTextField!

    private dynamic var defaults = [DefaultsEntry]()
    private var selectedAll = false

    override func viewDidLoad() {
        super.viewDidLoad()

        var appId = appIdentifierField.stringValue
        let arguments = ProcessInfo.processInfo.arguments
        for argument in arguments {
            if let index = argument.range(of: "appId=")?.upperBound {
                appId = argument.substring(from: index)
            }
        }
        appIdentifierField.stringValue = appId

        loadDefaults(appId)
    }

    @IBAction func clearSelected(_ sender: NSButton) {
        var domain = [String: Any]()

        for item in defaults {
            if !item.selected {
                guard let id = item.id,
                      let value = item.value else { continue }
                domain[id] = value
            }
        }

        let appId = appIdentifierField.stringValue
        
        let userDefaults = UserDefaults.standard
        userDefaults.removePersistentDomain(forName: appId)
        userDefaults.setPersistentDomain(domain, forName: appId)

        loadDefaults(appId)
    }

    @IBAction func refreshList(_ sender: NSButton) {
        loadDefaults(appIdentifierField.stringValue)
    }

    @IBAction func selectAllItems(_ sender: NSButton) {
        selectedAll = !selectedAll

        for item in defaults {
            item.selected = selectedAll
        }

        if selectedAll {
            sender.title = "Deselect All"
        } else {
            sender.title = "Select All"
        }
    }

    fileprivate func loadDefaults(_ appId: String) {
        let userDefaults = UserDefaults.standard

        defaults.removeAll()

        guard let domain = userDefaults.persistentDomain(forName: appId) else {
            let alert = NSAlert()
            alert.messageText = "No standard user defaults found for the app with the identifier:\n\(appId)"
            alert.informativeText = "The application might be sandboxed, in which case the defaults cannot be read by this tool."
            alert.beginSheetModal(for: self.view.window!)
            return
        }

        for (key, value) in domain {
            let item = DefaultsEntry(id: key, value: value)
            defaults.append(item)
        }
    }
}
