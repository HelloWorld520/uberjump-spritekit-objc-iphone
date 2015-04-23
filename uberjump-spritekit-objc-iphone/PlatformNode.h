//
//  PlatformNode.h
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, PlatformType) {
    PLATFORM_NORMAL,
    PLATFORM_BREAK
};

@interface PlatformNode : GameObjectNode

@property (nonatomic, assign) PlatformType platformType;

@end
