//
//  GTDeviceMotionManager.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CoreMotion
import CocoaLumberjack

protocol MotionDelegate: class {
    
    func didReceiveMotionUpdate(pitch: CGFloat, roll: CGFloat, yaw: CGFloat)
}

class GTDeviceMotionManager: NSObject {

    static var manager: GTDeviceMotionManager = GTDeviceMotionManager()
    
    weak var delegate: MotionDelegate?
    var motionManager: CMMotionManager?
    var pitch: CGFloat?
    var roll: CGFloat?
    var yaw: CGFloat?
    
    override init() {
        super.init()
        
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0/60.0
        motionManager?.gyroUpdateInterval = 1.0/60.0
    }
    
    func startMotionUpdates() {
        motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XTrueNorthZVertical, toQueue: NSOperationQueue.currentQueue()!, withHandler: { (deviceMotion, error) in
            if error != nil {
                DDLogError("[\(NSStringFromClass(self.dynamicType))] Error obtaining device motion update - \(error)")
            }
            else {
                let currentAttitude = deviceMotion?.attitude
                
                self.pitch = CGFloat(currentAttitude!.pitch*180/M_PI)
                self.roll = CGFloat(currentAttitude!.roll*180/M_PI)
                self.yaw = CGFloat(currentAttitude!.yaw*180/M_PI)
                
                self.pitch = round(100 * self.pitch!) / 100.0
                self.roll = round(100 * self.roll!) / 100.0
                self.yaw = round(100 * self.yaw!) / 100.0
                
                if self.delegate != nil {
                    self.delegate?.didReceiveMotionUpdate(self.pitch!, roll: self.roll!, yaw: self.yaw!)
                }
            }
        })
    }
    
    func stopMotionUpdates() {
        motionManager?.stopDeviceMotionUpdates()
    }
}
