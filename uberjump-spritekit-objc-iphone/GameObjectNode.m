//
//  GameObjectNode.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameObjectNode.h"

@implementation GameObjectNode

-(bool)collisionWithPlayer:(SKNode *)player{
    return NO;
}

-(void)checkNodeRemoval:(CGFloat)playerY{
    if (playerY > self.position.y + 300.0f) {
        [self removeFromParent];
    }
}

@end
