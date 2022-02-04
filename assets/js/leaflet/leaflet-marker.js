class LeafletMarker extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
  }

  connectedCallback() {
    this.dispatchEvent(
      new CustomEvent("marker-added", {
        bubbles: true,
        detail: { lat: this.getAttribute("lat"), lng: this.getAttribute("lng") },
      })
    );
  }
}

window.customElements.define("leaflet-marker", LeafletMarker);
