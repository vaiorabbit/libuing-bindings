// 14 august 2015
#import "uipriv_darwin.h"

// Horizontal sliders have no intrinsic width; we'll use the default Interface Builder width for them.
// This will also be used for the initial frame size, to ensure the slider is always horizontal (see below).
#define sliderWidth 92

@interface libui_intrinsicWidthNSSlider : NSSlider
@end

@implementation libui_intrinsicWidthNSSlider

- (NSSize)intrinsicContentSize
{
	NSSize s;

	s = [super intrinsicContentSize];
	s.width = sliderWidth;
	return s;
}

@end

struct uiSlider {
	uiDarwinControl c;
	NSSlider *slider;
	void (*onChanged)(uiSlider *, void *);
	void *onChangedData;
	void (*onReleased)(uiSlider *, void *);
	void *onReleasedData;
	BOOL hasToolTip;
};

static void _uiSliderUpdateToolTip(uiSlider *s);

@interface sliderDelegateClass : NSObject {
	uiprivMap *sliders;
}
- (IBAction)onChanged:(id)sender;
- (void)registerSlider:(uiSlider *)b;
- (void)unregisterSlider:(uiSlider *)b;
@end

@implementation sliderDelegateClass

- (id)init
{
	self = [super init];
	if (self)
		self->sliders = uiprivNewMap();
	return self;
}

- (void)dealloc
{
	uiprivMapDestroy(self->sliders);
	[super dealloc];
}

- (IBAction)onChanged:(id)sender
{
	uiSlider *s;
	s = (uiSlider *) uiprivMapGet(self->sliders, sender);

	NSEvent *currentEvent = [[sender window] currentEvent];
	if([currentEvent type] == NSLeftMouseUp) {
		(*(s->onReleased))(s, s->onReleasedData);
	} else {
		(*(s->onChanged))(s, s->onChangedData);
	}

	if (s->hasToolTip)
		_uiSliderUpdateToolTip(s);
}

- (void)registerSlider:(uiSlider *)s
{
	uiprivMapSet(self->sliders, s->slider, s);
	[s->slider setTarget:self];
	[s->slider setAction:@selector(onChanged:)];
}

- (void)unregisterSlider:(uiSlider *)s
{
	[s->slider setTarget:nil];
	uiprivMapDelete(self->sliders, s->slider);
}

@end

static sliderDelegateClass *sliderDelegate = nil;

uiDarwinControlAllDefaultsExceptDestroy(uiSlider, slider)

static void uiSliderDestroy(uiControl *c)
{
	uiSlider *s = uiSlider(c);

	[sliderDelegate unregisterSlider:s];
	[s->slider release];
	uiFreeControl(uiControl(s));
}

static void _uiSliderUpdateToolTip(uiSlider *s)
{
	[s->slider setToolTip:[NSString stringWithFormat:@"%ld", [s->slider integerValue]]];
}

int uiSliderHasToolTip(uiSlider *s)
{
	return s->hasToolTip;
}

void uiSliderSetHasToolTip(uiSlider *s, int hasToolTip)
{
	s->hasToolTip = hasToolTip;

	if (hasToolTip)
		_uiSliderUpdateToolTip(s);
	else
		[s->slider setToolTip:nil];
}

int uiSliderValue(uiSlider *s)
{
	return [s->slider integerValue];
}

void uiSliderSetValue(uiSlider *s, int value)
{
	[s->slider setIntegerValue:value];
}

void uiSliderOnChanged(uiSlider *s, void (*f)(uiSlider *, void *), void *data)
{
	s->onChanged = f;
	s->onChangedData = data;
}

static void defaultOnChanged(uiSlider *s, void *data)
{
	// do nothing
}

void uiSliderOnReleased(uiSlider *s, void (*f)(uiSlider *, void *), void *data)
{
	s->onReleased = f;
	s->onReleasedData = data;
}

static void defaultOnReleased(uiSlider *s, void *data)
{
	// do nothing
}

void uiSliderSetRange(uiSlider *s, int min, int max)
{
	int temp;

	if (min >= max) {
		temp = min;
		min = max;
		max = temp;
	}

	[s->slider setMinValue:min];
	[s->slider setMaxValue:max];
}

uiSlider *uiNewSlider(int min, int max)
{
	uiSlider *s;
	NSSliderCell *cell;
	int temp;

	if (min >= max) {
		temp = min;
		min = max;
		max = temp;
	}

	uiDarwinNewControl(uiSlider, s);

	// a horizontal slider is defined as one where the width > height, not by a flag
	// to be safe, don't use NSZeroRect, but make it horizontal from the get-go
	s->slider = [[libui_intrinsicWidthNSSlider alloc]
		initWithFrame:NSMakeRect(0, 0, sliderWidth, 2)];
	[s->slider setMinValue:min];
	[s->slider setMaxValue:max];
	[s->slider setAllowsTickMarkValuesOnly:NO];
	[s->slider setNumberOfTickMarks:0];
	[s->slider setTickMarkPosition:NSTickMarkAbove];

	cell = (NSSliderCell *) [s->slider cell];
	[cell setSliderType:NSLinearSlider];

	if (sliderDelegate == nil) {
		sliderDelegate = [[sliderDelegateClass new] autorelease];
		[uiprivDelegates addObject:[NSValue valueWithPointer:&sliderDelegate]];
	}
	[sliderDelegate registerSlider:s];
	uiSliderOnChanged(s, defaultOnChanged, NULL);
	uiSliderOnReleased(s, defaultOnReleased, NULL);

	uiSliderSetHasToolTip(s, 1);

	return s;
}
