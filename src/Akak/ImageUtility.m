//
//  ImageUtility.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 23/8/13.
//
//

#import "ImageUtility.h"

@implementation ImageUtility

+ (UIImage *)circleImageOfSize: (float) size
                withInnerColor: (UIColor *)innerColor
                 andOuterColor: (UIColor *)outerColor {
    
    CGRect rect = CGRectMake(0, 0, size, size);
    
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef viewContext = UIGraphicsGetCurrentContext();
    CGLayerRef pieLayer = CGLayerCreateWithContext(viewContext, CGSizeMake(size, size), NULL);
    CGContextRef pieLayerContext = CGLayerGetContext(pieLayer);
    
    CGContextSetStrokeColorWithColor(pieLayerContext, outerColor.CGColor);
    CGContextSetLineWidth(pieLayerContext, 1.5);
    
    CGContextStrokeEllipseInRect(pieLayerContext, CGRectMake(2, 2, size - 4, size - 4));

    CGContextSetFillColorWithColor(pieLayerContext, outerColor.CGColor);

    CGContextMoveToPoint(pieLayerContext, size / 2, size / 2);
    CGContextAddArc(pieLayerContext, size / 2, size / 2, (size / 2) - 2, 0, 360 * M_PI / 180, 0);
    CGContextClosePath(pieLayerContext);
    
    CGContextSetFillColorWithColor(pieLayerContext, innerColor.CGColor);
    CGContextFillPath(pieLayerContext);
    
    CGContextDrawLayerInRect(viewContext, rect, pieLayer);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image;
}

@end
