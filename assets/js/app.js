// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css";
import "remixicon/fonts/remixicon.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import "alpinejs";

import { Socket } from "phoenix";
import topbar from "../vendor/topbar";
import { LiveSocket } from "phoenix_live_view";
import Hooks from "./hooks";
import "./leaflet/leaflet-map";
import "./leaflet/leaflet-marker";
import "./leaflet/leaflet-icon";

let isVisible = (el) => !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);

// Accessible focus handling
let Focus = {
  focusMain() {
    let target = document.querySelector("main h1") || document.querySelector("main");
    if (target) {
      let origTabIndex = target.tabIndex;
      target.tabIndex = -1;
      target.focus();
      target.tabIndex = origTabIndex;
    }
  },
  // Subject to the W3C Software License at https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  isFocusable(el) {
    if (el.tabIndex > 0 || (el.tabIndex === 0 && el.getAttribute("tabIndex") !== null)) {
      return true;
    }
    if (el.disabled) {
      return false;
    }

    switch (el.nodeName) {
      case "A":
        return !!el.href && el.rel !== "ignore";
      case "INPUT":
        return el.type != "hidden" && el.type !== "file";
      case "BUTTON":
      case "SELECT":
      case "TEXTAREA":
        return true;
      default:
        return false;
    }
  },
  // Subject to the W3C Software License at https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  attemptFocus(el) {
    if (!el) {
      return;
    }
    if (!this.isFocusable(el)) {
      return false;
    }
    try {
      el.focus();
    } catch (e) {}

    return document.activeElement === el;
  },
  // Subject to the W3C Software License at https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  focusFirstDescendant(el) {
    for (let i = 0; i < el.childNodes.length; i++) {
      let child = el.childNodes[i];
      if (this.attemptFocus(child) || this.focusFirstDescendant(child)) {
        return true;
      }
    }
    return false;
  },
  // Subject to the W3C Software License at https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  focusLastDescendant(element) {
    for (let i = element.childNodes.length - 1; i >= 0; i--) {
      let child = element.childNodes[i];
      if (this.attemptFocus(child) || this.focusLastDescendant(child)) {
        return true;
      }
    }
    return false;
  },
};

let Uploaders = {};

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach((entry) => {
    let formData = new FormData();
    let { url, fields } = entry.meta;
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val));
    formData.append("file", entry.file);
    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () => xhr.status === 204 || entry.error();
    xhr.onerror = () => entry.error();
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        entry.progress(percent);
      }
    });

    xhr.open("POST", url, true);
    xhr.send(formData);
  });
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken,
  },
  uploaders: Uploaders,
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#FBBF24" }, shadowColor: "#D97706" });
let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 120);
  }
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

window.addEventListener("js:exec", (e) => e.target[e.detail.call](...e.detail.args));
window.addEventListener("js:focus", (e) => {
  let parent = document.querySelector(e.detail.parent);
  if (parent && isVisible(parent)) {
    e.target.focus();
  }
});
window.addEventListener("js:focus-closest", (e) => {
  let el = e.target;
  let sibling = el.nextElementSibling;
  while (sibling) {
    if (isVisible(sibling) && Focus.attemptFocus(sibling)) {
      return;
    }
    sibling = sibling.nextElementSibling;
  }
  sibling = el.previousElementSibling;
  while (sibling) {
    if (isVisible(sibling) && Focus.attemptFocus(sibling)) {
      return;
    }
    sibling = sibling.previousElementSibling;
  }
  Focus.attemptFocus(el.parent) || Focus.focusMain();
});
window.addEventListener("phx:remove-el", (e) => document.getElementById(e.detail.id).remove());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
