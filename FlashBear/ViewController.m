//
//  ViewController.m
//  FlashBear
//
//  Created by Paul Muren on 6/25/15.
//  Copyright (c) 2015 Paul Muren. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)loadSounds
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"jump" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"wav"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    self.musicPlayer.numberOfLoops = -1;
    [self.musicPlayer play];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[self positionBear];
    
    [self loadSounds];
    
    self.timer = [NSTimer timerWithTimeInterval:.016 target:self selector:@selector(timerFire) userInfo:nil repeats:true] ;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    gravity = 2.2;
    jumpForce = 24;
    fallSpeed = 0;
    
    xPosEpsilon = 0.001;
    xMoveInverseAcceleration = 6.5;
    isInXPlace = false;
    
    size = [[UIScreen mainScreen] bounds].size;

    [self delayLightning];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 40)];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];
    
    best = [[NSUserDefaults standardUserDefaults] integerForKey:@"best"];
}

- (void)delayLightning {
    lightningDelay = arc4random() % 500;
    lightningDelay += 80;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.label.text = [NSString stringWithFormat:@"%d", points];
}

- (void)prepareLightningStrike {
    framesUntilLightningStrike = 23;
    self.view.backgroundColor = [UIColor darkGrayColor];
}

- (void)lightningLoop
{
    if (lightningDelay) {
        lightningDelay--;
        if (lightningDelay <= 0) {
            lightnings++;
            [self prepareLightningStrike];
        }
    } else {
        framesUntilLightningStrike--;
        if (framesUntilLightningStrike <= 0) {
            if (dodged) {
                [self scorePoint];
            } else {
                [self lightningStrikesBear];
            }
            dodged = false;
            [self delayLightning];
        }
    }
}

- (void)showMenu {
    self.menu = [[Menu alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.menu.delegate = self;
    [self.view addSubview:self.menu];
}

- (void)retryTapped {
    [self.menu removeFromSuperview];
    self.menu = nil;
    [self delayLightning];
}

- (void)lightningStrikesBear
{
    points = 0;
    NSInteger bearDeaths = [[NSUserDefaults standardUserDefaults] integerForKey:@"strikes"];
    bearDeaths++;
    [[NSUserDefaults standardUserDefaults] setInteger:bearDeaths forKey:@"strikes"];
    
    NSInteger lightning = [[NSUserDefaults standardUserDefaults] integerForKey:@"lightning"];
    lightning+= lightnings;
    lightnings = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:lightning forKey:@"lightning"];

    NSInteger savedBest = [[NSUserDefaults standardUserDefaults] integerForKey:@"best"];
    if (best >= savedBest) {
        [[NSUserDefaults standardUserDefaults] setInteger:best forKey:@"best"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self showMenu];
}

- (void)scorePoint
{
    points++;
    if (points > best) {
        best = points;
    }
}

- (void)timerFire
{
    [self applyFalling];
    
    [self positionBear];

    if (!self.menu) {
        [self lightningLoop];
    }
}

- (bool)bearReachedGround
{
    return self.bear.frame.origin.y + self.bear.frame.size.height >= size.height;
}

- (void)positionBear
{
    int xTarget = onLeftSide ? (320*2/3) - 10 : (320/3) + 10;
    if(!isInXPlace && self.bear.center.x - xTarget < xPosEpsilon && xTarget - self.bear.center.x < xPosEpsilon)
    {
        self.bear.center = CGPointMake(xTarget, self.bear.center.y);
        isInXPlace = true;
    }
    else
    {
        float xIncrement = ABS(self.bear.center.x - xTarget)/xMoveInverseAcceleration;
        int xDirection = -ABS(self.bear.center.x - xTarget)/(self.bear.center.x - xTarget);
        self.bear.center = CGPointMake((self.bear.center.x + xIncrement*xDirection), self.bear.center.y);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self bearReachedGround])
    {
        onLeftSide = !onLeftSide;
        isInXPlace = false;
        [self jump];
    }
}

- (void)jump
{
//    self.bear.backgroundColor = [UIColor greenColor];
    fallSpeed = -jumpForce;
    self.bear.center = CGPointMake(self.bear.center.x, self.bear.center.y - 1);
    if (!lightningDelay) {
        dodged = true;
    }

}

- (void)plantBearOnGround {
    self.bear.center = CGPointMake(self.bear.center.x, size.height - self.bear.frame.size.height/2);
}

- (void)applyFalling
{
    if ([self bearReachedGround])
    {
        fallSpeed = 0;
        self.bear.backgroundColor = [UIColor blueColor];
        [self plantBearOnGround];
    } else {
        self.bear.center = CGPointMake(self.bear.center.x, self.bear.center.y + fallSpeed);
        fallSpeed += gravity;
        
        
        if ([self bearReachedGround])
        {
            //NSLog(@"got here");
            fallSpeed = 0;
            self.bear.backgroundColor = [UIColor blueColor];
            [self plantBearOnGround];
        }
    }
}


@end
