#import "InvertedMaskLabel.h"

@interface _UIBatteryView : UIView
@property (nonatomic, assign) UIView *bodyView;
@property (nonatomic, assign) UIView *fillView;
@property (nonatomic, assign) UIView *overlayView;
@property (nonatomic, assign) InvertedMaskLabel *firstLabel;
@property (nonatomic, assign) UILabel *secondLabel;
@property (nonatomic, assign) CGFloat firstViewWidth;
@property (nonatomic, assign) CGFloat secondViewWidth;
@property CGFloat chargePercent;
@property (nonatomic, copy, readwrite) UIColor *fillColor;
@property (nonatomic,copy) UIColor * pinColor;
@property (nonatomic,retain) CALayer * fillLayer;
@property(nonatomic, assign, readwrite) NSInteger chargingState;
@property(nonatomic, assign, readwrite) BOOL saverModeActive;
-(void)_updateFillLayer;
-(void)setFillColor:(UIColor *)arg1;
-(void)setBodyColor:(UIColor *)arg1;
-(void)setPinColor:(UIColor *)arg1;
-(void)setBodyLayer:(CAShapeLayer *)arg1;
-(void)setFillLayer:(CALayer *)arg1;
-(void)setBoltLayer:(CAShapeLayer *)arg1;
-(void)setBoltMaskLayer:(CAShapeLayer *)arg1;
-(void)setShowsInlineChargingIndicator:(BOOL)arg1;
-(id)initWithFrame:(CGRect)arg1;
-(void)setChargePercent:(double)arg1;
-(void)_updatePercentage;
-(void)layoutSubviews;
-(void)updateBatteryViewPercent;
-(void)updateBatteryViewWithColor:(UIColor *)color;
-(void)updateSomeColor;
-(NSString *)getLocaleBasedString:(NSString *)string ;
-(UIColor *)halfColor;
-(UIColor *)pinColor;
@end


%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
    	if([text containsString:@"%"]) 
     		return;
  	else 
   	    %orig(text);
}      
%end

%hook _UIBatteryView
%property (nonatomic, assign) UIView *bodyView;
%property (nonatomic, assign) UIView *fillView;
%property (nonatomic, assign) UIView *overlayView;
%property (nonatomic, assign) InvertedMaskLabel *firstLabel;
%property (nonatomic, assign) UILabel *secondLabel;
%property (nonatomic, assign) CGFloat firstViewWidth;
%property (nonatomic, assign) CGFloat secondViewWidth;

-(id)initWithFrame:(CGRect)arg1 {
	self = %orig;
	if (self) {
		self.firstViewWidth = 20*self.chargePercent;
		self.secondViewWidth = 20-self.firstViewWidth;
		
		self.bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 11.3)];
		self.bodyView.clipsToBounds = YES;
		self.bodyView.layer.cornerRadius = 3;
		self.bodyView.layer.borderWidth = 1;
		[self addSubview:self.bodyView];

		CGRect frame = self.bodyView.frame;
		frame.origin.x = self.frame.size.width - 24.333;
		frame.origin.y = (self.frame.size.height-11)/2;
		self.bodyView.frame = frame;
		
		self.fillView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, self.firstViewWidth, 11.3)];
		[self.bodyView addSubview:self.fillView];
		
		self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(self.firstViewWidth+1, 0, self.secondViewWidth, 11.3)];
		[self.bodyView addSubview:self.overlayView];

		self.firstLabel = [[InvertedMaskLabel alloc] initWithFrame:CGRectMake(0, 0, 20, 11.3)];
		self.firstLabel.text = [self getLocaleBasedString:[NSString stringWithFormat: @"%.f", self.chargePercent*100]];
		self.firstLabel.font = [UIFont systemFontOfSize:8 weight:UIFontWeightSemibold];
		self.firstLabel.textAlignment = NSTextAlignmentCenter;
		self.firstLabel.textColor = [UIColor whiteColor];
		self.fillView.maskView = self.firstLabel;
		
		self.secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(-self.firstViewWidth, 0, 20, 11.3)];
		self.secondLabel.text = self.firstLabel.text;
		self.secondLabel.font = [UIFont systemFontOfSize:8 weight:UIFontWeightSemibold];
		self.secondLabel.textAlignment = NSTextAlignmentCenter;
		self.secondLabel.textColor = [UIColor whiteColor];
		self.overlayView.maskView = self.secondLabel;
	}
	return self;
}

%new
-(void)updateBatteryViewPercent {
    self.firstViewWidth = 20*self.chargePercent;
    self.secondViewWidth = 20-self.firstViewWidth;
    
    CGRect fillViewFrame = self.fillView.frame;
    fillViewFrame.size.width = self.firstViewWidth;
    self.fillView.frame = fillViewFrame;
    
    CGRect overlayViewFrame = self.overlayView.frame;
    overlayViewFrame.origin.x = self.firstViewWidth+1;
    overlayViewFrame.size.width = self.secondViewWidth;
    self.overlayView.frame = overlayViewFrame;
    
    CGRect secondLabelFrame = self.secondLabel.frame;
    secondLabelFrame.origin.x = -self.firstViewWidth;
    self.secondLabel.frame = secondLabelFrame;
	
    self.firstLabel.text = [self getLocaleBasedString:[NSString stringWithFormat: @"%.f", self.chargePercent*100]];
    self.secondLabel.text = self.firstLabel.text;
}

%new
-(void)updateBatteryViewWithColor:(UIColor *)color {
	self.pinColor = color;
	self.fillView.backgroundColor = color;
	self.overlayView.backgroundColor = color;
	self.bodyView.layer.borderColor = [color CGColor];
}

%new
-(void)updateSomeColor {
	if (self.chargingState != 0) {
		[self updateBatteryViewWithColor:[UIColor colorWithRed:118.0f/255.0f green:213.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
	} else if (self.saverModeActive) {
		[self updateBatteryViewWithColor:[UIColor colorWithRed:247.0f/255.0f green:205.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
	} else if (self.chargePercent <= 0.2) {
		[self updateBatteryViewWithColor:[UIColor colorWithRed:235.0f/255.0f green:85.0f/255.0f blue:69.0f/255.0f alpha:1.0f]];
	} else {
		[self updateBatteryViewWithColor:self.fillColor];
	}
}

%new
-(NSString *)getLocaleBasedString:(NSString *)string {
	NSString *percentage;
	NSDecimalNumber *percentageInNumber = [NSDecimalNumber decimalNumberWithString:string];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
	percentage = [formatter stringFromNumber:percentageInNumber];

	if (![percentage isEqualToString:string]) {
		self.firstLabel.transform = CGAffineTransformMakeScale(-1, 1);
		self.secondLabel.transform = CGAffineTransformMakeScale(-1, 1);
	}


	return percentage;
}

-(void)setChargingState:(long long)arg1 {
	%orig(arg1);
	[self updateSomeColor];
}

- (void)setSaverModeActive:(BOOL)arg1 {
	%orig;
	[self updateSomeColor];
}

-(void)_updateFillLayer {
	%orig;
	[self updateSomeColor];
}

-(void)setChargePercent:(CGFloat)percent {
	%orig;
	[self updateBatteryViewPercent];
}

-(UIColor *)_batteryColor {
	return [UIColor clearColor];
}

-(UIColor *)bodyColor {
	return [UIColor clearColor];
}

-(void)setFillLayer:(CALayer *)arg1 {
	//noob
}

-(UIColor *)pinColor {
	return [%orig colorWithAlphaComponent:1.0];
}

-(void)setPinColor:(UIColor *)color {
	%orig([color colorWithAlphaComponent:1.0]);
}

-(void)setBoltLayer:(CAShapeLayer *)arg1 {
    arg1.hidden = YES;
	%orig(arg1);
}

-(void)setBoltMaskLayer:(CAShapeLayer *)arg1 {
	arg1.hidden = YES;
	%orig(arg1);
}

- (void)setShowsInlineChargingIndicator:(BOOL)arg1 {
	%orig(NO);
}

-(void)layoutSubviews {
	%orig;
	CGRect frame = self.bodyView.frame;
	frame.origin.x = self.frame.size.width - 24.333;
	if (self.frame.size.width == 24) frame.origin.x = 0;
	if (self.frame.size.width == 26.5) frame.origin.x = self.frame.size.width - 24.5;
	frame.origin.y = (self.frame.size.height-11)/2;
	self.bodyView.frame = frame;
	[self updateSomeColor];
}
%end