//
//  PlayViewController.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 1/15/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PlayViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var player = AVAudioPlayer()
    var breathingPlayer = AVAudioPlayer()
    var transitionPlayer = AVAudioPlayer()
    var presetPlayer = AVAudioPlayer()
    var timer = Timer()
    var clockTimer = Timer()
    
    var routineExercises = [String]()
    var exerciseTimes = [Int]()
    
    var passedRoutineName = ""
    var exerciseCounter = 0
    var audioState = "play"
    var i = 1
    var breathe = "in"
    var setBreath = "in"
    var routineSecs = 0
    var routineMins = 0
    var exerciseSecs = 0
    var exerciseMins = 0
    var continueExercise = true
    var continueTimer = true
    var continueRoutine = true
    var deductSet = true
    var dontDisturb = false
    var selectedSec = 0
    var selectedMin = 0
    var calculatedRSecs = 0
    var transitionCounter = 1
    var presetRow = 0
    
    var storedCountSpeed = ""
    var storedCountsIn = ""
    var storedCountsOut = ""
    var storedRepeats = ""
    var storedDuration = ""
    var storedHoldsIn = ""
    var storedHoldsOut = ""
    var storedRestCounts = ""
    var storedExercisePreset = ""
    var storedVoice = false
    var unchangedRepeats = ""
    
    @IBOutlet var routineName: UILabel!
    @IBOutlet var routineTimer: UILabel!
    @IBOutlet var exerciseTimer: UILabel!
    @IBOutlet var exerciseSets: UILabel!
    
    @IBOutlet var exerciseTable: UITableView!
    @IBOutlet var playPauseAudio: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        clockTimer.invalidate()
        UIApplication.shared.isIdleTimerDisabled = false
        presetPlayer.stop()
        transitionPlayer.stop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEnd" {
            let endView = segue.destination as! EndViewController
            endView.passedRoutineName = passedRoutineName
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exCell", for: indexPath)
        cell.textLabel?.text = routineExercises[indexPath.row]
        
        if indexPath.row == exerciseCounter {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        }
        else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        
        
        exerciseTable.delegate = self
        exerciseTable.dataSource = self
        //transitionPlayer.delegate = self
        exerciseTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        routineExercises.removeAll()
        calculatedRSecs = (60 * selectedMin) + selectedSec
        
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
                        counter = counter + 1
                    }
                    if let savedTime = result.value(forKey: "exerciseDuration") as? Int {
                        exerciseTimes.append(savedTime)
                    }
                }
            }
        }
        catch {
            print("Could not load exercises")
        }
        
        routineName.text = passedRoutineName
        
        if selectedSec < 10 || selectedMin < 10 {
            if selectedSec < 10 && selectedMin < 10 {
                routineTimer.text = "0" + String(selectedMin) + ":0" + String(selectedSec)
            }
            else if selectedSec < 10 {
                routineTimer.text = String(selectedMin) + ":0" + String(selectedSec)
            }
            else {
                routineTimer.text = "0" + String(selectedMin) + ":" + String(selectedSec)
            }
        }
        else {
            routineTimer.text = String(selectedMin) + ":" + String(selectedSec)
        }
        
        exerciseTable.reloadData()
        
        updateBasics()
        
        transitionCounter = 1
        UIApplication.shared.isIdleTimerDisabled = true
        nextExercise()
        /*
        if beginRoutine {
            let pAudioPath = Bundle.main.path(forResource: storedExercisePreset, ofType: "mp3")
            do {
                try presetPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: pAudioPath!))
            }
            catch {
                //process any errors
            }
            presetPlayer.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let beginAudioPath = Bundle.main.path(forResource: "RoutineBeginning", ofType: "mp3")
                do {
                    try self.transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: beginAudioPath!))
                }
                catch {
                    //process any errors
                }
                UIApplication.shared.isIdleTimerDisabled = true
                self.transitionPlayer.play()
                
                self.transitionPlayer.delegate = self
                
                self.beginRoutine = false
            }
        }
        */
        
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.predicate = NSPredicate(format: "exerciseName = %@", routineExercises[exerciseCounter])
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let routineChecker = result.value(forKey: "whichRoutine") as? String {
                        if routineChecker == passedRoutineName {
                            if let savedCountSpeed = result.value(forKey: "countSpeed") as? Int {
                                storedCountSpeed = String(savedCountSpeed)
                            }
                            if let savedCountsIn = result.value(forKey: "countsIn") as? Int {
                                storedCountsIn = String(savedCountsIn)
                            }
                            if let savedCountsOut = result.value(forKey: "countsOut") as? Int {
                                storedCountsOut = String(savedCountsOut)
                            }
                            if let savedRepeats = result.value(forKey: "exerciseRepeat") as? Int {
                                storedRepeats = String(savedRepeats)
                                unchangedRepeats = String(savedRepeats)
                            }
                            if let savedDuration = result.value(forKey: "exerciseDuration") as? Int {
                                storedDuration = String(savedDuration)
                            }
                            if let savedHoldsIn = result.value(forKey: "holdsIn") as? Int {
                                storedHoldsIn = String(savedHoldsIn)
                            }
                            if let savedHoldsOut = result.value(forKey: "holdsOut") as? Int {
                                storedHoldsOut = String(savedHoldsOut)
                            }
                            if let savedRestCounts = result.value(forKey: "restCounts") as? Int {
                                storedRestCounts = String(savedRestCounts)
                            }
                            if let savedExercisePreset = result.value(forKey: "exercisePreset") as? String {
                                storedExercisePreset = savedExercisePreset
                            }
                            if let savedPresetRow = result.value(forKey: "presetRow") as? Int {
                                presetRow = savedPresetRow
                            }
                            if let savedVoice = result.value(forKey: "voice") as? Bool {
                                if savedVoice {
                                    storedVoice = true
                                }
                                else {
                                   storedVoice = false
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {
            // error- "Your data could not be loaded. Please try again"
        }
    }
    
    func updateBasics() {
        getData()
        
        routineSecs = calculatedRSecs % 60
        routineMins = calculatedRSecs / 60
        if routineSecs < 10 || routineMins < 10 {
            if routineSecs < 10 && routineMins < 10 {
                routineTimer.text = "0" + String(routineMins) + ":0" + String(routineSecs)
            }
            else if routineSecs < 10 {
                routineTimer.text = String(routineMins) + ":0" + String(routineSecs)
            }
            else {
                routineTimer.text = "0" + String(routineMins) + ":" + String(routineSecs)
            }
        }
        else {
            routineTimer.text = String(routineMins) + ":" + String(routineSecs)
        }
        
        
        //exerciseDisplay.text = routineExercises[exerciseCounter] + " (\(storedExercisePreset))"
        exerciseSecs = Int(storedDuration)! % 60
        exerciseMins = Int(storedDuration)! / 60
        if exerciseSecs < 10 || exerciseMins < 10 {
            if exerciseSecs < 10 && exerciseMins < 10 {
                exerciseTimer.text = "0" + String(exerciseMins) + ":0" + String(exerciseSecs)
            }
            else if exerciseSecs < 10 {
                exerciseTimer.text = String(exerciseMins) + ":0" + String(exerciseSecs)
            }
            else {
                exerciseTimer.text = "0" + String(exerciseMins) + ":" + String(exerciseSecs)
            }
        }
        else {
            exerciseTimer.text = String(exerciseMins) + ":" + String(exerciseSecs)
        }
        
        if presetRow == 1 {
            exerciseSets.text = storedCountsOut
        }
        else {
            exerciseSets.text = storedRepeats
        }
        
        
        //var tableCounter = 0
        
        let selectedRow = IndexPath(row: exerciseCounter, section: 0)
        exerciseTable.scrollToRow(at: selectedRow, at: .top, animated: true)
    }
    
    
    func nextExercise() {
        
        audioState = "play"
        if #available(iOS 13.0, *) {
            playPauseAudio.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: [])
        } else {
            // Fallback on earlier versions
        }
        
        if exerciseCounter == routineExercises.count - 1 && transitionCounter == 0 {
            continueRoutine = false
        }
        
        if continueRoutine {
            
            if transitionCounter == 0 && exerciseCounter < (routineExercises.count - 1) {
                var timeCounter = 0
                var timeDeduct = 0
                exerciseCounter = exerciseCounter + 1
                
                while timeCounter < exerciseCounter {
                    timeDeduct = timeDeduct + exerciseTimes[timeCounter]
                    timeCounter = timeCounter + 1
                }
                
                let fullDuration = (60 * selectedMin) + selectedSec
                
                calculatedRSecs = fullDuration - timeDeduct
                
                updateBasics()
                exerciseTable.reloadData()
                
            }
            transitionCounter = transitionCounter + 1
            
            if transitionCounter == 1 {
                let unoAudioPath = Bundle.main.path(forResource: "Next Exercise Pronounce", ofType: "mp3")
                do {
                    try self.transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: unoAudioPath!))
                }
                catch {
                    //process any errors
                }
            }
            else if transitionCounter == 2 {
                if storedExercisePreset == "No Preset" {
                    transitionCounter = 3
                    let xtresAudioPath = Bundle.main.path(forResource: "321 Pronounce", ofType: "mp3")
                    do {
                        try self.transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: xtresAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                }
                
                else {
                    let dosAudioPath = Bundle.main.path(forResource: self.storedExercisePreset, ofType: "mp3")
                    do {
                        try self.transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: dosAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                }
            }
            else if transitionCounter == 3 {
                let tresAudioPath = Bundle.main.path(forResource: "321 Pronounce", ofType: "mp3")
                do {
                    try self.transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: tresAudioPath!))
                }
                catch {
                    //process any errors
                }
            }
            
            transitionPlayer.delegate = self
            /*
            if !(storedExercisePreset == "No Preset" && transitionCounter == 2) {
                transitionPlayer.play()
            }
            */
            transitionPlayer.play()
        }
        
        else {
            //UIApplication.shared.beginIgnoringInteractionEvents()
            self.view.isUserInteractionEnabled = true
            let endAudioPath = Bundle.main.path(forResource: "Ending", ofType: "mp3")
            do {
                try transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: endAudioPath!))
            }
            catch {
                //process any errors
            }
            transitionPlayer.delegate = self
            transitionPlayer.play()
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            if continueRoutine {
                if transitionCounter == 3 {
                    
                    if Int(storedCountsIn)! > 0 {
                        breathe = "in"
                        setBreath = "in"
                    }
                    else {
                        if Int(storedCountsIn) == 0 {
                            breathe = "inHold"
                            setBreath = "inHold"
                            
                            if Int(storedHoldsIn) == 0 {
                                breathe = "out"
                                setBreath = "out"
                                
                                if Int(storedCountsOut) == 0 {
                                    breathe = "outHold"
                                    setBreath = "outHold"
                                }
                            }
                        }
                    }
                    
                    i = 1
                    continueExercise = true
                    continueTimer = true
                    deductSet = true
                    exerciseAudio()
                }
                else {
                    nextExercise()
                }
            }
            
            else {
                performSegue(withIdentifier: "toEnd", sender: nil)
            }
        }
    }
        
    
    
    @objc func timerRunning() {
        let breatheIn = Int(storedCountsIn)
        let breatheOut = Int(storedCountsOut)
        let inHold = Int(storedHoldsIn)
        let outHold = Int(storedHoldsOut)
        
        
        
        if i == 1 {
            if breathe == setBreath {
                //sets counter decreases by 1
                if presetRow == 0 || presetRow == 1 || presetRow == 2 || presetRow == 3 {
                    storedRepeats = String(Int(storedRepeats)! - 1)
                }
                else {
                    if deductSet {
                        storedRepeats = String(Int(storedRepeats)! - 1)
                        deductSet = false
                    }
                    else {
                        deductSet = true
                    }
                    //print(storedRepeats)
                }
                
                if Int(storedRepeats)! < 0 {
                    storedRepeats = ""
                    continueExercise = false
                    timer.invalidate()
                    
                    if storedRestCounts == "0" || storedRestCounts == "" {
                        clockTimer.invalidate()
                        transitionCounter = 0
                        nextExercise()
                    }
                    else {
                        let restAudioPath = Bundle.main.path(forResource: "Rest", ofType: "mp3")
                        do {
                            try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: restAudioPath!))
                        }
                        catch {
                           //process any errors
                        }
                        breathingPlayer.play()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(storedRestCounts)!) {
                            self.clockTimer.invalidate()
                            self.transitionCounter = 0
                            self.nextExercise()
                        }
                    }
                }
                
                else {
                    continueExercise = true
                }
                
                if !(presetRow == 1 && unchangedRepeats == "1") {
                    if storedRepeats == "" {
                        exerciseSets.text = "0"
                    }
                    else {
                        exerciseSets.text = storedRepeats
                    }
                    
                }
                
                
                
            }
            
            if continueExercise {
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
                
                if breathe == "out" {
                    let outAudioPath = Bundle.main.path(forResource: "out", ofType: "mp3")
                    do {
                        try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: outAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                    breathingPlayer.play()
                }
                if breathe == "inHold" || breathe == "outHold" {
                    let holdAudioPath = Bundle.main.path(forResource: "Hold", ofType: "mp3")
                    do {
                        try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: holdAudioPath!))
                    }
                    catch {
                        //process any errors
                    }
                    breathingPlayer.play()
                }
                
                let tickAudioPath = Bundle.main.path(forResource: "Tick", ofType: "mp3")
                do {
                    try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: tickAudioPath!))
                }
                catch {
                    //process any errors
                }
            }
        }
        
        else if continueExercise && i > 1 {
            var countdown = -1
            let tockAudioPath = Bundle.main.path(forResource: "Tock", ofType: "mp3")
            do {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: tockAudioPath!))
            }
            catch {
                //process any errors
            }
            
            if breathe == "in" {
                if breatheIn! >= 5 {
                    countdown = breatheIn! - i
                }
            }
            else if breathe == "inHold" {
                if inHold! >= 5 {
                    countdown = inHold! - i
                }
            }
            else if breathe == "out" {
                if breatheOut! >= 5 {
                    countdown = breatheOut! - i
                }
            }
            else if breathe == "outHold" {
                if outHold! >= 5 {
                    countdown = outHold! - i
                }
            }
            
            if countdown == 2 || countdown == 1 || countdown == 0 {
                if storedVoice {
                    if countdown == 2 {
                        let countAudioPath = Bundle.main.path(forResource: "3 audio", ofType: "mp3")
                        do {
                            try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: countAudioPath!))
                        }
                        catch {
                            //process any errors
                        }
                    }
                    else if countdown == 1 {
                        let countAudioPath = Bundle.main.path(forResource: "2 audio", ofType: "mp3")
                        do {
                            try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: countAudioPath!))
                        }
                        catch {
                            //process any errors
                        }
                    }
                    else if countdown == 0 {
                        let countAudioPath = Bundle.main.path(forResource: "1 audio", ofType: "mp3")
                        do {
                            try breathingPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: countAudioPath!))
                        }
                        catch {
                            //process any errors
                        }
                    }
                    
                    breathingPlayer.play()
                }
                
            }
        }
        
        if continueExercise {
            player.play()
            
            if breathe == "in" {
                if i == breatheIn {
                    if inHold != 0 {
                        breathe = "inHold"
                    }
                    else if breatheOut != 0 {
                        breathe = "out"
                    }
                    else if outHold != 0 {
                        breathe = "outHold"
                    }
                    else {
                        breathe = "in"
                    }
                    i = 0
                }
            }
            else if breathe == "inHold" {
                if i == inHold {
                    if breatheOut != 0 {
                        breathe = "out"
                    }
                    else if outHold != 0 {
                        breathe = "outHold"
                    }
                    else if breatheIn != 0 {
                        breathe = "in"
                    }
                    else {
                        breathe = "inHold"
                    }
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
                    else if inHold != 0 {
                        breathe = "inHold"
                    }
                    else {
                        breathe = "out"
                    }
                    i = 0
                }
            }
            else {
                if i == outHold {
                    if breatheIn != 0 {
                        breathe = "in"
                    }
                    else if inHold != 0 {
                        breathe = "inHold"
                    }
                    else if breatheOut != 0 {
                        breathe = "out"
                    }
                    else {
                        breathe = "outHold"
                    }
                    i = 0
                }
            }
            if presetRow == 1 && unchangedRepeats == "1" {
                if i == 0 {
                    exerciseSets.text = "0"
                }
                else {
                    exerciseSets.text = String(breatheOut! - i)
                }
                
            }
            i = i + 1
        }
    }
    
    @objc func clockRunning() {
        storedDuration = String(Int(storedDuration)! - 1)
        if Int(storedDuration)! < 0 {
            continueTimer = false
        }
        
        if continueTimer {
            exerciseSecs = Int(storedDuration)! % 60
            exerciseMins = Int(storedDuration)! / 60
            if exerciseSecs < 10 || exerciseMins < 10 {
                if exerciseSecs < 10 && exerciseMins < 10 {
                    exerciseTimer.text = "0" + String(exerciseMins) + ":0" + String(exerciseSecs)
                }
                else if exerciseSecs < 10 {
                    exerciseTimer.text = String(exerciseMins) + ":0" + String(exerciseSecs)
                }
                else {
                    exerciseTimer.text = "0" + String(exerciseMins) + ":" + String(exerciseSecs)
                }
            }
            else {
                exerciseTimer.text = String(exerciseMins) + ":" + String(exerciseSecs)
            }
            
            calculatedRSecs = calculatedRSecs - 1
            routineSecs = calculatedRSecs % 60
            routineMins = calculatedRSecs / 60
            if routineSecs < 10 || routineMins < 10 {
                if routineSecs < 10 && routineMins < 10 {
                    routineTimer.text = "0" + String(routineMins) + ":0" + String(routineSecs)
                }
                else if routineSecs < 10 {
                    routineTimer.text = String(routineMins) + ":0" + String(routineSecs)
                }
                else {
                    routineTimer.text = "0" + String(routineMins) + ":" + String(routineSecs)
                }
            }
            else {
                routineTimer.text = String(routineMins) + ":" + String(routineSecs)
            }
        }
    }
    
    func exerciseAudio() {
        var xinterval: Double
        if storedCountSpeed == "1" {
            xinterval = 2.0
        }
        else if storedCountSpeed == "2" {
            xinterval = 1.5
        }
        else if storedCountSpeed == "3" {
            xinterval = 1.0
        }
        else {
            xinterval = 0.5
        }
        timer = Timer.scheduledTimer(timeInterval: xinterval, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(clockRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(clockTimer, forMode: RunLoop.Mode.common)
    }
    
    @available(iOS 13.0, *)
    @IBAction func controlAudio(_ sender: Any) {
        UIApplication.shared.isIdleTimerDisabled = true
        if audioState == "pause" {
            audioState = "play"
            playPauseAudio.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: [])
            
            if continueExercise == false {
                transitionPlayer.play()
            }
            else {
                exerciseAudio()
            }
        }
        else {
            UIApplication.shared.isIdleTimerDisabled = false
            playPauseAudio.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: [])
            audioState = "pause"
            
            if transitionPlayer.isPlaying {
                transitionPlayer.pause()
            }
            else {
                timer.invalidate()
            }
            
            clockTimer.invalidate()
        }

    }
    
    
    @IBAction func endRoutine(_ sender: Any) {
        //UIApplication.shared.beginIgnoringInteractionEvents()
        self.view.isUserInteractionEnabled = true
        continueRoutine = false
        timer.invalidate()
        clockTimer.invalidate()
        
        let endAudioPath = Bundle.main.path(forResource: "Ending", ofType: "mp3")
        do {
            try transitionPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: endAudioPath!))
        }
        catch {
            //process any errors
        }
        
        transitionPlayer.delegate = self
        transitionPlayer.play()
    }
    
    @IBAction func nextExercise(_ sender: Any) {
        storedRepeats = ""
        continueExercise = false
        timer.invalidate()
        clockTimer.invalidate()
        
        transitionCounter = 0
        nextExercise()
    }

}
