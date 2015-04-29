//
//  FullSizeCellProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "Streamable.h"

#ifndef DigiGraff_IOS_FullSizeCellProtocol_h
#define DigiGraff_IOS_FullSizeCellProtocol_h

@protocol FullSizeCellProtocol <NSObject>

@required
- (void)didTapLike:(Streamable *)item;
- (void)didTapComment:(Streamable *)item;
- (void)didTapLikesLabel:(Streamable *)item;
- (void)didTapOwner:(Streamable *)item;

@end

#endif
