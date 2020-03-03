#import "GUIScriptingChecker.h"
#import "SystemEvents.h"
#import "SystemPreferences.h"

#define GSCLocalizedString(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"GUIScriptingChecker_Localizable"]

@implementation GUIScriptingChecker

+ (BOOL)check
{
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_8)
    {
        if (AXIsProcessTrusted() || AXAPIEnabled()) {
            return YES;
        }
        NSAlert *alert = [NSAlert new];
        alert.messageText = GSCLocalizedString(@"GUI Scripting is not enabled.");
        [alert addButtonWithTitle:GSCLocalizedString(@"Enable GUI Scripting")];
        [alert addButtonWithTitle:GSCLocalizedString(@"Cancel")];
        alert.informativeText = GSCLocalizedString(@"Enable GUI Scripting ?");
        NSInteger alert_result = [alert runModal];

        if (NSAlertFirstButtonReturn == alert_result) {
            SystemEventsApplication * system_events_app = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
            system_events_app.UIElementsEnabled = YES;
            return system_events_app.UIElementsEnabled;
        }
    } else {
        NSDictionary *opts = @{(__bridge id) kAXTrustedCheckOptionPrompt : @YES};
        return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
    }
    
    return NO;
}

@end
