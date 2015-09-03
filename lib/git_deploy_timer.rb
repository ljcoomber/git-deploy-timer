require 'git_deploy_timer/version'
require 'date'
require 'fileutils'
require 'time_difference'

module GitDeployTimer
  ENVIRONMENTS = Array['sit', 'stg', 'prd']
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

  # Commits must be in the reverse chronological order
  def self.merge_commits_and_deploy_tags(commits, tags)
    env_timestamps = {}

    commits.map do |commit|
      tags.select { |t| t['id'] == commit['id'] }.each do |t|
        m = /(?<env>#{ENVIRONMENTS.join('|')})-\d*/.match(t['tag'])
        env_timestamps[m[:env] + 'Timestamp'] = t['tagTimestamp'] if m
      end

      commit.merge(env_timestamps)
    end
  end

  # Add elapsed times to merged commits and tags
  def self.add_elapsed_times(merged_commits_and_tags)
    merged_commits_and_tags.map do |m|
      deploy_times = ENVIRONMENTS.select { |env| m.key?(env + 'Timestamp') }.map do |env|
        env_date = m[env + 'Timestamp']
        dt = TimeDifference.between(m[COMMIT_TIMESTAMP_KEY], env_date)

        Hash["commitTo#{env.capitalize}Secs" => dt.in_seconds,
             "commitTo#{env.capitalize}" => pp_time_difference(dt.in_general)]
      end

      m.merge(deploy_times.reduce(:merge))
    end
  end

  def self.pp_time_difference(td)
    td.select { |_, v| v > 0 }.map { |k, v| "#{v} #{k.to_s.chop}#{'s' if v > 1}" }.join(', ')
  end
end
