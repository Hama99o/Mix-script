async updateselectedMode (mode) {
  this.selectedMode = mode
  this.goToNewPush(this.currentPoll, this.currentConversation)
}