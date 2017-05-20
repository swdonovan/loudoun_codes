require 'rails_helper'

RSpec.feature 'Admin scoreboard', type: :feature do
  let(:contest) { Contest.create! }

  scenario 'admin scoreboard is not accessible to participants' do
    visit admin_contest_scoreboard_path(contest)

    expect(current_path).to eq(root_path)
  end

  context "as an admin" do
    include_context "an authorized admin"

    scenario 'admin scoreboard is accessible to admins' do
      # TODO Update when authorization is in place
      visit admin_contest_scoreboard_path(contest)

      expect(current_path).to eq(admin_contest_scoreboard_path(contest))
    end

    scenario 'a team without activity is not shown', :include_contest do
      team = Team.create!(contest: contest, name: 'Team 1')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to_not have_text('Team 1')
    end

    scenario 'a team with activity is shown' do
      team = Team.create!(contest: contest, name: 'Team 1')
      problem = Problem.create!(contest: contest)
      submission = Submission.create!(team: team, problem: problem)

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('Team 1')
    end

    scenario 'teams are ranked by current score' do
      team_1 = Team.create!(contest: contest, name: 'Team 1')
      team_2 = Team.create!(contest: contest, name: 'Team 2')
      problem = Problem.create!(contest: contest)

      Submission.create!(problem: problem, team: team_1, passed: false)
      Submission.create!(problem: problem, team: team_2, passed: true)

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Team 2.*Team 1/)
    end
  end
end
