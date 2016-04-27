import Vue from 'vue';
import instances from './instances';

instances.forEach(instance => new Vue(instance))

new Vue({
  el: '#content'
});
