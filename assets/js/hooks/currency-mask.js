import { toCurrency } from "../currency-conversion";

export default {
  beforeUpdate() {
    this.el.value = toCurrency(this.el.value);
  },
};
