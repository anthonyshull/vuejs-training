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

<script>
  import Task from './task.vue'

  export default {
    // The `board` property gets passed by the parent element with :board=board
    props: ['board'],
    data: function() {
      return {
        input: ''
      }
    },
    methods: {
      addTask: function() {
        this.$dispatch('addTask', this.board.id, this.input);
        this.input = '';
      }
    },
    components: {
      'task': Task
    }
  };
</script>
