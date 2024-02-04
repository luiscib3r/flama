#include "include/flama_flutter_libs/flama_flutter_libs_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flama_flutter_libs_plugin.h"

void FlamaFlutterLibsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flama_flutter_libs::FlamaFlutterLibsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
