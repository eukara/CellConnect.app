/* All rights reserved */

#include <AppKit/AppKit.h>

@interface MainController : NSWindowController
{
	id tableView;
	NSArray *deviceList;
	NSMutableArray *records;
}
- (void) findPhone: (id)sender;
- (void) refreshList: (id)sender;
- (void) pingPhone: (id)sender;
- (void) pairPhone: (id)sender;
- (void) unpairPhone: (id)sender;
- (void) sendFile: (id)sender;
@end
