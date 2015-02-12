//
//  ViewController.m
//  rollingDots
//
//  Created by Avi on 2/10/15.
//  Copyright (c) 2015 Avi. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h> //for touch

@interface ViewController ()


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //to enable multiple touches
    [self.view setMultipleTouchEnabled:YES];

    
    
    //init motionManager for tracking gyro/accelerometer
    self.motionManager =[[CMMotionManager alloc] init];
    
    //update interval initializations to every ms
    self.motionManager.accelerometerUpdateInterval = 0.2;
    self.motionManager.gyroUpdateInterval = 0.2;
    
    //call startAccelerometerUpdatesToQueue method on motionManager,
    //use motionManager property to begin queueing accelerometer/gryo data to outputAccelerationData/outputRotationData
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
            [self outputAccelerationData:accelerometerData.acceleration];
                if(error){
                    NSLog(@"%@", error);
                }
        }];
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        [self outputRotationData:gyroData.rotationRate];
    }];
    
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int dotRadius = 50;
    // Remove old touches on screen
    NSArray *subviews = [self.view subviews];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    // Enumerate over all the touches and draw a red dot on the screen where the touches were
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        //create touch object and set the location of touch
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // Draw a dot where the touch happened
        UIView *touchView = [[UIView alloc] init];
        //#3882a6 - used webconverter
        [touchView setBackgroundColor:[UIColor colorWithRed:0.22 green:0.51 blue:0.651 alpha:1]];
        //create rect to place in touch location
        touchView.frame = CGRectMake(touchPoint.x, touchPoint.y, dotRadius, dotRadius);
        //trim rect into a dot!
        touchView.layer.cornerRadius = 25;
        //add the view
        [self.view addSubview:touchView];
    }];
}


-(void)outputAccelerationData:(CMAcceleration)acceleration {
    //update text field to current value of accelerometer
    self.accX.text = [NSString stringWithFormat:@"%.2fg", acceleration.x];
    self.accY.text = [NSString stringWithFormat:@"%.2fg", acceleration.y];
    self.accY.text = [NSString stringWithFormat:@"%.2fg", acceleration.z];
}

-(void)outputRotationData:(CMRotationRate)rotation {
    //update text field to current value of gryo
    self.rotX.text = [NSString stringWithFormat:@"%.2fr/s", rotation.x];
    self.rotY.text = [NSString stringWithFormat:@"%.2fr/s", rotation.y];
    self.rotZ.text = [NSString stringWithFormat:@"%.2fr/s", rotation.z];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
