//
//  LogTableViewController.swift
//  BeaconReceiver
//
//  Created by harada on 2014/10/26.
//  Copyright (c) 2014年 harada. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class LogTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        let currentInstallation = PFInstallation.currentInstallation()
        if(currentInstallation.badge != 0){
            currentInstallation.badge = 0;
            currentInstallation.saveEventually()
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        
        let fetchRequest = NSFetchRequest(entityName: "Logs");
        
        
        let dateSort =
        NSSortDescriptor(key: "date", ascending: false)
       
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: appDelegate.managedObjectContext!, sectionNameKeyPath: nil,
            cacheName: nil);
        fetchedResultsController.delegate = self;
        
        
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)) {
            println("Error: \(error?.localizedDescription)") }        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadHtml:", name: newHtmlNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadHtml(notification:NSNotification){
        
//        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        let html = appDelegate.html;
        
//        println(html)
        
    }
    
    // MARK : tableview
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return fetchedResultsController.sections!.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let resuseIdentifier = "DefaultCell"
        
        var cell =
        tableView.dequeueReusableCellWithIdentifier(
            resuseIdentifier, forIndexPath: indexPath) as TDBadgedCell;
        
        let log =
        fetchedResultsController.objectAtIndexPath(indexPath) as Logs
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        cell.textLabel.text = formatter.stringFromDate(log.date);

        if(log.status == 2){
            
            cell.detailTextLabel?.text = ""
        }else{
            cell.detailTextLabel?.text = "failed"
            cell.detailTextLabel?.textColor = UIColor.redColor()
        }
        
        return cell
    }
    
    // MARK - fetched result controller
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:  UITableViewRowAnimation.Automatic)
        case .Delete:
                println("delete")
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:  UITableViewRowAnimation.Automatic)
        case .Update:
            println("update")
//            let cell = tableView.cellForRowAtIndexPath(indexPath!)
//                    as TeamCell
//                configureCell(cell, indexPath: indexPath)
        case .Move:
                println("move")
//            self.tableView.deleteRowsAtIndexPaths([indexPath],
//                withRowAnimation: .Automatic) tableView.insertRowsAtIndexPaths([newIndexPath],
//                withRowAnimation: .Automatic) default:
            break
        }
        //TODO data 変更時のtable再描画
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    // MARK other
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showHtml"){
            let destVC = segue.destinationViewController as ViewController
            let sourceVC =  segue.sourceViewController as LogTableViewController
            let log = self.fetchedResultsController.objectAtIndexPath(self.tableView.indexPathForSelectedRow()!) as Logs
            destVC.html = log.html;
            destVC.data = log.data;
        }
    }
    
}

