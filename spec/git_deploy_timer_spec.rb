require 'spec_helper'
require 'date'
require 'fileutils'

# TODO: Negative cases
describe GitDeployTimer do
  before :all do
    @git_repo = init_git_repo
  end

  after :all do
    FileUtils.rm_rf(@git_repo)
  end

  it 'clones a repo into a tmp directory' do
    begin
      local_repo = GitDeployTimer.clone_repo(@git_repo)
      expect(local_repo).to have_last_commit_message('Feature 4')
    ensure
      FileUtils.rm_rf(local_repo)
    end
  end

  it 'extracts commits in reverse chronological order' do
    commits = GitDeployTimer.commit_times(@git_repo)
    expect(commits[0]['commitTimestamp']).to eq(DateTime.iso8601('2010-04-10T12:05:00+01:00'))
    expect(commits[1]['commitTimestamp']).to eq(DateTime.iso8601('2010-04-10T12:00:00+01:00'))
    expect(commits[2]['commitTimestamp']).to eq(DateTime.iso8601('2010-04-10T11:00:00+01:00'))
    expect(commits[3]['commitTimestamp']).to eq(DateTime.iso8601('2010-04-10T10:00:00+01:00'))
  end
end
