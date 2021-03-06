//
//  PeopleInLabViewController.swift
//  dali
//
//  Created by John Kotz on 6/25/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation
import UIKit
import DALI

class PeopleInLabViewController: UITableViewController {
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
	var members: [DALIMember]?
	
	var sharedObserver: Observation?
	var timObserver: Observation?
    
    // MARK: - Lifecycle
	
	override func viewDidLoad() {
		indicator.style = UIActivityIndicatorView.Style.gray
		indicator.center = self.view.center
		self.view.addSubview(indicator)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		indicator.startAnimating()
		indicator.backgroundColor = UIColor.white
		
		reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		sharedObserver?.stop()
		timObserver?.stop()
	}
    
    // MARK: - Actions
    
    @IBAction func donePressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true) {
            
        }
    }
    
    // MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			return members?.count ?? 0
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "TIM LOCATION"
		case 1:
			return "DALI MEMBERS"
		default:
			print("Unknown section number")
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell?
		switch indexPath.section {
		case 0:
			cell = tableView.dequeueReusableCell(withIdentifier: "timCell", for: indexPath)
			
			cell?.textLabel?.text = "Tim Tregubov"
            var text = "Location unknown"
            if DALILocation.Tim.current?.inDALI ?? false {
                text = "In DALI"
            } else if DALILocation.Tim.current?.inOffice ?? false {
                text = "In Office"
            }
			cell?.detailTextLabel?.text = text
			
		case 1:
			cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
			let member = members![indexPath.row]
			cell?.textLabel?.text = member.name
			
		default:
			return UITableViewCell()
		}
		
		return cell!
	}
    
    // MARK: - Helpers
    
    func reloadData() {
        timObserver = DALILocation.Tim.observe { (_, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        sharedObserver = DALILocation.Shared.observe { (members, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let members = members else {
                return
            }
            
            self.members = members
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.tableView.reloadData()
            }
        }
    }
}
