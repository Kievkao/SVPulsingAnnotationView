//
//  UIColor+SVHelpers.m
//  SVPulsingAnnotationView
//
//  Created by Andrey Kravchenko on 7/16/15.
//  Copyright (c) 2015 Sam Vermette. All rights reserved.
//

#import "UIColor+SVHelpers.h"

@implementation UIColor (SVHelpers)

- (UIColor *)darkerColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

@end
