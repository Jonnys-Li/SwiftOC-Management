#import "OCClass.h"

@implementation OCClass

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (NSString *)greeting {
    return [NSString stringWithFormat:@"Hello from OC, %@!", self.name];
}

@end
