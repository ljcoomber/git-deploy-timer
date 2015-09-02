require 'git_deploy_timer/version'
require 'date'
require 'fileutils'

module GitDeployTimer
  COMMIT_TIMESTAMP_KEY = 'commitTimestamp'

  # Clones a report without checking out HEAD. Returns the directory the repo is checked out into
  def self.clone_repo(repository)
    require 'tmpdir'
    repo_dir = Dir.mktmpdir
    `git clone -n #{repository} #{repo_dir}`
    repo_dir
  end

  # Returns commit IDs and times [ { "id" => ..., "commitTimestamp" =>}, { ... } ] in reverse chronological order
  def self.commit_times(local_repo)
    Dir.chdir(local_repo) do
      `git log --tags --pretty="%H %cI"`.each_line.map do |line|
        m = /(?<id>\w*) (?<timestamp>.*)/.match(line)
        { 'id' => m[:id], COMMIT_TIMESTAMP_KEY => DateTime.iso8601(m[:timestamp]) }
      end
    end
  end

  # Returns [ { "id" => ..., "tag" => ..., "tagTimestamp" =>}, { ... } ], reverse order of referenced commit
  def self.tag_times(local_repo)
    Dir.chdir(local_repo) do
      t = `git for-each-ref --sort='-*committerdate' --format '%(*objectname) %(tag) %(taggerdate:iso8601)' refs/tags`
      t.each_line.map do |line|
        m = /(?<id>\w*) (?<tag>\w*-\d*) (?<timestamp>.*)/.match(line)
        { 'id' => m[:id], 'tag' => m[:tag], 'tagTimestamp' => DateTime.parse(m[:timestamp]) } if m
      end.compact
    end
  end
end
