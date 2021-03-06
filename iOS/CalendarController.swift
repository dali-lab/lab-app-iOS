//
//  CalendarController.swift
//  DALISwift
//
//  Created by John Kotz on 7/12/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI
import SCLAlertView
import DALI

class CalendarController: NSObject, EKCalendarChooserDelegate {
    static private var _shared: CalendarController?
    static var shared: CalendarController {
        if _shared == nil {
            _shared = CalendarController()
        }
        return _shared!
    }
    
	let eventStore = EKEventStore()
	var event: DALIEvent!
	
	let eventView: EKCalendarChooser
	let navControl: UINavigationController
	
	override init() {
		eventView = EKCalendarChooser(selectionStyle: EKCalendarChooserSelectionStyle.single,
                                      displayStyle: EKCalendarChooserDisplayStyle.writableCalendarsOnly,
                                      entityType: EKEntityType.event, eventStore: self.eventStore)
		eventView.selectedCalendars = Set()
		navControl = UINavigationController(rootViewController: self.eventView)
		
		super.init()
		
		eventView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                      target: self,
                                                                      action: #selector(self.calendarChooserDidFinish))
		eventView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                     target: self,
                                                                     action: #selector(self.calendarChooserDidCancel))
	}
	
	func checkPermissions(callback: ((Bool) -> Void)?) {
		let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
		
		switch status {
		case EKAuthorizationStatus.notDetermined:
			// This happens on first-run
			self.requestPermissions(callback)
		case EKAuthorizationStatus.authorized:
			// Things are in line with being able to show the calendars in the table view
            callback?(true)
		case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
			// We need to help them give us permission
			callback?(false)
        default:
            callback?(false)
        }
	}
	
	func requestPermissions(_ callback: ((Bool) -> Void)?) {
		DispatchQueue.main.async {
			self.eventStore.requestAccess(to: EKEntityType.event) { (accessGranted: Bool, _) in
				callback?(accessGranted)
			}
		}
	}
	
	@objc func calendarChooserDidCancel() {
		self.navControl.dismiss(animated: true) {}
	}
	
	@objc func calendarChooserDidFinish() {
		if eventView.selectedCalendars.count == 0 {
			SCLAlertView().showError("Please select one", subTitle: "")
			return
		}
		
		for calender in eventView.selectedCalendars {
			let event = EKEvent(eventStore: self.eventStore)
		
			event.title = self.event.name
			event.startDate = self.event.start
			event.endDate = self.event.end
			event.location = self.event.location
            let description = self.event.description == nil ? "Description: \(self.event.description!)\n\n" : ""
			event.notes = "\(description)ID: \(self.event.id!)"
			
			event.calendar = calender
			
			do {
				try eventStore.save(event, span: .thisEvent)
			} catch let error as NSError {
				print("failed to save event with error : \(error)")
				
				DispatchQueue.main.async {
					SCLAlertView().showError("Encountered error!", subTitle: error.localizedDescription)
				}
			}
		}
		
		DispatchQueue.main.async {
			self.navControl.dismiss(animated: true) {}
		}
	}
	
	func showCalendarChooser(on vc: UIViewController) {
		self.checkPermissions { (success) in
			if success {
				
				self.navControl.modalPresentationStyle = .popover
				
				DispatchQueue.main.async {
					vc.present(self.navControl, animated: true, completion: {})
				}
			} else {
				SCLAlertView().showError("Cant access calendar!",
                                         subTitle: "You may have not allowed access to your calendar." +
                                            " Change this in your phone settings to put events on your calendar")
			}
		}
	}
}
