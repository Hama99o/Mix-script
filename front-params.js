  if (this.push.frontParams) {
        Object.keys(this.push.frontParams).forEach((key) =>
          (this.push[key] = this.push.frontParams[key])
        )
        this.push.segments = this.push.segments || []
      }


      push: {
        name: '',
        workflowState: '',
        template: '',
        sql: '',
        poll: this.$route.params.poll,
        sqlEnabled: false,
        publishDatetime: undefined,
        qualifAge: true,
        qualifGender: true,
        qualifCity: false,
        segments: [
          {
            ageFrom: 15,
            ageTo: 25,
            activityMonthAgo: 3,
            male: true,
            female: true,
            weekly: true,
            daily: true,
            otherSub: false,
            cityIds: [],
            segmentIndex: 1,
            availableCities: [
            ],
            usersCount: null,
            sql: ''
          }
        ],
        questionIds: [],
        excludedPushIds: [],
        frontParams: {}
      }
    }






    Show
    async getPush () {
      const data = await back.getPush(this.id)
      this.push = data.push
      if (typeof this.push.template !== 'string') this.push.template = yaml.safeDump(this.push.template)
      if (this.push.publishDatetime) this.push.publishDatetime = this.push.publishDatetime.split((':')).slice(0, 2).join(':')

      if (this.push.frontParams) {
        Object.keys(this.push.frontParams).forEach((key) =>
          (this.push[key] = this.push.frontParams[key])
        )
        this.push.segments = this.push.segments || []
      }
    }

    async duplicate () {
      await this.getAndDuplicatePush(this.push.id)
      this.$router.push({ name: 'NewPush' })
    },