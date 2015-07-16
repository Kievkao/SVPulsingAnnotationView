//
//  SVPulsingAnnotationView.m
//
//  Created by Sam Vermette on 01.03.13.
//  https://github.com/samvermette/SVPulsingAnnotationView
//

#import "SVPulsingAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kImageDiameter = 70.0f;

@interface SVPulsingAnnotationView ()

@property (nonatomic, strong) CALayer *shinyDotLayer;
@property (nonatomic, strong) CALayer *glowingHaloLayer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *headingImageView;

@property (nonatomic, strong) CALayer *mainHaloLayer;
@property (nonatomic, strong) CALayer *secondaryHaloLayer;
@property (nonatomic, strong) NSMutableArray *additionalHaloLayers;

@property (nonatomic, strong) CAAnimationGroup *mainAnimationGroup;
@property (nonatomic, strong) CAAnimationGroup *secondaryAnimationGroup;

@end

@implementation SVPulsingAnnotationView

@synthesize annotation = _annotation;
@synthesize image = _image;

+ (NSMutableDictionary*)cachedRingImages {
    static NSMutableDictionary *cachedRingLayers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ cachedRingLayers = [NSMutableDictionary new]; });
    return cachedRingLayers;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.calloutOffset = CGPointMake(0, 4);
        self.bounds = CGRectMake(0, 0, kImageDiameter, kImageDiameter);
        self.pulseScaleFactor = 5.3;
        self.pulseAnimationDuration = 1.5;
        self.outerPulseAnimationDuration = 3;
        self.delayBetweenPulseCycles = 0;
        self.annotationColor = [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        [self addGestureRecognizer:tapGesture];
        
        self.willMoveToSuperviewAnimationBlock = ^(SVPulsingAnnotationView *annotationView, UIView *superview) {
            CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            bounceAnimation.values = @[@0.05, @1.25, @0.8, @1.1, @0.9, @1.0];
            bounceAnimation.duration = 0.3;
            bounceAnimation.timingFunctions = @[easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut];
            [annotationView.layer addAnimation:bounceAnimation forKey:@"popIn"];
        };
    }
    return self;
}

- (void)tapDetected {
    CALayer *newLayer = [CALayer layer];
    [self configureLayer:newLayer];
    [self.layer insertSublayer:newLayer below:self.secondaryHaloLayer];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    bounceAnimation.values = @[@0.05, @1.25, @0.8, @1.1, @0.9, @1.0];
    bounceAnimation.duration = 0.3;
    bounceAnimation.timingFunctions = @[easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut];
    [self.imageView.layer addAnimation:bounceAnimation forKey:@"popIn"];
}

- (void)rebuildLayers {
    [_mainHaloLayer removeFromSuperlayer];
    _mainHaloLayer = nil;
    
    [_secondaryHaloLayer removeFromSuperlayer];
    _secondaryHaloLayer = nil;
    
    [_additionalHaloLayers removeAllObjects];
    
    _mainAnimationGroup = nil;
    
    if(!self.image) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    
    if (self.headingImage) {
        [self addSubview:self.headingImageView];
    }
    else {
        [_headingImageView removeFromSuperview];
        _headingImageView = nil;
    }
    
    [self.layer addSublayer:self.mainHaloLayer];
    [self.layer addSublayer:self.secondaryHaloLayer];
    
    [self addSubview:self.imageView];
}

- (void)willMoveToSuperview:(UIView *)superview {
    if(superview)
        [self rebuildLayers];
    
    if(self.willMoveToSuperviewAnimationBlock)
        self.willMoveToSuperviewAnimationBlock(self, superview);
}

- (void)popIn {
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    bounceAnimation.values = @[@0.05, @1.25, @0.8, @1.1, @0.9, @1.0];
    bounceAnimation.duration = 0.3;
    bounceAnimation.timingFunctions = @[easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut];
    [self.layer addAnimation:bounceAnimation forKey:@"popIn"];
}

#pragma mark - Setters

- (void)setAnnotationColor:(UIColor *)annotationColor {
    if(CGColorGetNumberOfComponents(annotationColor.CGColor) == 2) {
        float white = CGColorGetComponents(annotationColor.CGColor)[0];
        float alpha = CGColorGetComponents(annotationColor.CGColor)[1];
        annotationColor = [UIColor colorWithRed:white green:white blue:white alpha:alpha];
    }
    
    _annotationColor = annotationColor;
    _imageView.tintColor = annotationColor;
    _headingImageView.tintColor = annotationColor;
    
    if(self.superview)
        [self rebuildLayers];
}

- (void)setDelayBetweenPulseCycles:(NSTimeInterval)delayBetweenPulseCycles {
    _delayBetweenPulseCycles = delayBetweenPulseCycles;
    
    if(self.superview)
        [self rebuildLayers];
}

- (void)setPulseAnimationDuration:(NSTimeInterval)pulseAnimationDuration {
    _pulseAnimationDuration = pulseAnimationDuration;
    
    if(self.superview)
        [self rebuildLayers];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if(self.superview)
        [self rebuildLayers];
    
    self.imageView.image = image;
}

- (void)setHeadingImage:(UIImage *)image {
    _headingImage = image;
    
    if (self.superview) {
        [self rebuildLayers];
    }
    
    self.headingImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.headingImageView.bounds = CGRectMake(0, 0, ceil(image.size.width), ceil(image.size.height));
    self.headingImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.headingImageView.tintColor = self.annotationColor;
}

#pragma mark - Getters

- (UIColor *)pulseColor {
    if(!_pulseColor)
        return self.annotationColor;
    return _pulseColor;
}

- (void)configurePermamentAnimationGroup:(CAAnimationGroup *)animationGroup {
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    animationGroup.duration = self.outerPulseAnimationDuration + self.delayBetweenPulseCycles;
    animationGroup.repeatCount = INFINITY;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = defaultCurve;
    
    NSMutableArray *animations = [NSMutableArray new];
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = @(1/self.pulseScaleFactor);
    pulseAnimation.toValue = @1.0;
    pulseAnimation.duration = self.outerPulseAnimationDuration;
    [animations addObject:pulseAnimation];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.outerPulseAnimationDuration;
    opacityAnimation.values = @[@0.2, @0.9, @0];
    opacityAnimation.keyTimes = @[@0, @0.2, @1];
    opacityAnimation.removedOnCompletion = NO;
    [animations addObject:opacityAnimation];
    
    animationGroup.animations = animations;
}

- (CAAnimationGroup *)mainAnimationGroup {
    if (!_mainAnimationGroup) {
        _mainAnimationGroup = [CAAnimationGroup animation];
    }
    return _mainAnimationGroup;
}

- (CAAnimationGroup *)secondaryAnimationGroup {
    if (!_secondaryAnimationGroup) {
        _secondaryAnimationGroup = [CAAnimationGroup animation];
    }
    return _secondaryAnimationGroup;
}

#pragma mark - Graphics

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.cornerRadius = kImageDiameter / 2;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)headingImageView {
    if (!_headingImageView) {
        _headingImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _headingImageView.contentMode = UIViewContentModeTopLeft;
    }
    
    return _headingImageView;
}

- (void)configurePermanentHaloLayer:(CALayer *)layer withAnimationGroup:(CAAnimationGroup *)group {
    
    CGFloat width = self.bounds.size.width*self.pulseScaleFactor;
    layer.bounds = CGRectMake(0, 0, width, width);
    layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.backgroundColor = self.pulseColor.CGColor;
    layer.cornerRadius = width/2;
    layer.opacity = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if(self.delayBetweenPulseCycles != INFINITY) {
            CAAnimationGroup *animationGroup = group;
            [self configurePermamentAnimationGroup:animationGroup];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [layer addAnimation:animationGroup forKey:@"pulse"];
            });
        }
    });
}

- (CALayer *)mainHaloLayer {
    if(!_mainHaloLayer) {
        _mainHaloLayer = [CALayer layer];
        CGFloat width = self.bounds.size.width*self.pulseScaleFactor;
        _mainHaloLayer.bounds = CGRectMake(0, 0, width, width);
        _mainHaloLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _mainHaloLayer.contentsScale = [UIScreen mainScreen].scale;
        _mainHaloLayer.backgroundColor = self.pulseColor.CGColor;
        _mainHaloLayer.cornerRadius = width/2;
        _mainHaloLayer.opacity = 0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAAnimationGroup *animationGroup = self.mainAnimationGroup;
                [self configurePermamentAnimationGroup:animationGroup];
                //[self configurePermamentAnimationGroup:self.mainAnimationGroup];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_mainHaloLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return _mainHaloLayer;
}

- (CALayer *)secondaryHaloLayer {
    if(!_secondaryHaloLayer) {
        _secondaryHaloLayer = [CALayer layer];
        CGFloat width = self.bounds.size.width*self.pulseScaleFactor;
        _secondaryHaloLayer.bounds = CGRectMake(0, 0, width, width);
        _secondaryHaloLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _secondaryHaloLayer.contentsScale = [UIScreen mainScreen].scale;
        _secondaryHaloLayer.backgroundColor = self.pulseColor.CGColor;
        _secondaryHaloLayer.cornerRadius = width/2;
        _secondaryHaloLayer.opacity = 0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.outerPulseAnimationDuration/2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAAnimationGroup *animationGroup = self.secondaryAnimationGroup;
                [self configurePermamentAnimationGroup:animationGroup];
                //[self configurePermamentAnimationGroup:self.secondaryAnimationGroup];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [_secondaryHaloLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return _secondaryHaloLayer;
}

- (void)configureLayer:(CALayer *)layer {
    
    CGFloat width = self.bounds.size.width*self.pulseScaleFactor;
    layer.bounds = CGRectMake(0, 0, width, width);
    layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.backgroundColor = self.pulseColor.CGColor;
    layer.cornerRadius = width/2;
    layer.opacity = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if(self.delayBetweenPulseCycles != INFINITY) {
            CAAnimationGroup *animationGroup = [CAAnimationGroup new];
            [self configureGroup:animationGroup];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [layer addAnimation:animationGroup forKey:@"pulse"];
            });
        }
    });
}

- (void)configureGroup:(CAAnimationGroup *)group {
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    group.duration = self.outerPulseAnimationDuration + self.delayBetweenPulseCycles;
    group.repeatCount = 1;
    group.removedOnCompletion = YES;
    group.timingFunction = defaultCurve;
    
    NSMutableArray *animations = [NSMutableArray new];
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = @(1/self.pulseScaleFactor);
    pulseAnimation.toValue = @1.0;
    pulseAnimation.duration = self.outerPulseAnimationDuration;
    [animations addObject:pulseAnimation];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.outerPulseAnimationDuration;
    opacityAnimation.values = @[@0.2, @0.9, @0];
    opacityAnimation.keyTimes = @[@0, @0.2, @1];
    opacityAnimation.removedOnCompletion = NO;
    [animations addObject:opacityAnimation];
    
    group.animations = animations;
}

- (NSMutableArray *)additionalHaloLayers {
    
    if (!_additionalHaloLayers) {
        _additionalHaloLayers = [NSMutableArray new];
    }
    
    return _additionalHaloLayers;
}

- (UIImage*)circleImageWithColor:(UIColor*)color height:(float)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(height, height), NO, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, height, height)];
    [color setFill];
    [fillPath fill];
    
    UIImage *dotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorSpace);
    
    return dotImage;
}

@end
