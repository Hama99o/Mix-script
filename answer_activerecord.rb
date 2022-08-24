Answer.select(
  [
    Answer.arel_table[:message_id].count.as('count'), 
    Arel::Nodes::NamedFunction.new(
      'SUM', [
        Arel::Nodes::Case.new.when(User.arel_table[:gender].eq('male')).then(1).else(0)
      ]
    ).as('male'), 
    Arel::Nodes::NamedFunction.new(
      'SUM', [
        Arel::Nodes::Case.new.when(User.arel_table[:gender].eq('female')).then(1).else(0)
      ]
    ).as('female'), 
    Answer.arel_table[:text].as('text')
  ]
).where(
  Answer.arel_table[:question_id].eq(Question.arel_table[:id]).and(Answer.arel_table[:kind].eq(nil))
).joins(
  Answer.arel_table.join(User.arel_table).on(
    User.arel_table[:id].eq(Answer.arel_table[:user_id])
  ).join_sources
).group(:text)