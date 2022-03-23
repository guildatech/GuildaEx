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

// Accessible focus wrapping
export default {
  mounted() {
    this.content = document.querySelector(this.el.getAttribute("data-content"));
    this.focusStart = this.el.querySelector(`#${this.el.id}-start`);
    this.focusEnd = this.el.querySelector(`#${this.el.id}-end`);
    this.focusStart.addEventListener("focus", () => Focus.focusLastDescendant(this.content));
    this.focusEnd.addEventListener("focus", () => Focus.focusFirstDescendant(this.content));
    this.content.addEventListener("phx:show-end", () => this.content.focus());
    if (window.getComputedStyle(this.content).display !== "none") {
      Focus.focusFirstDescendant(this.content);
    }
  },
};
