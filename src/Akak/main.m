//
//  main.m
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define  PT_DENY_ATTACH  31
#endif  // !defined(PT_DENY_ATTACH)

int main(int argc, char *argv[])
{
#ifdef LITE_VERSION

#ifndef DEBUG
#ifndef TARGET_IPHONE_SIMULATOR
    char* ptrace_root = "socket";
    char ptrace_name[] = {0xfd, 0x05, 0x0f, 0xf6, 0xfe, 0xf1, 0x00};
    for (size_t i = 0; i < sizeof(ptrace_name); i++) {
        ptrace_name[i] += ptrace_root[i];
    }
    
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, ptrace_name);
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
#endif
#endif
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
