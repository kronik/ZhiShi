//
//  GameViewController.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"

@interface GameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *ruWords;
- (void)addBackButton;

@end
