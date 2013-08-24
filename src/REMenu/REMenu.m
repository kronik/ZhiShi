//
// REMenu.m
// REMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REMenu.h"
#import "REMenuItem.h"
#import "REMenuItemView.h"

#import "UIView+Screenshot.h"
#import <Accelerate/Accelerate.h>

@interface REMenuItem ()

@property (assign, nonatomic) REMenuItemView *itemView;

@end

@interface REMenu ()

@property (strong, nonatomic) UIView *menuView;
@property (strong, nonatomic) UIView *menuWrapperView;
@property (strong, nonatomic) REMenuContainerView *containerView;
@property (strong, nonatomic) UIButton *backgroundButton;
@property (assign, readwrite, nonatomic) BOOL isOpen;
@property (assign, nonatomic) float barOffset;
@property (strong, nonatomic) UIImageView *backgroundBlurredImageView;

@end

@implementation REMenu

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    self.itemHeight = 48;
    self.separatorHeight = 2;
    self.waitUntilAnimationIsComplete = YES;
    
    self.textOffset = CGSizeMake(0, 0);
    self.subtitleTextOffset = CGSizeMake(0, 0);
    self.font = [UIFont boldSystemFontOfSize:21];
    self.subtitleFont = [UIFont systemFontOfSize:14];
    
    self.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:52/255.0 alpha:1];
    self.separatorColor = [UIColor colorWithPatternImage:self.separatorImage];
    self.textColor = [UIColor colorWithRed:128/255.0 green:126/255.0 blue:124/255.0 alpha:1];
    self.textShadowColor = [UIColor blackColor];
    self.textShadowOffset = CGSizeMake(0, -1);
    self.textAlignment = NSTextAlignmentCenter;
    
    self.highlightedBackgroundColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1];
    self.highlightedSeparatorColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1];
    self.highlightedTextColor = [UIColor colorWithRed:128/255.0 green:126/255.0 blue:124/255.0 alpha:1];
    self.highlightedTextShadowColor = [UIColor blackColor];
    self.highlightedTextShadowOffset = CGSizeMake(0, -1);
    
    self.subtitleTextColor = [UIColor colorWithWhite:0.425 alpha:1.000];
    self.subtitleTextShadowColor = [UIColor blackColor];
    self.subtitleTextShadowOffset = CGSizeMake(0, -1);
    self.subtitleHighlightedTextColor = [UIColor colorWithRed:0.389 green:0.384 blue:0.379 alpha:1.000];
    self.subtitleHighlightedTextShadowColor = [UIColor blackColor];
    self.subtitleHighlightedTextShadowOffset = CGSizeMake(0, -1);
    self.subtitleTextAlignment = NSTextAlignmentCenter;
    
    self.borderWidth = 1;
    self.borderColor =  [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1];
    self.animationDuration = 0.3;
    
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    self = [self init];
    if (!self)
        return nil;
    
    self.items = items;

    return self;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view
{
    _isOpen = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.barOffset = 44;
    } else {
        self.barOffset = 0;
    }
    
    // Create views
    //
    _containerView = [[REMenuContainerView alloc] init];
    _menuView = [[UIView alloc] init];
    _menuWrapperView = [[UIView alloc] init];
    
    _containerView.clipsToBounds = YES;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _menuView.backgroundColor = self.backgroundColor;
    _menuView.layer.cornerRadius = self.cornerRadius;
    _menuView.layer.borderColor = self.borderColor.CGColor;
    _menuView.layer.borderWidth = self.borderWidth;
    _menuView.layer.masksToBounds = YES;
    _menuView.layer.shouldRasterize = YES;
    _menuView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _menuWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _menuWrapperView.layer.shadowColor = self.shadowColor.CGColor;
    _menuWrapperView.layer.shadowOffset = self.shadowOffset;
    _menuWrapperView.layer.shadowOpacity = self.shadowOpacity;
    _menuWrapperView.layer.shadowRadius = self.shadowRadius;
    _menuWrapperView.layer.shouldRasterize = YES;
    _menuWrapperView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backgroundButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundButton.accessibilityLabel = NSLocalizedString(@"Menu background", @"Menu background");
    _backgroundButton.accessibilityHint = NSLocalizedString(@"Double tap to close", @"Double tap to close");
    [_backgroundButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    _backgroundButton.backgroundColor = [UIColor clearColor];
    
    // Append new item views to REMenuView
    //
    
    for (REMenuItem *item in _items) {
        NSInteger index = [_items indexOfObject:item];
        
        CGFloat itemHeight = _itemHeight;
        UIView *separatorView = nil;
        
        if (_separatorHeight > 0.0) {
            separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     index * _itemHeight + (index) * _separatorHeight + 40,
                                                                     rect.size.width,
                                                                     _separatorHeight)];
            separatorView.backgroundColor = _separatorColor;
            separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [_menuView addSubview:separatorView];
        }
        
        REMenuItemView *itemView = [[REMenuItemView alloc] initWithFrame:CGRectMake(0,
                                                                                    index * _itemHeight + (index+1) * _separatorHeight + 40,
                                                                                    rect.size.width,
                                                                                    itemHeight)
                                                                    menu:self
                                                             hasSubtitle:item.subtitle.length > 0];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        itemView.item = item;
        item.itemView = itemView;
        itemView.separatorView = separatorView;
        itemView.autoresizesSubviews = YES;
        if (item.customView) {
            item.customView.frame = itemView.bounds;
            item.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [itemView addSubview:item.customView];
        }
        [_menuView addSubview:itemView];
    }
    
    // Set up frames
    //
    _menuWrapperView.frame = CGRectMake(0,
                                        - self.combinedHeight,
                                        rect.size.width,
                                        self.combinedHeight);
    _menuView.frame = _menuWrapperView.bounds;
    
    _containerView.frame = CGRectMake(rect.origin.x,
                                      rect.origin.y + self.barOffset,
                                      rect.size.width,
                                      rect.size.height);
    
    _backgroundButton.frame = _containerView.bounds;
    
    _backgroundBlurredImageView = [[UIImageView alloc] initWithFrame: _containerView.bounds];
    
    _backgroundBlurredImageView.backgroundColor = [UIColor clearColor];
    _backgroundBlurredImageView.alpha = 0.0;
    
    [_containerView addSubview: self.backgroundBlurredImageView];
    
    // Add subviews
    //
    [_menuWrapperView addSubview:_menuView];
    [_containerView addSubview:_backgroundButton];
    [_containerView addSubview:_menuWrapperView];
    [view addSubview:_containerView];
    
    // Animate appearance
    //
    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:_animationDuration animations:^{
        CGRect frame = weakSelf.menuView.frame;
        frame.origin.y = -40 - _separatorHeight;
        weakSelf.menuWrapperView.frame = frame;
    } completion:^(BOOL finished) {
        UIImage *backgroundImage = [view screenshot];
        
        dispatch_queue_t queue = dispatch_queue_create("Blur queue", NULL);
        
        dispatch_async(queue, ^ {
            UIImage *blurredImage = [REMenu blurryImage: backgroundImage withBlurLevel: 0.9f];
            dispatch_async(dispatch_get_main_queue(), ^{
                _backgroundBlurredImageView.image = blurredImage;
                [UIView animateWithDuration:0.5 animations:^{
                    _backgroundBlurredImageView.alpha = 1.0;
                }];
            });
        });
        
        dispatch_release(queue);
    }];
}

- (void)showInView:(UIView *)view
{
    [self showFromRect:view.bounds inView:view];
}

- (void)showFromNavigationController:(UINavigationController *)navigationController
{
    [self showFromRect:CGRectMake(0, 0, navigationController.navigationBar.frame.size.width, navigationController.view.frame.size.height)
                inView:navigationController.view];
    _containerView.navigationBar = navigationController.navigationBar;
}

- (void)closeWithCompletion:(void (^)(void))completion
{
    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _menuView.frame;
        frame.origin.y = -20;
        weakSelf.menuWrapperView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:_animationDuration animations:^{
            CGRect frame = _menuView.frame;
            frame.origin.y = - weakSelf.combinedHeight;
            weakSelf.menuWrapperView.frame = frame;
            _backgroundBlurredImageView.alpha = 0.0;

        } completion:^(BOOL finished) {
            [weakSelf.menuView removeFromSuperview];
            [weakSelf.menuWrapperView removeFromSuperview];
            [weakSelf.backgroundButton removeFromSuperview];
            [weakSelf.containerView removeFromSuperview];
            weakSelf.isOpen = NO;
            
            if (completion)
                completion();
          
            if (weakSelf.closeCompletionHandler)
                weakSelf.closeCompletionHandler();
        }];
    }];
}

+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)close
{
    [self closeWithCompletion:nil];
}

- (CGFloat)combinedHeight
{
    return _items.count * _itemHeight + _items.count  * _separatorHeight + 40;// + _cornerRadius;
}

#pragma mark -
#pragma mark Setting style

- (UIImage *)separatorImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 4));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 2));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:79/255.0 green:79/255.0 blue:77/255.0 alpha:1].CGColor);
    CGContextFillRect(context, CGRectMake(0, 3, 1, 2));
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:outputImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
}

@end
