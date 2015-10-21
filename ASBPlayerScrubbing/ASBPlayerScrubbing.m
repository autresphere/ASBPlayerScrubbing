//
//  ASBPlayerScrubbing.m
//  ASBPlayerScrubbing
//
//  Created by Philippe Converset on 09/04/13.
//  Copyright (c) 2013 AutreSphere. All rights reserved.
//

#import "ASBPlayerScrubbing.h"

@interface ASBPlayerScrubbing ()

@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;

@property (nonatomic, assign) BOOL playAfterDrag;
@property (nonatomic, assign) id timeObserver;
@property (nonatomic, assign) CGFloat frameDuration;
@property (nonatomic, assign) CGFloat nbFramesPerSecond;

@end


@implementation ASBPlayerScrubbing

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.showMinusSignOnRemainingTime = YES;
}

- (void)setSlider:(UISlider *)slider
{
    _slider = slider;
    [self setupSlider];
}

- (void)setPlayer:(AVPlayer *)player
{
    [self.player pause];
    [self removeTimeObserver];
    _player = player;

    self.nbFramesPerSecond = [ASBPlayerScrubbing nominalFrameRateForPlayer:self.player];
    
    if (self.nbFramesPerSecond > 0) {
        self.frameDuration = 1/self.nbFramesPerSecond;
    } else {
        self.frameDuration = 1/5.0;
    }
    
    [self setupTimeObserver];
    [self updateCurrentTimeLabelWithTime:0];
    
    [self addStatusObserverOnItem:self.player.currentItem];
}

- (void)setShowMinusSignOnRemainingTime:(BOOL)showMinusSignOnRemainingTime
{
    if(_showMinusSignOnRemainingTime == showMinusSignOnRemainingTime)
        return;
    
    _showMinusSignOnRemainingTime = showMinusSignOnRemainingTime;
    [self playerTimeChanged];
}

- (void)setShowTimeFrames:(BOOL)showTimeFrames
{
    if(_showTimeFrames == showTimeFrames)
        return;
    
    _showTimeFrames = showTimeFrames;
    [self playerTimeChanged];
}

- (void)setShowTimeHours:(BOOL)showTimeHours
{
    if(_showTimeHours == showTimeHours)
        return;
    
    _showTimeHours = showTimeHours;
    [self playerTimeChanged];
}

- (NSString *)timecodeForTimeInterval:(NSTimeInterval)time
{
    return [ASBPlayerScrubbing timecodeForTimeInterval:time frameRate:self.nbFramesPerSecond showFrames:self.showTimeFrames showHours:self.showTimeHours];
}

+ (NSString *)timecodeForTimeInterval:(NSTimeInterval)time frameRate:(CGFloat)frameRate showFrames:(BOOL)showFrames showHours:(BOOL)showHours {
    NSTimeInterval frametime = time - floorf(time);
    int frames = frametime * frameRate;
    
    int totalSeconds = (int)ceilf(time);
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    NSString *timecode = @"";

    if (showFrames) {
        timecode = [NSString stringWithFormat:@":%02d", frames];
    }
    
    if (hours > 0 || showHours) {
        timecode = [NSString stringWithFormat:@"%2d:%02d:%02d%@", hours, minutes, seconds, timecode];
    } else {
        timecode = [NSString stringWithFormat:@"%02d:%02d%@", minutes, seconds, timecode];
    }
    
    return timecode;
}

#pragma mark - Private
+ (CGFloat)nominalFrameRateForPlayer:(AVPlayer *)player
{
    AVAssetTrack *track = nil;
    NSArray *tracks;
    
    tracks = player.currentItem.asset.tracks;
    if(tracks.count > 0)
    {
        track = tracks[0];
    }
    
    return track.nominalFrameRate;
}

- (void)setupSlider
{
    UITapGestureRecognizer *gesture;
    
    if(self.slider == nil)
        return;
    
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSliderTap:)];
    [self.slider addGestureRecognizer:gesture];
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderDidEndDragging:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderDidCancelDragging:forEvent:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(sliderDidCancelDragging:forEvent:) forControlEvents:UIControlEventTouchCancel];
}

- (void)removeTimeObserver
{
    if(self.timeObserver != nil)
    {
        [self.player removeTimeObserver:self.timeObserver];
    }
    self.timeObserver = nil;
}

- (void)setupTimeObserver
{
    __weak ASBPlayerScrubbing *weakSelf;
    
    if(self.timeObserver != nil)
        return;

    weakSelf = self;
    if(self.frameDuration > 0)
    {
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(self.frameDuration, NSEC_PER_SEC)
                                                                      queue:NULL
                                                                 usingBlock:^(CMTime time) {
                                                                     [weakSelf playerTimeChanged];
                                                                 }];
    }
}

- (void)playerTimeChanged
{
    CGFloat nbSecondsElapsed;
    CGFloat nbSecondsDuration = 0;
    CGFloat ratio = 0;
    
    if(self.player.currentItem == nil)
        return;
    
    if (CMTIME_COMPARE_INLINE(self.player.currentItem.currentTime, ==, self.player.currentItem.duration)) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playerScrubbingDidFinishPlaying:)]) {
            [self.delegate playerScrubbingDidFinishPlaying:self];
        }
    }
    
    nbSecondsElapsed = CMTimeGetSeconds(self.player.currentItem.currentTime);
    if(CMTIME_IS_VALID(self.player.currentItem.duration) && !CMTIME_IS_INDEFINITE(self.player.currentItem.duration))
    {
        nbSecondsDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    }
    
    if(nbSecondsDuration != 0)
    {
        ratio = nbSecondsElapsed/nbSecondsDuration;
        [self updateDurationLabelWithTime:nbSecondsDuration];
    }
    
    self.slider.value = ratio;
    
    [self updateCurrentTimeLabelWithTime:nbSecondsElapsed];
    [self updateRemainingTimeLabelWithTime:nbSecondsDuration - nbSecondsElapsed];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playerScrubbingDidUpdateTime:)]) {
        [self.delegate playerScrubbingDidUpdateTime:self];
    }
}

- (void)updateDurationLabelWithTime:(NSTimeInterval)time
{
    if(self.durationLabel == nil)
        return;
    
    self.durationLabel.text = [self timecodeForTimeInterval:time];
}

- (void)updateCurrentTimeLabelWithTime:(NSTimeInterval)time
{
    if(self.currentTimeLabel == nil)
        return;
    
    self.currentTimeLabel.text = [self timecodeForTimeInterval:time];
}

- (void)updateRemainingTimeLabelWithTime:(NSTimeInterval)time
{
    if(self.remainingTimeLabel == nil)
        return;
    
    self.remainingTimeLabel.text = [self timecodeForTimeInterval:-time];
}

- (void)updatePlayer
{
    CGFloat nbSecondsDuration;
    CMTime time;

    nbSecondsDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    int timescale = self.player.currentItem.asset.duration.timescale;
    time = CMTimeMakeWithSeconds(nbSecondsDuration*self.slider.value, timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
}

#pragma mark - Actions
- (IBAction)sliderValueChanged:(id)sender forEvent:(UIEvent *)event
{
    UITouch *touch;
    
    touch = [[event allTouches] anyObject];

    if([self isPlaying] && touch.phase == UITouchPhaseBegan)
    {
        self.playAfterDrag = [self isPlaying];
        [self.player pause];
    }
    
    [self updatePlayer];
}

- (IBAction)sliderDidEndDragging:(id)sender forEvent:(UIEvent *)event
{
    if(self.playAfterDrag)
    {
        self.playAfterDrag = NO;
        [self.player play];
    }
}

- (IBAction)sliderDidCancelDragging:(id)sender forEvent:(UIEvent *)event
{
    if(self.playAfterDrag)
    {
        self.playAfterDrag = NO;
        [self.player play];
    }
}

- (BOOL)isPlaying
{
    return !(self.player.rate == 0);
}

- (IBAction)playPause:(id)sender
{
    if(self.isPlaying)
    {
        [self pause:sender];
    }
    else
    {
        
        [self play:sender];
    }
}

- (IBAction)play:(id)sender
{
    if(CMTIME_COMPARE_INLINE(self.player.currentTime, == , self.player.currentItem.duration))
    {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
    else
    {
        [self.player play];
    }
}

- (IBAction)pause:(id)sender
{
    [self.player pause];
}

- (void)handleSliderTap:(UIGestureRecognizer *)gesture
{
    CGPoint point;
    CGFloat ratio;
    CGFloat delta;
    CGFloat value;
    CGFloat thumbWidth;
    
    // tap on thumb, let slider deal with it
    if (self.slider.highlighted)
        return;
    
    CGRect trackRect = [self.slider trackRectForBounds:self.slider.bounds];
    CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds trackRect:trackRect value:0];
    CGSize thumbSize = thumbRect.size;
    thumbWidth = thumbSize.width;
    point = [gesture locationInView: self.slider];
    if(point.x < thumbWidth/2)
    {
        ratio = 0;
    }
    else if(point.x > self.slider.bounds.size.width - thumbWidth/2)
    {
        ratio = 1;
    }
    else
    {
        ratio = (point.x - thumbWidth/2) / (self.slider.bounds.size.width - thumbWidth);
    }
    delta = ratio * (self.slider.maximumValue - self.slider.minimumValue);
    value = self.slider.minimumValue + delta;
    [self.slider setValue:value animated:YES];
    [self updatePlayer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.player.currentItem && [keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        switch (item.status) {
            case AVPlayerItemStatusFailed:
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playerScrubbingDidError:)]) {
                    [self.delegate playerScrubbingDidError:self];
                }
                break;
            case AVPlayerItemStatusReadyToPlay:
            case AVPlayerItemStatusUnknown:
                break;
        }
    }
}

- (void)setCurrentPlayerItem:(AVPlayerItem *)currentPlayerItem {
    [self removeStatusObserverOnItem:_currentPlayerItem];
    _currentPlayerItem = currentPlayerItem;
}

- (void)addStatusObserverOnItem:(AVPlayerItem *)item {
    self.currentPlayerItem = self.player.currentItem;
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeStatusObserverOnItem:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
}

- (void)dealloc {
    [self removeStatusObserverOnItem:self.currentPlayerItem];
}

@end
