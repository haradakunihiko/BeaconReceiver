//
//  BeaconReceiver.swift
//  BeaconReceiver
//
//  Created by harada on 2014/10/26.
//  Copyright (c) 2014年 harada. All rights reserved.
//

import Foundation
import CoreData

class Logs: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var html: String
    @NSManaged var status: NSNumber
    @NSManaged var data: NSData

}
