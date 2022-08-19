
  describe('PUT api/v1/pushes/:id', () => {
    it('should update a push', (done) => {
      chai.request(localTestServer)
        .put('api/v1/pushes/9900')
        .send(push)
        .end((err, res) => {
          if (err) {
            throw (err)
          } else {
            // res.should.have.status(200)
            // res.body.should.be.a('object')
            // res.body.should.deep.eq(push)
            done()
          }
        })
    })
  })
