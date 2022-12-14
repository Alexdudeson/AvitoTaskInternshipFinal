//
//  ViewController.swift
//  AvitoTaskInternship
//
//  Created by Alexey Yarov on 30.10.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private var employeesLoader = EmployeesLoader()
    private var companies: [Сompany] = []
    var employees: [Employee] = []
    var triggerCash = false
    private enum EmployeesNotFound: Error {
        case codeError
    }

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelButton: UIBarButtonItem!
    @IBOutlet weak var labelCompany: UILabel!

    @IBAction func loadNewData(_ sender: Any) {
        if (triggerCash == true) {
            print("Old Data")
        } else {
            loadData()
            print("New Data")
        }
        sortingEmployees()
        labelCompany.text = companies[0].name
        tableView.reloadData()
        labelButton.title = "Reload Data"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadData()
    }

    func sortingEmployees() {
        employees = companies[0].employees
        employees = employees.sorted(by: { $0.name < $1.name })
        print(employees.map {$0.name})
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    private func showLoadingIndicator(_ available: Bool) {
        activityIndicator.isHidden = !available
        available ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        let confirmAction = UIAlertAction(
            title: "Try Again", style: .default) { (action) in
                self.loadData()
            }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Load&Saving

    func loadData(){
        showLoadingIndicator(true)
        employeesLoader.loadEmployees{ result in
            DispatchQueue.main.async{ [weak self] in
                guard let self = self else { return }
                switch result{
                case .success(let companies):
                    if [companies.company].isEmpty{
                        self.didFailToLoadData(with: EmployeesNotFound.codeError)
                    } else {
                        self.companies = [companies.company]
                        self.saveData(companies: self.companies)
                    }
                case .failure(let error):
                    self.didFailToLoadData(with: error)
                }
                self.showLoadingIndicator(false)
            }
        }
    }

    func saveData(companies: [Сompany]){
        print("saveData")
        self.companies = companies
        savindData()
        triggerCash = true
    }
//MARK: - Timer for saving
    
    func savindData(){
        if !triggerCash{
            DispatchQueue.main.asyncAfter(deadline:.now() + (60 * 60.0)){[self] in
                print("cash.removeAll")
                triggerCash = false
            }
        }
    }
}

// MARK: - TableView

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.isEmpty ? 0 : employees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }

    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "\(employees[indexPath.row].name)"
            var listOfSkills = "Phone:\t\(employees[indexPath.row].phone_number)\nSkills:\t"
            for skill in employees[indexPath.row].skills {
                listOfSkills += "\(skill), "
                }
            listOfSkills = listOfSkills.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
            configuration.secondaryText = listOfSkills
            cell.contentConfiguration = configuration
        } else {
            var listOfSkills = ""
            for skill in employees[indexPath.row].skills {
                listOfSkills += "\(skill), "
                }
            listOfSkills = listOfSkills.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
            cell.textLabel?.text = "\(employees[indexPath.row].name)\t (\(employees[indexPath.row].phone_number))"
            cell.detailTextLabel?.text = listOfSkills
        }
    }
}

// MARK: - TableView extension for deleting

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("You deleted -  \(employees[indexPath.row].name)")
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.employees.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}


