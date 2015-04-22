//
//  GameScene.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/22/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameScene.h"

@interface GameScene() {
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    SKNode *_player;
}
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(SKNode *)createBackgroundNode{
    SKNode *backgroundNode = [SKNode node];
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {
        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
        
        node.anchorPoint = CGPointMake(0.5f, 0.5f);
        node.position = CGPointMake(160.0f, nodeCount*64.0f);
        
        [backgroundNode addChild:node];
    }
    
    return backgroundNode;
}

-(SKNode *)createPlayer {
    SKNode *playerNode = [SKNode node];
    [playerNode setPosition:CGPointMake(160.0f, 80.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
    [playerNode addChild:sprite];
    
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic = YES;
    playerNode.physicsBody.allowsRotation = NO;
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    
    return playerNode;
}

@end
