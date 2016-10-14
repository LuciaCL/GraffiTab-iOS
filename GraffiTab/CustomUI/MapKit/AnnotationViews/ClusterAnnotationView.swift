//
//  ClusterAnnotationView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/10/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import Foundation
import MapKit
import kingpin

public class ClusterAnnotationViewOptions : NSObject {
    
    var smallClusterImage : String
    var mediumClusterImage : String
    var largeClusterImage : String
    
    public init (smallClusterImage : String, mediumClusterImage : String, largeClusterImage : String) {
        self.smallClusterImage = smallClusterImage;
        self.mediumClusterImage = mediumClusterImage;
        self.largeClusterImage = largeClusterImage;
    }
}

public class ClusterAnnotationView : MKAnnotationView {
    
    var countLabel: UILabel?
    
    var fontSize:CGFloat = 12
    var imageName = "clusterSmall"
    var loadExternalImage: Bool = false
    var borderWidth:CGFloat = 3
    var options: ClusterAnnotationViewOptions?
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, options: ClusterAnnotationViewOptions?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.options = options
        
        setupCommon()
        
        recomputeCluster()
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCommon()
        
        recomputeCluster()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCommon()
        
        recomputeCluster()
    }
    
    override public func layoutSubviews() {
        // Images are faster than using drawRect.
        let imageAsset = UIImage(named: imageName, inBundle: (!loadExternalImage) ? NSBundle(forClass: ClusterAnnotationView.self) : nil, compatibleWithTraitCollection: nil)
        
        countLabel?.frame = self.bounds
        image = imageAsset
        centerOffset = CGPointZero
        
        // Adds a white border around the green circle.
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = self.bounds.size.width / 2
    }
    
    func recomputeCluster() {
        if annotation == nil {
            return
        }
        
        let count = clusterSize()
        
        // Change the size of the cluster image based on number of stories.
        switch count {
            case 0...5:
                fontSize = 12
                borderWidth = 3
                if (options != nil) {
                    loadExternalImage = true
                    imageName = (options?.smallClusterImage)!
                }
                else {
                    imageName = "clusterSmall"
                }
            case 6...15:
                fontSize = 13
                borderWidth = 4
                if (options != nil) {
                    loadExternalImage = true
                    imageName = (options?.mediumClusterImage)!
                }
                else {
                    imageName = "clusterMedium"
                }
            default:
                fontSize = 14
                borderWidth = 5
                if (options != nil) {
                    loadExternalImage = true
                    imageName = (options?.largeClusterImage)!
                }
                else {
                    imageName = "clusterLarge"
                }
        }
        
        countLabel?.text = "\(count)"
        setNeedsLayout()
    }
    
    func clusterSize() -> Int {
        let cluster = annotation as! KPAnnotation
        return cluster.annotations.count
    }
    
    // MARK: - Setup
    
    func setupCommon() {
        backgroundColor = UIColor.clearColor()
        setupLabel()
    }
    
    func setupLabel() {
        if countLabel == nil {
            countLabel = UILabel(frame: bounds)
            countLabel!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            countLabel!.textAlignment = .Center
            countLabel!.backgroundColor = UIColor.clearColor()
            countLabel!.textColor = UIColor.whiteColor()
            countLabel!.adjustsFontSizeToFitWidth = true
            countLabel!.minimumScaleFactor = 2
            countLabel!.numberOfLines = 1
            countLabel!.font = UIFont.boldSystemFontOfSize(fontSize)
            countLabel!.baselineAdjustment = .AlignCenters
            addSubview(countLabel!)
        }
    }
}
