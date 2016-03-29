//
//  KeyDetailViewController.h
//  KeyShareConsumer

#import <UIKit/UIKit.h>
#import "KeyChainDataSource.h"
#import "ViewController.h"

@interface KeyDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    KeyChainDataSource* keyChain;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *importButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) KeyChainDataSource *keyChain;
@property (nonatomic, retain) ViewController *dpvc;
@property (nonatomic, assign) int itemIndex;
@end
