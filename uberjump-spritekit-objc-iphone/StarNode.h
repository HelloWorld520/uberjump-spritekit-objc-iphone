//
//  StarNode.h
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, StarType){
    STAR_NORMAL,
    STAR_SPECIAL
};

@interface StarNode : GameObjectNode

@property (nonatomic, assign) StarType starType;

@end
