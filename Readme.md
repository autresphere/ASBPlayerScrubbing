[![Build Status](https://travis-ci.org/autresphere/ASBPlayerScrubbing.svg)](https://travis-ci.org/autresphere/ASBPlayerScrubbing)


Purpose
-------
ASBPlayerScrubbing is an Objective-C library for easily adding scrubbing behavior to your AVPlayer on iOS.

Using ASBPlayerScrubbing requires only to link your player and slider to it. ASBPlayerScrubbing does all the wiring and computation to synchronize both slider and player. You can also optionally plug your time labels to the scrubbing such that they are also synchronized and show the corresponding times.

Example
-------
See the contained example to get a sample of ASBPlayerScrubbing created with Interface Builder.

![](https://github.com/autresphere/ASBPlayerScrubbing/raw/master/Screenshots/example1.jpg) 

Behavior class
--------------
ASBPlayerScrubbing is a **pure behavior** class, it does not come with any graphical component. 

This means you are supposed to already have your own ```AVPlayer``` as well as your own player control components such as a ```UISlider```, and some ```UILabel``` for time labels. By using ASBPlayerScrubbing, you are able to bind all these components together in order to get a consistent scrubbing behavior.

As ASBPlayerScrubbing is a pure behavior, it is highly reusable whatever your UI is made of.

Features
--------
* Update slider position depending on player time
* Update player time depending on slider position
* Change player time by taping anywhere on slider
* Play from the beginning if end is reached and play is called
* Update time labels (current time, remaining time and duration) with timecodes (hours:minutes:seconds or hours:minutes:seconds:frames)
* Update duration label as soon as this metadata is available from the player item

Using
-----
Copy ASBPlayerScrubbing.h and ASBPlayerScrubbing.m in your project.

You can either create a ASBPlayerScrubbing by code or inside Interface Builder.

Creating with Interface Builder
-------------------------------
Inside InterfaceBuilder, add an object to your nib or storyboard, and set its class to ```ASBPlayerScrubbing```. Create an outlet inside your ViewController which links to the ```ASBPlayerScrubbing``` object. Then link your slider to the corresponding ```ASBPlayerScrubbing``` slider outlet. Optionally, you can also link your time labels.

In your ViewController ```viewDidLoad``` method, you still need to set your player to the ```ASBPlayerScrubbing``` player property.
```objc
self.scrubbing.player = player;
```

NOTE: Creating an outlet inside your ViewController to keep track of the ```ASBPlayerScrubbing``` object is mandatory. This ensures the object won't be released.

Creating by code
----------------
Simply create a ASBPlayerScrubbing and set your player and your slider. Nothing more!
```objc
self.scrubbing = [ASBPlayerScrubbing new];
self.scrubbing.player = player;
self.scrubbing.slider = slider;
```
Time Labels
-----------
ASBPlayerScrubbing can automatically update these typical time labels: 
* current time
* duration
* remaining time.

These labels shows the time by default in a standard format using hours, minutes and seconds as for example "05:23" (5 minutes 23 seconds) or "1:23:09" (1 hour 23 minutes 9 seconds). Optionally it can also show frame numbers as for example "1:23:09:24" (1 hour 23 minutes 9 seconds 24 frames). The maximum frame number depends on the player item frame rate.

The remaining time is typically shown with a minus sign.

Properties
----------
```objc
@property (nonatomic, assign) BOOL showTimeHours;
```
Indicates whether time hours are always shown in time labels even if time is less than an hour. Defaults to NO.
```objc
@property (nonatomic, assign) BOOL showTimeFrames;
```
Indicates whether frames are shown in time labels. Defaults to NO.
```objc
@property (nonatomic, assign) BOOL showMinusSignOnRemainingTime;
```
Indicates whether a minus sgn is shown on remaining time label. Defaults to YES.

Limitations
-----------
ASBPlayerScrubbing does not support a change of currentItem on ```AVPlayer```.
ASBPlayerScrubbing does not support ```AVQueuePlayer``` with multiple ```AVPlayerItem```.

ARC Compatibility
-----------------
ASBPlayerScrubbing requires ARC. If you wish to use ASBPlayerScrubbing in a non-ARC project, just add the -fobjc-arc compiler flag to the ASBPlayerScrubbing.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click ASBPlayerScrubbing.m in the list and type -fobjc-arc into the popover.

Todo
----
* Improve drag support on slider
* Change scrubing speed depending on the finger vertical distance to the slider 

Recommended reading
-------------------
If you want to known more about behaviors:
* Chris Eidhof on Intentions http://chris.eidhof.nl/posts/intentions.html
* Krzysztof Zabłocki on Behaviors http://www.objc.io/issue-13/behaviors.html

Licence
-------
ASBPlayerScrubbing is available under the MIT license.

Author
------
Philippe Converset, AutreSphere - pconverset@autresphere.com

[@Follow me on Twitter](http://twitter.com/autresphere)
