//
//  PlatformNode.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "PlatformNode.h"


@implementation PlatformNode

-(bool)collisionWithPlayer:(SKNode *)player{
    // only bunce the player if he's falling
    if (player.physicsBody.velocity.dy < 0) {
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 250.0f);
        
        // remove if it is a Break type platform
        if (_platformType == PLATFORM_BREAK) {
            [self removeFromParent];
        }
    }
    
    // no stars for platforms
    return NO;
}

@end
