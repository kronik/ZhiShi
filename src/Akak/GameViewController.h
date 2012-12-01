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
#import <iAd/iAd.h>

#ifdef LITE_VERSION
#import "AdWhirlDelegateProtocol.h"
@class AdWhirlView;
#endif

@interface GameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KLExpandingSelectDataSource, KLExpandingSelectDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate
#ifdef LITE_VERSION
, ADBannerViewDelegate, AdWhirlDelegate>
{
    AdWhirlView *adView;
}
#else
>
#endif

@property (nonatomic, strong) NSArray *ruWords;
@property (nonatomic, strong) KLExpandingSelect* expandingSelect;

- (void)addBackButton;

@property (nonatomic) BOOL bannerIsVisible;

#ifdef LITE_VERSION

@property (strong, nonatomic) AdWhirlView *adView;

- (IBAction)buyFullVerButtonClicked: (UIButton*)button;
- (void)adjustAdSize;

#endif

@end
