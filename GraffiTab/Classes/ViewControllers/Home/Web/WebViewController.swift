//
//  WebViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class WebViewController: BackButtonViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadText()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController?.navigationBarHidden == true {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading
    
    func loadText() {
        do {
            let text = try String(contentsOfFile: filePath!)
            webView.loadHTMLString(text, baseURL: nil)
        } catch {
            DialogBuilder.showErrorAlert("Could not open file.", title: App.Title)
        }
    }
}
