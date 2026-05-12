#import "UserModel.h"

@implementation UserModel

- (instancetype)initWithUserId:(NSInteger)userId name:(NSString *)name role:(NSString *)role {
    self = [super init];
    if (self) {
        _userId = userId;
        _name = name;
        _role = role;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"User[%ld]: %@ (%@)", (long)self.userId, self.name, self.role];
}

@end
