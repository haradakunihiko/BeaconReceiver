//
//  BeaconReceiver.swift
//  BeaconReceiver
//
//  Created by harada on 2014/10/26.
//  Copyright (c) 2014年 harada. All rights reserved.
//

import Foundation
import CoreData

class BeaconReceiver: NSManagedObject {

    @NSManaged var date: NSNumber
    @NSManaged var html: String
    @NSManaged var status: NSNumber

}
