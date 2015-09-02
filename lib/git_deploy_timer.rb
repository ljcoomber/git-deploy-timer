require 'git_deploy_timer/version'

module GitDeployTimer
  # Clones a report without checking out HEAD. Returns the directory the repo is checked out into
  def self.clone_repo(repository)
    require 'tmpdir'
    repo_dir = Dir.mktmpdir
    `git clone -n #{repository} #{repo_dir}`
    repo_dir
  end
end
