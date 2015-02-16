
#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h> //for touch


@interface ViewController () <UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *surfaceBoundaryView;
@property (weak, nonatomic) IBOutlet UIView *dotView;

@property (weak, nonatomic) UILabel *StreetAddress;

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
const static float nearlyVertical   = 0.9;

const static int   cropRadius       = 25;
const static int   dotRadius        = 50;


//  create "dot" view and attach behaviors
- (void)viewDidLoad {
    
    [super viewDidLoad];

    //for CoreLocation's gps fetch
    locationManager = [[CLLocationManager   alloc] init];
    geocoder        = [[CLGeocoder          alloc] init];

    //boundary frame creation
    CGRect frame;
    frame.origin            = CGPointZero;
    frame.size.height       = self.view.bounds.size.height;
    frame.size.width        = self.view.bounds.size.width;
    UIView *view            = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor    = [UIColor colorWithRed:0.067 green:0.235 blue:0.282 alpha:1]; //#113c48- used webConverter

    self.surfaceBoundaryView = view;
    
    [self.view addSubview:_surfaceBoundaryView];
    
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 460, 200, 100)];
    _addressLabel.textColor = [UIColor colorWithRed:0.973 green:0.976 blue:0.537 alpha:1]; //#f8f989- used webconverter
    _addressLabel.numberOfLines = 4;
}

//wait for user to touch screen to draw dot and begin activity
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
        UIView *dotsView = [[UIView alloc] init];
        //#3882a6 - used webconverter
        [dotsView setBackgroundColor:[UIColor colorWithRed:0.22 green:0.51 blue:0.651 alpha:1]];
        //create rect to place in touch location
        dotsView.frame = CGRectMake(touchPoint.x, touchPoint.y, dotRadius, dotRadius);
        //trim rect into a dot!
        dotsView.layer.cornerRadius = cropRadius;
        //add the view
        self.dotView = dotsView;
        [self.surfaceBoundaryView addSubview:_dotView];
    }];
    
    [self dotMotionAcceleration:_dotView];
    
}

//  dot motion and accelerometer stuff
-(void)dotMotionAcceleration:(UIView *)dot {
    NSLog(@"dotMotionAcceleration");
    self.manager = [[CMMotionManager alloc] init];
    self.manager.accelerometerUpdateInterval = 1.0f/FRAME_RATE;
    CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *data, NSError *error) {[self dotMovement:dot andAccelerationData:data.acceleration];};
    [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:accelerometerHandler];
    
}

-(void)dotMovement:(UIView *)dot andAccelerationData:(CMAcceleration)data {
    //  get current frame location:
    float x = data.x;
    float y = data.y;
    
    //set min and max bounderies
    float bottomBoundary = _surfaceBoundaryView.bounds.size.height - (dot.frame.size.height/2);
    float notQuiteBottomBoundary = 0.98f * bottomBoundary;
    float topBoundary = dot.frame.size.width/2;
    
    float rightBoundary = _surfaceBoundaryView.bounds.size.width - (dot.frame.size.width/2);
    float leftBoundary = dot.frame.size.height/2;
    
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
    if(y > -nearlyVertical) {
        newY = MIN(MAX(newY+dot.center.y, topBoundary), notQuiteBottomBoundary);
    }
    else if (y < -nearlyVertical) {
        newY = MIN(MAX(newY+dot.center.y, topBoundary), bottomBoundary);
    }
    newX = MIN(MAX(newX+dot.center.x, leftBoundary), rightBoundary);
    //NSLog(@"newX: %f, newY: %f", newX, newY);
    //NSLog(@"horizontal boundary:: %f:%f:: %f  center:: %f: %f",leftBoundary,rightBoundary,newY+dot.center.x, dot.center.x,dot.center.y);
    
    //is this the first time the dot is entering the top edge?
    if (newY < 0.2 * bottomBoundary) {
        NSLog(@"dot in top edge\n");
        [self getAddress:self];
        
        //display street address label in bottom 20% of screen
        self.StreetAddress = _addressLabel;
        [self.surfaceBoundaryView addSubview:_StreetAddress];
        
    }
    //did dot leave the top edge?
    if (newY > 0.2 * bottomBoundary) {
        NSLog(@"dot leaves top edge\n\n");
        [_StreetAddress  removeFromSuperview];
    }
    dot.center = CGPointMake(newX, newY);
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
    
    CLLocation *currentLocation = [locations lastObject];
    
    //convert to street address (reverse geocode)
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            //update street address label
            _StreetAddress.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                      placemark.subThoroughfare, placemark.thoroughfare,
                                      placemark.postalCode, placemark.locality,
                                      placemark.administrativeArea, placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    [self.view setNeedsDisplay];
}

//did user shake device?
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        //reset dot
        NSLog(@"\n\nSHAKE\n\n");
        [_dotView removeFromSuperview];
    }
}

//override canBecomeFirstResponder to allow shaking the device to control clearing activity
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

@end


