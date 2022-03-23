import flatpickr from "flatpickr";

export default {
  mounted() {
    this.setupDatePicker(this.el);
  },

  updated() {
    this.setupDatePicker(this.el);
  },

  setupDatePicker(el) {
    let opts = {
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      defaultDate: el.getAttribute("value"),
      enableTime: false,
    };
    let removeMinDate = el.dataset.removeMinDate;

    if (removeMinDate === undefined) {
      opts.minDate = new Date(Date.now() - 1 * 24 * 60 * 60 * 1000 * 365);
    }

    flatpickr(el, opts);
  },
};
