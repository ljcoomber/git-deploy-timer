require 'spec_helper'
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

  it 'throws an error if cloning a non-existent repo' do
    expect { GitDeployTimer.clone_repo('NOT_FOUND') }.to raise_error('Error cloning repository NOT_FOUND')
  end

  it 'extracts commits in reverse chronological order' do
    expect(commit(0)).to eq_iso8601_date('2010-04-10T12:05:00+01:00')
    expect(commit(1)).to eq_iso8601_date('2010-04-10T12:00:00+01:00')
    expect(commit(2)).to eq_iso8601_date('2010-04-10T11:00:00+01:00')
    expect(commit(3)).to eq_iso8601_date('2010-04-10T10:00:00+01:00')
  end

  it 'extracts tags in reverse chronological order of referenced commit' do
    expect(tag(0)).to eq('prd-2')
    expect(tag(1)).to eq('sit-3')
    expect(tag(2)).to eq('stg-2')
    expect(tag(3)).to eq('sit-2')
    expect(tag(4)).to eq('prd-1')
    expect(tag(5)).to eq('stg-1')
    expect(tag(6)).to eq('sit-1')
  end

  it 'merges deployment tags with commits' do
    commits = GitDeployTimer.commit_times(@git_repo)
    tags = GitDeployTimer.tag_times(@git_repo)
    merged = GitDeployTimer.merge_commits_and_deploy_tags(commits, tags)

    expect(merged.length).to eq(4)
    expect(merged).to be_in_reverse_order_for('commitTimestamp')
    expect(merged).to be_in_reverse_order_for('sitTimestamp')
    expect(merged).to be_in_reverse_order_for('stgTimestamp')
    expect(merged).to be_in_reverse_order_for('prdTimestamp')
  end

  it 'adds elapsed times between commit and deploy to each environment' do
    fixture = [{ 'commitTimestamp' => DateTime.iso8601('2010-04-10T12:05:00+01:00'),
                 'prdTimestamp' => DateTime.iso8601('2010-06-02T08:00:00+01:00'),
                 'stgTimestamp' => DateTime.iso8601('2010-06-01T09:00:00+01:00') }]

    times = GitDeployTimer.add_elapsed_times(fixture)
    expect(times.length).to eq(1)
    expect(times.first['commitToStgSecs']).to eq(4481700)
    expect(times.first['commitToStg']).to eq('1 month, 3 weeks, 20 hours, 55 minutes')
  end

  it 'does not add times if no deployments have been made' do
    fixture = [{ 'commitTimestamp' => DateTime.iso8601('2010-04-10T12:05:00+01:00') }]

    times = GitDeployTimer.add_elapsed_times(fixture)
    expect(times).to eq(fixture)
  end
end
