//
//  TextEditorVC.swift
//  EGVApp
//
//  Created by Fabricio on 06/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import RichEditorView


protocol TextEditorDelegate: class {
    func editTextDone(text: String, vc: TextEditorVC)
}

class TextEditorVC: UIViewController {

    @IBOutlet weak var mTextEditorView: RichEditorView!
    
    weak var delegate: TextEditorDelegate!
    var previousText: String = ""
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.bold, RichEditorDefaultOption.italic,
            RichEditorDefaultOption.link,
            RichEditorDefaultOption.undo,
            RichEditorDefaultOption.redo,
            RichEditorDefaultOption.clear]
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mTextEditorView.placeholder = "Escreva aqui o seu texto..."
        toolbar.editor = mTextEditorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
        toolbar.delegate = self
        
        mTextEditorView.inputAccessoryView = toolbar
        
        if !previousText.isEmpty {
            mTextEditorView.html = previousText
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtDone(_ sender: UIBarButtonItem) {
        self.delegate.editTextDone(text: mTextEditorView.contentHTML, vc: self)
        print(mTextEditorView.contentHTML)
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TextEditorVC: RichEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}
