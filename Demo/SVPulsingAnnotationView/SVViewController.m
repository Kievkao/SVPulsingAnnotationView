//
//  SVViewController.m
//  SVPulsingAnnotationView
//
//  Created by Sam Vermette on 03.03.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import "SVViewController.h"
#import <MapKit/MapKit.h>
#import "SVAnnotation.h"

#import "SVPulsingAnnotationView.h"

@interface SVViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation SVViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}


- (void)viewDidAppear:(BOOL)animated {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45.52439, -73.57447);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:NO];
    
    // remove zoom by tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView.subviews[0] addGestureRecognizer:doubleTap];
    
    SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        static NSString *identifier = @"currentLocation";
		SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(pulsingView == nil) {
			pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.pulseColor = [UIColor colorWithRed:62.0/255.0 green:66.0/255.0 blue:110.0/255.0 alpha:1];
            pulsingView.pulseScaleFactor = 3;
            pulsingView.outerPulseAnimationDuration = 2;
            pulsingView.delayBetweenPulseCycles = 0;
            pulsingView.image = [UIImage imageNamed:@"demo_avatar_cook"];
            pulsingView.canShowCallout = YES;
        }
		
		return pulsingView;
    }
    
    return nil;
}

@end
