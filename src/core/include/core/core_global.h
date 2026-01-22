#ifndef TOOLSVIZ_CORE_GLOBAL_H
#define TOOLSVIZ_CORE_GLOBAL_H

#ifdef _WIN32
  #ifdef TOOLSVIZCORE_LIBRARY
    #define TOOLSVIZCORE_EXPORT __declspec(dllexport)
  #else
    #define TOOLSVIZCORE_EXPORT __declspec(dllimport)
  #endif
#else
  #define TOOLSVIZCORE_EXPORT
#endif

#endif // TOOLSVIZ_CORE_GLOBAL_H
