//
//  RulesSearcherViewController.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 18/11/12.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"
#import "BasicViewController.h"

@interface RulesSearcherViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>

- (void)addBackButton;

@property (nonatomic) BOOL sendNotifications;

@end
