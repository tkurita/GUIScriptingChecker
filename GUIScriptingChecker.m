//
//  GUIScriptingChecker.m
//  FileClipper
//
//  Created by Tetsuro Kurita on 2015/12/28.
//
//

#import "GUIScriptingChecker.h"
#import "SystemEvents.h"
#import "SystemPreferences.h"

#define GSCLocalizedString(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"GUIScriptingChecker_Localizable"]

@implementation GUIScriptingChecker

+ (BOOL)check
{
    if (AXIsProcessTrusted() || AXAPIEnabled()) {
        return YES;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSComparisonResult result = [dict[@"ProductVersion"] compare:@"10.9" options:NSNumericSearch];
    if (NSOrderedAscending == result) { //10.8 or before
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
        NSAlert *alert = [NSAlert new];
        alert.messageText = [NSString stringWithFormat:GSCLocalizedString(@"need accessibility"),
                                    [[NSRunningApplication currentApplication] localizedName]];
        [alert addButtonWithTitle:GSCLocalizedString(@"Open System Preferences")];
        [alert addButtonWithTitle:GSCLocalizedString(@"Deny")];
        alert.informativeText = GSCLocalizedString(@"Grant access");
        NSInteger alert_result = [alert runModal];

        if (NSAlertFirstButtonReturn == alert_result) {
            SystemPreferencesApplication *sys_pre_app = [SBApplication applicationWithBundleIdentifier:@"com.apple.systempreferences"];
            [[[[[sys_pre_app panes] objectWithID:@"com.apple.preference.security"]anchors]
                                                objectWithName:@"Privacy_Accessibility"] reveal];
            [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.systempreferences"]
              lastObject] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        }
        
    }
    
    return NO;
}

@end
