#import "UserManager.h"

@interface UserManager ()

@property (nonatomic, strong) NSMutableArray<UserModel *> *users;

@end

@implementation UserManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UserManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _users = [NSMutableArray array];
    }
    return self;
}

- (void)addUser:(UserModel *)user {
    [self.users addObject:user];
}

- (void)removeUserById:(NSInteger)userId {
    // Resolved: combine feature's indexOfObjectPassingTest + hotfix's warning log
    NSInteger index = [self.users indexOfObjectPassingTest:^BOOL(UserModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.userId == userId) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [self.users removeObjectAtIndex:index];
    } else {
        NSLog(@"Warning: user %ld not found, skipping removal", (long)userId);
    }
}

- (UserModel *)findUserById:(NSInteger)userId {
    for (UserModel *user in self.users) {
        if (user.userId == userId) {
            return user;
        }
    }
    return nil;
}

- (NSArray<UserModel *> *)listUsers {
    return [self.users copy];
}

- (NSInteger)userCount {
    return self.users.count;
}

@end
