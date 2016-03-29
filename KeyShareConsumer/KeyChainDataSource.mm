//
//  KeyChainDataSource.mm
//  KeyShareConsumer

#import "KeyChainDataSource.h"
#import <UIKit/UIKit.h>

#include <sstream>

//--------------------------------------------------------------
// Arrays containing attributes for each type of item associated
// with this class: certificate, key, identity
//--------------------------------------------------------------
CFTypeRef g_certAttrs[] = {
    kSecAttrAccessible,
    kSecAttrAccessGroup,
    kSecAttrCertificateType,
    kSecAttrCertificateEncoding,
    kSecAttrLabel,
    kSecAttrSubject,
    kSecAttrIssuer,
    kSecAttrSerialNumber,
    kSecAttrSubjectKeyID,
    kSecAttrPublicKeyHash,
    NULL
};

CFTypeRef g_keyAttrs[] = {
    kSecAttrAccessible,
    kSecAttrAccessGroup,
    kSecAttrKeyClass,
    kSecAttrLabel,
    kSecAttrApplicationLabel,
    kSecAttrIsPermanent,
    kSecAttrApplicationTag,
    kSecAttrKeyType,
    kSecAttrKeySizeInBits,
    kSecAttrEffectiveKeySize,
    kSecAttrCanEncrypt,
    kSecAttrCanDecrypt,
    kSecAttrCanDerive,
    kSecAttrCanSign,
    kSecAttrCanVerify,
    kSecAttrCanWrap,
    kSecAttrCanUnwrap,
    NULL
};

CFTypeRef g_identityAttrs[] = {
    kSecAttrAccessible,
    kSecAttrAccessGroup,
    kSecAttrCertificateType,
    kSecAttrCertificateEncoding,
    kSecAttrLabel,
    kSecAttrSubject,
    kSecAttrIssuer,
    kSecAttrSerialNumber,
    kSecAttrSubjectKeyID,
    kSecAttrPublicKeyHash,
    kSecAttrKeyClass,
    kSecAttrApplicationLabel,
    kSecAttrIsPermanent,
    kSecAttrApplicationTag,
    kSecAttrKeyType,
    kSecAttrKeySizeInBits,
    kSecAttrEffectiveKeySize,
    kSecAttrCanEncrypt,
    kSecAttrCanDecrypt,
    kSecAttrCanDerive,
    kSecAttrCanSign,
    kSecAttrCanVerify,
    kSecAttrCanWrap,
    kSecAttrCanUnwrap,
    NULL
};

//--------------------------------------------------------------
// Arrays containing attributes that are grouped together in a 
// single table cell for display purposes, i.e., a single string
// is returned containing information for all attributes in the 
// group.
//--------------------------------------------------------------
CFTypeRef g_keyRelatedAttrs[] = {
    kSecAttrKeyClass,
    kSecAttrKeyType,
    kSecAttrKeySizeInBits,
    kSecAttrEffectiveKeySize,
    NULL
};

CFTypeRef g_capabilityRelatedAttrs[] = {
    kSecAttrCanEncrypt,
    kSecAttrCanDecrypt,
    kSecAttrCanDerive,
    kSecAttrCanSign,
    kSecAttrCanVerify,
    kSecAttrCanWrap,
    kSecAttrCanUnwrap,
    NULL
};

CFTypeRef g_certRelatedAttrs[] = {
    kSecAttrCertificateType,
    kSecAttrCertificateEncoding,
    kSecAttrSubject,
    kSecAttrIssuer,
    kSecAttrSerialNumber,
    kSecAttrSubjectKeyID,
    kSecAttrPublicKeyHash,
    NULL
};

CFTypeRef g_miscRelatedAttrs[] = {
    kSecAttrLabel,
    kSecAttrAccessible,
    kSecAttrAccessGroup,
    kSecAttrApplicationLabel,
    kSecAttrIsPermanent,
    kSecAttrApplicationTag,
    NULL
};

//--------------------------------------------------------------
// Internal conversion helper functions
//--------------------------------------------------------------
@interface KeyChainDataSource (ConversionRoutines)

    //These return strings that should be autoreleased
    + (NSString*) getCFDateAsString:(CFDateRef) date;
    + (NSString*) getCFNumberAsString:(CFNumberRef) number;
    + (NSString*) getCFBooleanAsString:(CFBooleanRef) cfBool;
    + (NSString*) getCertificateTypeAsString:(CFNumberRef) number;
    + (NSString*) getKeyTypeAsString:(CFNumberRef) number;
    + (NSString*) getKeyClassAsString:(CFNumberRef) number;
    + (NSString*) getCertificateEncodingAsString:(CFNumberRef) number;
    + (NSString*) getAttrAccessibleAsString:(CFStringRef) attrAccessible;

    //The return freshly alloc'ed string
    + (NSString*) getDataAsAsciiHexString:(NSData*)data;
    + (NSString*) getDataAsNameString:(NSData*)data;

@end

@implementation KeyChainDataSource (ConversionRoutines)

+ (NSString*) getCFDateAsString:(CFDateRef) date
{
    NSDate* nsDate = (__bridge NSDate*)date;
    return [nsDate description];
}

+ (NSString*) getCFNumberAsString:(CFNumberRef) number
{
    NSNumber* nsNumber = (__bridge NSNumber*)number;
    return [nsNumber stringValue];
}

+ (NSString*) getCFBooleanAsString:(CFBooleanRef) cfBool
{
    if(CFBooleanGetValue(cfBool))
        return NSLocalizedString(@"Yes", nil);
    else
        return NSLocalizedString(@"No", nil);
}

+ (NSString*) getCertificateTypeAsString:(CFNumberRef) number
{
    NSNumber* nsNumber = (__bridge NSNumber*)number;
    switch([nsNumber intValue])
    {
        case 1:
            return NSLocalizedString(@"X509v1", nil);
        case 2:     
            return NSLocalizedString(@"X509v2", nil);
        case 3:    
            return NSLocalizedString(@"X509v3", nil);
        default:
            return NSLocalizedString(@"Unknown type", nil);
    }
}

+ (NSString*) getKeyClassAsString:(CFNumberRef) number
{
    NSString* nStr = [self getCFNumberAsString:number];

    if(NSOrderedSame == [(NSString*)kSecAttrKeyClassPublic compare:nStr])
        return NSLocalizedString(@"Public key", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrKeyClassPrivate compare:nStr])
        return NSLocalizedString(@"Private key", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrKeyClassSymmetric compare:nStr])
        return NSLocalizedString(@"Symmetric key", nil);
    else
        return NSLocalizedString(@"Unknown type", nil);
}

+ (NSString*) getKeyTypeAsString:(CFNumberRef) number
{
    NSString* nStr = [self getCFNumberAsString:number];
    
    if(NSOrderedSame == [(NSString*)kSecAttrKeyTypeRSA compare:nStr])
        return NSLocalizedString(@"RSA", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrKeyTypeRSA compare:nStr])
        return NSLocalizedString(@"Elliptic curve", nil);
    else
        return NSLocalizedString(@"Unknown type", nil);
}

+ (NSString*) getAttrAccessibleAsString:(CFStringRef) attrAccessible
{
    NSString* nStr = (__bridge NSString*)attrAccessible;

    if(NSOrderedSame == [(NSString*)kSecAttrAccessibleWhenUnlocked compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleWhenUnlocked", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrAccessibleAfterFirstUnlock compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleAfterFirstUnlock", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrAccessibleAlways compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleAlways", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrAccessibleWhenUnlockedThisDeviceOnly compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleWhenUnlockedThisDeviceOnly", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly", nil);
    else if(NSOrderedSame == [(NSString*)kSecAttrAccessibleAlwaysThisDeviceOnly compare:nStr])
        return NSLocalizedString(@"kSecAttrAccessibleAlwaysThisDeviceOnly", nil);
    else
        return NSLocalizedString(@"Unknown type", nil);
}

+ (NSString*) getCertificateEncodingAsString:(CFNumberRef) number
{
    NSNumber* nsNumber = (__bridge NSNumber*)number;
    if(3 == [nsNumber intValue])
        return NSLocalizedString(@"DER", nil);
    else
        return NSLocalizedString(@"Unknown type", nil);
}

+ (NSString *) hexString:(NSData*)data
{
    NSUInteger bytesCount = [data length];
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = (unsigned char*)[data bytes];
        char *chars = (char*)malloc(sizeof(char) * (bytesCount * 2 + 1));
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

+ (NSString*) getDataAsAsciiHexString:(NSData*)data
{
    return [self hexString:data];
}

+ (NSString*) getDataAsNameString:(NSData*)data
{
    //Implement after linking useful PKE support
    return nil;
}

@end

//--------------------------------------------------------------
// Internal conversion helper functions
//--------------------------------------------------------------
@interface KeyChainDataSource (PrivateMethods)

- (void) populateAttrMap;
- (int) countAttributesAtIndex:(long)index;
- (NSString*) getAttrValueAsString:(CFTypeRef)attribute value:(CFTypeRef)value;

@end

@implementation KeyChainDataSource (PrivateMethods)

- (void) populateAttrMap
{
    if(attrNames)
    {
        //[attrNames release];
        attrNames = nil;
    }
    
    attrNames = [[NSMutableDictionary alloc] init];
    
    //Set up the friendly names for each attribute that can be read from one 
    //of the three types of items this class cares about.
    [attrNames setObject:(id)@"Accessible" forKey:(id)kSecAttrAccessible];
    [attrNames setObject:(id)@"Access group" forKey:(id)kSecAttrAccessGroup];
    [attrNames setObject:(id)@"Certificate type" forKey:(id)kSecAttrCertificateType];
    [attrNames setObject:(id)@"Certificate encoding" forKey:(id)kSecAttrCertificateEncoding];
    [attrNames setObject:(id)@"Label" forKey:(id)kSecAttrLabel];
    
    //Re-enable these if linking in a certificate parser
    //[attrNames setObject:(id)@"Subject" forKey:(id)kSecAttrSubject];
    //[attrNames setObject:(id)@"Issuer" forKey:(id)kSecAttrIssuer];
    [attrNames setObject:(id)@"Serial number" forKey:(id)kSecAttrSerialNumber];
    [attrNames setObject:(id)@"Subject key ID" forKey:(id)kSecAttrSubjectKeyID];
    [attrNames setObject:(id)@"Public key hash" forKey:(id)kSecAttrPublicKeyHash];
    [attrNames setObject:(id)@"Key class" forKey:(id)kSecAttrKeyClass];
    [attrNames setObject:(id)@"Application label" forKey:(id)kSecAttrApplicationLabel];
    [attrNames setObject:(id)@"Is permanent" forKey:(id)kSecAttrIsPermanent];
    [attrNames setObject:(id)@"Application tag" forKey:(id)kSecAttrApplicationTag];
    [attrNames setObject:(id)@"Key type" forKey:(id)kSecAttrKeyType];
    [attrNames setObject:(id)@"Key size in bits" forKey:(id)kSecAttrKeySizeInBits];
    [attrNames setObject:(id)@"Effective key size" forKey:(id)kSecAttrEffectiveKeySize];
    [attrNames setObject:(id)@"Can encrypt" forKey:(id)kSecAttrCanEncrypt];
    [attrNames setObject:(id)@"Can decrypt" forKey:(id)kSecAttrCanDecrypt];
    [attrNames setObject:(id)@"Can derive" forKey:(id)kSecAttrCanDerive];
    [attrNames setObject:(id)@"Can sign" forKey:(id)kSecAttrCanSign];
    [attrNames setObject:(id)@"Can verify" forKey:(id)kSecAttrCanVerify];
    [attrNames setObject:(id)@"Can wrap" forKey:(id)kSecAttrCanWrap];
    [attrNames setObject:(id)@"Can unwrap" forKey:(id)kSecAttrCanUnwrap];
}

- (int) countAttributesAtIndex:(long)index
{
    int count = 0;
    
    CFTypeRef* attrs = NULL;
    
    switch (mode) {
        case KSM_Certificates:
            attrs = g_certAttrs;
            break;
        case KSM_Identities:
            attrs = g_identityAttrs;
            break;
        case KSM_Keys:
            attrs = g_keyAttrs;
            break;
        default:
            return 0;
    }
    
    @try 
    {
        CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:index];
        
        for(int ii = 0; attrs[ii]; ++ii)
        {
            if(true == CFDictionaryGetValueIfPresent(dict, attrs[ii], NULL)) 
                ++count;
        }
    } 
    @catch (NSException* rangeException) 
    {
        return 0;
    }
    
    return count;
}

- (NSString*) getAttrValueAsString:(CFTypeRef)attribute value:(CFTypeRef)value
 {
     NSString* attributeValueString = nil;
    
    if(kSecAttrAccessible == attribute)
    {
        attributeValueString = [KeyChainDataSource getAttrAccessibleAsString:(CFStringRef)value];
    }
    else if(kSecAttrAccessGroup == attribute)
    {
        attributeValueString = [[NSString alloc] initWithString:(__bridge NSString*)value] ;
    }
    else if(kSecAttrCertificateType == attribute)
    {
        attributeValueString = [KeyChainDataSource getCertificateTypeAsString:(CFNumberRef)value];
    }
    else if(kSecAttrCertificateEncoding == attribute)
    {
        attributeValueString = [KeyChainDataSource getCertificateEncodingAsString:(CFNumberRef)value];
    }
    else if(kSecAttrLabel == attribute)
    {
        attributeValueString = [[NSString alloc] initWithString:(__bridge NSString*)value] ;
    }
    else if(kSecAttrSubject == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsNameString:(__bridge NSData*)value];
    }
    else if(kSecAttrIssuer == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsNameString:(__bridge NSData*)value];
    }
    else if(kSecAttrSerialNumber == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsAsciiHexString:(__bridge NSData*)value];
    }
    else if(kSecAttrSubjectKeyID == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsAsciiHexString:(__bridge NSData*)value];
    }
    else if(kSecAttrPublicKeyHash == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsAsciiHexString:(__bridge NSData*)value];
    }
    else if(kSecAttrKeyClass == attribute)
    {
        attributeValueString = [KeyChainDataSource getKeyClassAsString:(CFNumberRef)value];
    }
    else if(kSecAttrApplicationLabel == attribute)
    {
        attributeValueString = [KeyChainDataSource getDataAsAsciiHexString:(__bridge NSData*)value];
    }
    else if(kSecAttrIsPermanent == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrApplicationTag == attribute)
    {
        if(CFGetTypeID(value) == CFDataGetTypeID())
        {
            NSData* d = (__bridge NSData*)value;
            attributeValueString = [NSString stringWithUTF8String:(char*)[d bytes]];
        }
        else
        {
            attributeValueString = [[NSString alloc] initWithString:(__bridge NSString*)value] ;
        }
    }
    else if(kSecAttrKeyType == attribute)
    {
        attributeValueString = [KeyChainDataSource getKeyTypeAsString:(CFNumberRef)value];
    }
    else if(kSecAttrKeySizeInBits == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFNumberAsString:(CFNumberRef)value];
    }
    else if(kSecAttrEffectiveKeySize == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFNumberAsString:(CFNumberRef)value];
    }
    else if(kSecAttrCanEncrypt == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanDecrypt == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanDerive == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanSign == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanVerify == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanWrap == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else if(kSecAttrCanUnwrap == attribute)
    {
        attributeValueString = [KeyChainDataSource getCFBooleanAsString:(CFBooleanRef)value];
    }
    else
    {
        attributeValueString = @"Unknown value";
    }
    
    return attributeValueString;
}

@end

//--------------------------------------------------------------
// KeyChainDataSource implementation
//--------------------------------------------------------------
@implementation KeyChainDataSource

//Public members
@synthesize displayEmptyAttributes;
@synthesize userQuery;

//Private members
@synthesize items;
@synthesize mode;
@synthesize initialized;
@synthesize attrNames;

- (int) numAttrGroups:(long)index
{
    return [self countAttributesAtIndex:index];
}

- (NSString*) getAttrStringForGroup:(CFTypeRef*)attrArray forItem:(long)index
{
    std::ostringstream oss;
    for(int ii = 0; attrArray[ii]; ++ii)
    {
        NSString* attrName = (NSString*)[attrNames objectForKey:(__bridge id)attrArray[ii]];
        if(attrName)
        {
            NSString* attrValue = [self getAttrValueAtSection:index attrType:attrArray[ii]];
            if(attrValue)
            {
                oss << [attrName UTF8String] << ": " << [attrValue UTF8String] << std::endl;
            }
        }
    }
    NSString* retVal = [[NSString alloc] initWithCString:oss.str().c_str() encoding:NSUTF8StringEncoding] ;
    return retVal;
}

- (NSString*) getAttrStringAtIndex:(long)index attrGroup:(long)attrGroup
{
    return [self getAttrValueAtSection:index attrIndex:attrGroup];        
}

/**
 LoadKeyChainContents prepares a dictionary containing a query filter based on the current mode.
 The results are stored in the items member variable with mode-specific contents.
 */
- (void) LoadKeyChainContents
{
    [self ClearContents];
    
    OSStatus resultCode = noErr;
    
    if(nil == userQuery)
    {
        NSMutableDictionary * query = [[NSMutableDictionary alloc] init];
        
        //Set up the invariant pieces of the query
        [query setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        
        //Set up the mode-specific pieces of the query
        switch(mode)
        {
            case KSM_Certificates:
            {
                [query setObject:(id)kSecClassCertificate forKey:(id)kSecClass];
                break;
            }
            case KSM_Identities:
            {
                [query setObject:(id)kSecClassIdentity forKey:(id)kSecClass];
                break;
            }
            case KSM_Keys:
            {
                [query setObject:(id)kSecClassKey forKey:(id)kSecClass];
                break;
            }
        }
        
        CFTypeRef result = nil;
        //Execute the query saving the results in items.
        resultCode = SecItemCopyMatching((CFDictionaryRef)query, &result);
        items = (__bridge_transfer NSMutableArray*)result;

        //[query release];
    }
    else
    {
        CFTypeRef result = nil;
        resultCode = SecItemCopyMatching((CFDictionaryRef)userQuery, &result);
        items = (__bridge_transfer NSMutableArray*)result;
    }
    
    if(resultCode != noErr)
    {
        //clean up anything that might have landed in items
        [self ClearContents];
    }
    else
    {
        //set the initialized flag
        initialized = true;
    }
    
    return;
}

//--------------------------------------------------------------
// KeyChainDataSource initialization/destruction
//--------------------------------------------------------------
- (id) init
{
    self = [super init];
    if(self)
    {
        mode = KSM_Identities;
        initialized = false;
        items = nil;
        displayEmptyAttributes = false;
        [self populateAttrMap];
    }
    return self;
}

- (id) initWithMode:(enum KeyChainDataSourceMode)kcdsMode
{
    self = [super init];
    if(self)
    {
        mode = kcdsMode;
        initialized = false;
        items = nil;
        displayEmptyAttributes = false;
        [self populateAttrMap];
    }
    return self;
}

- (void)dealloc
{
    //[items release];
    items = nil;

    //[attrNames release];
    attrNames = nil;
    
    //[userQuery release];
    userQuery = nil;
    
    [self ClearContents];
    //[super dealloc];
}

- (void) ClearContents
{
    //[items release];
    items = nil;

    initialized = false;
}

- (int) numItems
{
    //each item gets its own section
    if(nil == items)
        return 0;
    else
        return [items count];
} 

- (NSString*) GetEmailAddressAtIndex:(long)index
{
    //Implement after linking useful PKE support
    return nil;
}

- (NSString*) GetCommonNameAtIndex:(long)index
{
    SecCertificateRef certRef = [self getCertificateAt:index];
    if(certRef)
    {
        CFStringRef summaryRef = SecCertificateCopySubjectSummary(certRef);
        return (__bridge_transfer NSString*)summaryRef;
    }
    
    return nil;
}
- (NSString*) GetIdentityNameAtIndex:(long)index
{
    //look for email address first, failing that use the default keychain label
    NSString* emailAddress = [self GetEmailAddressAtIndex:index];
    if(!emailAddress)
    {
        NSString* subject = [self GetCommonNameAtIndex:index];
        if(!subject)
            return [self getAttrValueAtSection:index attrType:kSecAttrLabel];
        else
            return subject;
    }
    else
        return emailAddress;
}

- (SecIdentityRef) GetIdentityAtIndex:(long)index
{
    if(index >= [items count])
        return nil;
    CFDictionaryRef item = (__bridge CFDictionaryRef)[items objectAtIndex:index];
    
    SecIdentityRef identity = nil;
    CFTypeRef value;
    if(CFDictionaryGetValueIfPresent(item, kSecValueRef, &value))
    {
        identity = (SecIdentityRef)value;
    }

    return identity;
}

- (NSData*) GetPrivateKeyAtIndex:(long)index
{
    if(index >= [items count])
        return nil;
    CFDictionaryRef item = (__bridge CFDictionaryRef)[items objectAtIndex:index];
    
    NSData* privateKey = nil;
    CFTypeRef label;
    if(CFDictionaryGetValueIfPresent(item, kSecValueData, &label))
    {
        CFDataRef aCFString = (CFDataRef)label;
        privateKey = (__bridge NSData *)aCFString;
    }
    return privateKey;
}

- (void) removeObjectAtIndex:(long)index
{
    if(index >= [items count])
        return;
    
    CFDictionaryRef item = (__bridge CFDictionaryRef)[items objectAtIndex:index];
    
    CFTypeRef value;
    if(CFDictionaryGetValueIfPresent(item, kSecValueRef, &value))
    {
        SecIdentityRef identity = (SecIdentityRef)value;
        
        NSMutableDictionary * query = [[NSMutableDictionary alloc] init];
        
        //Set up the invariant pieces of the query
        [query setObject:(__bridge id)identity forKey:(id)kSecValueRef];
   
        //Execute the query saving the results in items.
        OSStatus resultCode = SecItemDelete((CFDictionaryRef) query);
        query = nil;

        if(errSecSuccess == resultCode)
        {
            [self LoadKeyChainContents];
        }
        else
        {
            NSLog(@"Failed to delete selected identity with error code %d.", (int)resultCode);
           
        }
    }
}

- (NSString*) getAttrNameAtSection:(long)sectionIndex attrIndex:(long)attrIndex
{
    CFTypeRef attribute, value;
    NSString* attrFriendlyName = nil;
    
    @try 
    {
        CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:sectionIndex];
        CFTypeRef* attrs = NULL;
        
        switch (mode) {
            case KSM_Certificates:
                attrs = g_certAttrs;
                break;
            case KSM_Identities:
                attrs = g_identityAttrs;
                break;
            case KSM_Keys:
                attrs = g_keyAttrs;
                break;
            default:
                return 0;
        }
        
        for(int ii = 0, jj = 0; attrs[ii]; ++ii)
        {
            if(CFDictionaryGetValueIfPresent(dict, attrs[ii], &value))
            {
                if(jj == attrIndex)
                {
                    attribute = attrs[ii];
                    break;
                }
                else
                    ++jj;
            }
        }
    } 
    @catch (NSException* rangeException) 
    {
        return 0;
    }
    
    //get the friendly name of the attribute
    attrFriendlyName = (NSString*)[attrNames objectForKey:(__bridge id)attribute];
    if(nil == attrFriendlyName)
        attrFriendlyName = NSLocalizedString(@"Unrecognized attribute",nil);
    
    return attrFriendlyName;
}

/**
 This function returns the attrIndex-th present value from the sectionIndex-th item
 */
- (NSString*) getAttrValueAtSection:(long)sectionIndex attrIndex:(long)attrIndex
{
    CFTypeRef attribute, value;
    
    @try 
    {
        CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:sectionIndex];
        CFTypeRef* attrs = NULL;
        
        switch (mode) {
            case KSM_Certificates:
                attrs = g_certAttrs;
                break;
            case KSM_Identities:
                attrs = g_identityAttrs;
                break;
            case KSM_Keys:
                attrs = g_keyAttrs;
                break;
            default:
                return 0;
        }
        
        for(int ii = 0, jj = 0; attrs[ii]; ++ii)
        {
            if(CFDictionaryGetValueIfPresent(dict, attrs[ii], &value))
            {
                if(jj == attrIndex)
                {
                    attribute = attrs[ii];
                    break;
                }
                else
                    ++jj;
            }
        }
    } 
    @catch (NSException* rangeException) 
    {
        return nil;
    }
    
    return [self getAttrValueAsString:attribute value:value];
}

- (NSString*) getAttrValueAtSection:(long)sectionIndex attrType:(CFTypeRef)attrType
{
    CFTypeRef value;
    
    @try 
    {
        CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:sectionIndex];
        if(!CFDictionaryGetValueIfPresent(dict, attrType, &value))
        {
            return nil;
        }
    } 
    @catch (NSException* rangeException) 
    {
        return nil;
    }
    
    return [self getAttrValueAsString:attrType value:value];
}

- (SecCertificateRef) getCertificateAt:(long)index
{
    if(index >= [items count])
       return nil;
    
    switch (mode) {
        case KSM_Certificates:
        {
            CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:index];
            SecCertificateRef cert = (SecCertificateRef)CFDictionaryGetValue(dict, kSecValueRef);
            return cert;
        }
        case KSM_Identities:
        {
            CFDictionaryRef dict = (__bridge CFDictionaryRef)[items objectAtIndex:index];
            SecIdentityRef identity = (SecIdentityRef)CFDictionaryGetValue(dict, kSecValueRef);
            SecCertificateRef cert = nil;
            OSStatus stat = SecIdentityCopyCertificate(identity, &cert);
            if(errSecSuccess == stat)
                return cert;
            else
                return nil;
        }
        case KSM_Keys:
        {
            return nil;
        }
        default:
        {
            return nil;
        }
    }
}

- (NSData*) GetPKCS12AtIndex:(long)index
{
    //Implement after linking useful PKE support
    return nil;
}

@end
