<template lang="html">
  <div class="container">
    <div class="d-flex">
      <div>
        <router-link :to="{ name: 'Pushes' }" class="btn btn-dark mr-2 backToPushes">
          <i class="fas fa-arrow-circle-left"></i>
          Back
        </router-link>
      </div>

      <div>
        <router-link :to="routeParams" class="btn btn-success mr-2 backToPushes">
          <i class="fas fa-comments"></i>
          Conversation
        </router-link>
      </div>

      <div class="mx-2" v-if="!push.scheduled && isShow">
        <button class="editPush btn btn-info shadow-sm" @click="editPath(push)">
          <i class="far fa-edit"></i>
          Edit
        </button>
      </div>

      <div v-if="isShow">
        <button class="duplicatePush btn btn-light shadow-sm" @click="duplicate(push)">
          <i class="far fa-copy"></i>
          Duplicate
        </button>
      </div>

      <div class="ml-auto" v-if="isShow">
        <button @click="destroyPush(push.id, push.name)" class="btn btn-warning deletePush mb-2" v-if="!push.scheduled">
          <i class="fas fa-trash"></i>
          Delete
        </button>
      </div>
    </div>

    <form class="my-4 form-container push-form" v-if="modeSql">
      <form-fields  :formFields="pushFields"
                    formId="push"
                    :formObject="push"
                    fieldsClass="w-100 mb-3"/>

      <div class="d-flex my-3">
        <button type="button" :data-checked="checked" class="check-button btn btn-success mb-2 mr-2 submitButton" @click="createOrUpdatePush()" :disabled="canSubmit || checked === 'saved'" >
          <i class="fas fa-exclamation-triangle" v-if="checked === 'error'"></i>
          <i class="fas fa-check-circle" v-if="checked === 'saved'"></i>
          <i class="fas fa-spinner fa-spin" v-if="checked === 'loading'"></i>
          <i class="fas fa-save" v-if="checked === 'save'"></i>
          Save
        </button>
      </div>
    </form>
    <template v-else>
      <div v-if="push.poll" class='section mt-2 rounded border'>
        <div class='section-header bg-light border-bottom'>
          <div class='row p-2'>
            <form-field
              :formObject="push"
              :formId="push"
              :field="{ type: 'normalizedtext', name: 'Nom du push', disabled: isShow }"
              fieldKey='name'
              class='col'
            />

            <form-field
              :formObject="push"
              :formId="push"
              :field="{ type: 'date', name: 'Heure du push', required: false, withHour: true, disabled: isShow }"
              fieldKey='publishDatetime'
              class='col-sm col-sm-auto'
            />
          </div>
          <div v-if='!push.sqlEnabled' class='p-2'>
            <div class='d-flex'>
              <label class='font-weight-bold'>Qualification: </label>
              <form-field
                :formObject="push"
                :formId="push"
                :field="{ type: 'boolean', name: 'Age', disabled: isShow }"
                fieldKey='qualifAge'
                class='col-sm col-sm-auto'
              />
              <form-field
                :formObject="push"
                :formId="push"
                :field="{ type: 'boolean', name: 'Genre', disabled: isShow }"
                fieldKey='qualifGender'
                class='col-sm col-sm-auto'
              />
              <form-field
                :formObject="push"
                :formId="push"
                :field="{ type: 'boolean', name: 'Ville', disabled: isShow }"
                fieldKey='qualifCity'
                class='col-sm col-sm-auto'
              />
            </div>
          </div>
        </div>

        <div class="section-body px-3 pb-3">
          <template v-if='!push.sqlEnabled'>
            <segment
            v-for="(segment, index) in push.segments"
            :key="index"
            :push="push"
            :index="index"
            :isShow="isShow" />
            <button
              v-if="!isShow"
              class="small-btn btn btn-lightgray mt-3"
              @click="addSegment()"
            >
              <i class="fas fa-plus text-success"></i>
            </button>
          </template>
          <div v-else class='text-secondary text-center mt-3'>
            <i class='fas fa-exclamation-triangle center'></i>
            Le sql a été édité manuellement, vous ne pouvez donc pas accéder à ce module
          </div>
        </div>
        <div class='section-footer p-2 border-top  d-flex'>
          <div class='w-100'>
            <modal-settings :push="push" :isShow="isShow"/>
          </div>

          <div v-if='validationErrors.length > 0' class='font-weight-light text-danger p-2 mx-2' style='min-width: max-content;'>
            {{ validationErrors[validationErrors.length - 1] }}
          </div>

          <div v-if="!isShow" >
            <button type="button" :data-checked="checked" class="p-2 px-3 rounded btn btn-success submitButton float-right" style='min-width: max-content' @click="createOrUpdatePush()" :disabled="checked === 'saved' || !canSubmit" >
              <i class="fas fa-exclamation-triangle" v-if="checked === 'error'"></i>
              <i class="fas fa-check-circle" v-if="checked === 'saved'"></i>
              <i class="fas fa-spinner fa-spin" v-if="checked === 'loading'"></i>
              <i class="fas fa-save" v-if="checked === 'save'"></i>
              Save
            </button>
          </div>

          <div v-if="!push.scheduled && isShow">
            <button type="button" :data-checked="checked" class="p-2 px-3 rounded check-button btn btn-success submitButton" @click="schedulePush()">
              <i class="fas fa-exclamation-triangle" v-if="checked === 'error'"></i>
              <i class="fas fa-check-circle" v-if="checked === 'saved'"></i>
              <i class="fas fa-spinner fa-spin" v-if="checked === 'loading'"></i>
              <i class="fas fa-check-circle" v-if="checked === 'save'"></i>
              Schedule
            </button>
          </div>
        </div>
      </div>
      <div v-else class='section mt-2 rounded border'>
        <label class='font-weight-bold'>Conversation: </label>
        <Select2 :options='availablePolls' :settings="{ placeholder: 'Séléctionner une conversation' }" @select="setConversation($event)" />
      </div>
    </template>
  </div>
</template>

<script>
import FormFields from '@/components/form/FormFields'
import FormField from '@/components/form/FormField'
import back from '@/services/back.js'
import yaml from 'js-yaml'
import ModalSettings from '@/components/pushes/ModalSettings'
import Segment from '@/components/pushes/Segment'
import Select2 from 'v-select2-component'

export default {
  name: 'push-form',
  components: { FormFields, FormField, ModalSettings, Segment, Select2 },
  props: {
    push: {
      type: Object,
      required: true
    },
    isShow: {
      type: Boolean
    }
  },
  data () {
    return {
      checked: '',
      pushFields: {
        name: { type: 'text', name: 'Nom', required: true },
        publishDatetime: { type: 'date', name: 'Push date and time', required: false, withHour: true },
        workflowState: { type: 'normalizedtext', name: 'Workflow State', required: true },
        template: { type: 'acetextarea', name: 'Template', required: true, lang: 'customyaml' },
        sql: { type: 'acetextarea', name: 'Sql', required: true, lang: 'sql' }
      },
      conversation: null,
      polls: [],
      modeSql: false
    }
  },

  methods: {
    async syncPushFromPoll () {
      if (this.push.pollId) {
        this.push.poll = await back.getPoll(this.push.pollId)
      }

      if (this.push.poll) {
        this.push.pollId = this.push.poll.id
        this.conversation = await back.getDraftByStateMachineId(this.push.poll.stateMachineId)
        if (!this.push.id) {
          const wordings = yaml.safeLoad(this.conversation.wordings)
          const mainState = Object.keys(wordings)[0]
          this.push.workflowState = mainState
          this.push.name = this.push.poll.name
          const template = {}
          template[mainState] = wordings[mainState]
          this.push.template = yaml.safeDump(template)
        }
        if (this.push.poll.questions === undefined) {
          this.push.poll = await back.getDraftPoll(this.conversation.id)
        }
        const questionLength = this.push.poll.questions.length
        if (questionLength > 0) {
          this.push.question_ids = [this.push.poll.questions[questionLength - 1].id]
        }
      }
    },

    async newPush () {
      try {
        this.checked = 'loading'
        const data = await back.postPush(this.pushParams)
        this.checked = 'saved'
        await new Promise(resolve => setTimeout(resolve, 1000))
        this.checked = 'save'
        this.$router.push({ name: 'PushShow', params: { id: data.push.id } })
      } catch {
        this.checked = 'error'
        await new Promise(resolve => setTimeout(resolve, 5000))
        this.checked = 'save'
      }
    },

    async updatePush () {
      try {
        this.checked = 'loading'
        const data = await back.putPush(this.push.id, this.pushParams)
        this.checked = 'saved'
        await new Promise(resolve => setTimeout(resolve, 1000))
        this.checked = 'save'
        this.$router.push({ name: 'PushShow', params: { id: data.push.id } })
      } catch {
        this.checked = 'error'
        await new Promise(resolve => setTimeout(resolve, 5000))
        this.checked = 'save'
      }
    },

    createOrUpdatePush () {
      if (this.push.id) {
        this.updatePush()
      } else {
        this.newPush()
      }
    },
    async postPushSegmentUserIds () {
      await back.postPushSegmentUserIds(this.segmentParams)
    },

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

    addSegment () {
      this.push.segments.push({
        ageFrom: 15,
        ageTo: 25,
        activityMonthAgo: 3,
        male: true,
        female: true,
        weekly: true,
        daily: true,
        otherSub: false,
        cityIds: [],
        availableCities: [],
        counter: null,
        usersCount: [],
        sql: ''
      })
    },

    async getAvailablePolls () {
      const polls = await back.getPolls()
      this.polls = polls
    },

    setConversation (event) {
      this.push.poll = this.polls.find(poll => poll.id === parseInt(event.id))
      if (this.push.poll.stateMachineId !== null) {
        this.syncPushFromPoll()
      }
    },
    duplicate (push) {
      return this.$router.push({ name: 'PushDuplicate', params: { id: push.id } })
    },
    editPath (push) {
      return this.$router.push({ name: 'PushEdit', params: { id: push.id } })
    }
  },

  computed: {
    canSubmit () {
      if (this.modeSql) {
        return Object.values(this.push).filter((value) => {
          if (value !== false && value !== null) {
            return !value
          }
        }).length !== 0
      } else {
        return this.validationErrors.length === 0
      }
    },

    frontParams () {
      return {
        qualifAge: this.push.qualifAge,
        qualifGender: this.push.qualifGender,
        qualifCity: this.push.qualifCity,
        segments: this.push.segments,
        questionIds: this.push.questionIds,
        excludedPushIds: this.push.excludedPushIds
      }
    },

    pushParams () {
      return {
        name: this.push.name,
        publishDatetime: this.push.publishDatetime,
        workflowState: this.push.workflowState,
        template: this.push.template,
        sql: this.sql,
        frontParams: { ...this.frontParams },
        pollId: this.push.pollId
      }
    },

    validationErrors () {
      const errors = []
      if (!this.sql) {
        errors.push("Sql can't be blank")
      }
      ['template', 'publishDatetime', 'workflowState'].forEach((field) => {
        if (!this.push[field]) {
          errors.push(field + " can't be blank")
        }
      })
      if (!this.push.segments.every(seg => seg.activityMonthAgo && seg.ageFrom && seg.ageTo)) {
        errors.push('There is some errors into the segments')
      }
      return errors
    },

    routeParams () {
      const params = { name: 'Pushes' }
      if (this.conversation) {
        params.name = 'ConversationEditor'
        params.params = { id: this.conversation.id }
      }
      return params
    },

    formattedTemplate () {
      return yaml.safeLoad(this.push.template)
    },

    sql () {
      return this.push.segments.map((s) => {
        return s.sql
      }).join('\n\nUNION \n\n')
    },

    availablePolls () {
      return this.polls.map(conv => ({ id: conv.id, text: conv.name }))
    }
  },

  created () {
    if (this.push.poll || this.push.pollId) {
      this.syncPushFromPoll()
    } else {
      this.getAvailablePolls()
    }
  }
}
</script>
