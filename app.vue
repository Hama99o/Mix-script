<template>
  <div id="app" class="d-flex flex-column">
    <background-animation />
    <router-view> </router-view>
  </div>
</template>

<script>
import BackgroundAnimation from './components/layouts/BackgroundAnimation.vue'
export default {
  name: 'App',
  components: { BackgroundAnimation }
}
</script>

<style>
.nightmode {
  background: #292b2c;
  color: #eee;
}
* {
  position: relative;
}
</style>