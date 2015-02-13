//
//  ViewController.h
//  rollingDots
//
//  Created by Avi on 2/10/15.
//  Copyright (c) 2015 Avi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

double currentMaxAccX;
double currentMaxAccY;
double currentMaxAccZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;

@interface ViewController : UIViewController

@property(strong, nonatomic) IBOutlet UILabel *accX;
@property(strong, nonatomic) IBOutlet UILabel *accY;
@property(strong, nonatomic) IBOutlet UILabel *accZ;

@property(strong, nonatomic) IBOutlet UILabel *maxAccX;
@property(strong, nonatomic) IBOutlet UILabel *maxAccY;
@property(strong, nonatomic) IBOutlet UILabel *maxAccZ;

@property(strong, nonatomic) IBOutlet UILabel *rotX;
@property(strong, nonatomic) IBOutlet UILabel *rotY;
@property(strong, nonatomic) IBOutlet UILabel *rotZ;

@property(strong, nonatomic) IBOutlet UILabel *maxRotX;
@property(strong, nonatomic) IBOutlet UILabel *maxRotY;
@property(strong, nonatomic) IBOutlet UILabel *maxRotZ;

@property(strong, nonatomic) CMMotionManager *motionManager;


@end

