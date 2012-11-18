//
//  UITableView+Toches.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 18/11/12.
//
//

#import "UITableView+Toches.h"

@implementation MYTableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];  //let the tableview handle cell selection
    [self.nextResponder touchesBegan:touches withEvent:event]; // give the controller a chance for handling touch events
}

@end
