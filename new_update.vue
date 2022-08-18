<template lang="html">
  <div class="container">
    <div class="d-flex">
      <div>
        <button @click="pushesPath()" class="btn btn-dark mr-2 backToPushes">
          <i class="fas fa-arrow-circle-left"></i>
          Back
        </button>
      </div>

      <div v-if="this.conversation">
        <button @click="conversationPath()" class="btn btn-success mr-2 backToPushes">
          <i class="fas fa-comments"></i>
          Conversation
        </button>
      </div>

      <div class="mx-2" v-if="!push.scheduled && isEditable">
        <button class="editPush btn btn-info shadow-sm" @click="editPath()">
          <i class="far fa-edit"></i>
          Edit
        </button>
      </div>

      <div v-if="isEditable && push.pollId">
        <button class="duplicatePush btn btn-light shadow-sm" @click="duplicatePath()">
          <i class="far fa-copy"></i>
          Duplicate
        </button>
      </div>

      <div class="ml-auto" v-if="isEditable">
        <button @click="destroyPush(push.id, push.name)" class="btn btn-warning deletePush mb-2" v-if="!push.scheduled">
          <i class="fas fa-trash"></i>
          Delete
        </button>
      </div>
    </div>

    <div v-if="push.poll || push.id" class='section mt-2 rounded border'>
      <div class='section-header bg-light border-bottom'>
        <div class='row p-2'>
          <form-field
            :formObject="push"
            :formId="push"
            :field="{ type: 'normalizedtext', name: 'Nom du push', disabled: isEditable, showValidationError: true }"
            fieldKey='name'
            class='col'
          />

          <form-field
            :formObject="push"
            :formId="push"
            :field="{ type: 'date', name: 'Heure du push', required: false, withHour: true, disabled: isEditable, showValidationError: true }"
            fieldKey='publishDatetime'
            class='col-sm col-sm-auto'
          />
        </div>
        <div v-if='!push.sqlEnabled' class='p-2'>
          <div class='d-flex'>
            <label class='font-weight-bold'>Qualification: </label>
             <form-fields :formFields="qualificationFields"
                    formId="push"
                    :formObject="push"
                    parentFieldsClass="d-flex"
                    fieldsClass="col-sm col-sm-auto"/>
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
          :isEditable="isEditable" />
          <button
            v-if="!isEditable"
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
          <modal-settings :push="push" :isEditable="isEditable"/>
        </div>

        <div v-if='validationErrors.length > 0' class='font-weight-light text-danger p-2 mx-2' style='min-width: max-content;'>
          {{ validationErrors[validationErrors.length - 1] }}
        </div>

        <div v-if="!isEditable && !push.sqlEnabled" >
          <button type="button" :data-checked="checked" class="p-2 px-3 rounded btn btn-success submitButton float-right" style='min-width: max-content' @click="createOrUpdatePush()" :disabled="checked === 'saved' || !canSubmit" >
            <i :class="saveAndScheduleButtonClass"></i>
            Save
          </button>
        </div>

        <div v-if="!push.scheduled && isEditable">
          <button type="button" :data-checked="checked" class="p-2 px-3 rounded check-button btn btn-success submitButton" @click="schedulePush()">
            <i :class="saveAndScheduleButtonClass"></i>
            Schedule
          </button>
        </div>
      </div>
    </div>
    <div v-else class='section mt-2 rounded border'>
      <label class='font-weight-bold'>Conversation: </label>
      <Select2 :options='availablePolls' :settings="{ placeholder: 'Séléctionner une conversation' }" @select="setConversation($event)" />
    </div>
  </div>
</template>

<script>
import FormField from '@/components/form/FormField'
import back from '@/services/back.js'
import yaml from 'js-yaml'
import ModalSettings from '@/components/pushes/ModalSettings'
import Segment from '@/components/pushes/Segment'
import Select2 from 'v-select2-component'
import FormFields from '@/components/form/FormFields'

export default {
  name: 'push-form',
  components: { FormField, ModalSettings, Segment, Select2, FormFields },
  props: {
    push: {
      type: Object,
      required: true
    },
    isEditable: {
      type: Boolean,
      default: false
    },
    isNewPush: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      checked: '',
      qualificationFields: {
        qualifAge: { type: 'boolean', name: 'Age', disabled: this.isEditable },
        qualifGender: { type: 'boolean', name: 'Genre', disabled: this.isEditable },
        qualifCity: { type: 'boolean', name: 'Ville', disabled: this.isEditable }
      },
      conversation: null,
      polls: []
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

        this.mergeConversationDataToPush()
        this.mergePollQuestionsToPush()
      }
    },

    mergeConversationDataToPush () {
      if (this.isNewPush) {
        const wordings = yaml.safeLoad(this.conversation.wordings)
        const mainState = Object.keys(wordings)[0]
        this.push.workflowState = mainState
        this.push.name = this.push.poll.name
        const template = {}
        template[mainState] = wordings[mainState]
        this.push.template = yaml.safeDump(template)
      }
    },

    async mergePollQuestionsToPush () {
      if (this.push.poll.questions === undefined) {
        this.push.poll = await back.getDraftPoll(this.conversation.id)
      }

      const questionLength = this.push.poll.questions.length

      if (questionLength > 0) {
        this.push.question_ids = [this.push.poll.questions[questionLength - 1].id]
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
    async getSegmentData () {
      await back.getSegmentData(this.segmentParams)
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
        usersCount: [],
        sql: ''
      })

      this.push = { ...this.push }
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
    duplicatePath () {
      return this.$router.push({ name: 'PushDuplicate', params: { id: this.push.id } })
    },
    editPath () {
      return this.$router.push({ name: 'PushEdit', params: { id: this.push.id } })
    },
    conversationPath () {
      return this.$router.push({ name: 'ConversationEditor', params: { id: this.conversation.id } })
    },
    pushesPath () {
      return this.$router.push({ name: 'Pushes' })
    }
  },

  computed: {
    canSubmit () {
      return this.validationErrors.length === 0
    },

    saveAndScheduleButtonClass () {
      if (this.checked === 'error') {
        return 'fas fa-exclamation-triangle'
      } else if (this.checked === 'saved') {
        return 'fas fa-check-circle'
      } else if (this.checked === 'loading') {
        return 'fas fa-spinner fa-spin'
      } else if (this.checked === 'save') {
        return 'fas fa-save'
      } else {
        return ''
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
      ['name', 'template', 'publishDatetime', 'workflowState'].forEach((field) => {
        if (!this.push[field]) {
          errors.push(field + " can't be blank")
        }
      })
      if (this.push.segments && !this.push.segments.every(seg => seg.activityMonthAgo && seg.ageFrom && seg.ageTo)) {
        errors.push('There is some errors into the segments')
      }
      return errors
    },

    formattedTemplate () {
      return yaml.safeLoad(this.push.template)
    },

    sql () {
      if (this.push.segments) {
        return this.push.segments.map((s) => {
          return s.sql
        }).join('\n\nUNION \n\n')
      } else {
        return this.push.sql
      }
    },

    availablePolls () {
      return this.polls.map(conv => ({ id: conv.id, text: conv.name }))
    }
  },

  created () {
    if (this.push.poll || this.push.pollId) {
      this.syncPushFromPoll()
    } else if (this.push.id && (!this.push.poll || !this.push.pollId) && !this.isNewPush) {
      this.push.sqlEnabled = true
    } else {
      this.getAvailablePolls()
    }
  }
}
</script>
