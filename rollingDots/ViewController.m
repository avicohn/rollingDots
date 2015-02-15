
#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h> //for touch


@interface ViewController () <UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *surfaceBoundaryView;
@property (weak, nonatomic) IBOutlet UIView *ballView;

@property (strong,nonatomic) CMMotionManager *manager;

@end

@implementation ViewController

//  some behavior and view constants.
const static float GRAVITY_SCALE    = 9.81f;
const static float FRAME_RATE       = 60.0f;
const static float tiltSensitivity  = 0.02f;
const static int   cropRadius       = 25;
const static int   dotRadius        = 50;

//  create "ball" view and attach behaviors
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size.height = self.view.bounds.size.height;
    frame.size.width = self.view.bounds.size.width;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor greenColor];
    
    self.surfaceBoundaryView = view;
    
    [self.view addSubview:_surfaceBoundaryView];
    
}

//  Touch Logic and Accelerometer Method Call 
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int dotRadius = 50;
    // Remove old touches on screen
    NSArray *subviews = [self.surfaceBoundaryView subviews];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    // Enumerate over all the touches and draw a red dot on the screen where the touches were
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        //create touch object and set the location of touch
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.surfaceBoundaryView];
        
        // Draw a dot where the touch happened
        UIView *ballsView = [[UIView alloc] init];
        //#3882a6 - used webconverter
        [ballsView setBackgroundColor:[UIColor colorWithRed:0.22 green:0.51 blue:0.651 alpha:1]];
        //create rect to place in touch location
        ballsView.frame = CGRectMake(touchPoint.x, touchPoint.y, dotRadius, dotRadius);
        //trim rect into a dot!
        ballsView.layer.cornerRadius = cropRadius;
        //add the view
        self.ballView = ballsView;
        [self.surfaceBoundaryView addSubview:_ballView];
        
    }];
    [self ballMotionAcceleration:_ballView];
    
    
}

//  ball motion and accelerometer stuff
-(void)ballMotionAcceleration:(UIView *)ball {
    NSLog(@"ballMotionAcceleration");
    self.manager = [[CMMotionManager alloc] init];
    self.manager.accelerometerUpdateInterval = 1.0f/FRAME_RATE;
    CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *data, NSError *error) {[self ballMovment:ball andAccelerationData:data.acceleration];};
    [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:accelerometerHandler];
    
}

-(void)ballMovment:(UIView *)ball andAccelerationData:(CMAcceleration)data {
    //  get current frame location:
    float x = data.x;
    float y = data.y;
    
    //set min and max bounderies
    float bottomBoundary = _surfaceBoundaryView.bounds.size.height - (ball.frame.size.height/2);
    float topBoundary = ball.frame.size.width/2;
    
    float rightBoundary = _surfaceBoundaryView.bounds.size.width - (ball.frame.size.width/2);
    float leftBoundary = ball.frame.size.height/2;
    
    float newY = 0;
    float newX = 0;
    
    
    //left and right tilt
    if (ABS(x) >= tiltSensitivity) {
        newX = x * GRAVITY_SCALE;
    }
    
    if (ABS(y) >= tiltSensitivity) {
        newY = y * -GRAVITY_SCALE;
    }
    NSLog(@"\nx: %f, y: %f\n", x, y);
    
    
    newY = MIN(MAX(newY+ball.center.y,topBoundary), bottomBoundary);
    newX = MIN(MAX(newX+ball.center.x,leftBoundary), rightBoundary);
    
    //NSLog(@"newX: %f, newY: %f", newX, newY);
    //NSLog(@"horizontal boundary:: %f:%f:: %f  center:: %f: %f",leftBoundary,rightBoundary,newY+ball.center.x, ball.center.x,ball.center.y);
    
    ball.center = CGPointMake(newX, newY);
    [self.surfaceBoundaryView setNeedsDisplay];
    
}

//  close the accelerometer updates when the view disappears
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.manager stopAccelerometerUpdates];
}

#pragma mark function to check if ball is in top 10% of screen

#pragma mark function to check if ball is in bottom 20% of screen

#pragma mark function to convert GPS coordinates to real-life address

@end


