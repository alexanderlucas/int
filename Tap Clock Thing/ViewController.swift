
//
//  ViewController.swift
//  Tap Clock Thing
//
//  Created by Alex Lucas on 1/24/16.
//  Copyright © 2016 tbd. All rights reserved.
//

import UIKit
import WatchConnectivity



class ViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!
    @IBOutlet weak var buttonSix: UIButton!
    @IBOutlet weak var buttonSeven: UIButton!
    @IBOutlet weak var buttonEight: UIButton!
    
    @IBOutlet weak var HMSView: UIView!
    
    @IBOutlet weak var flashView: UIView!
    
    var endTime = Date()
    
    var setting = false
    
    
    var timer = Timer()
    
    var time = 0.0
    
    var count:Countdown!
    
    var lastY:CGFloat!
    
    var first = true
    
    var buttonArray = [UIButton]()
    
    var alertDict = [String:Bool]()
    
    var started = false
    
    let defaults = UserDefaults(suiteName: "group.com.alexanderlucas.int")
    
    var device = UIDevice.current.modelName

    
    fileprivate var _session: AnyObject?
    @available(iOS 9.0, *)
    var session: WCSession? {
        get {
            return _session as? WCSession
        }
        set {
            _session = newValue
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.datePicker.center.y += self.datePicker.bounds.height
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "intbg.png")!);
        defaults?.synchronize()
        
        print(device)

        time = defaults!.double(forKey: "time")
        
        endTime = Date(timeIntervalSinceNow: time)

        print(time)
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)

        HMSView.isHidden = true
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.view.bounds

        view.addSubview(blurView)
        
        datePicker.setValue(UIColor(red: 0, green: 0, blue: 0x4F / 255.0, alpha: 1), forKey: "textColor")
        datePicker.setValue(UIColor.clear, forKey: "backgroundColor")
//        datePicker.subviews[0].subviews[1].backgroundColor = UIColor.whiteColor()
//        datePicker.subviews[0].subviews[2].backgroundColor = UIColor.whiteColor()
        
        var dateComp : DateComponents = DateComponents()
        dateComp.hour = 0
        dateComp.minute = 1
        (dateComp as NSDateComponents).timeZone = TimeZone.current
        let calendar : Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date : Date = calendar.date(from: dateComp)!
        
        datePicker.setDate(date, animated: true)


        first = true

        
//        MSView.layer.borderWidth = 1
//        MSView.layer.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1.0).CGColor
        
        setButton.setTitle("", for: .disabled)
        
        startButton.setTitle("Stop", for: UIControlState.selected)
        
        startButton.setTitleColor(UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1), for: .disabled)
        
        buttonArray.append(buttonOne)
        buttonArray.append(buttonTwo)
        buttonArray.append(buttonThree)
        buttonArray.append(buttonFour)
        buttonArray.append(buttonFive)
        buttonArray.append(buttonSix)
        buttonArray.append(buttonSeven)
        buttonArray.append(buttonEight)
        
        startButton.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), for: .highlighted)
        
        for i in 0..<buttonArray.count {
            buttonArray[i].layer.borderWidth = 2
            buttonArray[i].layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor
            alertDict[buttonArray[i].titleLabel!.text!] = defaults!.bool(forKey: buttonArray[i].titleLabel!.text!)
            if((alertDict[buttonArray[i].titleLabel!.text!])==true){
                buttonArray[i].layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1).cgColor

                buttonArray[i].isSelected = true
            }
        }
        
        startButton.layer.borderColor = UIColor(red: 0x1b / 255.0, green: 0x7f / 255.0, blue: 0x3a / 255.0, alpha: 1).cgColor
        startButton.layer.borderWidth = 3
        startButton.setTitleColor(UIColor(red: 0x1b / 255.0, green: 0x7f / 255.0, blue: 0x3a / 255.0, alpha: 1), for: UIControlState())
        startButton.backgroundColor = UIColor.clear
        //pauseButton.enabled = false;
        
        updateText()
        disableUnusableButtons()

        
        if(time == 0) {
//            minuteLabel.hidden = true
//            secondLabel.hidden = true
//            msColon.hidden = true
            startButton.isEnabled = false
        }
        
        defaults?.synchronize()
        
        setShortcut()

        if #available(iOS 9.0, *) {
            switch device {
            case "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone SE", "iPhone 4s", "iPhone 4", "iPod Touch 5", "iPod Touch 6":
                timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 70, weight: UIFontWeightThin)

            default:
                timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 90, weight: UIFontWeightThin)

            }
        } else {
            // Fallback on earlier versions
        }

    }
    func setShortcut() {
        if(!started){
            if #available(iOS 9.1, *) {
                let shortcut = UIApplicationShortcutItem(type: "com.alexanderlucas.int.startlasttimer", localizedTitle: "Start Previous", localizedSubtitle: formatTime(), icon: UIApplicationShortcutIcon(type: .time), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcut]
            
            } else {
            // Fallback on earlier versions
                if #available(iOS 9.0, *) {
                    let shortcut = UIApplicationShortcutItem(type: "com.alexanderlucas.int.startlasttimer", localizedTitle: "Start Previous", localizedSubtitle: formatTime(), icon: UIApplicationShortcutIcon(type: .play), userInfo: nil)
                    UIApplication.shared.shortcutItems = [shortcut]
                
                } else {
                // Fallback on earlier versions
                }
            }
        }
        else {
            if #available(iOS 9.1, *) {
                let shortcut = UIApplicationShortcutItem(type: "com.alexanderlucas.int.stoplasttimer", localizedTitle: "Stop Timer", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .prohibit), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcut]
                
            } else {
                if #available(iOS 9.0, *) {
                    let shortcut = UIApplicationShortcutItem(type: "com.alexanderlucas.int.stoplasttimer", localizedTitle: "Stop Timer", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .pause), userInfo: nil)
                    UIApplication.shared.shortcutItems = [shortcut]
                    
                } else {
                    // Fallback on earlier versions
                }
            }
        }

    }
    
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
      //  let counterValue = message["counterValue"] as? String
        
        print(message)
        time = defaults!.double(forKey: "time")
        defaults?.synchronize()

        print(time)
        
        endTime = message["endDate"] as! Date

        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
//            self.counterData.append(counterValue!)
//            self.mainTableView.reloadData()
            if(message["starting"] as! Bool){
                self.start()
            }
            else {
                self.stop()
            }

        }
        started = !started

    }

    
    override func viewDidLayoutSubviews() {
        if(first){
            lastY = datePicker.center.y
            first = false
        }

     //   startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.height
        startButton.clipsToBounds = true
        
        
        for i in 0..<buttonArray.count {
            buttonArray[i].layer.cornerRadius = 0.5 * buttonArray[i].bounds.size.height
            buttonArray[i].clipsToBounds = true
           buttonArray[i].setTitleColor(UIColor.white, for: .selected)
            buttonArray[i].setTitleColor(UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1), for: [.disabled, .selected])
            buttonArray[i].setTitleColor(UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1), for: .disabled)

           // buttonArray[i].setTitle("moo", forState: .Disabled)
           
        }

        
        datePicker.center.y = lastY

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return
            UIStatusBarStyle.default
    }
  
    
    @IBAction func startButtonPressed(_ sender: AnyObject) {
        if(started){
            stop()
//            let starting = [
//                "phoneStarting": false,
//                "phoneEndDate" : endTime,
//                "formattedText" : formatTime()
//            ]
//            if #available(iOS 9.0, *) {
//                session!.sendMessage(starting, replyHandler: {(_: [String : AnyObject]) -> Void in
//                    // handle reply from iPhone app here
//                    }, errorHandler: {(error ) -> Void in
//                        // catch any errors here
//                })
//            } else {
//                // Fallback on earlier versions
//            }

        }
        else{
//            let starting = [
//                "phoneStarting": true,
//                "phoneEndDate": endTime
//                ]
//            if #available(iOS 9.0, *) {
//                if(device != "iPhone 4s"){
//                session!.sendMessage(starting, replyHandler: {(_: [String : AnyObject]) -> Void in
//                    // handle reply from iPhone app here
//                    }, errorHandler: {(error ) -> Void in
//                        // catch any errors here
//                })
//            } else {
//                // Fallback on earlier versions
//                }
//            }

            start()
        }
        
        defaults?.synchronize()

        
        
    }

    @IBAction func setButtonPressed(_ sender: AnyObject) {
        print(datePicker.center.y)

        setting = !setting
        

//        if(datePicker.hidden){
//            print("unhiding")
//            
//            datePicker.hidden = false
//        }


        UIView.animate(withDuration: 0.6, animations: {
            
            if(self.setting){
                print("true")
                //self.datePicker.hidden = false
                self.datePicker.center.y += (self.datePicker.bounds.height + 15)
                self.datePicker.countDownDuration = self.time
                self.datePicker.alpha = 1
                self.datePicker.isEnabled = true
                self.HMSView.alpha = 0
                self.startButton.isEnabled = false
            }
            else {
                print("false")
                self.datePicker.center.y -= (self.datePicker.bounds.height + 15)
                //self.datePicker.hidden = true
                self.time = self.datePicker.countDownDuration
                self.defaults!.set(self.time, forKey: "time")
                self.datePicker.alpha = 0
                self.datePicker.isEnabled = false
                self.HMSView.alpha = 1

                self.startButton.isEnabled = true
            }
        })
        
        
        endTime = Date(timeIntervalSinceNow: time)
        
        lastY = datePicker.center.y

        updateText()
        disableUnusableButtons()

    }

    @IBAction func buttonPressed(_ sender: AnyObject) {
        let but = sender as! UIButton
        if but.isSelected {
           // but.layer.borderColor = UIColor.blackColor().CGColor
            //but.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).CGColor
            but.layer.backgroundColor = UIColor.clear.cgColor
            alertDict[but.titleLabel!.text!] = false
            defaults!.set(false, forKey: but.titleLabel!.text!)

        }
        else {
           // but.layer.borderColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0).CGColor
            but.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0x4F / 255.0, alpha: 1).cgColor
            alertDict[but.titleLabel!.text!] = true
            defaults!.set(true, forKey: but.titleLabel!.text!)


        }
        but.isSelected = !but.isSelected
    }
    
    func disableButtons() {
        for i in 0..<buttonArray.count {
            buttonArray[i].isEnabled = false
            if(!buttonArray[i].isSelected){
                buttonArray[i].layer.borderColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0).cgColor
                
            }
        }
    }
    
    func enableButtons() {
        for i in 0..<buttonArray.count {
            buttonArray[i].isEnabled = true
            buttonArray[i].layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor

        }
    }
    
    func setAlerts() {
        let keys = (alertDict as NSDictionary).allKeys(for: true) as! [String]
        
        for i in 0..<keys.count {
            print(keys[i])
            count.addFireTime(keys[i])
        }
    }
    
    func countDown() {
        time -= 0.1
        
        if (time <= 1){
            flash()
            timer.invalidate()
            time = 0
            stop()
//            let starting = [
//                "phoneStarting": false,
//                "phoneEndDate" : endTime,
//                "formattedText" : formatTime()
//            ]
//            if #available(iOS 9.0, *) {
//                session!.sendMessage(starting, replyHandler: {(_: [String : AnyObject]) -> Void in
//                    // handle reply from iPhone app here
//                    }, errorHandler: {(error ) -> Void in
//                        // catch any errors here
//                })
//            } else {
//                // Fallback on earlier versions
//            }


        }
        
        updateText()
        
    }
    
    func start() {
        started = true
        startButton.setTitle("Stop", for: UIControlState())
        //startButton.backgroundColor = UIColor(red: 0xa0 / 255.0, green: 0, blue: 2/255.0, alpha: 1)
        
        startButton.setTitleColor(UIColor(red: 0xa0 / 255.0, green: 0, blue: 2/255.0, alpha: 1), for: UIControlState())
        startButton.layer.borderColor = UIColor(red: 0xa0 / 255.0, green: 0, blue: 2/255.0, alpha: 1).cgColor
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.countDown), userInfo: nil, repeats: true)
        print(timer)
        
        
        count = Countdown(start: Date(timeIntervalSinceNow: 0), end: endTime, int: time)
        
        setButton.isEnabled = false
        
        disableButtons()
        
        setAlerts()
        UIApplication.shared.cancelAllLocalNotifications()

        count.setNotifications()
        

       
    }
    
    func stop(){
        started = false
        timer.invalidate()
        
        time = defaults!.double(forKey: "time")
        
        updateText()
        
        setButton.isEnabled = true
        
        enableButtons()
        disableUnusableButtons()
        
        UIApplication.shared.cancelAllLocalNotifications()
        //startButton.backgroundColor = UIColor(red: 0x1b / 255.0, green: 0x7f / 255.0, blue: 0x3a / 255.0, alpha: 1)
        startButton.layer.borderColor = UIColor(red: 0x1b / 255.0, green: 0x7f / 255.0, blue: 0x3a / 255.0, alpha: 1).cgColor
        
        startButton.setTitleColor(UIColor(red: 0x1b / 255.0, green: 0x7f / 255.0, blue: 0x3a / 255.0, alpha: 1), for: UIControlState())
        startButton.setTitle("Start", for: UIControlState())

        
        


    }
    
    func flash() {
        flashView.backgroundColor = UIColor.white
        UIView.animate(withDuration: 2, animations: {
            self.flashView.backgroundColor = UIColor.clear
        })

    }

    func updateTime() {
        let interval = endTime.timeIntervalSinceNow
        if(interval<=0) {
            stop()
        }
        else {
            time = interval
        }
    }
    
//    func isEvening() -> Bool {
//        let now = NSDate()
//        
//        return false;
//    }
//    
    
    
    
    func updateText() {
        HMSView.isHidden = false
        let total = round(time * 100) / 100
        let intTot = Int(total)
        
        let hours = intTot/3600
        let minutes = (intTot % 3600)/60
        let seconds = ((intTot % 3600)%60)%60
        
        var hoursText = ""
        var minutesText = String(minutes)
        var secondsText = String(seconds)
        
        if(minutes<10){
            minutesText = "0" + minutesText
        }
        
        if(seconds<10){
            secondsText = "0" + secondsText
        }
        
        if(hours>=1){
           // HMSView.hidden = false
           // MSView.hidden = true
            hoursText = String(hours)
            if(hours<10){
                hoursText = "0" + hoursText + ":"
            }
            else {
                hoursText = hoursText + ":"
            }
            
            //startButton.enabled = true

//            hourLabel.text = hoursText
//            hminuteLabel.text = minutesText
//            hsecondLabel.text = secondsText
        }
//        else if(time > 0){
////            minuteLabel.hidden = false
////            secondLabel.hidden = false
////            msColon.hidden = false
//            
//           // startButton.enabled = true
//
//            HMSView.hidden = true
//     //       MSView.hidden = false
////            minuteLabel.text = minutesText
////            secondLabel.text = secondsText
//        }
        
        timeLabel.text = hoursText + minutesText + ":" + secondsText
    }
    
    func disableUnusableButtons() {
        for button in buttonArray {
            print(button.currentTitle!)
            switch button.currentTitle! {
            case "5m":
                if(time <= 300) {
                    button.isEnabled = false
                    button.layer.borderColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0).cgColor

                    button.isSelected = false
                    button.layer.backgroundColor = UIColor.clear.cgColor
                    alertDict[button.titleLabel!.text!] = false
                    defaults!.set(false, forKey: button.titleLabel!.text!)
                }
                else {
                    button.isEnabled = true
                    button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor

                }
            case "Every 5":
                if(time <= 300 || time.truncatingRemainder(dividingBy: 300) != 0){
                    button.isEnabled = false
                    button.layer.borderColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0).cgColor
                    
                    button.isSelected = false
                    button.layer.backgroundColor = UIColor.clear.cgColor
                    alertDict[button.titleLabel!.text!] = false
                    defaults!.set(false, forKey: button.titleLabel!.text!)
                }
                else{
                    button.isEnabled = true
                    button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor
                }
            case "1m", "Every 1":
                if(time <= 60) {
                    button.isEnabled = false
                    button.layer.borderColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0).cgColor
                    
                    button.isSelected = false
                    button.layer.backgroundColor = UIColor.clear.cgColor
                    alertDict[button.titleLabel!.text!] = false
                    defaults!.set(false, forKey: button.titleLabel!.text!)
                }
                else {
                    button.isEnabled = true
                    button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor

                }
            case "2m":
                if(time <= 120) {
                    button.isEnabled = false
                    button.layer.borderColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0).cgColor
                    
                    button.isSelected = false
                    button.layer.backgroundColor = UIColor.clear.cgColor
                    alertDict[button.titleLabel!.text!] = false
                    defaults!.set(false, forKey: button.titleLabel!.text!)
                }
                else {
                    button.isEnabled = true
                    button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0x4f / 255.0, alpha: 1.0).cgColor

                }
            default:
                print("nope")
            }
        }
    }
    
    func formatTime() -> String {
        let total = round(time * 100) / 100
        let intTot = Int(total)
        
        let hours = intTot/3600
        let minutes = (intTot % 3600)/60
        let seconds = ((intTot % 3600)%60)%60
        
        var hoursText = ""
        var minutesText = String(minutes)
        var secondsText = String(seconds)
        
        var timeText = ""
        
        if(minutes<10){
            minutesText = "0" + minutesText
        }
        
        if(seconds<10){
            secondsText = "0" + secondsText
        }
        
        if(hours>=1){
            HMSView.isHidden = false
           // MSView.hidden = true
            hoursText = String(hours)
            if(hours<10){
                hoursText = "0" + hoursText
            }
            
            //startButton.enabled = true
            timeText = hoursText+":"+minutesText+":"+secondsText
            
        }
        else if(time > 0){
            
            timeText = minutesText+":"+secondsText

        }
        
        return timeText
    }
    
   }

