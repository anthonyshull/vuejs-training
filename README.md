# Version Two

In this tutorial you will create a super simple kanban board using Vue.js. You should get familiar with the [documentation](http://vuejs.org/guide/).

All of the routes, controllers, and models for the app have been created in previous sprints
so you just need to create the view layer.

Run the following to get your development environment up and running:

```sh
git checkout tutorial
git checkout -b TEAM_NAME
bundle install --path vendor/bundle
rake db:migrate
rake db:seed
npm install
npm run dev
```

All of your JS dependencies will now be in /node_modules. A `/client` directory has also been created to house your custom JS. A process is watching that directory; any time you save a file it will be converted and placed in the asset pipeline for Rails.

### Introduction

We'll start with some basics. The first thing a Vue application needs is an entry point. Create a file `entry.js` in the `/client` directory.

```js
import Vue from 'vue';
import instances from './instances';

// This is Turbolinks dependent. `page:change` wraps the `DOMContentLoaded` event
document.addEventListener('page:change', (/* event */) => {
  instances.forEach(instance => new Vue(instance))
})
```

A few things are happening here. First, we are importing the Vue library from `/node_modules`; next, we are importing all of the files in our `/client/instances/` directory (we will look at this a bit later). With our required modules imported, we wrap the body of this script in an event handler. This event handler listens for the generic Turbolinks `page:change` event, which fires on initial page load as well as all subsequent Turbolinks reroutes. By wrapping the body of the file in this listener, we ensure that our Vue component and instances are re-initialized on each page update, even if that update is an asynchronous Turbolinks update. Inside of this event handler we initialize each of our Vue instances (right now we only have one).

Let's check out that Vue instance,`/client/instances/version-two.js`, which has already been created for you:

```js
// This comes from node_modules
import Vue from "vue";
// Now we use the vue-resource from node_modules for AJAX
import VueResource from "vue-resource";
Vue.use(VueResource);
// This comes from node_modules; it's a vue + bootstrap component
import Alert from 'vue-strap/src/Alert.vue';
// This comes from client/components...
import Board from "../components/board.vue";

export default {
  // The element we're attaching our component to
  el: "#version-two",
  // Boards will get populated after an AJAX request
  data: {
    boards: []
  },
  // Register our board component so we can use it in our template
  components: {
    'vue-board': Board
  }
};
```

After importing everything we need, we create the options object that will initialize our new Vue instance (in `/client/entry.js`). It is given its `el` to tell it where to attach. The `data` attribute will hold all the data our component needs. Lastly, we register our child components with the `components` attribute.

The point of Vue, of course, is to render views. So, let's look at which views correspond to what we've already done. Our instance is attached to the `#version-two` element which can be found in `/app/views/boards/index.html.erb`. This is a normal ERB template.

```html
<div id="version-two">
  <vue-board v-for="board in boards"
             :board="board">
  </vue-board>
</div>
```

Notice that the template includes a `vue-board` component that was made available by our `components` attribute (**Note:** As best-practice and to keep your Rails view code as clear as possible, we recommend that you prefix all Vue components used anywhere in your `/apps/views/` directory with the `vue-` prefix). The `v-for` directive will loop over all of the boards in our
`data` attribute and render them from the `/client/components/board.vue` file. Let's look at that now:

```html
<template>
  <div class="col-md-4">
    <h3>
      <span class="badge">{{ board.tasks.length }}</span>
      {{ board.description }}
    </h3>
    <hr />
    <ul class="list-group">
      <!--- The colons mean that the prop is evaluated
            rather than passed as a string -->
      <task v-for="task in board.tasks"
            :task="task"
            :board="board.id">
      </task>
    </ul>
    <hr />
  </div>
</template>

<script>
  import Task from './task.vue'

  export default {
    // The `board` property gets passed by the parent element with :board=board
    props: ['board'],
    data: function() {
      return {};
    },
    components: {
      'task': Task
    }
  };
</script>

```

The first thing you'll notice is that the `.vue` file contains both a template and a script element. When components are structured this way, Vue knows that the object exported by the script tag controls the html in the template tag (**Note:** These `.vue` files are handled by the `vueify` plugin).

In the script tag you'll see a new attribute--`props`. These are properties that we want to pass down from parent to child components. In `/app/views/boards/index.html.erb` we set `:board=board`. The result is that `this.board` is available in the board component.

You'll see that in the template we can use curly braces to access data. We display the number of tasks in the board alongside the title of said board. It's important to remember that `this.board` in the script becomes `board` in the template.

We also register the task component in the `components` attribute so that we can use it as an element in the template. We again use `v-for` to render the task view for all the tasks on our board.

Finishing up, we'll take a look at that task view in `/client/components/task.vue`.

```html
<template>
  <li class="list-group-item">{{ task.description }}</li>
</template>

<script>
  export default {
    props: ['task', 'board'],
    data: function() {
      return {};
    }
  };
</script>
```

This should look familiar by now. The board component gives the task component its data via the `props` attribute. We also pass down the board id (we'll use it later.) The task merely renders its description with curly braces.

It might seem like we've already seen a lot of files, but the good news is that those are the only ones we'll be touching to complete our entire application. Everything here on out will be adding to those base components.

### Load Boards

We have all of our base components in place. But, as of yet, we can't see anything. That's because
`this.boards` is empty. Let's fetch whatever boards are already in the database.

Edit `/client/instances/version-two.js` and add a `methods` attribute to the Vue instance like so:

```js
methods: {
  fetchBoards: function() {
    // This comes from vue-resource and keeps a reference to `this`
    this.$http({
      url: 'boards.json',
      method: 'GET'
    })
    // The promise is returned as a response object
    .then(function(response) {
      // We change this.boards to the response data
      this.$set('boards', response.data);
    }, function(error) {
      console.error('Error fetching boards: ' + error.toString());
    });
  }
}
```

Now, we have a method `this.fetchBoards()` that will populate `this.boards`. We use `this.$http` from the vue-resources plugin. It issues a GET request to boards.json and returns a promise. If the promise returns a valid response we set `this.boards` to the `response.data`.

This method can be called at any point by our application instance. We want to call it as the instance is created by tapping into the `created` lifecycle event. Add a `created` attribute:

```js
// When the component is created we fetch our boards
created: function() {
  this.fetchBoards();
}
```
We can now see all of our boards and all of our tasks!

Check out other [lifecycle events](http://vuejs.org/guide/instance.html#Instance-Lifecycle).

### Add a Task

It's great that we can view all of our tasks. But we're looking for some real dynamism here. We want to be able to add tasks on the fly. For simplicity's sake, we will only be collecting a task description.

Let's start by adding an input to our board template:

```html
<!--- board.vue -->
<template>
  <div class="col-md-4">
    <h3>
      <span class="badge">{{ board.tasks.length }}</span>
      {{ board.description }}
    </h3>
    <hr />
    <ul class="list-group">
      <!--- The colons mean that the prop is evaluated
            rather than passed as a string -->
      <task v-for="task in board.tasks"
            :task="task"
            :board="board.id">
      </task>
    </ul>
    <hr />
    <h5>Add Task</h5>
    <input v-model="input"
           placeholder="description">
    <button class="btn btn-success btn-xs"
            @click="addTask">
      Add Task
      <span class="glyphicon glyphicon-ok"></span>
    </button>
  </div>
</template>
```

The `v-model` attribute on the input binds the value of the `input` element in the template to `this.input` data attribute in our script.

```js
data: function() {
  return {
    'input': ''
  }
}
```

**Note:** Vue really wants you to set your `data` attribute to a function returning an object. If you don't it will whine at you like a cat waiting to be fed. The reason why related to these being "components" (as opposed to "instances"). Vue components are meant to be reused, which means they will have multiple instances. If the `data` attribute were a simple object, each instance of a component would share the exact same `data`. By making the `data` attribute a function, each instance of a component is given its own version of the `data`.

Inside of this component's `data`, we set the initial value of our input to be empty.

Likewise, `@click` (shorthand for `v-on:click`) tells the script to call the method `this.addTask` on the click event. Let's add this to the script.

```js
methods: {
  addTask: function() {
    this.$dispatch('addTask', this.board.id, this.input);
    this.input = '';
  }
}
```

Our method uses `this.$dispatch` to send an event up its parent chain. The parent of our boards, of course, is our application instance. So, we need to listen for that event in `/client/instances/version-two.js`.

Add an `events` attribute to the instance.

```js
events: {
  addTask: function(board, task) {
    this.$http({
      url: 'tasks',
      method: 'POST',
      data: {
        board: board,
        task: task
      }
    })
    .then(function(response) {
      // Reload the boards
      this.fetchBoards();
    }, function(error) {
      console.error('Error adding task: ' + error.toString());
    });
  }
}
```

This will listen for the `addTask` event and send a request to the server to add a task given the `board.id` and task description. A success response triggers a re-load of all boards with `this.fetchBoards()`.

Wow! Now we can add tasks to our boards until we get bored enough to do something else.

### Delete a Task

Here's something else: we can add tasks, but we can't delete them yet. Let's do that.

Again, we'll start from the template and move up the chain. Add a button to the template with a click emitter.

```html
<!--- task.vue -->
<template>
  <li class="list-group-item">
    {{ task.description }}
    <!--- @click is shorthand for v-on:click
          any v-on: events can be prepended with an @ instead -->
    <button class="btn btn-danger btn-xs"
            @click="deleteTask">
      Delete Task
      <span class="glyphicon glyphicon-remove"></span>
    </button>
  </li>
</template>
```

Just like we did before, we need to add a method to our script object to handle that click.

```js
methods: {
  deleteTask: function() {
    // Send a message to the parent component to delete a task
    this.$dispatch('deleteTask', this.task.id);
  }
}
```

And, just like before, we use `this.$dispatch` to send it up our parental chain. We need to listen for that event in `/client/instances/version-two.js`. Create a new entry in the `events` object.

```js
deleteTask: function(task) {
  this.$http({
    url: 'tasks/' + task + '/delete',
    method: 'POST',
  })
  .then(function(response) {
    // Reload the boards
    this.fetchBoards();
  }, function(error) {
    console.error('Error deleting task: ' + error.toString());
  });
}
```

We send a web request and re-load the boards on success. Pretty easy, huh?

### Bootstrap Alert

We can add and delete tasks. But, besides the changing of data we have no way of showing the user
that they've done anything. We should add an alert whenever a user deletes a task.

If you look at the top of `/client/intances/version-two.js` you'll see that we imported an Alert object from `vue-strap`. Vue-strap gives us Bootstrap components that we can plug-and-play with Vue. That is, our component can pop-up a modal or alert or whatever all within Vue.

In order to use it we need to first register it as a component. Because we want the application to issue the alerts we'll add it to our instance. Add it to our list of `components` in `/client/instances/version-two.js`.

```js
components: {
  'vue-board': Board,
  'vue-alert': Alert
}
```

That makes available the `Alert` object we imported as the `<vue-alert>` tag in our template. Let's add it.

```html
<!--- /app/views/boards/index.html.erb -->
<div id="version-two">
  <vue-alert :show.sync="showAlert"
             :duration="3000"
             type="danger"
             width="400px"
             placement="top"
             dismissable>
    <p><span class="glyphicon glyphicon-trash"></span>You just deleted something.</p>
  </vue-alert>
  <vue-board v-for="board in boards"
             :board="board">
  </vue-board>
</div>
```

The only property we're really interested in is `:show.sync=showAlert`. That will use `this.showAlert` in the script to control visibility. Let's add that as a `data` attribute.

```js
data: {
  boards: [],
  showAlert: false
}
```

Finally, we need to trigger the showing of alerts. We'll edit the `deleteTask` methond.

```js
deleteTask: function(task) {
  this.$http({
    url: 'tasks/' + task + '/delete',
    method: 'POST',
  })
  .then(function(response) {
    // Reload the boards
    this.fetchBoards();
    // Trigger our alert
    this.showAlert = !this.showAlert;
  }, function(error) {
    console.error('Error deleting task: ' + error.toString());
  });
}
```

