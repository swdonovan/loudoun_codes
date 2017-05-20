require 'rails_helper'

RSpec.feature 'Admin scoreboard', type: :feature do
  let(:contest) { Contest.create!(started_at: Time.now) }

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

    scenario 'a team without activity is shown', :include_contest do
      team = Team.create!(contest: contest, name: 'Team 1')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('Team 1')
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

      Submission.create!(problem: problem, team: team_1, status: 'failed')
      Submission.create!(problem: problem, team: team_2, status: 'passed')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Team 2.*Team 1/)
    end

    scenario 'ties are broken by time' do
      team_1 = Team.create!(contest: contest, name: 'Team 1')
      team_2 = Team.create!(contest: contest, name: 'Team 2')
      problem = Problem.create!(contest: contest)

      submission_1 = Submission.create!(problem: problem, team: team_2, status: 'passed')
      submission_2 = Submission.create!(problem: problem, team: team_1, status: 'passed')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Team 2.*Team 1/)
    end

    scenario 'problem numbers are shown in the table header' do
      8.times { Problem.create!(contest: contest) }

      visit admin_contest_scoreboard_path(contest)

      8.times do |index|
        expect(page).to have_text(index + 1)
      end
    end

    scenario 'there is a team column' do
      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Team/)
    end

    scenario 'there is a score column' do
      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Score/)
    end

    scenario 'there is a time + penalty column' do
      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text(/Time \+ Penalty/)
    end

    scenario 'unattempted problems show a 0 total number of submissions' do
      team = Team.create!(contest: contest, name: 'Team 1')
      problem = Problem.create!(contest: contest)

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('0')
    end

    scenario 'unsolved problems show the total number of submissions' do
      team = Team.create!(contest: contest, name: 'Team 1')
      problem = Problem.create!(contest: contest)

      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('4')
    end

    scenario 'solved problems show the total number of submissions' do
      team = Team.create!(contest: contest, name: 'Team 1')
      problem = Problem.create!(contest: contest)

      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'passed')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('4')
    end

    scenario 'problems show the total number of submissions up to the first success' do
      team = Team.create!(contest: contest, name: 'Team 1')
      problem = Problem.create!(contest: contest)

      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'passed')
      submission = Submission.create!(team: team, problem: problem, status: 'failed')
      submission = Submission.create!(team: team, problem: problem, status: 'passed')

      visit admin_contest_scoreboard_path(contest)

      expect(page).to have_text('4')
    end
  end
end
