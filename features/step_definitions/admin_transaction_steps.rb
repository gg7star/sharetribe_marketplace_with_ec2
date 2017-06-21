module AdminTransactionSteps

  def build_transaction(transaction_data)
    last_message = eval(transaction_data[:latest_activity].gsub(' ', '.'))

    message = FactoryGirl.build(:message, created_at: last_message)
    conversation = FactoryGirl.build(:conversation, created_at: last_message, messages: [message])

    community = Community.find_by(ident: transaction_data[:community_ident])

    author = Person.find_by(username: transaction_data[:other_party], community_id: community.id)
    starter = Person.find_by(username: transaction_data[:starter], community_id: community.id)

    # TODO This is almost copy-paste from conversation_steps
    conversation.participations.build({
      person_id: starter.id,
      is_starter: true,
      is_read: true
    })

    conversation.participations.build({
      person_id: author.id,
      is_starter: false,
      is_read: false
    })

    transaction_opts = {
      created_at: eval(transaction_data[:started_at].gsub(' ', '.')),
      community: community
    }
    sum = transaction_data[:sum].to_i * 100 unless transaction_data[:sum].empty?

    shape = all_shapes.first
    listing = create_listing(
      shape: shape,
      opts: {
        title: transaction_data[:listing],
        author: author
      })

    transaction = FactoryGirl.build(
      :transaction,
      transaction_opts.merge({
          listing: listing,
          conversation: conversation,
          starter: starter,
          current_state: transaction_data[:status]
        })
      )

    transaction.transaction_transitions.build({
      to_state: transaction_data[:status].to_sym
    })

    transaction
  end

  def to_title(name)
    name.gsub("_", " ").capitalize
  end

  def find_column(column)
    page.all("thead > tr > th").find { |elem| elem.text.starts_with?(to_title(column)) }
  end

  def find_column_index(column)
    page.all("thead > tr > th").find_index { |elem| elem.text.starts_with?(to_title(column)) }
  end

  def column_values(column_index)
    page.all("tbody > tr").map { |row| row.all("td")[column_index].text }
  end

end

World AdminTransactionSteps
Given(/^there are following transactions$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |transaction|
    listing_conversation = build_transaction(transaction)
    listing_conversation.save!
  end
end

Then(/^I should see (\d+) transaction with status "(.*?)"$/) do |count, status_text|
  expect(page.all("td", :text => status_text).length).to eq count.to_i
end

When(/^I sort by "(.*?)"$/) do |column|
  find_column(column).find("a").click
end

Then(/^I should see the transactions in ascending order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
  expect(col_values).to eql col_values.sort
end

Then(/^I should see the transactions in descending order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
  expect(col_values).to eql col_values.sort.reverse
end

Then(/^I should see the transactions in ascending time order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
    .map { |value| DateTime.parse(value) }
  expect(col_values).to eql col_values.sort
end

Then(/^I should see the transactions in descending time order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
    .map { |value| DateTime.parse(value) }
  expect(col_values).to eql col_values.sort.reverse
end
