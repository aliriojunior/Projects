//
//  ViewController.swift
//  Lab 0 Alirio da Rocha
//
//  Created by Alirio Da Rocha on 8/20/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstNameTexTfield: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    
    @IBOutlet weak var yearSegmentedControl: UISegmentedControl!
    @IBOutlet weak var numberOfPetsLabels: UILabel!
    
    @IBOutlet weak var morePetsStepper: UIStepper!
    

    
    @IBOutlet weak var morePetsSwitch: UISwitch!
    
    @IBAction func introduceSelfDidTap(_ sender: UIButton) {
        
        
        // Let's us chose the title we have selected from the segmented control
        let year = yearSegmentedControl.titleForSegment(at: yearSegmentedControl.selectedSegmentIndex)
        
        // Creating a variable of type string, that holds an introduction. The introduction interpolates the values from the text fields provided.
        // Currently we can only present the information in a print statement. However, this lets us verify that our app is printing out what is intended!
        
        let introduction = "My name is \(firstNameTexTfield.text!) \(lastNameTextField.text!) and I attend \(schoolNameTextField.text!). " +
            "I am currently in my \(year!) year and I own \(numberOfPetsLabels	.text!) dogs. " +
            "It is \(morePetsSwitch.isOn) that I want more pets."
        
        
        // Creates the alert where we pass in our message, which our introduction.
        let alertController = UIAlertController(title: "My Introduction", message: introduction, preferredStyle: .alert)
        
        // A way to dismiss the box once it pops up
        let action = UIAlertAction(title: "Nice to meet you!", style: .default, handler: nil)
        
        // Passing this action to the alert controller so it can be dismissed
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func stepperDidChange(_ sender: UIStepper) {
        
        numberOfPetsLabels.text = "\(Int(sender.value))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

