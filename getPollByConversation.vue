    async getPollByConversation (conversation) {
      let poll = {}

      if (conversation.poll && conversation.poll.id) {
        poll = await this.getPoll(conversation.poll.id)
      }
      this.goToNewPush(poll, conversation)
    },