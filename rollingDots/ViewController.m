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
    
    //init max values to 0
    currentMaxAccX = 0;
    currentMaxAccY = 0;
    currentMaxAccZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    
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
    //gyro measures data in rotations/second
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        [self outputRotationData:gyroData.rotationRate];
    }];
    
}

#pragma mark function to check if ball is in top 10% of screen

#pragma mark function to check if ball is in bottom 20% of screen

#pragma mark function to convert GPS coordinates to real-life address

/*
-(void)update:(CFTimeInterval)currentTime {
    
    // Called before each frame is rendered
    
    //set min and max bounderies
    float maxY = screenHeight - (self.ball.size.width/2);
    float minY = 0 + (self.ball.size.width/2);
    
    float maxX = screenWidth - (self.ball.size.height/2);
    float minX = 0 + (self.ball.size.height/2);
    
    float newY = 0;
    float newX = 0;
    //left and right tilt
    if(currentMaxAccelX > 0.05){
        newX = currentMaxAccelX * -10;
    }
    else if(currentMaxAccelX < -0.05){
        newX = currentMaxAccelX*-10;
    }
    else{
        newX = currentMaxAccelX*-10;
    }
    //up and down tilt
    newY = currentMaxAccelY *10;
    
    newX = MIN(MAX(newX+self.ball.position.x,minY),maxY);
    newY = MIN(MAX(newY+self.ball.position.y,minX),maxX);
    
    self.ball.position = CGPointMake(newX, newY);
    
}
*/


- (void)updateDotPositionFromMotionManager {
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        //NSLog(@"acceleration value = %f",data.acceleration.x);
        //[_ship.physicsBody applyForce:CGVectorMake(0.0, 40.0 * data.acceleration.x)];
    }
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
    if(fabs(acceleration.x) > fabs(currentMaxAccX)) {
        currentMaxAccX = acceleration.x;
    }
    self.accY.text = [NSString stringWithFormat:@"%.2fg", acceleration.y];
    if(fabs(acceleration.y) > fabs(currentMaxAccY)) {
        currentMaxAccY = acceleration.y;
    }
    self.accY.text = [NSString stringWithFormat:@"%.2fg", acceleration.z];
    if(fabs(acceleration.z) > fabs(currentMaxAccZ)) {
        currentMaxAccZ = acceleration.z;
    }
    self.maxAccX.text = [NSString stringWithFormat:@" %.2f",currentMaxAccX];
    self.maxAccY.text = [NSString stringWithFormat:@" %.2f",currentMaxAccY];
    self.maxAccZ.text = [NSString stringWithFormat:@" %.2f",currentMaxAccZ];
}

-(void)outputRotationData:(CMRotationRate)rotation {
    //update text field to current value of gryo
    self.rotX.text = [NSString stringWithFormat:@"%.2fr/s", rotation.x];
    if(fabs(rotation.x) > fabs(currentMaxRotX)) {
        currentMaxRotX = rotation.x;
    }
    self.rotY.text = [NSString stringWithFormat:@"%.2fr/s", rotation.y];
    if(fabs(rotation.y) > fabs(currentMaxRotY)) {
        currentMaxRotY = rotation.y;
    }
    self.rotZ.text = [NSString stringWithFormat:@"%.2fr/s", rotation.z];
    if(fabs(rotation.z) > fabs(currentMaxRotZ)) {
        currentMaxRotZ = rotation.z;
    }
    self.maxRotX.text = [NSString stringWithFormat:@" %.2f",currentMaxRotX];
    self.maxRotY.text = [NSString stringWithFormat:@" %.2f",currentMaxRotY];
    self.maxRotZ.text = [NSString stringWithFormat:@" %.2f",currentMaxRotZ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
