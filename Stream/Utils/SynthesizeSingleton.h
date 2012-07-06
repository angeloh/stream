#define SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_CUSTOM_METHOD_NAME(classname, methodname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)methodname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [[self alloc] init]; \
} \
} \
\
return shared##classname; \
}

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_CUSTOM_METHOD_NAME(classname, shared##classname)