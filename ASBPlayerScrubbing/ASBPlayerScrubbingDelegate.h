//
//  ASBPlayerScrubbingDelegate.h
//  WildcardApp
//
//  Created by Lacy Rhoades on 9/28/15.
//  Copyright © 2015 Doug Petkanics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASBPlayerScrubbing;

@protocol ASBPlayerScrubbingDelegate <NSObject>

@optional
- (void)playerScrubbingDidUpdateTime:(ASBPlayerScrubbing *)scrubbing;
- (void)playerScrubbingDidFinishPlaying:(ASBPlayerScrubbing *)scrubbing;
@end
