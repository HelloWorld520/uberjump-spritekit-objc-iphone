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
#import "GameState.h"
#import "EndGameScene.h"
@import CoreMotion;

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
    
    // motion manager for accelerometer
    CMMotionManager *_motionManager;
    
    // acceleration value from accelerometer
    CGFloat _xAcceleration;
    
    SKLabelNode *_lblScore;
    SKLabelNode *_lblStars;
    
    // max y reached by player
    int _maxPlayerY;
    
    // game over dude!
    bool _gameOver;
}
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // reset
        _maxPlayerY = 80;
        [GameState sharedInstance].score = 0;
        _gameOver = NO;
        
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
        
        // build the HUD
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
        star.position = CGPointMake(25, self.size.height - 30);
        [_hudNode addChild:star];
        
        _lblStars = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblStars.fontSize = 30;
        _lblStars.fontColor = [SKColor whiteColor];
        _lblStars.position = CGPointMake(50, self.size.height-40);
        _lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [_lblStars setText:[NSString stringWithFormat:@"X %d", [GameState sharedInstance].stars]];
        [_hudNode addChild:_lblStars];
        
        // Score
        _lblScore = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblScore.fontSize = 30;
        _lblScore.fontColor = [SKColor whiteColor];
        _lblScore.position = CGPointMake(self.size.width-20, self.size.height-40);
        _lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        [_lblScore setText:@"0"];
        [_hudNode addChild:_lblScore];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            CMAcceleration acceleration = accelerometerData.acceleration;
            _xAcceleration = (acceleration.x * 0.75) + (_xAcceleration * 0.25);
        }];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_gameOver) {
        return;
    }
    
    // new max height ?
    if ((int)_player.position.y > _maxPlayerY) {
        [GameState sharedInstance].score += (int)_player.position.y - _maxPlayerY;
        _maxPlayerY = (int)_player.position.y;
        [_lblScore setText:[NSString stringWithFormat:@"%d", [GameState sharedInstance].score]];
    }
    
    // remove game objects that have passed by
    [_foregroundNode enumerateChildNodesWithName:@"NODE_PLATFORM" usingBlock:^(SKNode *node, BOOL *stop) {
        [((PlatformNode *)node) checkNodeRemoval:_player.position.y];
    }];
    
    [_foregroundNode enumerateChildNodesWithName:@"NODE_STAR" usingBlock:^(SKNode *node, BOOL *stop) {
        [((StarNode *)node) checkNodeRemoval:_player.position.y];
    }];
    
    // calculate player y offset
    if (_player.position.y > 200.0f) {
        _backgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/10));
        _midgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/4));
        _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
    
    // check if we've finished the level
    if (_player.position.y > _endLevelY) {
        [self endGame];
    }
    
    // check if we've fallen too far
    if (_player.position.y < (_maxPlayerY - 400)) {
        [self endGame];
    }
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
        [_lblStars setText:[NSString stringWithFormat:@"X %d", [GameState sharedInstance].stars]];
        [_lblScore setText:[NSString stringWithFormat:@"%d", [GameState sharedInstance].score]];
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

-(void)didSimulatePhysics{
    _player.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, _player.physicsBody.velocity.dy);
    
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(340.0f, _player.position.y);
    } else if (_player.position.x > 340.0f) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
}

-(void)endGame{
    _gameOver = YES;
    
    // save stars and high score
    [[GameState sharedInstance] saveState];
    
    SKScene *endGameScene = [[EndGameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:endGameScene transition:reveal];
}

@end
