//
//  GameState.m
//  uberjump-spritekit-objc-iphone
//
//  Created by giaunv on 4/25/15.
//  Copyright (c) 2015 366. All rights reserved.
//

#import "GameState.h"

@implementation GameState

+(instancetype)sharedInstance{
    static dispatch_once_t pred = 0;
    static GameState *_sharedInstance = nil;
    
    dispatch_once( &pred, ^{
        _sharedInstance = [[super alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init{
    if (self = [super init]) {
        _score = 0;
        _highScore = 0;
        _stars = 0;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id highScore = [defaults objectForKey:@"highScore"];
        if (highScore) {
            _highScore = [highScore intValue];
        }
        
        id stars = [defaults objectForKey:@"stars"];
        if (stars) {
            _stars = [stars intValue];
        }
    }
    
    return self;
}

-(void)saveState{
    _highScore = MAX(_score, _highScore);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:_highScore] forKey:@"highScore"];
    [defaults setObject:[NSNumber numberWithInt:_stars] forKey:@"stars"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
