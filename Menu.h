//
//  Menu.h
//  FlashBear
//
//  Created by quantum on 27/06/2015.
//  Copyright (c) 2015 Paul Muren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuDelegate <NSObject>

- (void)retryTapped;

@end

@interface Menu : UIView

@property (strong, nonatomic) UILabel *lightningLabel;
@property (strong, nonatomic) UILabel *deadBearLabel;
@property (strong, nonatomic) UILabel *highscoreLabel;
@property (strong, nonatomic) UILabel *scoreLabel;

@property (nonatomic, assign) id <MenuDelegate> delegate;

- (id)initWithFrame:(CGRect)frame points:(NSInteger)points;

@end