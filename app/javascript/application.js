// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import jquery from "jquery";
window.jQuery = jquery;
window.$ = jquery;

import "jquery_ujs";

import "select2";
import "select2-rails";

document.addEventListener("DOMContentLoaded", function () {
  $(".select2").select2();
  alert("1232131233");
});
