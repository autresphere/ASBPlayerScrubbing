//
//  ASBPlayerScrubbing.h
//  ASBPlayerScrubbing
//
//  Created by Philippe Converset on 09/04/13.
//  Copyright (c) 2013 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ASBPlayerScrubbing;

@protocol ASBPlayerScrubbingDelegate <NSObject>

- (void)playerScrubbingDidUpdateTime:(ASBPlayerScrubbing *)scrubbing;

@end


@interface ASBPlayerScrubbing : NSObject

@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *remainingTimeLabel;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) id<ASBPlayerScrubbingDelegate> delegate;

// Indicates whether time hours are always shown in time labels even if time is less than an hour. Defaults to NO.
@property (nonatomic, assign) BOOL showTimeHours;
// Indicates whether frames are shown in time labels. Defaults to NO.
@property (nonatomic, assign) BOOL showTimeFrames;
// Indicates whether a minus sgn is shown on remaining time label. Defaults to YES.
@property (nonatomic, assign) BOOL showMinusSignOnRemainingTime;

// Returns the formatted representation of the specified time. If showTimeFrames is YES, the representation respects the player frame rate.
- (NSString *)timecodeForTimeInterval:(NSTimeInterval)time;

@end
