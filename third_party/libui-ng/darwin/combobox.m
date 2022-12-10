// 14 august 2015
#import "uipriv_darwin.h"

// NSComboBoxes have no intrinsic width; we'll use the default Interface Builder width for them.
// NSPopUpButton is fine.
#define comboboxWidth 96

struct uiCombobox {
	uiDarwinControl c;
	NSPopUpButton *pb;
	NSArrayController *pbac;
	void (*onSelected)(uiCombobox *, void *);
	void *onSelectedData;
};

@interface comboboxDelegateClass : NSObject {
	uiprivMap *comboboxes;
}
- (IBAction)onSelected:(id)sender;
- (void)registerCombobox:(uiCombobox *)c;
- (void)unregisterCombobox:(uiCombobox *)c;
@end

@implementation comboboxDelegateClass

- (id)init
{
	self = [super init];
	if (self)
		self->comboboxes = uiprivNewMap();
	return self;
}

- (void)dealloc
{
	uiprivMapDestroy(self->comboboxes);
	[super dealloc];
}

- (IBAction)onSelected:(id)sender
{
	uiCombobox *c;

	c = uiCombobox(uiprivMapGet(self->comboboxes, sender));
	(*(c->onSelected))(c, c->onSelectedData);
}

- (void)registerCombobox:(uiCombobox *)c
{
	uiprivMapSet(self->comboboxes, c->pb, c);
	[c->pb setTarget:self];
	[c->pb setAction:@selector(onSelected:)];
}

- (void)unregisterCombobox:(uiCombobox *)c
{
	[c->pb setTarget:nil];
	uiprivMapDelete(self->comboboxes, c->pb);
}

@end

static comboboxDelegateClass *comboboxDelegate = nil;

uiDarwinControlAllDefaultsExceptDestroy(uiCombobox, pb)

static void uiComboboxDestroy(uiControl *cc)
{
	uiCombobox *c = uiCombobox(cc);

	[comboboxDelegate unregisterCombobox:c];
	[c->pb unbind:@"contentObjects"];
	[c->pb unbind:@"selectedIndex"];
	[c->pbac release];
	[c->pb release];
	uiFreeControl(uiControl(c));
}

void uiComboboxAppend(uiCombobox *c, const char *text)
{
	[c->pbac addObject:uiprivToNSString(text)];
	uiControlEnable(uiControl(c));
}

void uiComboboxInsertAt(uiCombobox *c, int n, const char *text)
{
	int selected = uiComboboxSelected(c);

	[c->pbac insertObject:uiprivToNSString(text) atArrangedObjectIndex:n];
	uiControlEnable(uiControl(c));

	if (n <= selected)
		uiComboboxSetSelected(c, selected+1);
	else
		uiComboboxSetSelected(c, selected);
}

void uiComboboxDelete(uiCombobox *c, int n)
{
	int selected = uiComboboxSelected(c);

	[c->pbac removeObjectAtArrangedObjectIndex:n];

	if (n < selected)
		uiComboboxSetSelected(c, selected-1);
	if (uiComboboxNumItems(c) == 0) {
		uiControlDisable(uiControl(c));
		uiComboboxSetSelected(c, -1);
	}
}

void uiComboboxClear(uiCombobox *c)
{
	[c->pbac removeObjectsAtArrangedObjectIndexes:[[c->pbac arrangedObjects]
		indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			// remove all items
			return TRUE;
	}]];
	uiComboboxSetSelected(c, -1);
	uiControlDisable(uiControl(c));
}

int uiComboboxNumItems(uiCombobox *c)
{
	return [[c->pbac arrangedObjects] count];
}

int uiComboboxSelected(uiCombobox *c)
{
	return [c->pb indexOfSelectedItem];
}

void uiComboboxSetSelected(uiCombobox *c, int n)
{
	[c->pb selectItemAtIndex:n];
}

void uiComboboxOnSelected(uiCombobox *c, void (*f)(uiCombobox *c, void *data), void *data)
{
	c->onSelected = f;
	c->onSelectedData = data;
}

static void defaultOnSelected(uiCombobox *c, void *data)
{
	// do nothing
}

uiCombobox *uiNewCombobox(void)
{
	uiCombobox *c;
	NSPopUpButtonCell *pbcell;

	uiDarwinNewControl(uiCombobox, c);

	c->pb = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	[c->pb setPreferredEdge:NSMinYEdge];
	pbcell = (NSPopUpButtonCell *) [c->pb cell];
	[pbcell setArrowPosition:NSPopUpArrowAtBottom];
	// the font defined by Interface Builder is Menu 13, which is lol
	// just use the regular control size for consistency
	uiDarwinSetControlFont(c->pb, NSRegularControlSize);

	// NSPopUpButton doesn't work like a combobox
	// - it automatically selects the first item
	// - it doesn't support duplicates
	// but we can use a NSArrayController and Cocoa bindings to bypass these restrictions
	c->pbac = [NSArrayController new];
	[c->pbac setAvoidsEmptySelection:NO];
	[c->pbac setSelectsInsertedObjects:NO];
	[c->pbac setAutomaticallyRearrangesObjects:NO];
	[c->pb bind:@"contentValues"
		toObject:c->pbac
		withKeyPath:@"arrangedObjects"
		options:nil];
	[c->pb bind:@"selectedIndex"
		toObject:c->pbac
		withKeyPath:@"selectionIndex"
		options:nil];

	if (comboboxDelegate == nil) {
		comboboxDelegate = [[comboboxDelegateClass new] autorelease];
		[uiprivDelegates addObject:[NSValue valueWithPointer:&comboboxDelegate]];
	}
	[comboboxDelegate registerCombobox:c];
	uiComboboxOnSelected(c, defaultOnSelected, NULL);
	uiComboboxSetSelected(c, -1);
	uiControlDisable(uiControl(c));

	return c;
}
