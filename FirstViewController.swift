//
//  FirstViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 4/1/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class FirstViewController: UIViewController {
    
    @IBOutlet var appTitle: UILabel!
    @IBOutlet var appSlogan: UILabel!
    @IBOutlet var appLogo: UIImageView!
    @IBOutlet var logoBackImage: UIImageView!
    
    @IBOutlet var middleView: UIView!
    
    var startingPlayer = AVAudioPlayer()
    
    var dCountsIn = [0, 0, 0, 1, 1, 5, 6, 7, 5 /*end of routine 1*/ , 0, 0, 0, 1, 1, 5, 7, 9, 5]
    var dCountsOut = [20, 30, 40, 1, 1, 10, 12, 14, 10 /*end of routine 1*/ , 30, 50, 70, 1, 1, 10, 14, 18, 10]
    var dCountSpeed = [4, 4, 4, 4, 4, 3, 3, 3, 3 /*end of routine 1*/ , 4, 4, 4, 4, 4, 3, 3, 3, 3]
    var dExerciseDuration = [25, 30, 35, 35, 30, 45, 51, 57, 105 /*end of routine 1*/ , 25, 40, 50, 35, 35, 45, 57, 69, 225]
    var dExerciseRepeat = [1, 1, 1, 20, 20, 2, 2, 2, 3 /*end of routine 1*/ , 1, 1, 1, 20, 20, 2, 2, 2, 3]
    var dHoldsIn = [0, 0, 0, 0, 0, 0, 0, 0, 0 /*end of routine 1*/ , 0, 0, 0, 0, 0, 0, 0, 0, 10]
    var dHoldsOut = [0, 0, 0, 0, 0, 0, 0, 0, 0 /*end of routine 1*/, 0, 0, 0, 0, 0, 0, 0, 0, 10]
    var dRestCounts = [15, 15, 15, 15, 15, 15, 15, 15, 15 /*end of routine 1*/ , 15, 15, 15, 15, 15, 15, 15, 15, 15]
    var dExerciseName = ["Kapala Bhati 20", "Kapala Bhati 30", "Kapala Bhati 40", "Bhastrika 1", "Bhastrika 2", "Deergha Shwasa 5", "Deergha Shwasa 6", "Deergha Shwasa 7", "Nadi Shodana no Kumbhaka" /*end of routine 1*/ , "Kapala Bhati 30", "Kapala Bhati 50", "Kapala Bhati 70", "Bhastrika 1", "Bhastrika 2", "Deergha Shwasa 5", "Deergha Shwasa 7", "Deergha Shwasa 9", "Nadi Shodana both Kumbhakas"]
    var dExercisePreset = ["Kapala Bhati", "Kapala Bhati", "Kapala Bhati", "Bhastrika", "Bhastrika", "Deergha Shwasa", "Deergha Shwasa", "Deergha Shwasa", "Nadi Shodana no Kumbhaka" /*end of routine 1*/ , "Kapala Bhati", "Kapala Bhati", "Kapala Bhati", "Bhastrika", "Bhastrika", "Deergha Shwasa", "Deergha Shwasa", "Deergha Shwasa", "Nadi Shodana both Kumbhakas"]
    var dWhichRoutine = ["Routine 1", "Routine 1", "Routine 1", "Routine 1", "Routine 1", "Routine 1", "Routine 1", "Routine 1", "Routine 1" /*end of routine 1*/ , "Routine 2", "Routine 2", "Routine 2", "Routine 2", "Routine 2", "Routine 2", "Routine 2", "Routine 2", "Routine 2"]
    var dVoice = [true, true, true, true, true, true, true, true, true /*end of routine 1*/ , true, true, true, true, true, true, true, true, true]
    
    var dRoutineNames = ["Routine 1", "Routine 2"]
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStart" {
            let startView = segue.destination as! RoutinesViewController
            startView.tableView.rowHeight = 80.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        
        appTitle.alpha = 0
        appSlogan.alpha = 0
        appLogo.alpha = 0
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Startup")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count == 0 {
                for i in 0..<dCountsIn.count {
                    let addDefault = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context)
                    addDefault.setValue(dCountsIn[i], forKey: "countsIn")
                    addDefault.setValue(dCountsOut[i], forKey: "countsOut")
                    addDefault.setValue(dCountSpeed[i], forKey: "countSpeed")
                    addDefault.setValue(dExerciseDuration[i], forKey: "exerciseDuration")
                    addDefault.setValue(dExerciseRepeat[i], forKey: "exerciseRepeat")
                    addDefault.setValue(dHoldsIn[i], forKey: "holdsIn")
                    addDefault.setValue(dHoldsOut[i], forKey: "holdsOut")
                    addDefault.setValue(dRestCounts[i], forKey: "restCounts")
                    addDefault.setValue(dExerciseName[i], forKey: "exerciseName")
                    addDefault.setValue(dExercisePreset[i], forKey: "exercisePreset")
                    addDefault.setValue(dWhichRoutine[i], forKey: "whichRoutine")
                    addDefault.setValue(dVoice[i], forKey: "voice")
                    do {
                        try context.save()
                    }
                    catch {
                        print("An error occurred. Please relaunch the app.")
                    }
                }
                
                
                for y in 0..<dRoutineNames.count {
                    let routineNameAdd = NSEntityDescription.insertNewObject(forEntityName: "Routines", into: context)
                    routineNameAdd.setValue(dRoutineNames[y], forKey: "routineName")
                    
                    do {
                        try context.save()
                    }
                    catch {
                        print("An error occurred. Please relaunch the app.")
                    }
                }
                

                let veteranAdd = NSEntityDescription.insertNewObject(forEntityName: "Startup", into: context)
                veteranAdd.setValue(true, forKey: "veteran")
                
                do {
                    try context.save()
                }
                catch {
                    print("An error occurred. Please relaunch the app.")
                }
            }
        }
        catch {
            print("Could not load routines")
        }
        
        let startAudioPath = Bundle.main.path(forResource: "App Opening Audio", ofType: "mp3")
        do {
            try startingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: startAudioPath!))
        }
        catch {
            //process any errors
        }
        startingPlayer.play()
        
        
        let titleFontAttrs = [ NSAttributedString.Key.font: UIFont(name: "League Spartan", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 255/255.0, green: 194/255.0, blue: 138/255.0, alpha: 1.0)
        appearance.titleTextAttributes = titleFontAttrs
        navigationController?.navigationBar.standardAppearance = appearance;
        
         
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        
        
        /*
         navigationController?.navigationBar.tintColor = UIColor(red: 172/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(red: 255/255.0, green: 194/255.0, blue: 138/255.0, alpha: 1.0)
        } else {
            // Fallback on earlier versions
        }
        */
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.logoBackImage.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 3, animations: {
                self.appLogo.alpha = 1
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 2, animations: {
                    self.appTitle.alpha = 1
                    self.appSlogan.alpha = 1
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.performSegue(withIdentifier: "toStart", sender: nil)
                }
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
