<div v-if="isEditable" >
  <button type="button" :data-checked="checked" class="p-2 px-3 rounded btn btn-success submitButton float-right" style='min-width: max-content' @click="createOrUpdatePush()" :disabled="checked === 'saved' || !canSubmit" >
    <i :class="saveAndScheduleButtonClass"></i>
    Save
  </button>
</div>