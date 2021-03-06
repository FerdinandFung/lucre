//
//  DashboardTableViewController.swift
//  Sanity
//
//  Created by Jordan Coppert on 10/7/17.
//  Copyright © 2017 CSC310Team22. All rights reserved.
//
import UIKit
import Firebase
class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userEmail: String!
    var budgets = [Budget]()
    
    @IBOutlet weak var placeholder: UILabel!
    @IBAction func addButtonPress(_ sender: Any) {
        // Create the action sheet
        let myActionSheet = UIAlertController(title: "Add", message: "Add new budget or transaction?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let transactionAction = UIAlertAction(title: "Transaction", style: UIAlertActionStyle.default) { (action) in
            if !self.budgets.isEmpty{
                self.performSegue(withIdentifier: "addTransactionSegue", sender: self)
            } else{
                let alert = UIAlertController(title: "No Existing Budgets", message: "You must create a budget before adding a transaction!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let budgetAction = UIAlertAction(title: "Budget", style: UIAlertActionStyle.default) { (action) in
            self.performSegue(withIdentifier: "addBudgetSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
        }
        
        // add action buttons to action sheet
        myActionSheet.addAction(transactionAction)
        myActionSheet.addAction(budgetAction)
        myActionSheet.addAction(cancelAction)
        
        // present the action sheet
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 101
        fetchBudgets()
        tableView.reloadData()
        tableView.refreshControl = self.refreshControl
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(refreshControl: UIRefreshControl){
        self.fetchBudgets()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "budget", for: indexPath)
        if let cell = dequeued as? BudgetOverviewCell {
            cell.backgroundColor = UIColor(red: 204.0/255.0, green: 248.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            let currentBudget = budgets[indexPath.row]
            cell.budgetName.text = currentBudget.getName()
            
            cell.budgetRemaining.text = "$" + String(format: "%.2f", currentBudget.getBudgetRemaining());
         
            cell.budgetRemaining.textColor = UIColor.green
            if currentBudget.getBudgetRemaining() > 0.0 {
                cell.budgetRemaining.textColor = UIColor.green
            }
            else {
                cell.budgetRemaining.textColor = UIColor.red
            }
            var floatBudgetRemaining = Float(currentBudget.getBudgetRemaining())
            floatBudgetRemaining = floatBudgetRemaining / Float(currentBudget.getTotalBudget())
            cell.progressBar.setProgress(floatBudgetRemaining, animated: false)
            
            
            let calendar = NSCalendar.current
            
            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: Date())
            let date2 = calendar.startOfDay(for: currentBudget.getResetDate())
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            
            cell.daysUntilReset.text = (String(describing: components.day!)) + " days left"
            return cell
        }
        return dequeued
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            deleteBudget(budgetName: budgets[indexPath.row].getName())
        }
    }
    
    func deleteBudget(budgetName: String){
        Firestore.firestore().collection("Users").document(userEmail!).collection("Budgets").document(budgetName).delete(completion: {err in
            self.fetchBudgets()
        })
    }
    
    //Trigger segue to budget detail view once a budget row is tapped in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "budgetDetail", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "budgetDet", sender: budgets[indexPath.row])
    }
    
    func fetchBudgets(){
        let collRef: CollectionReference = Firestore.firestore().collection("Users/\(userEmail!)/Budgets")
        collRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
            } else {
                self.budgets = querySnapshot!.documents.flatMap({Budget(dictionary: $0.data())})
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                //if there are no budgets to display, populate placeholder and hide table
                if self.budgets.isEmpty{
                    self.placeholder.isHidden = false
                    self.placeholder.text = "You have no budgets to display! Start tracking!"
                    self.placeholder.font = UIFont(name: "DidactGothic-Regular", size: 20)
                    self.tableView.isHidden = true
                } else{
                    self.placeholder.isHidden = true
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "addTransactionSegue":
                let backItem = UIBarButtonItem()
                backItem.title = "Cancel"
                navigationItem.backBarButtonItem = backItem
                let vc = segue.destination as? AddTransactionViewController
                vc?.userEmail = userEmail
            case "addBudgetSegue":
                let backItem = UIBarButtonItem()
                backItem.title = "Cancel"
                navigationItem.backBarButtonItem = backItem
                let vc = segue.destination as? AddBudgetViewController
                vc?.userEmail = userEmail
            case "budgetDet":
                let vc = segue.destination as? BudgetDetailViewController
                //                let cell = sender as? BudgetOverviewCell
                //                vc?.budgetName = cell?.budgetName.text!
                //                vc?.userEmail = userEmail
                let budget = sender as? Budget
                vc?.budget = budget
                vc?.userEmail = userEmail
            case "settingsSegue":
                let backItem = UIBarButtonItem()
                backItem.title = "Budgets"
                navigationItem.backBarButtonItem = backItem
                let vc = segue.destination as? SettingsViewController
                vc?.userEmail = userEmail
            default: break
            }
        }
    }
    
}
