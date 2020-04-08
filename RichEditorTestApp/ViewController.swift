//
//  ViewController.swift
//  RichEditorTestApp
//
//  Created by soltan on 08/04/2020.
//  Copyright © 2020 dev.skyit. All rights reserved.
//

import UIKit
import RichEditorViewSwift

class ViewController: UIViewController {
    
    var prevText = ""
    
    @IBOutlet weak var editorView: RichEditorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        


        let toolbar = RichEditorToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        toolbar.options = RichEditorDefaultOption.all
        toolbar.delegate = self
        toolbar.editor = editorView
        editorView.delegate = self 
        editorView.inputAccessoryView = toolbar

        editorView.placeholder = "This is working now"
        editorView.editingEnabled = true

    }

    func isValidURL (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}

extension ViewController: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        // This is meant to act as a text cap
        if content.count > 40000 {
            editor.html = prevText
        } else {
            prevText = content
        }
    }
}

extension ViewController: RichEditorToolbarDelegate {
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        let alertController = UIAlertController(title: "Enter link and text", message: "You can leave the text empty to only show a clickable link", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Insert", style: .default) { (_) in
            var link = alertController.textFields?[0].text
            let text = alertController.textFields?[1].text
            if link?.last != "/" { link = link! + "/" }
            toolbar.editor?.insertLink(href: link!, text: text ?? link!)
            self.editorView.focus()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        confirmAction.isEnabled = false
        let linkPH = "Link (required)"
        let txtPH = "Text (Clickable text that redirects to link)"
        toolbar.editor?.hasRangeSelection(handler: { r in
            if r == true {
                alertController.addTextField { (textField) in
                    textField.placeholder = linkPH
                    toolbar.editor?.getSelectedHref(handler: { a in
                        if a?.last != "/" {
                            textField.text = nil
                        } else {
                            if self.isValidURL(urlString: a) == true {
                                textField.text = a
                            }
                        }
                    })
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                        if self.isValidURL(urlString: textField.text) == true {
                            confirmAction.isEnabled = textField.hasText
                        } else {
                            confirmAction.isEnabled = false
                        }
                    }
                }
                alertController.addTextField { (textField) in
                    textField.placeholder = txtPH
                    toolbar.editor?.getSelectedText(handler: { a in
                        textField.text = a
                    })
                }
            } else {
                alertController.addTextField { (textField) in
                    textField.placeholder = linkPH
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                        if self.isValidURL(urlString: textField.text) == true {
                            confirmAction.isEnabled = textField.hasText
                        } else {
                            confirmAction.isEnabled = false
                        }
                    }
                }
                alertController.addTextField { (textField) in textField.placeholder = txtPH }
            }
        })
    }
}
