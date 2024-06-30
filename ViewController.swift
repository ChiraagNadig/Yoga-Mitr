//
//  ViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 8/2/20.
//  Copyright © 2020 Chiraag Nadig. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var yogaBrain = YogaBrain()
    var player = AVAudioPlayer()
    var breathingPlayer = AVAudioPlayer()
    var timer = Timer()
    var exerciseState = ""
    var storedCountSpeed = ""
    var storedCountsIn = ""
    var storedInHold = ""
    var storedCountsOut = ""
    var storedOutHold = ""
    var storedSets = ""
    var storedRestCounts = ""
    var presetValue = "No Preset"
    var presetRow = 0
    var isSanskrit = true
    
    @IBOutlet var countSpeedText: UILabel!
    @IBOutlet var countsInText: UILabel!
    @IBOutlet var inHoldText: UILabel!
    @IBOutlet var countsOutText: UILabel!
    @IBOutlet var outHoldText: UILabel!
    @IBOutlet var setsText: UILabel!
    @IBOutlet var interval: UITextField!
    @IBOutlet var countsIn: UITextField!
    @IBOutlet var countsOut: UITextField!
    @IBOutlet var repeatValue: UITextField!
    @IBOutlet var holdsIn: UITextField!
    @IBOutlet var holdsOut: UITextField!
    @IBOutlet var restCounts: UITextField!
    
    @IBOutlet var manageSound: UIButton!
    @IBOutlet var voice: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var pickerOutlet: UIPickerView!
    @IBOutlet var languageChooser: UISegmentedControl!
    
    var i = 1
    var breathe = "in"
    var voiceCommand = true
    var titleTouched = false
    var exerciseSecs = ""
    var exercisePresets = [
        "No Preset", "Kapala Bhati", "Bhastrika", "Deergha Shwasa",
        "Nadi Shodana no Kumbhaka", "Nadi Shodana Antara Kumbhaka",
        "Nadi Shodana Bahya Kumbhaka", "Nadi Shodana both Kumbhakas"
    ]
    var engPresets = [
        "No Preset", "Skull Shining Breath", "Bellows Breath", "Deep Breath",
        "Alternate nostril breath, no holds", "Alternate nostril breath, inBreath hold", "Alternate nostril breath, outBreath hold", "Alternate nostril breath, both holds"
    ]
    
    @IBOutlet var countSpeedSlider: UISlider!
    @IBOutlet var countInSlider: UISlider!
    @IBOutlet var countOutSlider: UISlider!
    @IBOutlet var repeatSlider: UISlider!
    @IBOutlet var holdInSlider: UISlider!
    @IBOutlet var holdOutSlider: UISlider!
    @IBOutlet var restSlider: UISlider!
    
    @IBOutlet var saveStatus: UILabel!
    @IBOutlet var exerciseName: UITextField!
    var saveData = true
    var updateData = true
    var customizeExercise = false
    var storedExerciseName = ""
    var passedRoutineName = ""
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if exerciseName.isEditing {
            titleTouched = true
        }
        else {
            UIView.animate(withDuration: 0.3) { //1
                self.view.frame.origin.y -= 150
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 1 || textField.tag == 2 {
            UIView.animate(withDuration: 0.3) { //1
                self.view.frame.origin.y += 150
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if saveButton.currentTitle == "Save" {
            saveData = true
            updateData = false
        }
        else {
            saveData = false
            updateData = true
        }
        var intSecs = 0
        if exerciseName.text == "" {
            //saveStatus.text = "Please enter a name for your exercise"
            displayAlert(title: "Error", message: "Please enter a name for your exercise")
        }
        else {
            //finding time
            var secsInterval: Double
            if interval.text == "1" {
                secsInterval = 2.0
            }
            else if interval.text == "2" {
                secsInterval = 1.5
            }
            else if interval.text == "3" {
                secsInterval = 1.0
            }
            else {
                secsInterval = 0.5
            }
            let inValue = Double(countsIn.text!)
            let outValue = Double(countsOut.text!)
            let holdInValue = Double(holdsIn.text!)
            let holdOutValue = Double(holdsOut.text!)
            let repeatNum = Double(repeatValue.text!)
            let restNum = Double(restCounts.text!)
            let almostNum = Int(((inValue! + outValue! + holdInValue! + holdOutValue!) * secsInterval) * repeatNum!)
            intSecs = almostNum + Int(restNum!)
            if presetRow == 0 || presetRow == 1 || presetRow == 2 || presetRow == 3 {
                intSecs = almostNum + Int(restNum!)
            }
            else {
                intSecs = (2 * almostNum) + Int(restNum!)
            }
            exerciseSecs = String(intSecs)
            //let timeSecs = Int(exerciseSecs)! % 60
            //let timeMins = Int(exerciseSecs)! / 60
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let exerciseTitle = result.value(forKey: "exerciseName") as? String {
                            if let routineLabel = result.value(forKey: "whichRoutine") as? String {
                                if saveButton.currentTitle == "Save" {
                                    if exerciseName.text == exerciseTitle && routineLabel == passedRoutineName {
                                        saveData = false
                                        displayAlert(title: "Error", message: "The exercise \(exerciseName.text!) already exists.")
                                    }
                                }
                                else {
                                    if saveButton.currentTitle == "Update" {
                                        if exerciseName.text == exerciseTitle && routineLabel == passedRoutineName && exerciseTitle != storedExerciseName {
                                            updateData = false
                                            displayAlert(title: "Error", message: "The exercise \(exerciseName.text!) already exists.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch {
                displayAlert(title: "Error", message: "An error occurred. Please try again.")
            }
            if saveData {
                let newExercise = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context)
                newExercise.setValue(Int(interval.text!), forKey: "countSpeed")
                newExercise.setValue(Int(countsIn.text!), forKey: "countsIn")
                newExercise.setValue(Int(countsOut.text!), forKey: "countsOut")
                newExercise.setValue(voiceCommand, forKey: "voice")
                newExercise.setValue(exerciseName.text, forKey: "exerciseName")
                newExercise.setValue(passedRoutineName, forKey: "whichRoutine")
                newExercise.setValue(Int(repeatValue.text!), forKey: "exerciseRepeat")
                newExercise.setValue(Int(exerciseSecs), forKey: "exerciseDuration")
                newExercise.setValue(Int(holdsIn.text!), forKey: "holdsIn")
                newExercise.setValue(Int(holdsOut.text!), forKey: "holdsOut")
                newExercise.setValue(Int(restCounts.text!), forKey: "restCounts")
                newExercise.setValue(presetValue, forKey: "exercisePreset")
                newExercise.setValue(presetRow, forKey: "presetRow")
                newExercise.setValue(isSanskrit, forKey: "sanskrit")
                do {
                    try context.save()
                    //saveStatus.text = "Your exercise has been saved!"
                    let alertController = UIAlertController(title: "Saved", message: "Your exercise has been saved!", preferredStyle:  UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    saveButton.setTitle("Update", for: [])
                    //self.navigationItem.title = exerciseName.text! + " (" + String(timeMins) + "m " + String(timeSecs) + "s)"
                }
                catch {
                    //process any errors
                    //saveStatus.text = "An error occurred. Please try again."
                    displayAlert(title: "Error", message: "An error occurred when trying to save your Exercise. Please try again.")
                }
            }
            
            if saveButton.currentTitle == "Update" && updateData {
                request.predicate = NSPredicate(format: "exerciseName = %@", storedExerciseName)
                request.returnsObjectsAsFaults = false
                do {
                    let updateResults = try context.fetch(request)
                    if updateResults.count > 0 {
                        for updateResult in updateResults as! [NSManagedObject] {
                            if let routineTag = updateResult.value(forKey: "whichRoutine") as? String {
                                if routineTag == passedRoutineName {
                                    updateResult.setValue(exerciseName.text, forKey: "exerciseName")
                                    updateResult.setValue(Int(interval.text!), forKey: "countSpeed")
                                    updateResult.setValue(Int(countsIn.text!), forKey: "countsIn")
                                    updateResult.setValue(Int(countsOut.text!), forKey: "countsOut")
                                    updateResult.setValue(Int(repeatValue.text!), forKey: "exerciseRepeat")
                                    updateResult.setValue(Int(exerciseSecs), forKey: "exerciseDuration")
                                    updateResult.setValue(Int(holdsIn.text!), forKey: "holdsIn")
                                    updateResult.setValue(Int(holdsOut.text!), forKey: "holdsOut")
                                    updateResult.setValue(Int(restCounts.text!), forKey: "restCounts")
                                    updateResult.setValue(presetValue, forKey: "exercisePreset")
                                    updateResult.setValue(presetRow, forKey: "presetRow")
                                    updateResult.setValue(isSanskrit, forKey: "sanskrit")
                                    if voice.currentTitle == "Turn voice instruction on" {
                                        updateResult.setValue(false, forKey: "voice")
                                    }
                                    else {
                                        updateResult.setValue(true, forKey: "voice")
                                    }
                                    do {
                                       try context.save()
                                        //saveStatus.text = "Your exercise has been updated!"
                                        let alertController = UIAlertController(title: "Updated", message: "Your exercise has been updated!", preferredStyle:  UIAlertController.Style.alert)
                                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            self.dismiss(animated: true, completion: nil)
                                            self.navigationController?.popViewController(animated: true)
                                        }))
                                        self.present(alertController, animated: true, completion: nil)
                                        //self.navigationItem.title = exerciseName.text! + " (" + String(timeMins) + "m " + String(timeSecs) + "s)"
                                    }
                                    catch {
                                        //saveStatus.text = "Your exercise failed to be updated. Please try again"
                                    }
                                }
                            }
                            
                        }
                    }
                }
                catch {
                    displayAlert(title: "Error", message: "An error occurred. Please try again.")
                }
                /*
                let updateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
                updateRequest.predicate = NSPredicate(format: "exerciseName = %@", storedExerciseName)
                updateRequest.returnsObjectsAsFaults = false
                do {
                    let updateResults = try context.fetch(updateRequest)
                    if updateResults.count > 0 {
                        print(updateResults)
                        for updateResult in updateResults as! [NSManagedObject] {
                            updateResult.setValue(exerciseName.text, forKey: "exerciseName")
                            updateResult.setValue(Int(interval.text!), forKey: "countSpeed")
                            updateResult.setValue(Int(countsIn.text!), forKey: "countsIn")
                            updateResult.setValue(Int(countsOut.text!), forKey: "countsOut")
                            updateResult.setValue(Int(repeatValue.text!), forKey: "exerciseRepeat")
                            updateResult.setValue(Int(exerciseSecs), forKey: "exerciseDuration")
                            updateResult.setValue(Int(holdsIn.text!), forKey: "holdsIn")
                            updateResult.setValue(Int(holdsOut.text!), forKey: "holdsOut")
                            updateResult.setValue(Int(restCounts.text!), forKey: "restCounts")
                            updateResult.setValue(presetValue, forKey: "exercisePreset")
                            if voice.currentTitle == "Turn voice instruction on" {
                                updateResult.setValue(false, forKey: "voice")
                            }
                            else {
                                updateResult.setValue(true, forKey: "voice")
                            }
                            do {
                               try context.save()
                                //saveStatus.text = "Your exercise has been updated!"
                                let alertController = UIAlertController(title: "Updated", message: "Your exercise has been updated!", preferredStyle:  UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.dismiss(animated: true, completion: nil)
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alertController, animated: true, completion: nil)
                                self.navigationItem.title = exerciseName.text! + " (" + String(timeMins) + "m " + String(timeSecs) + "s)"
                            }
                            catch {
                                //saveStatus.text = "Your exercise failed to be updated. Please try again"
                            }
                        }
                    }
                }
                catch {
                    displayAlert(title: "Error", message: "An error occurred. Please try again.")
                }
            */
            }
            
        }
        
    }
    
    @IBAction func countSpeedChanged(_ sender: Any) {
        countSpeedSlider.value = countSpeedSlider.value.rounded()
        if countSpeedSlider.value == 1.0 {
            interval.text = "1"
        }
        else if countSpeedSlider.value == 2.0 {
            interval.text = "2"
        }
        else if countSpeedSlider.value == 3.0 {
            interval.text = "3"
        }
        else {
            interval.text = "4"
        }
    }
    
    @IBAction func countsInChanged(_ sender: Any) {
        countInSlider.value = countInSlider.value.rounded()
        countsIn.text = String(Int(countInSlider.value))
        countOutSlider.value = countInSlider.value * 2
        countsOut.text = String(Int(countOutSlider.value))
    }
    
    @IBAction func countsOutChanged(_ sender: Any) {
        countOutSlider.value = countOutSlider.value.rounded()
        countsOut.text = String(Int(countOutSlider.value))
    }
    
    @IBAction func setsChanged(_ sender: Any) {
        repeatSlider.value = repeatSlider.value.rounded()
        repeatValue.text = String(Int(repeatSlider.value))
    }
    
    @IBAction func inHoldsChanged(_ sender: Any) {
        holdInSlider.value = holdInSlider.value.rounded()
        holdsIn.text = String(Int(holdInSlider.value))
    }
    
    @IBAction func outHoldsChanged(_ sender: Any) {
        holdOutSlider.value = holdOutSlider.value.rounded()
        holdsOut.text = String(Int(holdOutSlider.value))
    }
    
    @IBAction func restChanged(_ sender: Any) {
        restSlider.value = restSlider.value.rounded()
        restCounts.text = String(Int(restSlider.value))
    }
    
    @IBAction func voiceInstruction(_ sender: Any) {
        if voice.currentTitle == "Turn voice instruction on" {
            voice.setTitle("Turn voice instruction off", for: [])
            voiceCommand = true
        }
        else {
            voice.setTitle("Turn voice instruction on", for: [])
            voiceCommand = false
        }
    }
    
    @objc func timerRunning() {
        let breatheIn = Int(countsIn.text!)
        let breatheOut = Int(countsOut.text!)
        let inHold = Int(holdsIn.text!)
        let outHold = Int(holdsOut.text!)
        if i == 1 {
            if voiceCommand {
                if breathe == "in" {
                    let inAudioPath = Bundle.main.path(forResource: "in", ofType: "mp3")
                    do {
                        try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: inAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                    breathingPlayer.play()
                }
                else if breathe == "out" {
                    let outAudioPath = Bundle.main.path(forResource: "out", ofType: "mp3")
                    do {
                        try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: outAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                    breathingPlayer.play()
                }
                //if breathe == "inHold" || breathe == "outHold" {
                else {
                    let holdAudioPath = Bundle.main.path(forResource: "Hold", ofType: "mp3")
                    do {
                        try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: holdAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                    breathingPlayer.play()
                }
            }
            let tickAudioPath = Bundle.main.path(forResource: "Tick", ofType: "mp3")
            do {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: tickAudioPath!))
            }
            catch {
                //process any errors
            }
        }
        
        if i > 1 {
            let tockAudioPath = Bundle.main.path(forResource: "Tock", ofType: "mp3")
            do {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: tockAudioPath!))
            }
            catch {
                //process any errors
            }
        }
        
        player.play()
        
        if breathe == "in" {
            if i == breatheIn {
                if inHold != 0 {
                    breathe = "inHold"
                }
                else {
                    breathe = "out"
                }
                i = 0
            }
        }
        else if breathe == "inHold" {
            if i == inHold {
                breathe = "out"
                i = 0
            }
        }
        else if breathe == "out" {
            if i == breatheOut {
                if outHold != 0 {
                    breathe = "outHold"
                }
                else if breatheIn != 0 {
                    breathe = "in"
                }
                else {
                    breathe = "out"
                }
                i = 0
            }
        }
        else {
            if i == outHold {
                breathe = "in"
                i = 0
            }
        }
        
        i = i + 1
    }
    
    
    @IBAction func switchLang(_ sender: Any) {
        if languageChooser.selectedSegmentIndex == 0 {
            isSanskrit = true
            exercisePresets = [
                "No Preset", "Kapala Bhati", "Bhastrika", "Deergha Shwasa",
                "Nadi Shodana no Kumbhaka", "Nadi Shodana Antara Kumbhaka",
                "Nadi Shodana Bahya Kumbhaka", "Nadi Shodana both Kumbhakas", "Bhramari"
            ]
        }
        else {
            exercisePresets = engPresets
            isSanskrit = false
        }
        
        
        
        pickerOutlet.reloadAllComponents()
        
        
        
        
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return exercisePresets[row]
        }
    }
    
    @IBAction func controlSound(_ sender: Any) {
        var xinterval: Double
        if manageSound.currentTitle == "Test" {
            manageSound.setTitle("Stop", for: [])
            if Int(countsIn.text!)! > 0 {
                breathe = "in"
            }
            else {
                breathe = "out"
            }
            i = 1
            if interval.text == "1" {
                xinterval = 2.0
            }
            else if interval.text == "2" {
                xinterval = 1.5
            }
            else if interval.text == "3" {
                xinterval = 1.0
            }
            else {
                xinterval = 0.5
            }
            timer = Timer.scheduledTimer(timeInterval: xinterval, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
        else {
            manageSound.setTitle("Test", for: [])
            timer.invalidate()
        }
    }
    
    override func touchesBegan(_ touches: Set <UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        
        exerciseName.delegate = self
        repeatValue.delegate = self
        restCounts.delegate = self
        exerciseName.tag = 0
        repeatValue.tag = 1
        restCounts.tag = 2
        //exerciseName.autocorrectionType = .no
        countSpeedSlider.minimumValue = 1
        countSpeedSlider.maximumValue = 4
        countInSlider.minimumValue = 1
        countInSlider.maximumValue = 60
        countOutSlider.minimumValue = 1
        countOutSlider.maximumValue = 120
        repeatSlider.minimumValue = 1
        repeatSlider.maximumValue = 100
        holdInSlider.minimumValue = 0
        holdInSlider.maximumValue = 30
        holdOutSlider.minimumValue = 0
        holdOutSlider.maximumValue = 60
        restSlider.minimumValue = 0
        restSlider.maximumValue = 60
        
        languageChooser.setTitle("Sanskrit", forSegmentAt: 0)
        languageChooser.setTitle("English", forSegmentAt: 1)
        
        if customizeExercise {
            saveButton.setTitle("Update", for: [])
            exerciseName.text = storedExerciseName
            //self.navigationItem.title = storedExerciseName
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
            request.predicate = NSPredicate(format: "exerciseName = %@", storedExerciseName)
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let checkRoutineName = result.value(forKey: "whichRoutine") as? String {
                            if checkRoutineName == passedRoutineName {
                                if let savedCountSpeed = result.value(forKey: "countSpeed") as? Int {
                                    storedCountSpeed = String(savedCountSpeed)
                                    interval.text = String(savedCountSpeed)
                                    countSpeedSlider.value = Float(savedCountSpeed)
                                }
                                if let savedCountsIn = result.value(forKey: "countsIn") as? Int {
                                    storedCountsIn = String(savedCountsIn)
                                    countsIn.text = String(savedCountsIn)
                                    countInSlider.value = Float(savedCountsIn)
                                }
                                if let savedCountsOut = result.value(forKey: "countsOut") as? Int {
                                    storedCountsOut = String(savedCountsOut)
                                    countsOut.text = String(savedCountsOut)
                                    countOutSlider.value = Float(savedCountsOut)
                                }
                                if let savedRepeats = result.value(forKey: "exerciseRepeat") as? Int {
                                    storedSets = String(savedRepeats)
                                    repeatValue.text = String(savedRepeats)
                                    repeatSlider.value = Float(savedRepeats)
                                }
                                if let savedHoldsIn = result.value(forKey: "holdsIn") as? Int {
                                    storedInHold = String(savedHoldsIn)
                                    holdsIn.text = String(savedHoldsIn)
                                    holdInSlider.value = Float(savedHoldsIn)
                                }
                                if let savedHoldsOut = result.value(forKey: "holdsOut") as? Int {
                                    storedOutHold = String(savedHoldsOut)
                                    holdsOut.text = String(savedHoldsOut)
                                    holdOutSlider.value = Float(savedHoldsOut)
                                }
                                if let savedRestCounts = result.value(forKey: "restCounts") as? Int {
                                    storedRestCounts = String(savedRestCounts)
                                    restCounts.text = String(savedRestCounts)
                                    restSlider.value = Float(savedRestCounts)
                                }
                                if let savedSanskrit = result.value(forKey: "sanskrit") as? Bool {
                                    isSanskrit = savedSanskrit
                                    if !isSanskrit {
                                        exercisePresets = engPresets
                                        languageChooser.selectedSegmentIndex = 1
                                    }
                                }
                                if let savedPresetValue = result.value(forKey: "exercisePreset") as? String {
                                    presetValue = savedPresetValue
                                    pickerOutlet.selectRow(exercisePresets.firstIndex(of: presetValue)!, inComponent: 0, animated: false)
                                }
                                if let savedPresetRow = result.value(forKey: "presetRow") as? Int {
                                    presetRow = savedPresetRow
                                }
                                if let savedVoice = result.value(forKey: "voice") as? Bool {
                                    if savedVoice {
                                        voiceCommand = true
                                        voice.setTitle("Turn voice instruction off", for: [])
                                    }
                                    else {
                                        voiceCommand = false
                                        voice.setTitle("Turn voice instruction on", for: [])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch {
                displayAlert(title: "Error", message: "Your data could not be loaded. Please try again")
            }
        }
        else {
            presetValue = "No Preset"
        }
        
        
        
        
        if customizeExercise != true {
            handlePresets()
        }
        /*
        else {
            presetRow = exercisePresets.firstIndex(of: presetValue)!
            handlePresets()
        }
        */
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exercisePresets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exercisePresets[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //saveStatus.text = exercisePresets[row]
        
        if titleTouched == false {
            exerciseName.text = exercisePresets[row]
        }
        
        presetValue = exercisePresets[row]
        
        presetRow = row
        
        handlePresets()
    }

    func handlePresets() {
        if presetRow == 0 {
            interval.text = "3"
            countSpeedSlider.value = 3
            countsIn.text = "5"
            countInSlider.value = 5
            holdsIn.text = "5"
            holdInSlider.value = 5
            countsOut.text = "10"
            countOutSlider.value = 10
            holdsOut.text = "5"
            holdOutSlider.value = 5
            repeatValue.text = "5"
            repeatSlider.value = 1
            
            interval.alpha = 1
            countSpeedSlider.alpha = 1
            countsIn.alpha = 1
            countInSlider.alpha = 1
            holdsIn.alpha = 1
            holdInSlider.alpha = 1
            countsOut.alpha = 1
            countOutSlider.alpha = 1
            holdsOut.alpha = 1
            holdOutSlider.alpha = 1
            repeatValue.alpha = 1
            repeatSlider.alpha = 1
            countSpeedText.alpha = 1
            countsInText.alpha = 1
            inHoldText.alpha = 1
            countsOutText.alpha = 1
            outHoldText.alpha = 1
            setsText.alpha = 1
            
            interval.isUserInteractionEnabled = true
            countSpeedSlider.isUserInteractionEnabled = true
            countsIn.isUserInteractionEnabled = true
            countInSlider.isUserInteractionEnabled = true
            holdsIn.isUserInteractionEnabled = true
            holdInSlider.isUserInteractionEnabled = true
            countsOut.isUserInteractionEnabled = true
            countOutSlider.isUserInteractionEnabled = true
            holdsOut.isUserInteractionEnabled = true
            holdOutSlider.isUserInteractionEnabled = true
            repeatValue.isUserInteractionEnabled = true
            repeatSlider.isUserInteractionEnabled = true
            countSpeedText.isUserInteractionEnabled = true
            countsInText.isUserInteractionEnabled = true
            inHoldText.isUserInteractionEnabled = true
            countsOutText.isUserInteractionEnabled = true
            outHoldText.isUserInteractionEnabled = true
            setsText.isUserInteractionEnabled = true
        }
        
        else {
            yogaBrain.calculateValues(exercise: presetRow)
            if yogaBrain.returnCountSpeed() > 0 {
                interval.text = String(yogaBrain.returnCountSpeed())
                countSpeedSlider.value = Float(yogaBrain.returnCountSpeed())
                interval.isUserInteractionEnabled = true
                countSpeedSlider.isUserInteractionEnabled = true
                interval.alpha = 1
                countSpeedSlider.alpha = 1
                countSpeedText.alpha = 1
            }
            else {
                interval.text = "0"
                countSpeedSlider.value = 0
                interval.isUserInteractionEnabled = false
                countSpeedSlider.isUserInteractionEnabled = false
                interval.alpha = 0.4
                countSpeedSlider.alpha = 0.4
                countSpeedText.alpha = 0.4
            }
            if yogaBrain.returnCountsIn() > 0 {
                countsIn.text = String(yogaBrain.returnCountsIn())
                countInSlider.value = Float(yogaBrain.returnCountsIn())
                countsIn.isUserInteractionEnabled = true
                countInSlider.isUserInteractionEnabled = true
                countsIn.alpha = 1
                countInSlider.alpha = 1
                countsInText.alpha = 1
            }
            else {
                countsIn.text = "0"
                countInSlider.value = 0
                countsIn.isUserInteractionEnabled = false
                countInSlider.isUserInteractionEnabled = false
                countsIn.alpha = 0.4
                countInSlider.alpha = 0.4
                countsInText.alpha = 0.4
            }
            if yogaBrain.returnInHold() > 0 {
                holdsIn.text = String(yogaBrain.returnInHold())
                holdInSlider.value = Float(yogaBrain.returnInHold())
                holdsIn.isUserInteractionEnabled = true
                holdInSlider.isUserInteractionEnabled = true
                holdsIn.alpha = 1
                holdInSlider.alpha = 1
                inHoldText.alpha = 1
            }
            else {
                holdsIn.text = "0"
                holdInSlider.value = 0
                holdsIn.isUserInteractionEnabled = false
                holdInSlider.isUserInteractionEnabled = false
                holdsIn.alpha = 0.4
                holdInSlider.alpha = 0.4
                inHoldText.alpha = 0.4
            }
            if yogaBrain.returnCountsOut() > 0 {
                countsOut.text = String(yogaBrain.returnCountsOut())
                countOutSlider.value = Float(yogaBrain.returnCountsOut())
                countsOut.isUserInteractionEnabled = true
                countOutSlider.isUserInteractionEnabled = true
                countsOut.alpha = 1
                countOutSlider.alpha = 1
                countsOutText.alpha = 1
            }
            else {
                countsOut.text = "0"
                countOutSlider.value = 0
                countsOut.isUserInteractionEnabled = false
                countOutSlider.isUserInteractionEnabled = false
                countsOut.alpha = 0.4
                countOutSlider.alpha = 0.4
                countsOutText.alpha = 0.4
            }
            if yogaBrain.returnOutHold() > 0 {
                holdsOut.text = String(yogaBrain.returnOutHold())
                holdOutSlider.value = Float(yogaBrain.returnOutHold())
                holdsOut.isUserInteractionEnabled = true
                holdOutSlider.isUserInteractionEnabled = true
                holdsOut.alpha = 1
                holdOutSlider.alpha = 1
                outHoldText.alpha = 1
            }
            else {
                holdsOut.text = "0"
                holdOutSlider.value = 0
                holdsOut.isUserInteractionEnabled = false
                holdOutSlider.isUserInteractionEnabled = false
                holdsOut.alpha = 0.4
                holdOutSlider.alpha = 0.4
                outHoldText.alpha = 0.4
            }
            if yogaBrain.returnSets() > 0 {
                repeatValue.text = String(yogaBrain.returnSets())
                repeatSlider.value = Float(yogaBrain.returnSets())
                repeatValue.isUserInteractionEnabled = true
                repeatSlider.isUserInteractionEnabled = true
                repeatValue.alpha = 1
                repeatSlider.alpha = 1
                setsText.alpha = 1
            }
            else {
                repeatValue.text = "0"
                repeatSlider.value = 0
                repeatValue.isUserInteractionEnabled = false
                repeatSlider.isUserInteractionEnabled = false
                repeatValue.alpha = 0.4
                repeatSlider.alpha = 0.4
                setsText.alpha = 0.4
            }
        }
    }
    
}

