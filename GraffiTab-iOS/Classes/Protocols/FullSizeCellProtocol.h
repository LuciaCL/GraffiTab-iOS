//
//  FullSizeCellProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_FullSizeCellProtocol_h
#define DigiGraff_IOS_FullSizeCellProtocol_h

@protocol FullSizeCellProtocol <NSObject>

@required
- (void)didTapLike:(GTStreamable *)item;
- (void)didTapComment:(GTStreamable *)item;
- (void)didTapShare:(GTStreamable *)item image:(UIImage *)image;
- (void)didTapLikesLabel:(GTStreamable *)item;
- (void)didTapOwner:(GTStreamable *)item;

@end

#endif
