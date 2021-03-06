require 'rails_helper'

RSpec.describe SubmissionRunners::Python, type: 'docker' do
  describe 'docker command and barebone Python image' do
    let(:fixtures) { Pathname.new(Rails.root).join('spec/fixtures/submission_runners/python/') }
    let(:contest) { Contest.instance }
    let(:account) { contest.accounts.create! }

    let(:problem) do
      Problem.create_from_files!({
        contest:     contest,
        name:        problem_name,
        input_file:  fixtures.join('ProblemA.in'),
        output_file: fixtures.join('ProblemA.out'),
      })
    end

    let(:submission) {
      Submission.create_from_file({
        problem:  problem,
        account:  account,
        filename: fixtures.join("#{problem_name}.py"),
      }).tap(&:validate!)
    }

    subject(:runner) { described_class.new submission }

    context 'good entry submission' do
      let(:problem_name) { 'good_run' }

      it "runs via call" do
        runner.call
        expect(runner.output).to eq(problem.output)
        expect(runner.output_type).to eq("success")
        expect(runner.run_succeeded).to be_truthy
      end
    end

    context 'failing entry submission' do
      let(:problem_name) { 'bad_run' }

      it "runs via call" do
        runner.call
        expect(runner.output).to_not eq(problem.output)
        expect(runner.output_type).to eq("success")
        expect(runner.run_succeeded).to be_truthy
      end
    end

    context 'invalid syntax entry submission' do
      let(:problem_name) { 'corrupt_code' }

      it "fails run via run" do
        runner.build
        r = runner.run
        expect(r.out).to_not eq(problem.output)
        expect(r.err).to_not eq('')
        expect(r.exitstatus).to_not eq(0)
        expect(r.success?).to be_falsey
      end

      it "fails run via call" do
        runner.call
        expect(runner.output_type).to eq("run_failure")
        expect(runner.run_succeeded).to be_falsey
      end
    end
  end
end
