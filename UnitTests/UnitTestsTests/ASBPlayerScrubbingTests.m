//
//  UnitTestsTests.m
//  UnitTestsTests
//
//  Created by Philippe Converset on 16/03/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import "ASBPlayerScrubbing.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString * const kVideoPath = @"http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v";

@interface ASBPlayerScrubbingTests : XCTestCase

@property (strong, nonatomic) ASBPlayerScrubbing *scrubbing;

@end

@implementation ASBPlayerScrubbingTests

- (void)setupPlayer
{
    AVPlayer *player;
    NSURL *url;
    
    // Duration
    url = [NSURL URLWithString:kVideoPath];
    player = [AVPlayer playerWithURL:url];

    self.scrubbing = [ASBPlayerScrubbing new];
    self.scrubbing.player = player;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self setupPlayer];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimecodeOptions
{
    NSString *timecode;
    NSTimeInterval time;
    
    time = 61;
    self.scrubbing.showTimeFrames = NO;
    self.scrubbing.showTimeHours = NO;
    timecode = [self.scrubbing timecodeForTimeInterval:time];
    XCTAssert([timecode isEqualToString:@"01:01"], @"");
    
    self.scrubbing.showTimeFrames = YES;
    self.scrubbing.showTimeHours = NO;
    timecode = [self.scrubbing timecodeForTimeInterval:time];
    XCTAssert([timecode isEqualToString:@"01:01:00"], @"");
    
    self.scrubbing.showTimeFrames = YES;
    self.scrubbing.showTimeHours = YES;
    timecode = [self.scrubbing timecodeForTimeInterval:time];
    XCTAssert([timecode isEqualToString:@"0:01:01:00"], @"");
}


- (void)testTimecodeOptionsAfterSeek
{
    __block XCTestExpectation *expectation;
    UILabel *currentTimeLabel;
    
    currentTimeLabel = [UILabel new];
    self.scrubbing.currentTimeLabel = currentTimeLabel;
    
    [self keyValueObservingExpectationForObject:self.scrubbing.player keyPath:@"status" handler:^BOOL(id observedObject, NSDictionary *change) {
        CMTime time;
        
        if(self.scrubbing.player.status != AVPlayerStatusReadyToPlay)
            return NO;
        
        time = CMTimeMakeWithSeconds(10, NSEC_PER_SEC);
        [self.scrubbing.player seekToTime:time completionHandler:^(BOOL finished) {
            self.scrubbing.showTimeFrames = NO;
            self.scrubbing.showTimeHours = NO;
            XCTAssert([self.scrubbing.currentTimeLabel.text isEqualToString:@"00:10"], @"");
            
            self.scrubbing.showTimeFrames = YES;
            self.scrubbing.showTimeHours = NO;
            XCTAssert([self.scrubbing.currentTimeLabel.text isEqualToString:@"00:10:00"], @"");
            
            self.scrubbing.showTimeFrames = YES;
            self.scrubbing.showTimeHours = YES;
            XCTAssert([self.scrubbing.currentTimeLabel.text isEqualToString:@"0:00:10:00"], @"");
            
            [expectation fulfill];
        }];
        
        return YES;
    }];
    
    expectation = [self expectationWithDescription:@""];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testLabels
{
    __block XCTestExpectation *expectation;
    UILabel *currentTimeLabel;
    UILabel *durationLabel;
    UILabel *remainingTimeLabel;
    
    currentTimeLabel = [UILabel new];
    durationLabel = [UILabel new];
    remainingTimeLabel = [UILabel new];
    self.scrubbing.currentTimeLabel = currentTimeLabel;
    self.scrubbing.durationLabel = durationLabel;
    self.scrubbing.remainingTimeLabel = remainingTimeLabel;
    
    [self keyValueObservingExpectationForObject:self.scrubbing.player.currentItem keyPath:@"duration" handler:^BOOL(id observedObject, NSDictionary *change) {
        CMTime time;
        
        if(self.scrubbing.player.status != AVPlayerStatusReadyToPlay)
            return NO;
        
        time = CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
        [self.scrubbing.player seekToTime:time completionHandler:^(BOOL finished) {
            self.scrubbing.showTimeFrames = NO;
            self.scrubbing.showTimeHours = NO;
            self.scrubbing.showMinusSignOnRemainingTime = NO;
            
            XCTAssert([self.scrubbing.currentTimeLabel.text isEqualToString:@"00:00"], @"");
            
            XCTAssert([self.scrubbing.durationLabel.text isEqualToString:self.scrubbing.remainingTimeLabel.text], @"");
            
            [expectation fulfill];
        }];
        
        return YES;
    }];
    
    expectation = [self expectationWithDescription:@""];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testMinusSignOption
{
    __block XCTestExpectation *expectation;
    UILabel *remainingTimeLabel;
    
    remainingTimeLabel = [UILabel new];
    self.scrubbing.remainingTimeLabel = remainingTimeLabel;
    
    [self keyValueObservingExpectationForObject:self.scrubbing.player.currentItem keyPath:@"duration" handler:^BOOL(id observedObject, NSDictionary *change) {
        CMTime time;
        
        if(self.scrubbing.player.status != AVPlayerStatusReadyToPlay)
            return NO;
        
        time = CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
        [self.scrubbing.player seekToTime:time completionHandler:^(BOOL finished) {
            NSString *timecodeWithMinusSign;
            NSString *timecodeWithoutMinusSign;
            
            self.scrubbing.showMinusSignOnRemainingTime = YES;
            timecodeWithMinusSign = self.scrubbing.remainingTimeLabel.text;
            self.scrubbing.showMinusSignOnRemainingTime = NO;
            timecodeWithoutMinusSign = self.scrubbing.remainingTimeLabel.text;
            
            XCTAssert([timecodeWithoutMinusSign isEqualToString:[timecodeWithMinusSign substringFromIndex:1]], @"");
            
            [expectation fulfill];
        }];
        
        return YES;
    }];
    
    expectation = [self expectationWithDescription:@""];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
