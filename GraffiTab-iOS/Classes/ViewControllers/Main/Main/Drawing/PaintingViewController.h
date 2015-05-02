//
//  PaintingViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintingViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVYPhotoEditorControllerDelegate>

@property (nonatomic, weak) GTStreamableTag *toEdit;
@property (nonatomic, strong) UIImage *toEditImage;

@end
