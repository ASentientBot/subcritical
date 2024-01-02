@import Foundation;
@import ObjectiveC;

// TODO: not sure why i can't get MSHookInterface to work with ElleKit 🤦🏻‍♀️
// this works, but...

void swizzle(NSString* className,NSString* selName,BOOL isInstance,IMP newImp,IMP* oldImpOut)
{
	Class class=NSClassFromString(className);
	assert(class);
	
	SEL sel=NSSelectorFromString(selName);
	Method method=(isInstance?class_getInstanceMethod:class_getClassMethod)(class,sel);
	assert(method);
	
	IMP oldImp=method_setImplementation(method,newImp);
	if(oldImpOut)
	{
		*oldImpOut=oldImp;
	}
}

BOOL wasCritical=false;

void showAlert(NSString* message)
{
	Class AlertClass=NSClassFromString(@"SBDismissOnlyAlertItem");
	NSObject* alertItem=[[AlertClass alloc] initWithTitle:@"subcritical 🔋" body:message];
	[AlertClass activateAlertItem:alertItem];
	alertItem.release;
}

void (*real_updateBatteryState)(id,SEL,NSMutableDictionary*);
void fake_updateBatteryState(id self,SEL sel,NSMutableDictionary* state)
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
	
	real_updateBatteryState(self,sel,state);
}

__attribute__((constructor)) void load()
{
	swizzle(@"SBUIController",@"updateBatteryState:",true,(IMP)fake_updateBatteryState,(IMP*)&real_updateBatteryState);
}