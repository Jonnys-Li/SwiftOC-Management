#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *role;

- (instancetype)initWithUserId:(NSInteger)userId name:(NSString *)name role:(NSString *)role;

@end

NS_ASSUME_NONNULL_END
