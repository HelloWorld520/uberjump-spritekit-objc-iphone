//
//  GameObjectNode.h
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/23/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameObjectNode : SKNode

// called when a player physics body collides with the game object's physics body
-(bool)collisionWithPlayer:(SKNode *)player;

// called every frame to see if the game object should be removed from the scene
-(void)checkNodeRemoval:(CGFloat)playerY;

@end
