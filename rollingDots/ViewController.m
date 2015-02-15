
#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h> //for touch


@interface ViewController () <UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *surfaceBoundaryView;
@property (weak, nonatomic) IBOutlet UIView *ballView;

@property (strong,nonatomic) CMMotionManager *manager;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

//  some behavior and view constants.
const static float GRAVITY_SCALE    = 9.81f;
const static float FRAME_RATE       = 60.0f;
const static float tiltSensitivity  = 0.02f;
const static int   cropRadius       = 25;
const static int   dotRadius        = 50;

//  create "ball" view and attach behaviors
- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];

    CGRect frame;
    frame.origin = CGPointZero;
    frame.size.height = self.view.bounds.size.height;
    frame.size.width = self.view.bounds.size.width;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithRed:0.067 green:0.235 blue:0.282 alpha:1]; //#113c48- used webConverter

    
    self.surfaceBoundaryView = view;
    
    [self.view addSubview:_surfaceBoundaryView];
    
}

//  Touch Logic and Accelerometer Method Call 
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Remove old touches on screen
    NSArray *subviews = [self.surfaceBoundaryView subviews];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    //draw a dot on  screen where/when touch occurs
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
    CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *data, NSError *error) {[self ballMovement:ball andAccelerationData:data.acceleration];};
    [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:accelerometerHandler];
    
}

-(void)ballMovement:(UIView *)ball andAccelerationData:(CMAcceleration)data {
    //  get current frame location:
    float x = data.x;
    float y = data.y;
    
    //set min and max bounderies
    float bottomBoundary = _surfaceBoundaryView.bounds.size.height - (ball.frame.size.height/2);
    float notQuiteBottomBoundary = 0.98f * bottomBoundary;
    float topBoundary = ball.frame.size.width/2;
    
    float rightBoundary = _surfaceBoundaryView.bounds.size.width - (ball.frame.size.width/2);
    float leftBoundary = ball.frame.size.height/2;
    
    float newY = 0;
    float newX = 0;
    
    //left and right tilt
    if (ABS(x) >= tiltSensitivity) {
        newX = x * GRAVITY_SCALE;
    }
    
    //up and down tilt
    if (ABS(y) >= tiltSensitivity) {
        newY = y * -GRAVITY_SCALE;
    }
    NSLog(@"\nx: %f, y: %f\n", x, y);
    
    //is device nearly vertical?
    if(y > -0.9) {
        newY = MIN(MAX(newY+ball.center.y, topBoundary), notQuiteBottomBoundary);
    }
    else if (y < -0.9) {
        newY = MIN(MAX(newY+ball.center.y, topBoundary), bottomBoundary);
    }
    newX = MIN(MAX(newX+ball.center.x, leftBoundary), rightBoundary);
    
    //NSLog(@"newX: %f, newY: %f", newX, newY);
    //NSLog(@"horizontal boundary:: %f:%f:: %f  center:: %f: %f",leftBoundary,rightBoundary,newY+ball.center.x, ball.center.x,ball.center.y);
    if (newY < 0.2 * bottomBoundary) {
        NSLog(@"ball in top edge\n");
    }
    ball.center = CGPointMake(newX, newY);
    [self.surfaceBoundaryView setNeedsDisplay];
    
}

- (IBAction)getAddress:(id)sender {
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //viewController is delegate object to updateLocation
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    NSLog(@"locationManager began \n");
    
}
//locationManager delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"GPS%@", [locations lastObject]);
    
    NSLog(@"didUpdateToLocation: %@", locations); //newLocation);
    CLLocation *currentLocation = [locations lastObject]; //newLocation;
    NSLog(@"currentLocation: %@", currentLocation);
    //store long and lat data
    float longitude = currentLocation.coordinate.longitude;
    float latitude = currentLocation.coordinate.latitude;
    NSLog(@"long: %f, lat: %f", longitude, latitude);

    
    //convert to street address
    //reverse geocode
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            //update street address label
            _StreetAddress.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                      placemark.subThoroughfare, placemark.thoroughfare,
                                      placemark.postalCode, placemark.locality,
                                      placemark.administrativeArea,
                                      placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    //display street address label in bottom 20% of screen
    [self.view setNeedsDisplay];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        //reset dot
        NSLog(@"\n\nSHAKE\n\n");
        [_ballView removeFromSuperview];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

//  close the accelerometer updates when the view disappears
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.manager stopAccelerometerUpdates];
}

#pragma mark function to check if device is tilted near vertically to allow ball to go to bottom edge of screen

#pragma mark function to check if ball is in top 20% of screen to display GPS street address on bottom 20% of screen

#pragma mark function to convert GPS coordinates to real-life address

@end


