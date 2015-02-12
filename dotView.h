//
//  dotView.h
//  rollingDots
//
//  Created by Avi on 2/10/15.
//  Copyright (c) 2015 Avi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol dotView <NSObject>

@interface PhysicalView: UIImageView
@property(nonatomic, assign) BOOL isStatic;
@property(nonatomic, assign) BOOL isCircle;
@property(nonatomic, assign) BOOL isSensor;
@property(nonatomic, assign) CGFloat mass;
@property(nonatomic, copy) NSString *type;

-(void)update; //method to refresh display

@end
