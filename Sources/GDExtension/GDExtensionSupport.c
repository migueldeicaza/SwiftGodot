//
//  GDExtensionBridge.c.c
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//
#include <stdio.h>
#include "GDExtension.h"

void DEMO_defineEntryPoint (DEMO_ENTRY_POINT a) {
}

void miguel_test (void **a) {
    printf ("Received address: %p\n", a);
    *a = 0xdeadb0d1;
}
