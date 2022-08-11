<template lang="html">
  <div class="container">
    <div class="d-flex">
      <router-link :to="routeParams" class="btn btn-info mr-2 backToPushes">
        <i class="fas fa-arrow-circle-left"></i>
        Back
      </router-link>
    </div>

    <form class="my-4 form-container push-form" v-if="modeSql">
      <form-fields  :formFields="pushFields"
                    formId="push"
                    :formObject="push"
                    fieldsClass="w-100 mb-3"/>

    </form>
    <template v-else>
      <div v-if="push.poll" class='section mt-2 rounded border'>
        <div class='section-header bg-light border-bottom'>
          <div class='row p-2'>
            <form-field
              :formObject="push"
              :formId="push"
              :field="{ type: 'normalizedtext', name: 'Nom du push' }"
              fieldKey='name'
              class='col'
            />
            <form-field
              :formObject="push"
              :formId="push"
              :field="{ type: 'date', name: 'Heure du push', required: false, withHour: true }"
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
                :field="{ type: 'boolean', name: 'Age' }"
                fieldKey='qualifAge'
                class='col-sm col-sm-auto'
              />
              <form-field
                :formObject="push"
                :formId="push"
                :field="{ type: 'boolean', name: 'Genre' }"
                fieldKey='qualifGender'
                class='col-sm col-sm-auto'
              />
              <form-field
                :formObject="push"
                :formId="push"
                :field="{ type: 'boolean', name: 'Ville' }"
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
            :index="index" />
            <button
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
        <div class='section-footer p-2 border-top d-flex  justify-content-between'>
           <modal-settings :push="push"/>
            <button type="button" :data-checked="checked" class="p-2 px-3 rounded check-button btn btn-success submitButton" style='min-width: max-content' @click="createOrUpdatePush()" :disabled="checked === 'saved'" >
              <i class="fas fa-exclamation-triangle" v-if="checked === 'error'"></i>
              <i class="fas fa-check-circle" v-if="checked === 'saved'"></i>
              <i class="fas fa-spinner fa-spin" v-if="checked === 'loading'"></i>
              <i class="fas fa-save" v-if="checked === 'save'"></i>
              Save
            </button>
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
    async getConversation () {
      if (this.push.pollId) {
        this.push.poll = await back.getPoll(this.push.pollId)
      }

      if (this.push.poll) {
        this.push.pollId = this.push.poll.id
        this.conversation = await back.getDraftByStateMachineId(this.push.poll.stateMachineId)
        const wordings = yaml.safeLoad(this.conversation.wordings)
        const mainState = Object.keys(wordings)[0]
        this.push.workflowState = mainState
        this.push.name = this.push.poll.name
        const template = {}
        template[mainState] = wordings[mainState]
        this.push.template = yaml.safeDump(template)
        if (this.push.poll.questions === undefined) {
          this.push.poll = await back.getDraftPoll(this.conversation.id)
        }
        const questionLength = this.push.poll.questions.length
        if (questionLength > 0) {
          this.push.question_ids = [this.push.poll.questions[questionLength - 1].uid]
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
        const data = await back.putPush(this.push)
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
    addSegment () {
      this.push.segments.push({
        ageFrom: 12,
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
        this.getConversation()
        this.postPushSegmentUserIds()
      }
    }
  },
  computed: {
    canSubmit () {
      return Object.values(this.push).filter((value) => {
        if (value !== false && value !== null) {
          return !value
        }
      }).length !== 0
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

    segmentParams () {
      return {
        timePush: this.push.publishDatetime,
        qualification: {
          gender: this.push.qualifAge,
          age: this.push.qualifGender,
          city: this.push.qualifCity,
          excludedPushIds: this.push.pushIds,
          questionIds: this.push.questionIds
        }
      }
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
      this.getConversation()
      this.postPushSegmentUserIds()
    } else {
      this.getAvailablePolls()
    }
  },
  watch: {
    segmentParams () {
      this.postPushSegmentUserIds()
    }
  }
}
</script>
