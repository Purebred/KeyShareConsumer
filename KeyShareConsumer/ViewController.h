//
//  ViewController.h
//  KeyShareConsumer

#import <UIKit/UIKit.h>
#import "KeyChainDataSource.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    //provides information about key chain contents
    KeyChainDataSource* keyChain;
    
    //table view to display summary of key chain contents
    IBOutlet UITableView* tableViewKeyChain;
    
    //string to receive password entered by user
    NSString* passwordFromUser;

    //buffer to receive PKCS12 file read from iCloud
    NSData* pkcs12Data;
}

//Callbacks used by KeyDetailViewController for iTunes file sharing
- (void)import:(int)index;
- (void)dismissWithoutImporting:(int)index;

//Button click handlers
- (IBAction)openImportDocumentPicker:(id)sender;
- (IBAction)clearKeyChain:(id)sender;

@property (nonatomic, retain) UITableView *tableViewKeyChain;
@property (nonatomic, retain) KeyChainDataSource *keyChain;
@property (nonatomic, assign) int imageWidth;

@end

