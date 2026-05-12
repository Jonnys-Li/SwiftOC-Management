#import "ViewController.h"
#import "SwiftOC-Swift.h"
#import "UserManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // --- Swift & OC interop demo ---
    SwiftClass *swift = [[SwiftClass alloc] initWithName:@"OC"];
    NSLog(@"%@", [swift greeting]);
    NSLog(@"%@", [SwiftClass callOC]);

    // --- UserManager demo ---
    UserManager *mgr = [UserManager sharedInstance];
    [mgr addUser:[[UserModel alloc] initWithUserId:1 name:@"Alice" role:@"Admin"]];
    [mgr addUser:[[UserModel alloc] initWithUserId:2 name:@"Bob"   role:@"Editor"]];
    [mgr addUser:[[UserModel alloc] initWithUserId:3 name:@"Charlie" role:@"Viewer"]];

    NSLog(@"Total users: %ld", (long)[mgr userCount]);
    for (UserModel *u in [mgr listUsers]) {
        NSLog(@"%@", u);
    }

    UserModel *found = [mgr findUserById:2];
    NSLog(@"Found user 2: %@", found);

    // Warning: removeUserById: in v1.0.0 has NO bounds check
    // Passing userId that doesn't exist (e.g. 99) will crash
    // [mgr removeUserById:99];  // ← index out of bounds crash
    
    [mgr removeUserById:0];
    NSLog(@"After removal, count: %ld", (long)[mgr userCount]);

    // --- UI label ---
    UILabel *label = [[UILabel alloc] init];
    label.text = [swift greeting];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.view.bounds;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:label];
}

@end
