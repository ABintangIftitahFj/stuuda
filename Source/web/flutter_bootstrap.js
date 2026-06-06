{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Remove splash screen / clear background once the engine is ready
    if (typeof removeSplashFromWeb === 'function') {
      removeSplashFromWeb();
    }
    
    await appRunner.runApp();
  }
});
