//
//  ViewController.m
//  KeyShareConsumer

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "KeyDetailViewController.h"
#import <CommonCrypto/CommonDigest.h>

#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"

@interface ViewController ()<UIDocumentPickerDelegate>
@end

@implementation ViewController
@synthesize tableViewKeyChain;
@synthesize keyChain;

//------------------------------------------------------------------------------
#pragma mark - View controller functions
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set this class as the table delegate
    [tableViewKeyChain setDelegate:self];
    
    //Create a key chain data source object targeting identities
    keyChain = [[KeyChainDataSource alloc] initWithMode:KSM_Identities];
    
    //load the key chain to serve as backend for the table view
    [keyChain LoadKeyChainContents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
#pragma mark - Button click handlers
//------------------------------------------------------------------------------
- (IBAction)openImportDocumentPicker:(id)sender
{
    //Clear the pasteboard, since a password may be provided via that mechanism
    //UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    //[pasteboard setString:@""];
    //passwordFromUser = @"";
    
    NSUserDefaults* standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults synchronize];
    
    NSMutableArray* utis = [[NSMutableArray alloc]init];
    
    if([standardDefaults boolForKey:@"toggle_com_rsa_pkcs12"])
        [utis addObject:@"com.rsa.pkcs-12"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_all"])
        [utis addObject:@"purebred.select.all"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_all_user"])
        [utis addObject:@"purebred.select.all_user"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_all-user"])
        [utis addObject:@"purebred.select.all-user"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_signature"])
        [utis addObject:@"purebred.select.signature"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_encryption"])
        [utis addObject:@"purebred.select.encryption"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_authentication"])
        [utis addObject:@"purebred.select.authentication"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_device"])
        [utis addObject:@"purebred.select.device"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_no_filter"])
        [utis addObject:@"purebred.select.no_filter"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_no-filter"])
        [utis addObject:@"purebred.select.no-filter"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_no-filter"])
        [utis addObject:@"purebred.select.no-filter"];
    if([standardDefaults boolForKey:@"toggle_purebred_select_no-filter"])
        [utis addObject:@"purebred.select.no-filter"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_all"])
        [utis addObject:@"purebred.zip.all"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_all_user"])
        [utis addObject:@"purebred.zip.all_user"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_all-user"])
        [utis addObject:@"purebred.zip.all-user"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_signature"])
        [utis addObject:@"purebred.zip.signature"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_encryption"])
        [utis addObject:@"purebred.zip.encryption"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_authentication"])
        [utis addObject:@"purebred.zip.authentication"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_device"])
        [utis addObject:@"purebred.zip.device"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_no_filter"])
        [utis addObject:@"purebred.zip.no_filter"];
    if([standardDefaults boolForKey:@"toggle_purebred_zip_no-filter"])
        [utis addObject:@"purebred.zip.no-filter"];

    if(0 == [utis count])
        [utis addObject:@"com.rsa.pkcs-12"];
    
    //Display the UIDocumentPickerViewController to enable the user to select a key to import. Purebred Registration only works with UIDocumentPickerModeOpen mode.
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:utis inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (IBAction)clearKeyChain:(id)sender
{
    [self resetKeychain];
    [keyChain LoadKeyChainContents];
    [[self tableViewKeyChain] reloadData];
}

//------------------------------------------------------------------------------
#pragma mark - UIDocumentPickerViewController delegate functions
//------------------------------------------------------------------------------
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    NSLog(@"Cancelled");
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *>*)urls {
    NSURL* url = urls[0];
    if(controller.documentPickerMode == UIDocumentPickerModeOpen)
    {
        BOOL startAccessingWorked = [url startAccessingSecurityScopedResource];
        NSURL *ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSLog(@"ubiquityURL %@",ubiquityURL);
        NSLog(@"start %d",startAccessingWorked);
        
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            
            NSLog(@"error %@",error);
            NSLog(@"data %@",data);
            if(nil == data)
                return;

            // Read the password from the pasteboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString* pw = [pasteboard string];
            
            if(nil != pw && 0 != [pw length])
            {
                passwordFromUser = pw;
            }

            pkcs12Data = data;
       }];
        [url stopAccessingSecurityScopedResource];
        
        if(nil == passwordFromUser || 0 == [passwordFromUser length])
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" message:@"Please enter the password for the selected PKCS #12 file" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
            alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [alert show];
        }
        else{
            /*
            NSString* p12File = @"tmp.p12";
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *p12Path = [documentsDirectory stringByAppendingPathComponent:p12File];
            
            NSLog(@"Password: %@", passwordFromUser);
            //Write the private key and certificate to a pair of files
            [pkcs12Data writeToFile:p12Path atomically:YES];
            */
            
            [self importP12:pkcs12Data password:passwordFromUser];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Table view data source
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //The KeyChainDataSource is written to supply cells in groups where each group is an identity.
    //This view is written to list each identity on one row.  Thus, return the number of sections
    //recognized by the data source.
    return [keyChain numItems];
}
#define FONT_SIZE 14.0f
#define CELL_CONTENT_MARGIN 10.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [keyChain GetIdentityNameAtIndex:indexPath.row];
    
    CGRect frameRect = [tableView frame];
    //CGSize constraint = CGSizeMake(frameRect.size.width - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    //CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    
    NSAttributedString *attributedText =
        [[NSAttributedString alloc]
            initWithString:text
            attributes:@
            {
                NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]
            }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){frameRect.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;

    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel* label = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero] ;
        [label setLineBreakMode:NSLineBreakByCharWrapping];
        //[label setMinimumFontSize:FONT_SIZE];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [label setTag:1];
        
        [[cell contentView] addSubview:label];
        
    }
    NSString *text = [keyChain GetIdentityNameAtIndex:indexPath.row];
    
    CGRect frameRect = [tableView frame];
    //CGSize constraint = CGSizeMake(frameRect.size.width - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    //CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    
    NSAttributedString *attributedText =
        [[NSAttributedString alloc]
            initWithString:text
            attributes:@
            {
                NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]
            }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){frameRect.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;

    if (!label)
        label = (UILabel*)[cell viewWithTag:1];
    
    //display the keys icon for each entry in the table
    UIImage* image = [UIImage imageNamed:@"0155-keys.png"];
    [cell.imageView setImage:image];
    
    self.imageWidth = 44;
    
    [label setText:text];
    [label setFrame:CGRectMake((CELL_CONTENT_MARGIN*2) + self.imageWidth, CELL_CONTENT_MARGIN, frameRect.size.width - (CELL_CONTENT_MARGIN * 2) - self.imageWidth, MAX(size.height, 44.0f))];
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // We remove the row being deleted from the source
        [keyChain removeObjectAtIndex:[indexPath row]];
        
        [tableView reloadData];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Table view delegate
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    KeyDetailViewController *kdvc = [storyboard instantiateViewControllerWithIdentifier:@"KeyDetailViewController"];
    [kdvc setKeyChain:[self keyChain]];
    [kdvc setItemIndex:indexPath.row];
    [kdvc setDpvc:self];
    [self presentViewController:kdvc animated:YES completion:nil];
}

//------------------------------------------------------------------------------
#pragma mark - Callbacks used by KeyDetailViewController for iTunes file sharing
//------------------------------------------------------------------------------

/**
 Called when "Share with iTunes" button is clicked on the KeyDetailViewController.
 */
- (void) import:(long)row
{
    //Read the identity and private key for the indicated item using the KeyChainDataSource instance.
    SecIdentityRef identity = [keyChain GetIdentityAtIndex:row];
    NSData* privateKeyBits = [keyChain GetPrivateKeyAtIndex:row];

    //If either could not be read, display an error and return.
    if(nil == identity || nil == privateKeyBits)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete",nil) message:@"Fail to retrieve selected identity or private key" delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
        [alertView show];

        return;
    }
    
    //Copy the certificate from the SecIdentityRef object
    SecCertificateRef cert = nil;
    OSStatus status = SecIdentityCopyCertificate(identity, &cert );
    
    //If copy operation failed, display an error and return
    if(nil == cert || 0 != status)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete",nil) message:@"Fail to load certificate or private key" delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
        [alertView show];
        
        return;
    }

    //Get the binary encoded representation of the certificate to write to a file
    NSData *decodedData = (__bridge_transfer NSData *) SecCertificateCopyData(cert);
    if(nil == decodedData)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete",nil) message:@"Fail to copy certificate data" delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
        [alertView show];
        
        return;
    }

    //Get the destination folder for the files
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Generate a file name using the sha1 hash of the certificate with .p8 extension for private key and .der for certificate
    NSString* hash = [self sha1:decodedData];
    NSString* p8File = [hash stringByAppendingString:@".p8"];
    NSString* derFile = [hash stringByAppendingString:@".der"];
    NSString *p8Path = [documentsDirectory stringByAppendingPathComponent:p8File];
    NSString *derPath = [documentsDirectory stringByAppendingPathComponent:derFile];

    //Write the private key and certificate to a pair of files
    [privateKeyBits writeToFile:p8Path atomically:YES];
    [decodedData writeToFile:derPath atomically:YES];

    //Prepare a message to display to the user indicating the hash used to name the files
    NSString* msg = [NSString stringWithFormat:@"Shared using hash %s", [hash UTF8String]];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Complete",nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alertView show];

    //dismiss the details view controller
    [self dismissWithoutImporting:row];
}

/**
 Called when "Return to key chain" button is clicked on the KeyDetailViewController.
 */
- (void) dismissWithoutImporting:(long)row
{
    [self dismissViewControllerAnimated:NO completion:nil];
    NSIndexPath* indexPath = [[self tableViewKeyChain] indexPathForSelectedRow];
    [[self tableViewKeyChain] deselectRowAtIndexPath:indexPath animated:NO];
}

//------------------------------------------------------------------------------
#pragma mark - Utility functions
//------------------------------------------------------------------------------
-(void)resetKeychain {
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
    [self deleteAllKeysForSecClass:kSecClassIdentity];
}

-(void)deleteAllKeysForSecClass:(CFTypeRef)secClass {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)secClass forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%d)", (int)result);
}

//Called when preparing file names for iTunes file sharing
- (NSString *)sha1:(NSData*)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
        if(10 == i)
            [output appendString:@"\n"];
    }
    
    return output;
}

//Called to solicit password from user when file is chosen from iCloud (or other non-Purebred source)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(1 == buttonIndex)
    {
        passwordFromUser = [[alertView textFieldAtIndex:0] text];
        if(nil != passwordFromUser && 0 != [passwordFromUser length])
        {
            [self importP12:pkcs12Data password:passwordFromUser];
        }
    }
}

//Called to parse a PKCS12 object, decrypt it and import it into app's key chain
- (void)importP12:(NSData*) pkcs12DataToImport password:(NSString*)password
{
    //Get the destination folder for the files
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Generate a file name using the sha1 hash of the certificate with .p8 extension for private key and .der for certificate
    NSString* p12File = @"p12ForReview.p12";
    NSString* passFile = @"p12Password.txt";
    NSString *p8Path = [documentsDirectory stringByAppendingPathComponent:p12File];
    NSString *passPath = [documentsDirectory stringByAppendingPathComponent:passFile];
    
    //Write the private key and certificate to a pair of files
    [pkcs12DataToImport writeToFile:p8Path atomically:YES];
    [password writeToFile:passPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    CFDataRef inPKCS12Data = (__bridge CFDataRef)pkcs12DataToImport;
    
    OSStatus securityError = errSecSuccess;
    
    //SecPKCS12Import requires a dictionary with a single value (only one option is supported)
    NSMutableDictionary * optionsDictionary = [[NSMutableDictionary alloc] init];
    [optionsDictionary setObject:(id)password forKey:(id)kSecImportExportPassphrase];
    [optionsDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
    [optionsDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [optionsDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    
    //Create an array to receive the data parsed from the PKCS12 blob
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    //Parse the PKCS12 blob
    securityError = SecPKCS12Import(inPKCS12Data, (CFDictionaryRef)optionsDictionary, &items);
    if(0 == securityError)
    {
        long count = CFArrayGetCount(items);
        if(count > 1)
        {
            NSLog(@"%s %d %s - %s", __FILE__, __LINE__, __PRETTY_FUNCTION__, "SecPKCS12Import returned more than one item.  Ignoring all but the first item.");
        }
        
        for(long ii = 0; ii < count; ++ii)
        {
            //get the first time from the array populated by SecPKCS12Import
            CFDictionaryRef pkcs12Contents = (CFDictionaryRef)CFArrayGetValueAtIndex(items, ii);
            
            //we're primarily interested in the identity value
            if(CFDictionaryContainsKey(pkcs12Contents, kSecImportItemIdentity))
            {
                //Grab the identity from the dictionary
                SecIdentityRef identity = (SecIdentityRef)CFDictionaryGetValue(pkcs12Contents, kSecImportItemIdentity);
                
                NSString* tagstr = @"red.hound.purebred.pkcs12";
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                [dict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnPersistentRef];
                [dict setObject:(__bridge id)identity forKey:(id)kSecValueRef];
                [dict setObject:tagstr forKey:(id)kSecAttrLabel];
                [dict setObject:(id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly forKey:(id)kSecAttrAccessible];
                CFTypeRef persistent_ref;
                securityError = SecItemAdd((CFDictionaryRef)dict, &persistent_ref);
                
                if(errSecSuccess != securityError)
                {
                    NSLog(@"%s %d %s - %s %s", __FILE__, __LINE__, __PRETTY_FUNCTION__, "SecItemAdd failed to import identity harvested from PKCS #12 data with error code ", [[[NSNumber numberWithInt:securityError] stringValue] UTF8String]);
                    
                    if(errSecDuplicateItem == securityError)
                    {
                        NSLog(@"Failed to import because item is there already");
                    }
                    else
                    {
                        NSString *alertMessage = [NSString stringWithFormat:@"Failed to import key from PKCS #12 file with error code %d", (int)securityError];
                        NSLog(@"%@", alertMessage);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *alertController = [UIAlertController
                                                                  alertControllerWithTitle:@"Import Error"
                                                                  message:alertMessage
                                                                  preferredStyle:UIAlertControllerStyleAlert];
                            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
                            [self presentViewController:alertController animated:YES completion:nil];
                        });
                    }
                }
                
                [keyChain LoadKeyChainContents];
                [[self tableViewKeyChain] reloadData];
            }
            
            if(errSecSuccess == securityError && CFDictionaryContainsKey(pkcs12Contents, kSecImportItemTrust))
            {
                //SecTrustRef trust = (SecTrustRef)CFDictionaryGetValue (pkcs12Contents, kSecImportItemTrust);
                //evaluate the trust and output an error log if there is a problem, if desired
            }
            
            if(errSecSuccess == securityError && CFDictionaryContainsKey(pkcs12Contents, kSecImportItemCertChain))
            {
                //CFArrayRef certChain = (CFArrayRef)CFDictionaryGetValue (pkcs12Contents, kSecImportItemCertChain);
                //import certificates from chain, if desired
            }
        }
        
    }
    else
    {
        //Get the destination folder for the files
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //Generate a file name using the sha1 hash of the certificate with .p8 extension for private key and .der for certificate
        NSString* zipFile = @"tmp.zip";
        NSString *zipPath = [documentsDirectory stringByAppendingPathComponent:zipFile];
       
        [pkcs12DataToImport writeToFile:zipPath atomically:YES];
        
        ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
        if(NULL != unzipFile)
        {
            NSArray *infos= [unzipFile listFileInZipInfos];
            [unzipFile goToFirstFileInZip];
            
            for (FileInZipInfo *info in infos)
            {
                ZipReadStream *read1= [unzipFile readCurrentFileInZip];
                
                NSData *data= [read1 readDataOfLength:info.length];
               
                if(data)
                {
                    [self importP12:data password:password];
                }
                    
                
                [read1 finishedReading];
                [unzipFile goToNextFileInZip];
            }
            
            [unzipFile close];
            [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
        }
        else{
            NSString *alertMessage = [NSString stringWithFormat:@"Failed to parse or decrypt PKCS #12 file with error code %d", (int)securityError];
            NSLog(@"%@", alertMessage);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Import Error"
                                                      message:alertMessage
                                                      preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
    }
}

@end
