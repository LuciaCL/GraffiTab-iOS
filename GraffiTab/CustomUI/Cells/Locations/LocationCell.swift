//
//  LocationCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 23/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import AlamofireImage

protocol LocationCellDelegate {
    
    func didTapOptions(location: GTLocation, indexPath: NSIndexPath)
}

class LocationCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    
    var delegate: LocationCellDelegate?
    var previousItem: GTLocation?
    var previousItemRequest: Request?
    var item: GTLocation? {
        didSet {
            setItem()
            
            previousItem = item
        }
    }
    var itemPosition: NSIndexPath?
    
    class func reusableIdentifier() -> String {
        return "LocationCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupImageViews()
    }
    
    func setItem() {
        // Setup labels.
        addressLbl.text = item?.address
        
        loadThumbnail()
    }
    
    func onClickOptions() {
        if delegate != nil {
            delegate?.didTapOptions(item!, indexPath: itemPosition!)
        }
    }
    
    // MARK: - Loading
    
    func loadThumbnail() {
        if previousItem != nil && previousItem!.id != item?.id {
            thumbnail.image = nil
            previousItemRequest?.cancel()
        }
        
        previousItemRequest = Alamofire.request(.GET, GoogleStaticApiUtils.getStaticMapUrl(item!.latitude!, longitude: item!.longitude!))
            .responseImage { response in
                let image = response.result.value
                
                if response.request?.URLString == GoogleStaticApiUtils.getStaticMapUrl(self.item!.latitude!, longitude: self.item!.longitude!) { // Verify we're still loading the current image.
                    self.thumbnail.image = image
                }
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        thumbnail.layer.cornerRadius = 3
    }
}