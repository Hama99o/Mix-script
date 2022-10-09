async getSegmentsData () {
  if (!this.validatedParams) return
  this.toggleLoading(true)
  const data = await this.getSegmentData(this.segmentParams)
  this.toggleLoading(false)
  this.segment.usersCount = data.usersCount
  this.segment.availableCities = data.cities
  this.segment.sql = data.sql
  this.push.sql = format(this.push.frontParams.segments.map((s) => {
    return s.sql
  }).join('\n\nUNION \n\n'))
}