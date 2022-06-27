    it "strips quick replies" do
      expect(question.quick_replies[0]).to eq 'oui'
      expect(question.quick_replies[1]).to eq 'non'
      expect(question.quick_replies[2]).to eq 'peut-être'
    end