const breakpoints = {
  xs: "576px",
  sm: "768px",
  md: "992px",
  lg: "1200px",
  xl: "1440px"
};

export default class Screen {
  
  static min(device) {
    return `@media (min-width: ${breakpoints[device]})`;
  }

  static max(device) {
    return `@media (max-width: ${breakpoints[device]})`;
  }

  static between(device_1, device_2) {
    return `@media (min-width: ${breakpoints[device_1]}) and (max-width: ${breakpoints[device_2]})`;
  }
}