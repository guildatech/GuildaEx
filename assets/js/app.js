// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

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
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import { toCurrency } from "./currency-conversion";
import flatpickr from "flatpickr";

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

let Hooks = {};

Hooks.PodcastPlayer = {
  mounted() {
    this._lastSecond = 0;

    this.el.addEventListener("timeupdate", (event) => {
      var currentTime = Math.round(event.target.currentTime);
      if (currentTime != this._lastSecond && !event.target.paused) {
        this._lastSecond = currentTime;
        this.pushEventTo(`#${this.el.dataset.target}`, "play-second-elapsed", {
          time: currentTime,
        });
      }
    });
  },
};

Hooks.CurrencyMask = {
  beforeUpdate() {
    this.el.value = toCurrency(this.el.value);
  },
};

Hooks.DatePicker = {
  mounted() {
    this.setupDatePicker(this.el);
  },

  updated() {
    this.setupDatePicker(this.el);
  },

  setupDatePicker(el) {
    flatpickr(el, {
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      defaultDate: el.getAttribute("value"),
      enableTime: false,
    });
  },
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
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
