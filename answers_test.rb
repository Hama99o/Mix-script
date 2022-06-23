    context "with answers" do
      let(:question) { create(:question, :with_answers, nb_responders: 5) }

      it "returns the percents for each quick_reply" do
        expect(subject).to eq("• oui : 40%\n• non : 40%\n• peut-être : 20%")
      end

      context "with an answer which is not a quick reply" do
        let(:bad_answer) { create(:answer, question: question, text: 'weird shit') }
        before { bad_answer }

        it "doens't count the extra answer" do
          expect(subject).to eq("• oui : 40%\n• non : 40%\n• peut-être : 20%")
        end
      end
    end
