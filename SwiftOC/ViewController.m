#import "ViewController.h"
#import "SwiftOC-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SwiftClass *swift = [[SwiftClass alloc] initWithName:@"OC"];
    NSLog(@"%@", [swift greeting]);

    NSLog(@"%@", [SwiftClass callOC]);

    UILabel *label = [[UILabel alloc] init];
    label.text = [swift greeting];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.view.bounds;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:label];
}

@end
