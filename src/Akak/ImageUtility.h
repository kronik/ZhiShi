//
//  ImageUtility.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 23/8/13.
//
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject

+ (UIImage *)circleImageOfSize: (float) size
                withInnerColor: (UIColor *)innerColor
                 andOuterColor: (UIColor *)outerColor;

@end
