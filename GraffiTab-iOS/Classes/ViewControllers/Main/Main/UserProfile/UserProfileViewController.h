//
//  UserProfileViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "UIScrollView+VGParallaxHeader.h"
#import "HeaderViewWithImage.h"
#import "FullSizeCellProtocol.h"

@interface UserProfileViewController : BackButtonTableViewController <UserHeaderProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FullSizeCellProtocol>

@property (nonatomic, strong) GTPerson *user;
@property (nonatomic, copy) NSString *usernameToSearch;

@end
