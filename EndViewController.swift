//
//  EndViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 1/24/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
    var passedRoutineName = ""
    
    @IBOutlet var routineLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        
        //UIApplication.shared.endIgnoringInteractionEvents()
        self.view.isUserInteractionEnabled = true
        
        routineLabel.text = passedRoutineName

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHome" {
            let homeView = segue.destination as! RoutinesViewController
            homeView.tableView.rowHeight = 80.0
        }
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
