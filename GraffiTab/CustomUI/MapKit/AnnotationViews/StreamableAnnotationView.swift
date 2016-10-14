//
//  StreamableAnnotationView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/10/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import kingpin

class StreamableAnnotationView: MKPinAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupCommon()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCommon()
    }
    
    func getStreamableAnnotation() -> StreamableAnnotation {
        return (self.annotation as! KPAnnotation).annotations!.first as! StreamableAnnotation
    }
    
    // MARK: - Setup
    
    func setupCommon() {
        self.canShowCallout = true
        self.animatesDrop = false
        self.pinTintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
}
