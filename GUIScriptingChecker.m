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
        NSInteger alert_result = [[NSAlert
                                   alertWithMessageText:GSCLocalizedString(@"GUI Scripting is not enabled.")
                                   defaultButton:GSCLocalizedString(@"Enable GUI Scripting")
                                   alternateButton:GSCLocalizedString(@"Cancel")
                                   otherButton:nil
                                   informativeTextWithFormat:@"%@", GSCLocalizedString(@"Enable GUI Scripting ?")]
                                  runModal];
        if (NSAlertDefaultReturn == alert_result) {
            SystemEventsApplication * system_events_app = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
            system_events_app.UIElementsEnabled = YES;
            return system_events_app.UIElementsEnabled;
        }
    } else {
        NSString *title_string = [NSString stringWithFormat:
                                  GSCLocalizedString(@"need accessibility"),
                                    [[NSRunningApplication currentApplication] localizedName]];
        NSInteger alert_result = [[NSAlert
                                    alertWithMessageText:title_string
                                    defaultButton:GSCLocalizedString(@"Open System Preferences")
                                    alternateButton:GSCLocalizedString(@"Deny")
                                    otherButton:nil
                                   informativeTextWithFormat:@"%@", GSCLocalizedString(@"Grant access")]
                                  runModal];
        if (NSAlertDefaultReturn == alert_result) {
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
