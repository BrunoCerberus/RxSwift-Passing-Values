//
//  TaskDetailsViewController.swift
//  Hello-RxSwift
//
//  Created by Mohammad Azam on 4/11/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TaskDetailsViewController : UIViewController {
    
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    private var disposeBag = DisposeBag()
    
    private var task: BehaviorRelay<Task?> = BehaviorRelay(value: nil)
    var taskDriver: Driver<Task?> {
        return task.asDriver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        taskTitleTextField.text = ""
    }
    
    @IBAction func passButtonPressed() {
        
        self.task.accept(Task(title: self.taskTitleTextField.text!))
    }
}
