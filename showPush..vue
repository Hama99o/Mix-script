<template lang="html">
  <div class="container push-show" v-if="pushExists">
    <div class="d-flex">
      <div>
        <router-link :to="{ name: 'Pushes' }" class="btn btn-dark mr-2 backToPushes">
          <i class="fas fa-arrow-circle-left"></i>
          Back
        </router-link>
      </div>

      <div class="mx-2" v-if="!push.scheduled">
        <button class="editPush btn btn-info shadow-sm" @click="editPath(push)">
          <i class="far fa-edit"></i>
          Edit
        </button>
      </div>

      <div>
        <button class="duplicatePush btn btn-light shadow-sm" @click="duplicate(push)">
          <i class="far fa-copy"></i>
          Duplicate
        </button>
      </div>

      <div class="ml-auto">
        <button @click="destroyPush(push.id, push.name)" class="btn btn-warning deletePush mb-2" v-if="isPushed">
          <i class="fas fa-trash"></i>
          Delete
        </button>
      </div>
    </div>

    <div class="push mt-3">
      <span class="d-flex justify-content-center h3 name"> {{push.name}}</span>

      <div class="d-flex justify-content-center my-3 flex-wrap">
        <span class="mr-1 py-1 px-2 border rounded-pill bg-white workflowState">{{push.workflowState}}</span>
        <span class="mr-1 py-1 px-2 border rounded-pill bg-white publishDatetime">{{(new Date(push.publishDatetime)).toLocaleString('fr', { dateStyle: 'short', timeStyle: 'short' })}}</span>
      </div>

      <span class=""> <ace-text-area v-if="push.template" name="Template :" :value="push.template" formId="push_show" fieldKey="template" :disabled="true" /></span>
      <span> <ace-text-area v-if="push.template" name="SQL :" :value="push.sql" :disabled="true" formId="push_show" fieldKey="sql" lang="sql" class="pr-" /></span>
    </div>

    <div class="d-flex my-3">
      <button type="button" :data-checked="checked" class="check-button btn btn-success mb-2 mr-2 submitButton" @click="schedulePush()" :disabled="!push.scheduled">
        <i class="fas fa-exclamation-triangle" v-if="checked === 'error'"></i>
        <i class="fas fa-check-circle" v-if="checked === 'saved'"></i>
        <i class="fas fa-spinner fa-spin" v-if="checked === 'loading'"></i>
        <i class="fas fa-check-circle" v-if="checked === 'save'"></i>
        Schedule
      </button>
    </div>
  </div>
  <loading-container v-else :isLoading="!pushExists" />
</template>
<script>
import back from '@/services/back.js'
import AceTextArea from '@/components/form/AceTextArea'
import LoadingContainer from '@/components/layout/LoadingContainer'
import store from '@/store/mappers'
import yaml from 'js-yaml'

export default {
  name: 'push-show',
  components: { AceTextArea, LoadingContainer },
  data () {
    return {
      checked: '',
      id: this.$route.params.id
    }
  },
  computed: {
    ...store.state('drafts', ['push']),
    pushExists () {
      console.log(this.push)
      return Object.keys(this.push).length !== 0
    },
    isPushed () {
      return new Date(this.push.publishDatetime) < new Date()
    }
  },
  methods: {
    ...store.actions('drafts', ['getPush']),
    async schedulePush () {
      try {
        this.checked = 'loading'
        const data = await back.patchPush(this.push.id)
        this.push.scheduled = data.push.scheduled
        this.checked = 'saved'
        await new Promise(resolve => setTimeout(resolve, 1000))
        this.checked = 'save'
      } catch {
        this.checked = 'error'
        await new Promise(resolve => setTimeout(resolve, 5000))
        this.checked = 'save'
      }
    },
    async destroyPush (id, name) {
      this.$confirm(
        name,
        'Êtes-vous sûr de vouloir supprimer',
        'warning'
      ).then(() => {
        back.deletePush(id)
        return this.$router.push({ name: 'Pushes' })
      })
    },
    duplicate (push) {
      return this.$router.push({ name: 'PushDuplicate', params: { id: push.id } })
    },
    editPath (push) {
      return this.$router.push({ name: 'PushEdit', params: { id: push.id } })
    }
  },
  created () {
    this.getPush(this.id)
    if (typeof this.push.template !== 'string') {
      this.push.template = yaml.safeDump(this.push.template)
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
