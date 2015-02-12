//
//  ViewController.h
//  rollingDots
//
//  Created by Avi on 2/10/15.
//  Copyright (c) 2015 Avi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface ViewController : UIViewController

@property(strong, nonatomic) IBOutlet UILabel *accX;
@property(strong, nonatomic) IBOutlet UILabel *accY;
@property(strong, nonatomic) IBOutlet UILabel *accZ;

@property(strong, nonatomic) IBOutlet UILabel *rotX;
@property(strong, nonatomic) IBOutlet UILabel *rotY;
@property(strong, nonatomic) IBOutlet UILabel *rotZ;

@property(strong, nonatomic) CMMotionManager *motionManager;


@end

