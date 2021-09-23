/* All rights reserved */

#include <AppKit/AppKit.h>
#include "MainController.h"

@implementation MainController


- (id) init
{
	NSImage *icon = [[NSImage imageNamed:@"CellConnect.tiff"] retain];
	[NSApp setApplicationIconImage: icon];
   self = [super init];
   records = [NSMutableArray new];
   return self;
}

- (void) dealloc
{
   RELEASE(records);
   [super dealloc];
}


- (int) numberOfRowsInTableView: (NSTableView *) view
{
   return [records count];
}

- (id) tableView: (NSTableView *) view
       objectValueForTableColumn: (NSTableColumn *) column 
       row: (int) row
{
   if (row >= [records count])
      {
         return @""; 
      }
   else
      {
         return [records objectAtIndex: row];
      }
}

- (void) refreshAll
{
	int i;
	[tableView sizeLastColumnToFit];
	[tableView setAutoresizesAllColumnsToFit: YES];
	[records removeAllObjects];
	[tableView reloadData];

	// get out list of items
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *file = pipe.fileHandleForReading;
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/kdeconnect-cli";
	[task setArguments: [NSArray arrayWithObjects: @"-l", @"--name-only", nil]];
	task.standardOutput = pipe;
	[task launch];
	NSData *data = [file readDataToEndOfFile];
	[file closeFile];
	NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	/* dump it */
	deviceList = [grepOutput componentsSeparatedByString:@"\n"];

	for (i = 0; i < ([deviceList count] - 1); i++) {
		NSArray *cunk = [[deviceList objectAtIndex: i] componentsSeparatedByString: @":"];
		[records addObject: [cunk objectAtIndex: 0]];
	}

	[tableView reloadData];
}

 -(void)windowDidLoad
{
	[self refreshAll];
}

- (void) refreshList: (id)sender
{
	[self refreshAll];
}

- (void) pingPhone: (id)sender
{
	/* get selected phone */
	NSInteger row = [tableView selectedRow];
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"phoneName"];
	NSCell *cell = [column dataCellForRow:row];
	NSString *name = [cell stringValue];

	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/kdeconnect-cli";
	[task setArguments: [NSArray arrayWithObjects: @"-n", name,  @"--ping", nil]];

	[task launch];
}

- (void) findPhone: (id)sender
{
	/* get selected phone */
	NSInteger row = [tableView selectedRow];
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"phoneName"];
	NSCell *cell = [column dataCellForRow:row];
	NSString *name = [cell stringValue];

	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/kdeconnect-cli";
	[task setArguments: [NSArray arrayWithObjects: @"-n", name,  @"--ring", nil]];

	[task launch];
}

- (void) pairPhone: (id)sender
{
	/* get selected phone */
	NSInteger row = [tableView selectedRow];
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"phoneName"];
	NSCell *cell = [column dataCellForRow:row];
	NSString *name = [cell stringValue];

	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/kdeconnect-cli";
	[task setArguments: [NSArray arrayWithObjects: @"--pair", @"-n", name, nil]];

	[task launch];
}

- (void) unpairPhone: (id)sender
{
	/* get selected phone */
	NSInteger row = [tableView selectedRow];
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"phoneName"];
	NSCell *cell = [column dataCellForRow:row];
	NSString *name = [cell stringValue];

	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/kdeconnect-cli";
	[task setArguments: [NSArray arrayWithObjects: @"-n", name,  @"--unpair", nil]];

	[task launch];
}


- (void) sendFile: (id)sender
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];

	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];

	/* get selected phone */
	NSInteger row = [tableView selectedRow];
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"phoneName"];
	NSCell *cell = [column dataCellForRow:row];
	NSString *name = [cell stringValue];

	if ([openDlg runModalForDirectory: nil file: nil] == NSOKButton)
	{
		NSArray* files = [openDlg filenames];
		NSString* fileName = [files objectAtIndex: 0];

		NSTask *task = [[NSTask alloc] init];
		task.launchPath = @"/usr/bin/kdeconnect-cli";
		[task setArguments: [NSArray arrayWithObjects: @"-n", name, @"--share", fileName,  nil]];

		[task launch];
	}
}

@end
