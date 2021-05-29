@import Foundation;
#import <CydiaSubstrate/CydiaSubstrate.h>

BOOL wasCritical=false;

void showAlert(NSString* message)
{
	Class AlertClass=NSClassFromString(@"SBDismissOnlyAlertItem");
	id alertItem=[[AlertClass alloc] initWithTitle:@"subcritical 🔋" body:message];
	[AlertClass activateAlertItem:alertItem];
}

MSHookInterface(SBUIController,FakeSBUIController,NSObject)

@implementation FakeSBUIController

-(void)updateBatteryState:(NSMutableDictionary*)state
{
	if(((NSNumber*)state[@"AtCriticalLevel"]).boolValue)
	{
		state[@"AtCriticalLevel"]=@false;
		
		if(!wasCritical)
		{
			showAlert(@"blocking critical status");
			wasCritical=true;
		}
	}
	else if(wasCritical)
	{
		showAlert(@"no longer critical");
		wasCritical=false;
	}
	
	[super updateBatteryState:state];
}

@end