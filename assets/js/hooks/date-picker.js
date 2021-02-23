import flatpickr from "flatpickr";

export default {
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
