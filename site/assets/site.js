(() => {
  "use strict";

  const STORAGE_KEY = "subshell.palette";
  const DEVICE_VALUE = "device";

  const root = document.documentElement;

  function dynamicColourSupported() {
    return Boolean(
      window.CSS &&
      CSS.supports &&
      CSS.supports("color", "AccentColor") &&
      CSS.supports(
        "color",
        "color-mix(in oklab, red 20%, blue)"
      )
    );
  }

  function storedPalette() {
    try {
      return localStorage.getItem(STORAGE_KEY);
    } catch (_) {
      return null;
    }
  }

  function storePalette(value) {
    try {
      if (value === DEVICE_VALUE) {
        localStorage.setItem(STORAGE_KEY, DEVICE_VALUE);
      } else {
        localStorage.removeItem(STORAGE_KEY);
      }
    } catch (_) {}
  }

  function dynamicEnabled() {
    return (
      dynamicColourSupported() &&
      root.dataset.palette === DEVICE_VALUE
    );
  }

  function applySupportedState(toggle) {
    const supported = dynamicColourSupported();

    toggle.dataset.supported =
      supported ? "true" : "false";

    if (!supported) {
      root.removeAttribute("data-palette");

      toggle.disabled = true;
      toggle.setAttribute("aria-pressed", "false");
      toggle.setAttribute(
        "aria-label",
        "Dynamic device colour is not available in this browser"
      );
      toggle.title =
        "This browser does not expose a usable device accent colour. " +
        "Subshell colours are used instead.";

      return false;
    }

    toggle.disabled = false;

    return true;
  }

  function render(toggle) {
    const enabled = dynamicEnabled();

    toggle.setAttribute(
      "aria-pressed",
      enabled ? "true" : "false"
    );

    toggle.setAttribute(
      "aria-label",
      enabled
        ? "Use Subshell colour"
        : "Use dynamic device colour"
    );

    toggle.title = enabled
      ? "Dynamic colour is on. Click to use Subshell orange."
      : "Use your device accent colour where supported.";
  }

  function init() {
    const toggle =
      document.getElementById("palette-toggle");

    if (!toggle) {
      return;
    }

    if (!applySupportedState(toggle)) {
      return;
    }

    if (storedPalette() === DEVICE_VALUE) {
      root.dataset.palette = DEVICE_VALUE;
    } else {
      root.removeAttribute("data-palette");
    }

    render(toggle);

    toggle.addEventListener("click", () => {
      if (dynamicEnabled()) {
        root.removeAttribute("data-palette");
        storePalette(null);
      } else {
        root.dataset.palette = DEVICE_VALUE;
        storePalette(DEVICE_VALUE);
      }

      render(toggle);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener(
      "DOMContentLoaded",
      init,
      { once: true }
    );
  } else {
    init();
  }
})();
