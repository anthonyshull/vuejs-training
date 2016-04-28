import Vue from 'vue';
import instances from './instances';

// This is Turbolinks dependent. `page:change` wraps the `DOMContentLoaded` event
document.addEventListener('page:change', (/* event */) => {
  instances.forEach(instance => new Vue(instance));

  // eslint-disable-next-line no-new
  new Vue({
    el: '#content',
  });
});
