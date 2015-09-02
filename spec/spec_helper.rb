require 'git_deploy_timer'

require 'date'
require 'fileutils'
require 'rspec/expectations'
require 'tmpdir'

# rubocop:disable Metrics/MethodLength
def init_git_repo
  tmpdir = Dir.mktmpdir
  Dir.chdir(tmpdir) do
    `git init`

    `echo 1 > mock_codebase`
    `git add mock_codebase`
    `GIT_AUTHOR_DATE="2010-04-10 10:00" GIT_COMMITTER_DATE="2010-04-10 10:00" git commit -m "Feature 1"`
    `GIT_COMMITTER_DATE="2010-04-10 10:10" git tag -a sit-1 -m "SIT deploy complete" HEAD`
    `GIT_COMMITTER_DATE="2010-04-10 10:15" git tag -a stg-1 -m "Stage deploy complete" HEAD`
    `GIT_COMMITTER_DATE="2010-04-10 10:20" git tag -a prd-1 -m "Prod deploy complete" HEAD`

    `echo 2 > mock_codebase`
    `git add mock_codebase`
    `GIT_AUTHOR_DATE="2010-04-10 11:00" GIT_COMMITTER_DATE="2010-04-10 11:00" git commit -m "Feature 2"`
    `GIT_COMMITTER_DATE="2010-04-10 11:10" git tag -a sit-2 -m "SIT deploy complete" HEAD`

    `echo 3 > mock_codebase`
    `git add mock_codebase`
    `GIT_AUTHOR_DATE="2010-04-10 12:00" GIT_COMMITTER_DATE="2010-04-10 12:00" git commit -m "Feature 3"`

    `echo 4 > mock_codebase`
    `git add mock_codebase`
    `GIT_AUTHOR_DATE="2010-04-10 12:05" GIT_COMMITTER_DATE="2010-04-10 12:05" git commit -m "Feature 4"`

    `GIT_COMMITTER_DATE="2010-04-10 12:30" git tag -a sit-3 -m "SIT deploy complete" HEAD`
    `GIT_COMMITTER_DATE="2010-04-14 13:35" git tag -a stg-2 -m "Stage deploy complete" HEAD`
    `GIT_COMMITTER_DATE="2010-06-02 08:00" git tag -a prd-2 -m "Prod deploy complete" HEAD`

    `git tag -a RANDOM_TAG -m "A tag to ensure non-deploy tags are ignored"`
  end

  tmpdir
end
# rubocop:enable Metrics/MethodLength

RSpec::Matchers.define :have_last_commit_message do |message|
  match do |repo|
    message == last_commit_message(repo)
  end

  failure_message do |repo|
    "expected last commit message to be '#{message}' but was '#{last_commit_message(repo)}' in repo #{repo}"
  end

  def last_commit_message(repo)
    Dir.chdir(repo) do
      /\w* (?<last_message>.*)/ =~ `git log -n 1 --pretty=oneline`
      last_message
    end
  end
end

def commit(idx)
  commits = GitDeployTimer.commit_times(@git_repo)
  commits[idx]['commitTimestamp']
end

RSpec::Matchers.define :eq_iso8601_date do |expected|
  match do |actual|
    # TODO: to_s comparison is purely here to stop Ruby segfaulting!
    actual.to_s == DateTime.iso8601(expected).to_s
  end

  failure_message do |actual|
    "expected date to be #{expected} but was #{actual}"
  end
end

def tag(idx)
  tags = GitDeployTimer.tag_times(@git_repo)
  tags[idx]['tag']
end

RSpec::Matchers.define :be_in_reverse_order_for do |key|
  match do |merged|
    vals = extract(merged, key)
    sorted = vals.sort.reverse
    vals == sorted
  end

  failure_message do |merged|
    "expected #{key} to be in reverse order but was not: #{extract(merged, key)}"
  end

  def extract(merged, key)
    merged.map { |m| m[key] }
  end
end
