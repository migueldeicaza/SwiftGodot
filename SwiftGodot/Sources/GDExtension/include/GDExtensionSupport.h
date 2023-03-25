//
//  GDExtensionSupport.c.h
//  
//
//  Created by Miguel de Icaza on 3/24/23.
//

#ifndef GDExtensionSupport_c_h
#define GDExtensionSupport_c_h

#include <stdio.h>
#include <gdextension_interface.h>

typedef GDExtensionBool (*DEMO_ENTRY_POINT)(const GDExtensionInterface *p_interface, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization);

    
void DEMO_defineEntryPoint (DEMO_ENTRY_POINT a);

#endif /* GDExtensionSupport_c_h */
