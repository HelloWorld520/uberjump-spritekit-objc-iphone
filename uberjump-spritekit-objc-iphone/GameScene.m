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
}
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
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

@end
