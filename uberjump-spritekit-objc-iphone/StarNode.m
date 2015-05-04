//
//  StarNode.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "StarNode.h"
#import "GameState.h"
@import AVFoundation;

@interface StarNode(){
    SKAction *_starSound;
}
@end

@implementation StarNode

-(id)init{
    if (self = [super init]) {
        _starSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
    }
    
    return self;
}

-(bool)collisionWithPlayer:(SKNode *)player{
    // boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
    
    // play sound
    [self.parent runAction:_starSound];
    
    // remove this star
    [self removeFromParent];
    
    // award score
    [GameState sharedInstance].score += (_starType == STAR_NORMAL ? 20 : 100);
    
    // award stars
    [GameState sharedInstance].stars += (_starType == STAR_NORMAL ? 1 : 5);
    
    // the HUD needs updating to show the new stars and score
    return YES;
}

@end
