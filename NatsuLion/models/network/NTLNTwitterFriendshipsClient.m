#import "NTLNTwitterFriendshipsClient.h"
#import "NTLNTwitterUserXMLReader.h"
#import "NTLNAccount.h"
#import "NTLNHttpClientPool.h"

@implementation NTLNTwitterFriendshipsClient

@synthesize delegate;
@synthesize users;

- (void)dealloc {
	[delegate release];
	[users release];
	[super dealloc];
}

- (void)createFriendshipsWithUserId:(NSString*)userId {
	NSString* url = [NSString stringWithFormat:@"http://twitter.com/friendships/create/%@.xml", userId];
	[super requestPOST:url body:nil];
}

- (void)destroyFriendshipsWithUserId:(NSString*)userId {
	NSString* url = [NSString stringWithFormat:@"http://twitter.com/friendships/destroy/%@.xml", userId];
	[super requestPOST:url body:nil];
}


- (void)getFriendshipsWithScreenName:(NSString*)testScreenName {
	NSString *username = [[NTLNAccount sharedInstance] screenName];
	NSString *url = [NSString stringWithFormat:@"http://twitter.com/friendships/exists.xml?user_a=%@&user_b=%@", 
							username, 
							testScreenName];
	[super requestGET:url];
}

- (void)requestSucceeded {
	if (statusCode == 200) {
		if (contentTypeIsXml) {
			NTLNTwitterUserXMLReader *xr = [[NTLNTwitterUserXMLReader alloc] init];
			[xr parseXMLData:recievedData];
			users = [xr.users retain];
			[xr release];
		}
	}	
	
	[delegate twitterFriendshipsClientSucceeded:self];
	[[NTLNHttpClientPool sharedInstance] releaseClient:self];
}

- (void)requestFailed:(NSError*)error {
	[delegate twitterFriendshipsClientFailed:self];
	[[NTLNHttpClientPool sharedInstance] releaseClient:self];
}

@end
