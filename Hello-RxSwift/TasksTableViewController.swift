//
//  TasksTableViewController.swift
//  Hello-RxSwift
//
//  Created by Mohammad Azam on 4/11/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct Task {
    var title: String
}

class TasksTableViewController: UITableViewController {
    
    @IBOutlet weak var addTaskBarButton: UIBarButtonItem!
    
    private var taskDetailsVC: TaskDetailsViewController!
    private var tasks: BehaviorRelay<[Task]> = BehaviorRelay(value: [])
    var tasksDriver: Driver<[Task]> {
        return tasks.asDriver()
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetailsViewController") as? TaskDetailsViewController
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        bindUI()
    }
    
    private func bindUI() {
        
        bindAddTaskButtonTap()
        bindTableView()
        bindTableViewSelected()
    }
    
    private func bindTableViewSelected() {
        
        tableView
            .rx
            .modelSelected(Task.self)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                guard let taskDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetailsViewController") as? TaskDetailsViewController else {
                    fatalError("TaskDetailsViewController not found")
                }
                self.navigationController?.pushViewController(taskDetailsVC, animated: true)
            }).disposed(by: disposeBag)

    }
    
    private func bindTableView() {
        
        tasks.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element.title
                
        }.disposed(by: disposeBag)
        
        taskDetailsVC.taskDriver.drive(onNext: { [weak self] task in
            guard let task = task, task.title != "" else { return }
            self?.tasks.accept((self?.tasks.value)! + [task])
            self?.taskDetailsVC.dismiss(animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
        
        // just adding an item for demoing purposes!
        tasks.accept(tasks.value + [Task(title: "Feed the dog")])
    }
    
    private func bindAddTaskButtonTap() {
       
        self.addTaskBarButton.rx.tap
            .throttle(RxTimeInterval.milliseconds(5), latest: false, scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.present(self.taskDetailsVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
}
