import L from "leaflet";

const template = document.createElement("template");
template.innerHTML = `
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
    integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
    crossorigin=""/>
    <div style="height: 100%;">
      <slot />
    </div>
`;

class LeafletMap extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
    this.shadowRoot.appendChild(template.content.cloneNode(true));
    this.mapElement = this.shadowRoot.querySelector("div");

    const accessToken = window.mapAccessToken;

    this.map = L.map(this.mapElement, { maxZoom: 15 });
    this.markersLayer = L.featureGroup().addTo(this.map);

    L.tileLayer("https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}", {
      attribution:
        'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 18,
      id: "mapbox/streets-v11",
      tileSize: 512,
      zoomOffset: -1,
      accessToken: accessToken,
    }).addTo(this.map);

    this.defaultIcon = L.icon({
      iconUrl: "/images/guilda-logo.png",
      iconSize: [64, 64],
    });
  }

  connectedCallback() {
    const markerElements = this.querySelectorAll("leaflet-marker");
    markerElements.forEach((markerEl) => {
      const lat = markerEl.getAttribute("lat");
      const lng = markerEl.getAttribute("lng");
      L.marker([lat, lng], { icon: this.defaultIcon }).addTo(this.markersLayer);
    });
    const bounds = this.markersLayer.getBounds().pad(0.1);
    this.map.fitBounds(bounds);
  }
}

window.customElements.define("leaflet-map", LeafletMap);
