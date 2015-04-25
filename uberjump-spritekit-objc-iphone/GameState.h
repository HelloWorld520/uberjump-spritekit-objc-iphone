//
//  GameState.h
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/25/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int stars;

+(instancetype)sharedInstance;
-(void)saveState;

@end
