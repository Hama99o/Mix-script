<template>
  <div class="p-2 rounded shadow-sm bg-light">
    <div v-for="(verbatim, index) in verbatimsCopy" :key="index" class="my-2 d-flex flex-column p-2 verbatims-input">
      <div title="remove verbatims" @click="removeInput(index)" class=" align-self-end symbol delete badge badge-danger cursor-pointer d-flex align-items-center justify-content-center">
        <i class="fas fa-times"></i>
      </div>

      Text: <textarea v-model="verbatim.text" name="trend_report[verbatims][][text]" class="w-100 form-control" type="text" placeholder="Text displayed at the bottom of the trends page"> </textarea>
      Info: <input v-model="verbatim.info" class="w-100 form-control" name="trend_report[verbatims][][info]" type="text" placeholder="Text information like user's name, gender, age, city...">
    </div>

    <div title="Add verbatims" @click="addInput" class="symbol add-verbatims py-1 px-2 mt-1 badge badge-success cursor-pointer d-flex align-items-center justify-content-center">
      <i class="fas fa-plus"></i>
    </div>
  </div>
</template>

<script>

export default {
  name: "verbatims_input",
  props: ['verbatims'],
  data () {
    return {
      verbatimsCopy: []
    }
  },
  methods: {
    addInput() {
      const newInput = { text: '', info: '' };
      this.verbatimsCopy.push(newInput)
    },
    removeInput(index) {
      this.verbatimsCopy.splice(index, 1);
    }
  },
  created () {
    this.verbatimsCopy = this.verbatims
  }
}
</script>

<style scoped>
.verbatims-input {
  background-color: rgb(248, 246, 242);
}
.symbol {
  font-size: 8px;
  width: 23px;
  height: 20px;
  text-align: center;
}
</style>
