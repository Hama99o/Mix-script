export default {
  filterAnswersByPollQuestionsAndQuickReplies (answers, pollAnswers, selectedQuestions, selectedQuickReplies) {
    if (selectedQuestions) {
      return answers.filter((answer) => {
        if (pollAnswers) {
          const selectedPollAnswers = this.selectedPollAnswers(selectedQuestions, pollAnswers, answer)

          if (Array.isArray(selectedPollAnswers) && selectedPollAnswers.length !== selectedQuestions.length) {
            return false
          }

          if (Array.isArray(selectedQuickReplies) && selectedQuickReplies.length > 0) {
            return selectedPollAnswers.some(selectedPollAnswer=> selectedQuickReplies.includes(selectedPollAnswer.text))
          } else {
            return answer
          }
        } else {
          return answer
        }
      })
    } else {
      return answers
    }
  },
  selectedPollAnswers (selectedQuestions, pollAnswers, answer) {
    const selectedPollAnswers = []

    selectedQuestions.filter((question) => {
      pollAnswers.find((pollAnswer) => {
        if (pollAnswer.question_id === question.id && answer.user.id === pollAnswer.user_id) {
          selectedPollAnswers.push(pollAnswer)
        }
      })

      return answer
    })
    return selectedPollAnswers
  }
}
