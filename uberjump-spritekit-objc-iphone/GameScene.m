//
//  GameScene.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/22/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameScene.h"
#import "StarNode.h"
#import "PlatformNode.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory){
    CollisionCategoryPlayer = 0x1 << 0,
    CollisionCategoryStar = 0x1 << 1,
    CollisionCategoryPlatform = 0x1 << 2
};

@interface GameScene() <SKPhysicsContactDelegate> {
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    SKNode *_player;
    SKNode *_tapToStartNode;
    // height at which the player ends the level
    int _endLevelY;
}
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        self.physicsWorld.contactDelegate = self;
        
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        _midgroundNode = [self createMidgroundNode];
        [self addChild:_midgroundNode];
        
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        _hudNode = [SKNode node];
        [self addChild:_hudNode];
        
        NSString *levelPlist = [[NSBundle mainBundle] pathForResource:@"Level01" ofType:@"plist"];
        NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
        _endLevelY = [levelData[@"EndY"] intValue];
        
        // add the platforms
        NSDictionary *platforms = levelData[@"Platforms"];
        NSDictionary *platformPatterns = platforms[@"Patterns"];
        NSArray *platformPositions = platforms[@"Positions"];
        for (NSDictionary *platformPosition in platformPositions) {
            CGFloat patternX = [platformPosition[@"x"] floatValue];
            CGFloat patternY = [platformPosition[@"y"] floatValue];
            NSString *pattern = platformPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *platformPattern = platformPatterns[pattern];
            for (NSDictionary *platformPoint in platformPattern) {
                CGFloat x = [platformPoint[@"x"] floatValue];
                CGFloat y = [platformPoint[@"y"] floatValue];
                PlatformType type = [platformPoint[@"type"] intValue];
                
                PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY)
                                                                     ofType:type];
                [_foregroundNode addChild:platformNode];
            }
        }
        
        //PlatformNode *platform = [self createPlatformAtPosition:CGPointMake(160, 320) ofType:PLATFORM_NORMAL];
        //[_foregroundNode addChild:platform];
        
        // Add the stars
        NSDictionary *stars = levelData[@"Stars"];
        NSDictionary *starPatterns = stars[@"Patterns"];
        NSArray *starPositions = stars[@"Positions"];
        for (NSDictionary *starPosition in starPositions) {
            CGFloat patternX = [starPosition[@"x"] floatValue];
            CGFloat patternY = [starPosition[@"y"] floatValue];
            NSString *pattern = starPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *starPattern = starPatterns[pattern];
            for (NSDictionary *starPoint in starPattern) {
                CGFloat x = [starPoint[@"x"] floatValue];
                CGFloat y = [starPoint[@"y"] floatValue];
                StarType type = [starPoint[@"type"] intValue];
                
                StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:starNode];
            }
        }
        //StarNode *star = [self createStarAtPosition:CGPointMake(160, 220) ofType:STAR_SPECIAL];
        //[_foregroundNode addChild:star];
        
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
        
        _tapToStartNode = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        _tapToStartNode.position = CGPointMake(160, 180.0f);
        [_hudNode addChild:_tapToStartNode];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_player.physicsBody.dynamic) {
        return;
    }
    
    [_tapToStartNode removeFromParent];
    
    _player.physicsBody.dynamic = YES;
    [_player.physicsBody applyImpulse:CGVectorMake(0.0f, 20.0f)];
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    bool updateHUD = NO;
    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];
    if (updateHUD) {
        // TODO: update HUD
    }
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
    playerNode.physicsBody.dynamic = NO;
    playerNode.physicsBody.allowsRotation = NO;
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform;
    
    return playerNode;
}

-(StarNode *)createStarAtPosition:(CGPoint)position ofType:(StarType)type{
    StarNode *node = [StarNode node];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    
    [node setStarType:type];
    SKSpriteNode *sprite;
    if (type == STAR_SPECIAL) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    }
    [node addChild:sprite];
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    node.physicsBody.dynamic = NO;
    
    node.physicsBody.categoryBitMask = CollisionCategoryStar;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

-(PlatformNode *)createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type{
    PlatformNode *node = [PlatformNode node];
    [node setPosition:position];
    [node setName:@"NODE_PLATFORM"];
    [node setPlatformType:type];
    
    SKSpriteNode *sprite;
    if (type == PLATFORM_BREAK) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PlatformBreak"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform"];
    }
    [node addChild:sprite];
    
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = CollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

-(SKNode *)createMidgroundNode{
    // create the node
    SKNode *midgroundNode = [SKNode node];
    
    // add some branches to the midground
    for (int i = 0; i < 10; i++) {
        NSString *spriteName;
        
        int r = arc4random() % 2;
        if (r > 0) {
            spriteName = @"BranchRight";
        } else {
            spriteName = @"BranchLeft";
        }
        
        SKSpriteNode *branchNode = [SKSpriteNode spriteNodeWithImageNamed:spriteName];
        branchNode.position = CGPointMake(160.0f, 500.0f * i);
        [midgroundNode addChild:branchNode];
    }
    
    return midgroundNode;
}

@end
