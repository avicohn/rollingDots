//
//  BallBehavior.m
//  Rolling Ball
//
//  Created by DeerMeat on 2/11/15.
//  Copyright (c) 2015 DeerMeat. All rights reserved.
//

#import "BallBehavior.h"
@interface BallBehavior()
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@end

@implementation BallBehavior

- (instancetype)init {
    self = [super init];
    [self addChildBehavior:self.collisionBehavior];
    return self;
}

- (void)addItem:(id <UIDynamicItem>)item {
    [self.collisionBehavior addItem:item];
}

- (void)removeItem:(id <UIDynamicItem>)item {
    [self.collisionBehavior removeItem:item];
}

//bounce back from border
- (UICollisionBehavior *)collisionBehavior {
    if (!_collisionBehavior) {
        _collisionBehavior = [[UICollisionBehavior alloc] init];
        _collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    }
    return _collisionBehavior;
}

@end
