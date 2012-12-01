//
//  LASharekit.m
//
//  Created by Luis Ascorbe on 08/11/12.
//  Copyright (c) 2012 Luis Ascorbe. All rights reserved.
//
/*
 
 LASharekit is available under the MIT license.
 
 Copyright © 2012 Luis Ascorbe.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <Foundation/Foundation.h>

// MY OWN BLOCK
typedef void (^MyCompletionBlock)();

@interface LASharekit : NSObject

// Controller   -> Is used to present modalViews
// title        -> Is used for the title in facebook, twitter and pinterest, then in the subject for email
// Text         -> Is used for the text in facebook, twitter and pinterest, then in the boddy for email
// Url          -> Is used for the url in facebook, twitter and pinterest, then in the boddy for email
// ImageUrl     -> Is used for pinterest, to show the image
// Image        -> Is used for the image in facebook, twitter and pinterest, then in the attached for email and to save in the cameraroll
// tweetCC      -> Is used to insert a cc on the tweet

@property (nonatomic, retain) id controller;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *imageUrl;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *tweetCC;

// INITS
- (id)init:(id)controller_;
- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_;
- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_;
- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_  completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled;
- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_  imageUrl:(NSURL *)imageUrl_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled;
- (id)initWithImage:(UIImage *)image_;

// BLOCKS
- (void) setCompletionDone:(MyCompletionBlock)blockDone;
- (void) setCompletionCanceled:(MyCompletionBlock)blockCanceled;
- (void) setCompletionFailed:(MyCompletionBlock)blockFailed;
- (void) setCompletionSaved:(MyCompletionBlock)blockSaved;

// FUNCTIONS
- (void)setController:(id)controller_;
- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_;
- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_;
- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled;
- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled;

// SHARE
- (void) facebookPost;              // FACEBOOK
- (void) tweet;                     // TWITTER
- (void) pinIt;                     // PINTEREST
- (void) emailIt;                   // EMAIL
- (void) saveImage;                 // SAVE IMAGE TO CAMERAROLL

- (void) copyTitleToPasteboard;     // COPY THE TITLE TO THE PASTEBOARD
- (void) copyTextToPasteboard;      // COPY THE TEXT TO THE PASTEBOARD
- (void) copyUrlToPasteboard;       // COPY THE URL TO THE PASTEBOARD
- (void) copyImageToPasteboard;     // COPY THE IMAGE TO THE PASTEBOARD
- (void) copyImageUrlToPasteboard;  // COPY THE IMAGEURL TO THE PASTEBOARD

@end
