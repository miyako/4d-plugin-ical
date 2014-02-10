#import "PAListener.h"

@implementation PAListener

@synthesize listenerMethodName;
@synthesize listenerMethodId;
@synthesize listenerProcessNumber;

@synthesize notificationType;

- (id)initWithMethodName:(NSString *)methodName methodId:(NSNumber *)methodId processNumber:(NSNumber *)processNumber
{
	if(!(self = [super init]))return self;
	
	self.listenerMethodName = methodName;
	self.listenerMethodId = methodId;	
	self.listenerProcessNumber = processNumber;
	
	shouldTerminate = NO;
	locked = NO;
	
	return self;
}

- (BOOL)shouldTerminate
{
	return shouldTerminate;	
}

- (void)terminate
{
	locked = YES;
	shouldTerminate = YES;
	
	PA_UnfreezeProcess([self.listenerProcessNumber intValue]);		
}

- (void)unlock
{
	locked = NO;
}

- (BOOL)lock
{
	if(!locked){
		locked = YES;
		return YES;
	}else{
		return NO;
	}
	
}

@end