require 'spec_helper'
require 'fileutils'

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
end
