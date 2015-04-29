//
//  EditCellProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 19/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_EditCellProtocol_h
#define DigiGraff_IOS_EditCellProtocol_h

@protocol EditCellProtocol <NSObject>

@required
- (void)onEdit:(id)sender;
- (void)onDelete:(id)sender;
- (void)onCopy:(id)sender;

@end

#endif
