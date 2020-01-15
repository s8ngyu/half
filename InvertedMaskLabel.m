//
//  InvertedMaskLabel.m
//
//  Created by Soongyu Kwon on 30/09/2019.
//  Copyright © 2019 Soongyu Kwon. All rights reserved.
//

#import "InvertedMaskLabel.h"

@implementation InvertedMaskLabel

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [super drawTextInRect:rect];
    CGContextRestoreGState(context);
}

@end
