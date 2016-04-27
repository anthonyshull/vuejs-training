import Vue from 'vue';
import VersionTwo from './instances/version-two';

// This is Turbolinks dependent. `page:change` wraps the `DOMContentLoaded` event
document.addEventListener('page:change', (/* event */) => {
  new Vue({
    el: '#content'
  });
})
