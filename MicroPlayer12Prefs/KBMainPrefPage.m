#include "KBMainPrefPage.h"
#import <Preferences/PSSpecifier.h>

@implementation KBMainPrefPage

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"KBMainPrefPage"
                                                 target:self];
    }

    return _specifiers;
}

@end

@implementation KBInstructionsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers =
            [self loadSpecifiersFromPlistName:@"KBInstructionsController"
                                       target:self];
    }
    return _specifiers;
}
@end

@implementation KBOptionsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"KBOptionsController"
                                                 target:self];       
    }

    return _specifiers;
}
@end

@implementation KBActivatorController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"KBActivatorController"
                                                  target:self];
    }

    return _specifiers;
}
@end