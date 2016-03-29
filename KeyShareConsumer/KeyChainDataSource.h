//
//  KeyChainDataSource.h
//  KeyShareConsumer

#import <Foundation/Foundation.h>

/**
 KeyChainDataSource has three modes of usage, each defined by the type of
 item sought in the key chain.  
 */
enum KeyChainDataSourceMode
{
    KSM_Certificates,
    KSM_Identities,
    KSM_Keys
};

/**
 The KeyChainDataSource class is intended to function as a data source for table views displaying
 various information from a key chain.  Each KeyStore instance is associated with a type
 of key chain item, i.e., identity, certificate, key.  
 
 Each item is a section in the table with various information appropriate to the item
 displayed in the section. 
 
 Should only be used with tables with table style UITableViewStyleGrouped.
 */
@interface KeyChainDataSource : NSObject 
{
    
@public
    //!When false, empty attributes are not returned, when true empty attributes are returned with 
    // empty string value.
    bool displayEmptyAttributes;
    
    //!userQuery can be specified to change the search behavior applied by KeyChainDataSource
    // before serving data to a table view.
    NSMutableDictionary* userQuery;

    //!mode indicates the type of object associated with an instance (set upon instantiation)
    enum KeyChainDataSourceMode mode;

@private
    //!initialized indicates whether LoadKeyChainContents has been successfully executed.
    bool initialized;
        
    //!items contains the values retrieved from the key chain
    NSMutableArray* items;
    
    //!dictionary with friendly attribute names (prepared in init)
    NSMutableDictionary* attrNames;
}

//Public properties
@property (nonatomic, assign) bool displayEmptyAttributes;
@property (nonatomic, retain) NSMutableDictionary* userQuery;

//Private properties
@property (nonatomic, retain) NSArray* items;
@property (nonatomic, assign) enum KeyChainDataSourceMode mode;
@property (nonatomic, assign) bool initialized;
@property (nonatomic, retain) NSMutableDictionary* attrNames;

- (id) initWithMode:(enum KeyChainDataSourceMode)mode;
- (void) ClearContents;
- (void) LoadKeyChainContents;
- (NSString*) GetIdentityNameAtIndex:(long)index;
- (NSString*) GetEmailAddressAtIndex:(long)index;
- (void) removeObjectAtIndex:(long)index;
- (int) numItems;
- (SecIdentityRef) GetIdentityAtIndex:(long)index;
- (NSData*) GetPKCS12AtIndex:(long)index;
- (NSData*) GetPrivateKeyAtIndex:(long)index;

- (int) numAttrGroups:(long)index;
- (NSString*) getAttrStringAtIndex:(long)index attrGroup:(long)attrGroup;

- (NSString*) getAttrNameAtSection:(long)sectionIndex attrIndex:(long)attrIndex;
- (NSString*) getAttrValueAtSection:(long)sectionIndex attrIndex:(long)attrIndex;
- (NSString*) getAttrValueAtSection:(long)sectionIndex attrType:(CFTypeRef)attrType;

- (SecCertificateRef) getCertificateAt:(long)index;

@end
