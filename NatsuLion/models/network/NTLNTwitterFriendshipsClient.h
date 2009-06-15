#import <UIKit/UIKit.h>
//#import "NTLNUser.h"
#import "NTLNHttpClient.h"
#import "NTLNOAuthHttpClient.h"

@class NTLNTwitterFriendshipsClient;

@protocol NTLNTwitterFriendshipsClientDelegate
- (void)twitterFriendshipsClientSucceeded:(NTLNTwitterFriendshipsClient*)sender;
- (void)twitterFriendshipsClientFailed:(NTLNTwitterFriendshipsClient*)sender;
@end

#ifdef ENABLE_OAUTH
@interface NTLNTwitterFriendshipsClient : NTLNOAuthHttpClient {
#else
@interface NTLNTwitterFriendshipsClient : NTLNHttpClient {
#endif
@private
	NSObject<NTLNTwitterFriendshipsClientDelegate> *delegate;
	NSMutableArray *users;
}

@property (readwrite, retain) NSObject<NTLNTwitterFriendshipsClientDelegate> *delegate;

- (void)destroyFriendshipsWithUserId:(NSString*)userId;
- (void)createFriendshipsWithUserId:(NSString*)userId;
- (void)getFriendshipsWithScreenName:(NSString*)testScreenName;

@property (readonly) NSMutableArray *users;

@end
