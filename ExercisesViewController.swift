//
//  ExercisesViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 8/30/20.
//  Copyright © 2020 Chiraag Nadig. All rights reserved.
//

import UIKit
import CoreData

class ExercisesViewController: UITableViewController {
    var customizeExercise = false
    var storedExerciseName = ""
    var passedRoutineName = ""
    var routineExercises = [String]()
    var exerciseDurations = [Int]()
    var exerciseSecs = [Int]()
    var exerciseMins = [Int]()
    var addRoutine = false
    var rsecs = 0
    var rmins = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        exerciseDurations.removeAll()
        
        /*
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "LeagueSpartan-Bold", size: 20)!]
        }
        else {
            // Fallback on earlier versions
        }
        */
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.predicate = NSPredicate(format: "whichRoutine = %@", passedRoutineName)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                var counter = 0
                for result in results as! [NSManagedObject] {
                    if let exerciseName = result.value(forKey: "exerciseName") as? String {
                        if results.count > routineExercises.count {
                            if routineExercises.contains(exerciseName) == false {
                                routineExercises.append(exerciseName)
                            }
                        }
                        else if routineExercises.contains(exerciseName) == false {
                            routineExercises[counter] = exerciseName
                        }
                    }
                    if let exerciseDuration = result.value(forKey: "exerciseDuration") as? Int {
                        exerciseDurations.append(exerciseDuration)
                    }
                    counter = counter + 1
                }
            }
        }
        catch {
            print("Could not load exercises")
        }
        
        if exerciseDurations.count > 0 {
            exerciseSecs.removeAll()
            exerciseMins.removeAll()
            var routineTime = 0
            for duration in exerciseDurations {
                let secs = duration % 60
                exerciseSecs.append(secs)
                let mins = duration / 60
                exerciseMins.append(mins)
            
                routineTime = routineTime + duration
            }
            rsecs = routineTime % 60
            rmins = routineTime / 60
        }
        if rsecs == 0 && rmins == 0 {
            self.navigationItem.title = passedRoutineName
        }
        else {
            self.navigationItem.title = passedRoutineName + " (" + String(rmins) + "m " + String(rsecs) + "s)"
        }
        
        tableView.reloadData()
        
        if routineExercises.count == 0 {
            let alertController = UIAlertController(title: "Empty Table", message: "Please add an exercise!", preferredStyle:  UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineExercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExercisesCell
        cell.exerciseLabel.text = routineExercises[indexPath.row]
        cell.exerciseTimeLabel.text = String(exerciseMins[indexPath.row]) + "m " + String(exerciseSecs[indexPath.row]) + "s"
        cell.exerciseNumberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
            request.predicate = NSPredicate(format: "exerciseName = %@", routineExercises[indexPath.row])
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
            routineExercises.remove(at: indexPath.row)
            exerciseDurations.remove(at: indexPath.row)
            exerciseSecs.remove(at: indexPath.row)
            exerciseMins.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //activeRow = indexPath.row
        customizeExercise = true
        storedExerciseName = routineExercises[indexPath.row]
        performSegue(withIdentifier: "toCustomizing", sender: nil)
    }
    
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCustomizing" {
            let secondView = segue.destination as! ViewController
            secondView.customizeExercise = customizeExercise
            secondView.storedExerciseName = storedExerciseName
            secondView.passedRoutineName = passedRoutineName
            customizeExercise = false
        }
    }
    
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

}

