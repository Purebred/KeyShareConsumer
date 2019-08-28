# Purebred's Key Sharing interface

The Purebred Registration app is used to provision derived credentials and recovered encryption credentials to iOS, Android, selected Windows 10 and Yubikey devices. On all except iOS, keys are provisioned such that third party and system applications can use the keys via system-provided APIs. On iOS, keys are provisioned such that keys can be exported from the Purebred app into system or third party applications.  

The Purebred Registration app has included support for sharing derived credentials with other apps since iOS 8. Credentials are shared using the document provider framework defined by Apple. Apps importing keys do not require any Purebred-specific API but use the [UIDocumentPickerViewController](https://developer.apple.com/documentation/uikit/uidocumentpickerextensionviewcontroller?language=objc) in concert with either Apple's standard com.rsa.pkcs-12 uniform type identifier (UTI) or UTIs defined by the Purebred app to obtain a PKCS 12 or set of PKCS 12 files. Passwords for the PKCS 12 file(s) are shared via the system pasteboard in parallel with the sharing of the PKCS 12 file(s). Purebred-defined UTIs allow for display of specific types of credentials, i.e., signature, authentication, encryption. This is different from display of different types of files, i.e., PDF, JPEG, etc. Additionally, the Purebred-defined UTIs can be paired with a UTI indicating not to filter based on issuance date.

# Key Sharing and iOS13

Since iOS13/iPadOS 13 beta 1, the key sharing capability of the Purebred Registration app has been in a state of flux, working in some cases and not working in other cases. Several feedback submissions have been provided, forum discussions posted and etc. following beta 1 and over the course of the subsequent beta releases. The simplest summary is available in the forum post to the iOS13 beta forum titled [NSExtensionFileProviderSupportsEnumeration set to NO not respected on first run](https://forums.developer.apple.com/thread/120997). As noted in the forum post, the mechanisms used to share keys no longer works as expected, but can be made to work via an unsustainable series of install/uninstall/reinstall steps with the value of the NSExtensionFileProviderSupportsEnumeration value in the file provider's Info.plist altered. After executing the steps noted in the forum post, the existing mechanisms continue to work as before.

The NSExtensionFileProviderSupportsEnumeration setting referenced in the forum post was introduced in iOS 11 as part of changes to the document provider mechanisms. The changes facilitate the use of the Files app that was introduced in iOS 11. As part of these changes, a standard user interface provided by the system for all file provider interactions, vs. user interfaces provided specific to each file provider type. Purebred did not adopt these APIs in part due to the nature of the files being shared, which do not lend themselves to use of the Files app nor standard user actions like delete, rename or move. 

# Purebred Registration v1.5 (112) beta

A beta release of the Purebred Registration app is being made available for testing by mobility offices and vendors due to the relatively significant changes required to mitigate the iOS13 issue noted above. This release adds support for NSExtensionFileProviderSupportsEnumeration and use of the standard system-provided user interface for browsing file providers. The intent is for this release to require no changes to vendor code, i.e., existing invocation of UIDocumentPickerViewController should continue to work as before. However, changes to the user experience are unavoidable and some changes to vendors applications may be warranted to avoid some deprecated interfaces, however.

The user experience changes are due to how the user interface interrogates the file provider and how the UI handles files that do not correspond to UTIs requested by the consuming application. In previous releases, the Purebred Registration app provided the user interface and received a list of UTIs desired by the consuming application. This enabled the app to display only credentials of the types desired by the consuming application. In the new implementation, the Purebred Registration app only provides the file provider, not the user interface. File providers do not receive a list of UTIs from the consuming application and cannot filter the list of files returned. The standard user interface shows all files listed by a file provider in all cases, with files that do not match a requested UTI grayed out. 

To avoid a single long list of mostly grayed out files, this release features a folder-based display for key sharing. The folders correspond to the Purebred-defined UTIs. The folder names and corresponding UTIs are as follows:

- All Credentials				[purebred.select.all]
- All Credentials (PKCS-12)		[com.rsa.pkcs-12]
- All Credentials (unfiltered)	[purebred.select.all with
purebred.select.no_filter]
- All User Credentials			[purebred.select.all_user]
- Authentication Credentials	[purebred.select.authentication]
- Device Credentials			[purebred.select.device]
- Digital Signature Credentials	[purebred.select.signature]
- Encryption Credentials		[purebred.select.encryption]

Each folder's contents is a list of certificate files associated with the indicated UTI along with a zip file associated with the corresponding purebred.zip UTI. As noted, most files will appear as grayed out under typical use. User documentation describing steps required to import keys into various products should be updated to reflect this. The Key Share Consumer sample app can be used to experiment with various UTI combinations. 

This approach was elected to retain as much flexibility as possible relative to the previous set of UTIs. Lost in this release is the pairing of the no_filter UTIs with UTIs other than purebred.select.all/purebred.zip.all, which was retained due to current prevalence of use. Flexibility is retained owing to limited time for vendors to test prior to the general release of iOS13 and iPadOS13. Future versions of the Purebred Registration app may reduce the set of UTIs provided, add support for use of tags, etc.  


