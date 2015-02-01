# OSXWebsiteHealthChecker

This is a very simple application designed to show you the status of a list of 
websites. This might be useful if your daily workflow depends on certain
websites being available. Multiple sites can be added, and their status' 
are displayed in the drop down menu. The status' of all added sites are checked 
using Apple's reachability api. When a site is found to be unreachable, 
a notification will pop up indicating this to be the case.

## Building this code

Probably the esaiest thing to do is create a cocoa Xcode project named OSXWebSiteHealthChecker.
Upon creation, this will contain a sub folder also of the same name. You should remove this sub-folder 
in its entirety, replacing it with a clone of this repo. You will then need to add the
SystemConfiguration.framework as this is used for the reachability checking.
The project should then compile and link correctly.
