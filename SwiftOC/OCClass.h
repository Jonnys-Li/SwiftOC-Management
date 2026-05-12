#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCClass : NSObject

@property (nonatomic, copy) NSString *name;

- (instancetype)initWithName:(NSString *)name;
- (NSString *)greeting;

@end

NS_ASSUME_NONNULL_END
