//
//  StarNode.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "StarNode.h"

@implementation StarNode

-(bool)collisionWithPlayer:(SKNode *)player{
    // boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
    
    // remove this star
    [self removeFromParent];
    
    // the HUD needs updating to show the new stars and score
    return YES;
}

@end
