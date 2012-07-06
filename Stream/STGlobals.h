#ifdef _DEBUG
#define STLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define STLog(format, ...)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ARC on iOS 4 and 5 
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 && !defined (SH_DONT_USE_ARC_WEAK_FEATURE)

#define sh_weak   weak
#define __sh_weak __weak
#define sh_nil(x)


#else

#define sh_weak   unsafe_unretained
#define __sh_weak __unsafe_unretained
#define sh_nil(x) x = nil

#endif


#define TAG_BUTTON_FACEBOOK		100

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook

#define FACEBOOK_APP_ID    @"188134217910342"
