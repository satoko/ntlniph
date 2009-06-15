#import <UIKit/UIKit.h>
#import "NTLNTwitterUserClient.h"
#import "NTLNTwitterFriendshipsClient.h"
#import "NTLNMessage.h"

@interface NTLNUserViewController : UITableViewController 
	<UITableViewDelegate, UITableViewDataSource, NTLNTwitterUserClientDelegate, NTLNTwitterFriendshipsClientDelegate> {
	NTLNMessage *message;
	NTLNUser *userInfo;
	UIButton *followButton;
	UIActivityIndicatorView *followAI;
}

@property(readwrite, retain) NTLNMessage *message;

@end
