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


/* PUBLIC01C7_SCREENSHOT_GALLERY_V1 */
(() => {
  "use strict";

  function initGallery() {
    const track = document.getElementById("gallery-track");
    const counter = document.getElementById("gallery-counter");
    const prev = document.getElementById("gallery-prev");
    const next = document.getElementById("gallery-next");
    const fullscreen = document.getElementById("gallery-fullscreen");
    const dots = Array.from(
      document.querySelectorAll("[data-gallery-go]")
    );
    const slides = Array.from(
      document.querySelectorAll(".gallery-slide")
    );

    const dialog = document.getElementById("gallery-dialog");
    const dialogTitle =
      document.getElementById("gallery-dialog-title");
    const dialogCounter =
      document.getElementById("gallery-dialog-counter");
    const dialogContent =
      document.getElementById("gallery-dialog-content");
    const dialogPrev =
      document.getElementById("gallery-dialog-prev");
    const dialogNext =
      document.getElementById("gallery-dialog-next");
    const dialogClose =
      document.getElementById("gallery-dialog-close");

    if (
      !track ||
      !counter ||
      !prev ||
      !next ||
      !fullscreen ||
      !dialog ||
      !dialogContent ||
      slides.length === 0
    ) {
      return;
    }

    let index = 0;
    let dialogIndex = 0;
    let scrollTimer = 0;

    function bounded(value) {
      return Math.max(
        0,
        Math.min(slides.length - 1, value)
      );
    }

    function nearestIndex() {
      const left = track.scrollLeft;

      let best = 0;
      let bestDistance = Infinity;

      slides.forEach((slide, candidate) => {
        const distance =
          Math.abs(slide.offsetLeft - left);

        if (distance < bestDistance) {
          best = candidate;
          bestDistance = distance;
        }
      });

      return best;
    }

    function render() {
      counter.textContent =
        `${index + 1} / ${slides.length}`;

      prev.disabled = index === 0;
      next.disabled = index === slides.length - 1;

      dots.forEach((dot, candidate) => {
        const active = candidate === index;

        dot.classList.toggle("active", active);

        if (active) {
          dot.setAttribute("aria-current", "true");
        } else {
          dot.removeAttribute("aria-current");
        }
      });
    }

    function goTo(value, behavior = "smooth") {
      index = bounded(value);

      track.scrollTo({
        left: slides[index].offsetLeft,
        behavior
      });

      render();
    }

    function syncFromScroll() {
      const nextIndex = nearestIndex();

      if (nextIndex !== index) {
        index = nextIndex;
        render();
      }
    }

    function renderDialog() {
      dialogIndex = bounded(dialogIndex);

      const slide = slides[dialogIndex];
      const shot = slide.querySelector(".gallery-shot");
      const title =
        slide.dataset.galleryTitle || "Screenshot";

      if (!shot) {
        return;
      }

      dialogTitle.textContent = title;
      dialogCounter.textContent =
        `${dialogIndex + 1} / ${slides.length}`;

      dialogPrev.disabled = dialogIndex === 0;
      dialogNext.disabled =
        dialogIndex === slides.length - 1;

      dialogContent.replaceChildren(
        shot.cloneNode(true)
      );
    }

    function openDialog(value) {
      dialogIndex = bounded(value);
      renderDialog();

      document.body.classList.add(
        "gallery-dialog-open"
      );

      if (
        typeof dialog.showModal === "function"
      ) {
        dialog.showModal();
      } else {
        dialog.setAttribute("open", "");
      }
    }

    function closeDialog() {
      document.body.classList.remove(
        "gallery-dialog-open"
      );

      if (
        typeof dialog.close === "function" &&
        dialog.open
      ) {
        dialog.close();
      } else {
        dialog.removeAttribute("open");
      }
    }

    prev.addEventListener(
      "click",
      () => goTo(index - 1)
    );

    next.addEventListener(
      "click",
      () => goTo(index + 1)
    );

    fullscreen.addEventListener(
      "click",
      () => openDialog(index)
    );

    dots.forEach((dot) => {
      dot.addEventListener("click", () => {
        goTo(
          Number(dot.dataset.galleryGo)
        );
      });
    });

    track.addEventListener(
      "scroll",
      () => {
        clearTimeout(scrollTimer);

        scrollTimer = window.setTimeout(
          syncFromScroll,
          70
        );
      },
      { passive: true }
    );

    track.addEventListener(
      "keydown",
      (event) => {
        if (event.key === "ArrowLeft") {
          event.preventDefault();
          goTo(index - 1);
        }

        if (event.key === "ArrowRight") {
          event.preventDefault();
          goTo(index + 1);
        }

        if (
          event.key === "Enter" ||
          event.key === " "
        ) {
          event.preventDefault();
          openDialog(index);
        }
      }
    );

    document.querySelectorAll(
      "[data-gallery-index]"
    ).forEach((button) => {
      button.addEventListener("click", () => {
        openDialog(
          Number(button.dataset.galleryIndex)
        );
      });
    });

    dialogPrev.addEventListener(
      "click",
      () => {
        dialogIndex = bounded(dialogIndex - 1);
        renderDialog();
      }
    );

    dialogNext.addEventListener(
      "click",
      () => {
        dialogIndex = bounded(dialogIndex + 1);
        renderDialog();
      }
    );

    dialogClose.addEventListener(
      "click",
      closeDialog
    );

    dialog.addEventListener(
      "click",
      (event) => {
        if (event.target === dialog) {
          closeDialog();
        }
      }
    );

    dialog.addEventListener(
      "close",
      () => {
        document.body.classList.remove(
          "gallery-dialog-open"
        );
      }
    );

    document.addEventListener(
      "keydown",
      (event) => {
        if (!dialog.open) {
          return;
        }

        if (event.key === "ArrowLeft") {
          event.preventDefault();
          dialogIndex =
            bounded(dialogIndex - 1);
          renderDialog();
        }

        if (event.key === "ArrowRight") {
          event.preventDefault();
          dialogIndex =
            bounded(dialogIndex + 1);
          renderDialog();
        }
      }
    );

    window.addEventListener(
      "resize",
      () => {
        goTo(index, "auto");
      }
    );

    render();
  }

  if (document.readyState === "loading") {
    document.addEventListener(
      "DOMContentLoaded",
      initGallery,
      { once: true }
    );
  } else {
    initGallery();
  }
})();
