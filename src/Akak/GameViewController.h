//
//  GameViewController.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"
#import "KLExpandingSelect.h"
#import <MessageUI/MessageUI.h>

@interface GameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KLExpandingSelectDataSource, KLExpandingSelectDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *ruWords;
@property (nonatomic, strong) KLExpandingSelect* expandingSelect;

- (void)addBackButton;

@end
