export default {
  methods: {
    copyString (text) {
      const copyText = document.createElement('textarea')
      copyText.value = text

      document.body.appendChild(copyText)
      copyText.select()
      copyText.setSelectionRange(0, 99999)
      document.execCommand('copy')
      document.body.removeChild(copyText)
    },
    copyTextConfirm (value) {
      try {
        this.copyString(value)
        this.$fire({
          title: 'You just copied: ',
          text: value,
          type: 'success',
          timer: 3000
        })
      } catch {
        this.$alert('Failed to copy text')
      }
    }
  }
}
