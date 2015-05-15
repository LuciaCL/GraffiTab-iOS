//
//  CreditsLibrary.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditsLibrary : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

- (id)initFromJson:(NSDictionary *)json;

@end
