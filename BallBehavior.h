//
//  BallBehavior.h
//  Rolling Ball
//
//  Created by DeerMeat on 2/11/15.
//  Copyright (c) 2015 DeerMeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallBehavior : UIDynamicBehavior
- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;
@end
