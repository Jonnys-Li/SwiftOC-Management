#import <Foundation/Foundation.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

+ (instancetype)sharedInstance;

- (void)addUser:(UserModel *)user;
- (void)removeUserById:(NSInteger)userId;
- (UserModel *_Nullable)findUserById:(NSInteger)userId;
- (NSArray<UserModel *> *)listUsers;
- (NSInteger)userCount;

@end

NS_ASSUME_NONNULL_END
