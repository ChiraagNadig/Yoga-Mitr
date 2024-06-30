//
//  RoutinesViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 12/17/20.
//  Copyright © 2020 Chiraag Nadig. All rights reserved.
//

import UIKit
import CoreData

class RoutinesViewController: UITableViewController {
    var routineNames = [String]()
    var customizeRoutine = false
    var routineLocation = -1
    var storedRoutineName = ""
    var passedRoutineName = ""
    var addRoutine = false
    var routineSecs = [Int]()
    var routineMins = [Int]()
    var selectedSec = 0
    var selectedMin = 0
    var cellLocation = 0
    
    /*
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Toggles the edit button state
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        tableView.setEditing(editing, animated: true)
        
        if tableView.isEditing {
            print("Editing")
            
            
        }
        else {
            print("Not editing")
        }
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tableView.isEditing = false
        self.isEditing = false
    }
    
    /*
    @objc func editPressed(sender: UIBarButtonItem) {
        if tableView.isEditing {
            print("Editing")
        }
        else {
            print("nothing")
        }
    }
    */
    
    @IBAction func playPressed(_ sender: UIButton) {
        cellLocation = sender.tag
        passedRoutineName = routineNames[cellLocation]
        
        if routineMins[cellLocation] > 0 || routineSecs[cellLocation] > 0 {
            selectedSec = routineSecs[cellLocation]
            selectedMin = routineMins[cellLocation]
            performSegue(withIdentifier: "playRoutine", sender: nil)
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "You cannot play a routine that has no exercises!", preferredStyle:  UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewRoutine" {
            let otherView = segue.destination as! ExercisesViewController
            otherView.passedRoutineName = passedRoutineName
            otherView.addRoutine = addRoutine
            otherView.tableView.rowHeight = 80.0
            addRoutine = false
        }
        else if segue.identifier == "playRoutine" {
            let playView = segue.destination as! PlayViewController
            playView.passedRoutineName = passedRoutineName
            playView.selectedSec = selectedSec
            playView.selectedMin = selectedMin
        }
    }
    
    @IBAction func newRoutine(_ sender: Any) {
        let alertController = UIAlertController(title: "New Routine", message: "Name this routine", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let inputName = alertController.textFields![0].text {
                if self.routineNames.contains(inputName) == false {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Routines")
                    request.returnsObjectsAsFaults = false
                    let newRoutine = NSEntityDescription.insertNewObject(forEntityName: "Routines", into: context)
                    newRoutine.setValue(inputName, forKey: "routineName")
                    do {
                        try context.save()
                        //pop up that routine name has been saved
                        //perform segue - send the name of the routine over
                        self.passedRoutineName = inputName
                        self.addRoutine = true
                        self.performSegue(withIdentifier: "viewRoutine", sender: nil)
                    }
                    catch {
                        //pop up that an error occured
                        print("An error occured. Please try again")
                    }
                }
                else {
                    //routine name already exists
                    print("A routine with this name already exists")
                }
            }
            else {
                //please enter a routine name
                print("Please enter a routine name")
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        /*
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        */
        
        routineSecs.removeAll()
        routineMins.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Routines")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                var counter = 0
                for result in results as! [NSManagedObject] {
                    if let routineName = result.value(forKey: "routineName") as? String {
                        counter = counter + 1
                        if counter > routineNames.count {
                            routineNames.append(routineName)
                        }
                    }
                }
            }
        }
        catch {
            print("Could not load routines")
        }
        let timeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        for name in routineNames {
            var rSec = 0
            timeRequest.predicate = NSPredicate(format: "whichRoutine = %@", name)
            timeRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(timeRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let exerciseDuration = result.value(forKey: "exerciseDuration") as? Int {
                            rSec = rSec + exerciseDuration
                        }
                    }
                }
            }
            catch {
                print("Could not load exercises")
            }
            
            let rouSecs = rSec % 60
            let rouMins = rSec / 60
            routineSecs.append(rouSecs)
            routineMins.append(rouMins)
        }
        
        tableView.reloadData()
        
        if routineNames.count == 0 {
            let alertController = UIAlertController(title: "Empty Table", message: "Please add a routine!", preferredStyle:  UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        

        navigationItem.leftBarButtonItem = editButtonItem
        
        //navigationItem.leftBarButtonItem?.action = #selector(editPressed(sender:))
        
        self.tableView.allowsSelectionDuringEditing = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        /*
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "LeagueSpartan-Bold", size: 20)!]
        }
        else {
            // Fallback on earlier versions
        }
        */
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {

        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let editIndexPath = self.tableView.indexPathForRow(at: touchPoint) {
                
                 let alertController = UIAlertController(title: "Rename Routine", message: "Enter a different name for this routine", preferredStyle: .alert)

                 alertController.addTextField { (textField) in
                    textField.text = self.routineNames[editIndexPath.row]
                 }

                 let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                 let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                     if let inputName = alertController.textFields![0].text {
                         if self.routineNames.contains(inputName) == false {
                            
                             let appDelegate = UIApplication.shared.delegate as! AppDelegate
                             let context = appDelegate.persistentContainer.viewContext
                             let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Routines")
                             request.predicate = NSPredicate(format: "routineName = %@", self.routineNames[editIndexPath.row])
                             request.returnsObjectsAsFaults = false
                             
                             do {
                                
                                let results = try context.fetch(request)
                                if results.count > 0 {
                                    for result in results as! [NSManagedObject] {
                                        result.setValue(inputName, forKey: "routineName")
                                    }
                                }
                                try context.save()
                                 //pop up that routine name has been saved
                                 //perform segue - send the name of the routine over
                                
                                let otherRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
                                otherRequest.predicate = NSPredicate(format: "whichRoutine = %@", self.routineNames[editIndexPath.row])
                                otherRequest.returnsObjectsAsFaults = false
                                
                                do {
                                    let otherResults = try context.fetch(otherRequest)
                                    if otherResults.count > 0 {
                                        for oResult in otherResults as! [NSManagedObject] {
                                            oResult.setValue(inputName, forKey: "whichRoutine")
                                        }
                                    }
                                    try context.save()
                                    
                                    self.routineNames[editIndexPath.row] = inputName
                                    
                                    self.passedRoutineName = inputName
                                    //self.addRoutine = true
                                    self.performSegue(withIdentifier: "viewRoutine", sender: nil)
                                }
                                catch {
                                    print("An error occured. Please try again")
                                }
                             }
                             catch {
                                 //pop up that an error occured
                                 print("An error occured. Please try again")
                             }
                         }
                         else {
                             //routine name already exists
                             print("A routine with this name already exists")
                         }
                     }
                     else {
                         //please enter a routine name
                         print("Please enter a routine name")
                     }
                 }
                 alertController.addAction(cancelAction)
                 alertController.addAction(saveAction)

                 present(alertController, animated: true, completion: nil)
            }
        }
    }
        
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routineNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "xCell", for: indexPath) as! RoutinesCell
        
        cell.routineLabel.text = routineNames[indexPath.row]
        cell.timeLabel.text = String(routineMins[indexPath.row]) + "m " + String(routineSecs[indexPath.row]) + "s"
        cell.orderLabel.text = String(indexPath.row + 1)
        cell.playButton.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        passedRoutineName = routineNames[indexPath.row]
        performSegue(withIdentifier: "viewRoutine", sender: nil)
    }
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Routines")
            request.predicate = NSPredicate(format: "routineName = %@", routineNames[indexPath.row])
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        context.delete(result)
                        do {
                            try context.save()
                        }
                        catch {
                            print("could not delete")
                        }
                    }
                }
            }
            catch {
                print("could not fetch results")
            }
            
            request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
            request.predicate = NSPredicate(format: "whichRoutine = %@", routineNames[indexPath.row])
            request.returnsObjectsAsFaults = false
            do {
                let exResults = try context.fetch(request)
                if exResults.count > 0 {
                    for exResult in exResults as! [NSManagedObject] {
                        context.delete(exResult)
                    }
                    do {
                        try context.save()
                    }
                    catch {
                        print("could not delete routine exercises")
                    }
                }
            }
            catch {
                print("could not fetch exercise results")
            }
           
            routineNames.remove(at: indexPath.row)
            routineSecs.remove(at: indexPath.row)
            routineMins.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
 
