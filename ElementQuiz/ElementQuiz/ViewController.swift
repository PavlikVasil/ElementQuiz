//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Павел on 08.01.2020.
//  Copyright © 2020 Павел. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    struct AppUtility {

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

            self.lockOrientation(orientation)

            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateElement()
        TextField.delegate=self
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
            //Stop listening for keyboard hide/show events
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        TextField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
    if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
             view.frame.origin.y = -keyboardRect.height
        } else {
        view.frame.origin.y = 0
        }
    }

    @IBAction func enterTap(_ sender: UIButton) {
        
        if TextField.text==elementList[currentElementIndex]{
                answerLabel.text = "Верно"
                scoreCounter += 10
                score.text = "Score: \(scoreCounter)"
                elementList.remove(at: currentElementIndex)
            if elementList.count == 0 {
                answerLabel.text = "Your score: \(scoreCounter)"
                sender.isEnabled = false
                
            }
                TextField.text = ""
        }else {
         answerLabel.text = "Неверно"
         scoreCounter = scoreCounter - 5
         score.text = "Score: \(scoreCounter)"
         TextField.text = ""
            }
        }
    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var score: UILabel!
    
    var elementList = ["Протон", "Нейтрон", "Электрон", "Плутон"]
    var currentElementIndex = 0
    var scoreCounter = 0

    func updateElement() {
        answerLabel.text = "?"
        if elementList.isEmpty{
            answerLabel.text = "Your score: \(scoreCounter)"
        } else {
            let elementName = elementList[currentElementIndex]
            let image = UIImage(named: elementName)
            imageView.image = image
            TextField.text = ""
        }
    }
    
    @IBAction func showAnswer(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1105))
        if elementList.isEmpty{
            answerLabel.text = "Your score: "
        } else {
          answerLabel.text = elementList[currentElementIndex]
          elementList.remove(at: currentElementIndex)
                     if elementList.count == 0 {
                         answerLabel.text = "Your score: \(scoreCounter)"
                         sender.isEnabled = false
                        
                     }
        }
    }
    
    @IBAction func gotoNextElement(_ sender: Any) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        currentElementIndex += 1
        if currentElementIndex >= elementList.count{
            currentElementIndex = 0
        }
        updateElement()
    }
    
    @IBAction func gotoPrevious(_ sender: Any) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        currentElementIndex = currentElementIndex - 1
        if currentElementIndex == -1{
            currentElementIndex = elementList.count-1
        }
        updateElement()
    }
}

