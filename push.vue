
        <div class='section-body px-3 pb-3'>
          <div v-for="(segment, index) in push.segments" :key="index" class="card mt-3">
            <button
              class="insert-message after position-absolute small-btn btn btn-lightgray rounded-circle p-2"
              style="top: -8px; left: -8px;"
              @click="removeSegment(index)"
              v-if="canRemoveSegment"
            >
              <i class="fas fa-minus text-danger"></i>
            </button>
            <div class='card-body'>
              <div class='row'>
                <div class='col'>
                  <label class='font-weight-bold'>Genre:</label>
                  <div class='d-flex'>
                    <form-field
                      :formObject="segment"
                      :formId="index"
                      :field="{ type: 'boolean', name: 'Homme' }"
                      fieldKey='male'
                      class='col-sm col-sm-auto'
                      @onUpdate="updateSegment('male', $event, index)"
                    />
                    <form-field
                      :formObject="segment"
                      :formId="index"
                      :field="{ type: 'boolean', name: 'Femme' }"
                      fieldKey='female'
                      class='col-sm col-sm-auto'
                      @onUpdate="updateSegment('female', $event, index)"
                    />
                  </div>
                </div>
                <div class="col">
                  <label class='font-weight-bold'>Subscription:</label>
                  <div class='d-flex'>
                    <form-field
                      :formObject="segment"
                      :formId="index"
                      :field="{ type: 'boolean', name: 'Daily' }"
                      fieldKey='daily'
                      class='col-sm col-sm-auto'
                      @onUpdate="updateSegment('daily', $event, index)"
                    />
                    <form-field
                      :formObject="segment"
                      :formId="index"
                      :field="{ type: 'boolean', name: 'Weekly' }"
                      fieldKey='weekly'
                      class='col-sm col-sm-auto'
                      @onUpdate="updateSegment('weekly', $event, index)"
                    />
                    <form-field
                      :formObject="segment"
                      :formId="index"
                      :field="{ type: 'boolean', name: 'Other' }"
                      fieldKey='other_sub'
                      class='col-sm col-sm-auto'
                      @onUpdate="updateSegment('other_sub', $event, index)"
                    />
                  </div>
                </div>

                <div class='col text-right'>
                  <form-field
                    :formObject="segment"
                    :formId="segment"
                    :field="{ type: 'number', name: 'Dernière activité (en mois)' }"
                    fieldKey='activity_month_ago'
                    class=''
                    @onUpdate="updateSegment('activity_month_ago', $event, index)"
                  />
                </div>
              </div>
              <div class='row'>
                <div class='col-sm col-sm-auto'>
                  <div class="d-flex">
                    <form-field
                      :formObject="segment"
                      :formId="segment"
                      :field="{ type: 'number', name: 'Age min' }"
                      fieldKey='age_from'
                      style='width: 185px;'
                      @onUpdate="updateSegment('age_from', $event, index)"
                    />
                    <form-field
                      :formObject="segment"
                      :formId="segment"
                      :field="{ type: 'number', name: 'Age max' }"
                      fieldKey='age_to'
                      style='width: 185px;'
                      @onUpdate="updateSegment('age_to', $event, index)"
                    />
                  </div>
                </div>
                <div class='col'>
                  <label class='font-weight-bold'>Villes: </label>
                  <Select2 v-model="segment.city_ids" :options="segment.available_cities" :settings="{ multiple: true, placeholder: 'Séléctionner des villes' }" @change="updateSegment('city_ids', $event, index)" @select="selectCities($event)" />
                </div>
              </div>

            </div>
            <div class='card-footer'>
              <div class="float-right p-2 border">
                1242 users
              </div>
            </div>
            <button
              class="insert-message after position-absolute small-btn btn btn-lightgray rounded-circle p-2"
              style="bottom: -8px; left: -8px;"
              @click="addSegment()"
              v-if="push.segments.length === index + 1"
            >
              <i class="fas fa-plus text-success"></i>
            </button>
          </div>
        </div>